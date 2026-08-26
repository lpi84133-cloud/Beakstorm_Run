import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// A track that always fills from left to right.
///
/// The widget is intentionally dumb: it renders exactly the [value] it is given
/// and never animates ahead of it. Smoothing belongs to whoever owns the value,
/// so the bar can never show progress that has not actually happened.
class BeakProgressBar extends StatelessWidget {
  const BeakProgressBar({
    super.key,
    required this.value,
    this.thickness = 12,
    this.trackColor,
    this.showGlow = true,
  });

  final double value;
  final double thickness;
  final Color? trackColor;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clamped = value.clamp(0.0, 1.0);

    return Semantics(
      value: '${(clamped * 100).round()}%',
      child: Container(
        height: thickness,
        decoration: BoxDecoration(
          color: trackColor ?? colors.borderStrong,
          borderRadius: Corners.pillRadius,
        ),
        child: ClipRRect(
          borderRadius: Corners.pillRadius,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: clamped == 0 ? null : clamped,
              child: clamped == 0
                  ? const SizedBox.shrink()
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: Corners.pillRadius,
                        gradient: const LinearGradient(
                          colors: [Palette.yellow600, Palette.yellow300],
                        ),
                        boxShadow: showGlow
                            ? [
                                BoxShadow(
                                  color: Palette.yellow500.withValues(
                                    alpha: 0.55,
                                  ),
                                  blurRadius: 14,
                                  spreadRadius: -2,
                                ),
                              ]
                            : null,
                      ),
                      child: const SizedBox.expand(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
