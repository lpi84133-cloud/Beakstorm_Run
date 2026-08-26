import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

/// Section title with an optional eyebrow and a trailing action.
///
/// The short accent rule on the left is the recurring "route line" motif that
/// ties list sections to the road illustrations.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: eyebrow == null ? 22 : 36,
          margin: const EdgeInsets.only(right: Insets.md),
          decoration: BoxDecoration(
            gradient: colors.accentSweep,
            borderRadius: Corners.pillRadius,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!.toUpperCase(),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              Text(title, style: context.text.headlineSmall),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: colors.accent,
              textStyle: context.text.labelMedium,
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
