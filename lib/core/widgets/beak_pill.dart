import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Compact tag used for tempo names, durations and template labels.
class BeakPill extends StatelessWidget {
  const BeakPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = color ?? colors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.xs + 2,
      ),
      decoration: BoxDecoration(
        color: filled ? tint : tint.withValues(alpha: 0.14),
        borderRadius: Corners.pillRadius,
        border: Border.all(color: tint.withValues(alpha: filled ? 1 : 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: filled ? colors.onAccent : tint,
            ),
            const SizedBox(width: Insets.xs + 2),
          ],
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: filled ? colors.onAccent : tint,
            ),
          ),
        ],
      ),
    );
  }
}
