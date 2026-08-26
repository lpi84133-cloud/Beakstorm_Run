import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/beak_button.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/session_repository.dart';
import '../../data/workout_repository.dart';
import '../../domain/statistics.dart';
import '../../domain/workout.dart';
import '../../domain/workout_templates.dart';
import '../plan/widgets/plan_card.dart';
import 'widgets/recovery_card.dart';
import '../routes/widgets/template_card.dart';
import '../routes/widgets/workout_card.dart';

/// The opening screen: what today looks like, the route most likely to be run
/// next, and the built-in structures to start from.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(savedWorkoutsProvider);
    final stats = ref.watch(statisticsProvider(StatsRange.week));

    return Scaffold(
      body: PageBackdrop(
        image: AppImages.nightRoute,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Layout.maxContentWidth,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  Insets.xl,
                  Insets.lg,
                  Insets.xl,
                  dockClearance(context),
                ),
                children: [
                  const _Greeting(),
                  const SizedBox(height: Insets.lg),
                  const RecoveryCard(),
                  const SizedBox(height: Insets.xxl),
                  const PlanCard(),
                  const SizedBox(height: Insets.xxl),
                  _NextRun(workouts: workouts),
                  const SizedBox(height: Insets.xxl),
                  _WeekSummary(stats: stats),
                  const SizedBox(height: Insets.xxl),
                  SectionHeader(
                    title: 'Start from a structure',
                    eyebrow: 'Built in',
                    actionLabel: 'All routes',
                    onAction: () => context.go(AppRoute.routes),
                  ),
                  const SizedBox(height: Insets.lg),
                  const _TemplateRail(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();

    final salutation = switch (now.hour) {
      < 12 => 'Good morning',
      < 18 => 'Good afternoon',
      _ => 'Good evening',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, d MMMM').format(now).toUpperCase(),
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: Insets.xs),
        Text(salutation, style: context.text.displaySmall),
      ],
    );
  }
}

/// The hero card. It answers one question: what am I running today?
class _NextRun extends StatelessWidget {
  const _NextRun({required this.workouts});

  final AsyncValue<List<Workout>> workouts;

  @override
  Widget build(BuildContext context) {
    return workouts.when(
      loading: () => const _NextRunSkeleton(),
      error: (error, _) => BeakCard(
        child: Text(
          'Your routes could not be opened. Restart the app to try again.',
          style: context.text.bodyMedium,
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return BeakCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.lg,
              vertical: Insets.xxl,
            ),
            child: EmptyState(
              title: 'No routes yet',
              message:
                  'Build a sequence of walking and running stages, then follow '
                  'it with the timer. Everything stays on this device.',
              actionLabel: 'Build a route',
              onAction: () => context.push(AppRoute.builder),
            ),
          );
        }

        final next = list.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Up next', eyebrow: 'Last edited'),
            const SizedBox(height: Insets.lg),
            WorkoutCard(
              workout: next,
              onTap: () => context.push(AppRoute.edit(next.id)),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: Insets.md),
            Row(
              children: [
                Expanded(
                  child: BeakButton(
                    label: 'Start run',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.push(AppRoute.run(next.id)),
                  ),
                ),
                const SizedBox(width: Insets.md),
                BeakButton(
                  label: 'New',
                  icon: Icons.add_rounded,
                  variant: BeakButtonVariant.secondary,
                  expand: false,
                  onPressed: () => context.push(AppRoute.builder),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Placeholder with the same footprint as the loaded card, so the layout does
/// not jump once the database answers.
class _NextRunSkeleton extends StatelessWidget {
  const _NextRunSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 160,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: Corners.pillRadius,
            ),
          ),
          const SizedBox(height: Insets.md),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: Corners.cardRadius,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({required this.stats});

  final AsyncValue<WorkoutStats> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = stats.value ?? WorkoutStats.empty(StatsRange.week);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'This week',
          eyebrow: 'Your activity',
          actionLabel: 'Details',
          onAction: () => context.go(AppRoute.activity),
        ),
        const SizedBox(height: Insets.lg),
        BeakCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatTile(
                value: '${value.sessionCount}',
                caption: 'Runs',
                accent: value.sessionCount > 0,
              ),
              Container(width: 1, height: 34, color: colors.border),
              StatTile(
                value: value.totalTime.minutesOnly,
                unit: 'min',
                caption: 'Time moving',
              ),
              Container(width: 1, height: 34, color: colors.border),
              StatTile(
                value: '${value.streakDays}',
                unit: value.streakDays == 1 ? 'day' : 'days',
                caption: 'Streak',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateRail extends StatelessWidget {
  const _TemplateRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: workoutTemplates.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.md),
        itemBuilder: (context, index) {
          final template = workoutTemplates[index];
          return TemplateCard(
            template: template,
            onTap: () => context.push(AppRoute.fromTemplate(template.key)),
          );
        },
      ),
    );
  }
}
