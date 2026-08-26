import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// The single surface primitive of the app: a soft rounded panel with a hairline
/// border and a low, wide shadow that echoes the moulded look of the artwork.
class BeakCard extends StatelessWidget {
  const BeakCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.borderRadius = Corners.cardRadius,
    this.color,
    this.borderColor,
    this.gradient,
    this.elevated = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final decorated = AnimatedContainer(
      duration: Motion.fast,
      curve: Motion.enter,
      padding: padding,
      decoration: BoxDecoration(
        // Panels carry a faint top-down sheen unless the caller supplies its
        // own gradient, so a screen full of cards keeps some depth.
        gradient: gradient ?? colors.surfaceSheen(base: color),
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? colors.border),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: colors.accentSoft,
        highlightColor: colors.accentSoft,
        child: decorated,
      ),
    );
  }
}
