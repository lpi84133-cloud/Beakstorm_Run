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
  static const double _ceiling = 0.35;
  static const Duration _holdAfterReady = Duration(milliseconds: 260);

  late double _displayed;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  TrailTarget? _destination;
  bool _started = false;
  bool _leaving = false;
  bool _whiteReady = false;
  ProviderSubscription<StartupProgress>? _whiteSub;

  @override
  void initState() {
    super.initState();
    _displayed = widget.initialProgress.clamp(0.0, _ceiling);
    _ticker = createTicker(_onTick)..start();
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _whiteSub?.close();
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      unawaited(_resolveTrail());
    }
  }

  /// While the verdict can still be no-wifi the bar may not pass 35%.
  /// 100% is reserved for a known non-offline destination.
  double get _target {
    final dest = _destination;
    if (dest == null || dest is OfflineTrail) {
      return _ceiling;
    }
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
    final speed = rising ? 1.45 : 0.40;
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
    if (target is NativeTrail) _watchWhiteStartup();
    setState(() => _destination = target);
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
      unawaited(_openAfterHold(dest));
      return;
    }
    if (_displayed < 0.995) return;
    if (dest is NativeTrail && !_whiteReady) return;
    _leaving = true;
    _ticker.stop();
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

    if (destination is NativeTrail) {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const BeakstormRunApp(skipStartupGate: true),
        ),
      );
      return;
    }

    if (destination is OfflineTrail) {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StillAirPage(
            probe: coordinator.probe,
            retryBuilder: (_) => DashBoot(
              coordinator: coordinator,
              initialProgress: _ceiling,
            ),
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

      if (coordinator.vault.shouldShowPushInvite &&
          await coordinator.notifications.canOfferPermission()) {
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => FlockInvite(
              vault: coordinator.vault,
              notifications: coordinator.notifications,
              nextBuilder: portalBuilder,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        await Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute<void>(builder: portalBuilder));
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
