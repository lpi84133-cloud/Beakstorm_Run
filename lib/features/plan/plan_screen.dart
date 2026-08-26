import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/beak_button.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/beak_pill.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tempo_strip.dart';
import '../../data/plan_repository.dart';
import '../../domain/auto_route.dart';
import '../../domain/training_plan.dart';

/// The multi-week schedule: which session is next, what is already behind, and
/// how the weeks build on each other.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Training plan')),
      body: PageBackdrop(
        image: AppImages.nightRoute,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Layout.maxContentWidth,
              ),
              child: plan.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, _) => const _PlanIntro(),
                data: (value) =>
                    value == null ? const _PlanIntro() : _PlanBody(plan: value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when no plan is running: explains what a plan is for before asking for
/// any settings.
class _PlanIntro extends StatelessWidget {
  const _PlanIntro();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Insets.xl, Insets.lg, Insets.xl, Insets.xxl),
      children: [
        BeakCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.xxl,
          ),
          child: EmptyState(
            title: 'No plan running',
            message:
                'A plan turns single runs into a few weeks that build on each '
                'other. Sessions get a little longer week by week, and the last '
                'week eases off.',
            actionLabel: 'Build a plan',
            onAction: () => openPlanSetup(context),
          ),
        ),
        const SizedBox(height: Insets.xxl),
        const _PlanFacts(),
      ],
    );
  }
}

class _PlanFacts extends StatelessWidget {
  const _PlanFacts();

  @override
  Widget build(BuildContext context) {
    const facts = [
      (
        Icons.calendar_month_rounded,
        'You pick the shape',
        'Length, sessions per week and how hard they should feel.',
      ),
      (
        Icons.auto_awesome_rounded,
        'Sessions are built for you',
        'Each one is a full route of stages, ready for the timer.',
      ),
      (
        Icons.check_circle_outline_rounded,
        'Progress is yours alone',
        'Finished sessions are ticked off on this device. Nothing is sent anywhere.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'How it works', eyebrow: 'Plans'),
        const SizedBox(height: Insets.lg),
        for (final (icon, title, body) in facts) ...[
          BeakCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: context.colors.accent, size: 22),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      const SizedBox(height: Insets.xs),
                      Text(
                        body,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),
        ],
      ],
    );
  }
}

