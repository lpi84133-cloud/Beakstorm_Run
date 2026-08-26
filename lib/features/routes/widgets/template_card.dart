import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/marker_style.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/beak_card.dart';
import '../../../core/widgets/tempo_strip.dart';
import '../../../domain/workout_templates.dart';

/// One of the built-in structures, offered as a starting point rather than a
/// prescription: opening it drops an editable copy into the builder.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.width = 268,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final peak = template.stages
        .map((stage) => stage.tempo)
        .reduce((a, b) => a.intensity >= b.intensity ? a : b);

    return SizedBox(
      width: width,
      child: BeakCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: peak.color(colors).withValues(alpha: 0.16),
                    borderRadius: Corners.cardRadius,
                  ),
                  child: Icon(peak.icon, size: 18, color: peak.color(colors)),
                ),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Insets.md),
            Text(
              template.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: Insets.lg),
            TempoStrip(stages: template.stages, height: 34, showMarkers: false),
            const SizedBox(height: Insets.md),
            Text(
              '${template.totalDuration.compact}  ·  ${template.stageCount} stages',
              style: context.text.labelMedium?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
