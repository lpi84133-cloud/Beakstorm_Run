import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_dimens.dart';
import 'startup_controller.dart';
import 'startup_screen.dart';

/// Shows the launch screen until initialisation is genuinely finished, then
/// hands over to [builder].
///
/// The displayed value is eased toward the controller's real value with a
/// bounded speed. Easing can only ever lag behind the truth, never lead it, so
/// the bar stays honest while still moving smoothly.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate>
    with SingleTickerProviderStateMixin {
  /// How quickly the bar closes the remaining gap, per second.
  static const _catchUpRate = 5.5;

  /// Floor on movement so a large gap never crawls, expressed per second.
  static const _minimumRate = 0.10;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _displayed = 0;
  bool _handedOver = false;

  /// Each label paired with the progress value it was announced at. The screen
  /// shows the label the bar has actually reached, so the caption never gets
  /// ahead of the fill when the work finishes faster than the animation.
  final List<(double, String)> _labels = [(0, 'Getting ready')];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (delta <= 0) return;

    final progress = ref.read(startupControllerProvider);
    final step = math.min(delta, 0.05);
    final gap = progress.value - _displayed;

    final next = gap <= 0.0015
        ? progress.value
        : math.min(
            progress.value,
            _displayed + math.max(gap * _catchUpRate * step, _minimumRate * step),
          );

    if (next != _displayed) {
      setState(() => _displayed = next);
    }

    if (progress.isReady && _displayed >= 0.9995 && !_handedOver) {
      _ticker.stop();
      setState(() => _handedOver = true);
    }
  }

  String get _visibleLabel {
    var label = _labels.first.$2;
    for (final entry in _labels) {
      if (entry.$1 > _displayed) break;
      label = entry.$2;
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(startupControllerProvider);
    if (_labels.last.$2 != progress.label) {
      _labels.add((progress.value, progress.label));
    }

    return AnimatedSwitcher(
      duration: Motion.slow,
      switchInCurve: Motion.enter,
      switchOutCurve: Motion.exit,
      child: _handedOver
          ? KeyedSubtree(
              key: const ValueKey('app'),
              child: widget.builder(context),
            )
          : StartupScreen(
              key: const ValueKey('startup'),
              progress: _displayed,
              label: _visibleLabel,
            ),
    );
  }
}