class _PlanBody extends ConsumerWidget {
  const _PlanBody({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = plan.nextSession;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Insets.xl, Insets.lg, Insets.xl, Insets.xxl),
      children: [
        _PlanHeader(plan: plan),
        const SizedBox(height: Insets.xxl),
        if (next != null) ...[
          const SectionHeader(title: 'Next session', eyebrow: 'Up now'),
          const SizedBox(height: Insets.lg),
          _SessionCard(session: next, done: false, highlighted: true),
          const SizedBox(height: Insets.xxl),
        ],
        for (var week = 1; week <= plan.weeks; week++) ...[
          _WeekBlock(plan: plan, week: week),
          const SizedBox(height: Insets.xl),
        ],
        const SizedBox(height: Insets.md),
        BeakButton(
          label: plan.isComplete ? 'Start a new plan' : 'Replace this plan',
          icon: Icons.refresh_rounded,
          variant: BeakButtonVariant.secondary,
          onPressed: () => openPlanSetup(context),
        ),
        const SizedBox(height: Insets.md),
        TextButton(
          onPressed: () => unawaited(_confirmStop(context, ref)),
          child: const Text('Stop following the plan'),
        ),
      ],
    );
  }

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop the plan?'),
        content: const Text(
          'Your finished sessions stay in your activity history. The schedule '
          'itself will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (stop ?? false) {
      await ref.read(planRepositoryProvider).cancel();
    }
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
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
                      plan.isComplete
                          ? 'PLAN COMPLETE'
                          : 'WEEK ${plan.currentWeek} OF ${plan.weeks}',
                      style: context.text.labelSmall?.copyWith(
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(
                      '${plan.doneCount} of ${plan.totalSessions} sessions done',
                      style: context.text.titleMedium,
                    ),
                  ],
                ),
              ),
              BeakPill(
                label: plan.effort.label,
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: Insets.lg),
          ClipRRect(
            borderRadius: Corners.pillRadius,
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 8,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: Insets.md),
          Text(
            plan.isComplete
                ? 'Every session is behind you. Build another plan to keep going.'
                : 'This week: ${plan.sessionsIn(plan.currentWeek).length} sessions, '
                      '${plan.weeklyLoad.minutesOnly} minutes in total.',
            style: context.text.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({required this.plan, required this.week});

  final TrainingPlan plan;
  final int week;

  @override
  Widget build(BuildContext context) {
    final sessions = plan.sessionsIn(week);
    final done = plan.doneIn(week);
    final current = week == plan.currentWeek && !plan.isComplete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Week $week',
          eyebrow: current ? 'This week' : '$done of ${sessions.length} done',
        ),
        const SizedBox(height: Insets.lg),
        for (final session in sessions) ...[
          _SessionCard(
            session: session,
            done: plan.isDone(session),
            highlighted: false,
          ),
          const SizedBox(height: Insets.md),
        ],
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.done,
    required this.highlighted,
  });

  final PlannedSession session;
  final bool done;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final workout = session.toWorkout(DateTime.now());

    return BeakCard(
      borderColor: highlighted ? colors.accent.withValues(alpha: 0.55) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: done ? colors.easyRun : colors.textMuted,
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.focus.label} · session ${session.position}',
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.focus.description,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              BeakPill(label: workout.totalDuration.compact),
            ],
          ),
          const SizedBox(height: Insets.md),
          TempoStrip(stages: workout.runStages),
          if (highlighted) ...[
            const SizedBox(height: Insets.lg),
            BeakButton(
              label: 'Start session',
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.push(AppRoute.runPlanned(session.key)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Asks for the four things a plan needs, with sensible values already chosen.
Future<void> openPlanSetup(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // Push through the root navigator so the sheet sits above the floating
    // dock rather than inside the shell layer where the dock would cover it.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PlanSetupSheet(),
  );
}

class _PlanSetupSheet extends ConsumerStatefulWidget {
  const _PlanSetupSheet();

  @override
  ConsumerState<_PlanSetupSheet> createState() => _PlanSetupSheetState();
}

class _PlanSetupSheetState extends ConsumerState<_PlanSetupSheet> {
  int _weeks = 4;
  int _perWeek = 3;
  int _minutes = 30;
  RouteEffort _effort = RouteEffort.moderate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = buildTrainingPlan(
      weeks: _weeks,
      sessionsPerWeek: _perWeek,
      effort: _effort,
      baseMinutes: _minutes,
      startedAt: DateTime.now(),
    );

    final total = preview.sessions.fold(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.lg,
        Insets.xl,
        MediaQuery.viewInsetsOf(context).bottom + Insets.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: Corners.pillRadius,
                ),
              ),
            ),
            const SizedBox(height: Insets.xl),
            Text('Build a plan', style: context.text.titleLarge),
            const SizedBox(height: Insets.xs),
            Text(
              'Everything here can be replaced later, and every session stays '
              'editable while you run it.',
              style: context.text.bodySmall?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: Insets.xxl),
            _Choice<int>(
              title: 'Length',
              value: _weeks,
              options: const [2, 4, 6, 8],
              labelFor: (weeks) => '$weeks weeks',
              onChanged: (value) => setState(() => _weeks = value),
            ),
            const SizedBox(height: Insets.xl),
            _Choice<int>(
              title: 'Sessions per week',
              value: _perWeek,
              options: const [2, 3, 4, 5],
              labelFor: (count) => '$count',
              onChanged: (value) => setState(() => _perWeek = value),
            ),
            const SizedBox(height: Insets.xl),
            _Choice<RouteEffort>(
              title: 'Effort',
              value: _effort,
              options: RouteEffort.values,
              labelFor: (effort) => effort.label,
              onChanged: (value) => setState(() => _effort = value),
            ),
            const SizedBox(height: Insets.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Starting session length',
                    style: context.text.titleSmall,
                  ),
                ),
                Text(
                  '$_minutes min',
                  style: context.text.titleSmall?.copyWith(color: colors.accent),
                ),
              ],
            ),
            Slider.adaptive(
              value: _minutes.toDouble(),
              min: 15,
              max: 75,
              divisions: 12,
              onChanged: (value) => setState(() => _minutes = value.round()),
            ),
            const SizedBox(height: Insets.md),
            Text(
              '${preview.totalSessions} sessions, ${total.minutesOnly} minutes of '
              'running in total. Later weeks are longer than the first.',
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: Insets.xl),
            BeakButton(
              label: 'Start the plan',
              icon: Icons.flag_rounded,
              onPressed: _start,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    unawaited(HapticFeedback.mediumImpact());

    await ref
        .read(planRepositoryProvider)
        .start(
          weeks: _weeks,
          sessionsPerWeek: _perWeek,
          effort: _effort,
          baseMinutes: _minutes,
        );

    if (mounted) Navigator.of(context).pop();
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.value,
    required this.options,
    required this.labelFor,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<T> options;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleSmall),
        const SizedBox(height: Insets.md),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            for (final option in options)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(option);
                },
                child: BeakPill(
                  label: labelFor(option),
                  filled: option == value,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
