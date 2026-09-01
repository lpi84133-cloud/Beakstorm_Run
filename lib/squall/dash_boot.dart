import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app.dart';
import '../core/theme/app_theme.dart';
import '../features/startup/startup_controller.dart';
import '../features/startup/startup_screen.dart';
import 'core/trail_models.dart';
import 'pages/flock_invite.dart';
import 'pages/still_air.dart';
import 'pages/storm_portal.dart';
import 'squall_coordinator.dart';

class DashBoot extends ConsumerStatefulWidget {
  const DashBoot({
    super.key,
    required this.coordinator,
    this.initialProgress = 0,
  });

  final SquallCoordinator coordinator;

  /// Retry after no-wifi continues from the 35% ceiling instead of 0.
  final double initialProgress;

  @override
  ConsumerState<DashBoot> createState() => _DashBootState();
}

class _DashBootState extends ConsumerState<DashBoot>
    with SingleTickerProviderStateMixin {
  /// Unknown-verdict ceiling. The bar eases toward this but never reaches
  /// 100% until Native/Portal is decided.
  static const double _softCap = 0.90;

  /// Speed changes at 35%: fast up to it, then a slow endless trickle.
  static const double _phaseBoundary = 0.35;
  static const Duration _holdAfterReady = Duration(milliseconds: 260);

  late double _displayed;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  TrailTarget? _destination;
  bool _started = false;
  bool _leaving = false;
  bool _whiteReady = false;
  ProviderSubscription<StartupProgress>? _whiteSub;
  Timer? _whiteDeadline;
  Timer? _leaveDeadline;
  Timer? _lastResort;

  @override
  void initState() {
    super.initState();
    _displayed = widget.initialProgress.clamp(0.0, _softCap);
    _ticker = createTicker(_onTick)..start();
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Same safety net as HenheavenDash WarmupGate: splash must never stay
    // on screen forever if a leave await wedges.
    _lastResort = Timer(const Duration(seconds: 42), () {
      if (!mounted || _leaving) return;
      _destination ??= const NativeTrail();
      _whiteReady = true;
      _displayed = 1;
      _tryLeave();
    });
  }

  @override
  void dispose() {
    _whiteSub?.close();
    _whiteDeadline?.cancel();
    _leaveDeadline?.cancel();
    _lastResort?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      // Warm the white part in parallel so Native never sits at 100% waiting.
      _watchWhiteStartup();
      unawaited(_resolveTrail());
    }
  }

  /// While the verdict can still be no-wifi the bar may not pass [_softCap].
  /// 100% is reserved for a known non-offline destination.
  double get _target {
    final dest = _destination;
    if (dest == null) return _softCap;
    if (dest is OfflineTrail) return _displayed;
    return 1.0;
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1000000).clamp(
      0.0,
      0.05,
    );
    _lastElapsed = elapsed;
    if (dt <= 0) return;

    final dest = _destination;
    if (dest is OfflineTrail) {
      _tryLeave();
      return;
    }

    final target = _target;
    final rising = dest is NativeTrail || dest is PortalTrail;
    final double speed;
    if (rising) {
      speed = 1.45;
    } else if (_displayed < _phaseBoundary) {
      speed = 0.40;
    } else {
      // Keep ticking so the bar never looks frozen during ATT / AF / config.
      // Asymptotic: slower as we near the cap, but always a little motion.
      final remaining = math.max(0.0, target - _displayed);
      speed = math.max(0.008, remaining * 0.11);
    }
    final next = math.min(target, _displayed + speed * dt);

    if ((next - _displayed).abs() > 0.0005) {
      setState(() => _displayed = next);
    } else if (_displayed != target && target <= _displayed) {
      _displayed = target;
    }

    if (rising && _displayed >= 0.995) {
      if (_displayed != 1) setState(() => _displayed = 1);
      _tryLeave();
    }
  }

  Future<void> _resolveTrail() async {
    TrailTarget target;
    try {
      target = await widget.coordinator.decide(onProgress: (_) {});
    } catch (_) {
      target = widget.coordinator.vault.route == TrailKind.first
          ? const OfflineTrail(returnToNative: false)
          : const NativeTrail();
    }
    if (!mounted) return;
    // Prepare notify BEFORE the bar hits 100%. HenheavenDash already finished
    // push.boot() during the pipeline; we only wait until messaging exists.
    if (target is PortalTrail &&
        !widget.coordinator.notifications.isReady) {
      try {
        await widget.coordinator.notifications
            .boot()
            .timeout(const Duration(seconds: 3), onTimeout: () {});
      } catch (_) {}
    }
    if (!mounted) return;
    if (target is NativeTrail) {
      _whiteDeadline?.cancel();
      _whiteDeadline = Timer(const Duration(seconds: 9), () {
        if (!mounted || _leaving) return;
        _whiteReady = true;
        _tryLeave();
      });
    }
    setState(() => _destination = target);
    if (target is NativeTrail || target is PortalTrail) {
      _leaveDeadline?.cancel();
      _leaveDeadline = Timer(const Duration(seconds: 2), () {
        if (!mounted || _leaving) return;
        _whiteReady = true;
        if (_displayed < 1) setState(() => _displayed = 1);
        _tryLeave();
      });
    }
    _tryLeave();
  }

  void _watchWhiteStartup() {
    if (_whiteSub != null) return;
    _whiteSub = ref.listenManual<StartupProgress>(startupControllerProvider, (
      _,
      next,
    ) {
      _whiteReady = next.isReady;
      if (next.isReady) _tryLeave();
    }, fireImmediately: true);
  }

  void _tryLeave() {
    if (_leaving) return;
    final dest = _destination;
    if (dest == null) return;
    if (dest is OfflineTrail) {
      _leaving = true;
      _ticker.stop();
      _leaveDeadline?.cancel();
      _lastResort?.cancel();
      unawaited(_openAfterHold(dest));
      return;
    }
    if (_displayed < 0.995) return;
    if (dest is NativeTrail && !_whiteReady) return;
    _leaving = true;
    _ticker.stop();
    _leaveDeadline?.cancel();
    _lastResort?.cancel();
    unawaited(_openAfterHold(dest));
  }

  Future<void> _openAfterHold(TrailTarget destination) async {
    if (destination is! OfflineTrail) {
      await Future<void>.delayed(_holdAfterReady);
    }
    if (!mounted) return;
    await _openDestination(destination);
  }

  Future<void> _openDestination(TrailTarget destination) async {
    final coordinator = widget.coordinator;
    if (!mounted) return;

    // Same leave as HenheavenDash WarmupGate / EggRunner BootScreen:
    // pushReplacement on the live loader route. Do not await boot() here —
    // that is what parked the bar at 100%. Notify is prepared in _resolveTrail.
    void replace(Widget page) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => page),
      );
    }

    if (destination is NativeTrail) {
      replace(const BeakstormRunApp(skipStartupGate: true));
      return;
    }

    if (destination is OfflineTrail) {
      replace(
        StillAirPage(
          probe: coordinator.probe,
          retryBuilder: (_) => DashBoot(
            coordinator: coordinator,
            initialProgress: _phaseBoundary,
          ),
        ),
      );
      return;
    }

    if (destination is PortalTrail) {
      Widget portalBuilder(BuildContext _) => StormPortal(
        url: destination.url,
        coldLaunch: destination.coldLaunch,
        vault: coordinator.vault,
        probe: coordinator.probe,
        notifications: coordinator.notifications,
        agent: coordinator.agent,
      );

      // Killed-app notification tap: open the WebView immediately.
      // FlockInvite is only for a normal first portal session.
      if (destination.coldLaunch) {
        replace(portalBuilder(context));
        return;
      }

      if (!coordinator.notifications.isReady) {
        try {
          await coordinator.notifications
              .boot()
              .timeout(const Duration(seconds: 3), onTimeout: () {});
        } catch (_) {}
      }
      if (!mounted) return;
      if (coordinator.vault.shouldShowPushInvite &&
          await coordinator.notifications.canOfferPermission()) {
        replace(
          FlockInvite(
            vault: coordinator.vault,
            notifications: coordinator.notifications,
            nextBuilder: portalBuilder,
          ),
        );
      } else {
        replace(portalBuilder(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark(),
      child: StartupScreen(progress: _displayed, label: 'Loading'),
    );
  }
}
