import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/beak_button.dart';
import '../../../core/widgets/beak_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/plan_repository.dart';
import '../../../domain/training_plan.dart';
import '../plan_screen.dart';

/// The plan as it appears on the home screen: one session to run, or an
/// invitation to build a schedule.
class PlanCard extends ConsumerWidget {
  const PlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(activePlanProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: plan == null ? 'Train with a plan' : 'Your plan',
          eyebrow: plan == null
              ? 'A few weeks at a time'
              : 'Week ${plan.currentWeek} of ${plan.weeks}',
          actionLabel: plan == null ? null : 'Open',
          onAction: plan == null ? null : () => context.push(AppRoute.plan),
        ),
        const SizedBox(height: Insets.lg),
        if (plan == null) const _NoPlan() else _PlanProgress(plan: plan),
      ],
    );
  }
}

class _NoPlan extends StatelessWidget {
  const _NoPlan();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Single runs are easy to skip. A plan lays out a few weeks of '
            'sessions that get a little longer as you go.',
            style: context.text.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: Insets.lg),
          BeakButton(
            label: 'Build a plan',
            icon: Icons.calendar_month_rounded,
            variant: BeakButtonVariant.secondary,
            onPressed: () => openPlanSetup(context),
          ),
        ],
      ),
    );
  }
}

class _PlanProgress extends StatelessWidget {
  const _PlanProgress({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final next = plan.nextSession;

    return BeakCard(
      onTap: () => context.push(AppRoute.plan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  next == null
                      ? 'Plan complete'
                      : '${next.focus.label} · ${next.duration.compact}',
                  style: context.text.titleMedium,
                ),
              ),
              Text(
                '${plan.doneCount}/${plan.totalSessions}',
                style: context.text.labelMedium?.copyWith(color: colors.accent),
              ),
            ],
          ),
          const SizedBox(height: Insets.xs),
          Text(
            next?.focus.description ??
                'Every session is behind you. Build another plan to keep the '
                    'rhythm going.',
            style: context.text.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Insets.md),
          ClipRRect(
            borderRadius: Corners.pillRadius,
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 6,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: Insets.lg),
          if (next == null)
            BeakButton(
              label: 'Build a new plan',
              icon: Icons.refresh_rounded,
              variant: BeakButtonVariant.secondary,
              onPressed: () => openPlanSetup(context),
            )
          else
            BeakButton(
              label: 'Start today\'s session',
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.push(AppRoute.runPlanned(next.key)),
            ),
        ],
      ),
    );
  }
}
