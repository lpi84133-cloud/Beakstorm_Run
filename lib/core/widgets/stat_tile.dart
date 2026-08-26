import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// A single figure with its caption, shared by home, summary and statistics so
/// numbers always align on the same baseline across the app.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.caption,
    this.unit,
    this.accent = false,
    this.alignment = CrossAxisAlignment.start,
  });

  final String value;
  final String caption;
  final String? unit;
  final bool accent;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: context.text.headlineMedium?.copyWith(
                color: accent ? colors.accent : colors.textPrimary,
                fontFeatures: kTabularFigures,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Text(
                unit!,
                style: context.text.labelMedium?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: context.text.bodySmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
