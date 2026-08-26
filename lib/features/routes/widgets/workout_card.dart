import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/beak_card.dart';
import '../../../core/widgets/tempo_strip.dart';
import '../../../domain/workout.dart';
import '../../../domain/workout_templates.dart';

/// A saved route as it appears in lists: name, shape and the two numbers that
/// decide whether it fits the time available.
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.trailing,
  });

  final Workout workout;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final template = templateByKey(workout.templateKey);

    return BeakCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        workout.totalDuration.compact,
                        '${workout.stageCount} stages',
                        if (template != null) 'from ${template.name}',
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: Insets.lg),
          TempoStrip(stages: workout.runStages),
        ],
      ),
    );
  }
}
