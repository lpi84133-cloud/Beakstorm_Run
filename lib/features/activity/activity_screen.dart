import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_shell.dart';
import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/marker_style.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/session_repository.dart';
import '../../domain/milestones.dart';
import '../../domain/session.dart';
import '../../domain/statistics.dart';
import '../../domain/tempo.dart';

/// History and statistics, both computed from the runs stored on this device.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  StatsRange _range = StatsRange.week;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(sessionHistoryProvider);
    final stats = ref.watch(statisticsProvider(_range));

    return Scaffold(
      body: PageBackdrop(
        image: AppImages.track,
        height: 260,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Layout.maxContentWidth,
              ),
              child: history.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: Insets.page,
                    child: Text(
                      'Your history could not be opened.\n$error',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium,
                    ),
                  ),
                ),
                data: (sessions) => sessions.isEmpty
                    ? _NoHistory()
                    : ListView(
                        padding: EdgeInsets.fromLTRB(
                          Insets.xl,
                          Insets.lg,
                          Insets.xl,
                          dockClearance(context),
                        ),
                        children: [
                          const SectionHeader(
                            title: 'Activity',
                            eyebrow: 'Stored on this device',
                          ),
                          const SizedBox(height: Insets.lg),
                          _RangePicker(
                            value: _range,
                            onChanged: (range) =>
                                setState(() => _range = range),
                          ),
                          const SizedBox(height: Insets.lg),
                          _Summary(
                            stats:
                                stats.value ?? WorkoutStats.empty(_range),
                          ),
                          const SizedBox(height: Insets.lg),
                          _ActivityChart(
                            stats:
                                stats.value ?? WorkoutStats.empty(_range),
                          ),
                          const SizedBox(height: Insets.lg),
                          _TempoBreakdown(
                            stats:
                                stats.value ?? WorkoutStats.empty(_range),
                          ),
                          if ((stats.value ?? WorkoutStats.empty(_range))
                                  .averageEffort !=
                              null) ...[
                            const SizedBox(height: Insets.lg),
                            _EffortSummary(
                              stats: stats.value ?? WorkoutStats.empty(_range),
                            ),
                          ],
                          const SizedBox(height: Insets.xxl),
                          const SectionHeader(
                            title: 'Personal bests',
                            eyebrow: 'All time',
                          ),
                          const SizedBox(height: Insets.lg),
                          _MilestonesCard(sessions: sessions),
                          const SizedBox(height: Insets.xxl),
                          const SectionHeader(
                            title: 'Recent runs',
                            eyebrow: 'Newest first',
                          ),
                          const SizedBox(height: Insets.lg),
                          for (final session in sessions.take(20))
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: Insets.md,
                              ),
                              child: _SessionCard(session: session),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.value, required this.onChanged});

  final StatsRange value;
  final ValueChanged<StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(Insets.xs),
      decoration: BoxDecoration(
        color: colors.canvasElevated,
        borderRadius: Corners.pillRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          for (final range in StatsRange.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(range),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  curve: Motion.enter,
                  padding: const EdgeInsets.symmetric(vertical: Insets.sm + 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: range == value ? colors.accent : Colors.transparent,
                    borderRadius: Corners.pillRadius,
                  ),
                  child: Text(
                    range.label,
                    style: context.text.labelMedium?.copyWith(
                      color: range == value
                          ? colors.onAccent
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats});

  final WorkoutStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatTile(
            value: '${stats.sessionCount}',
            caption: 'Runs',
            accent: stats.sessionCount > 0,
          ),
          Container(width: 1, height: 34, color: colors.border),
          StatTile(
            value: stats.totalTime.minutesOnly,
            unit: 'min',
            caption: 'Time moving',
          ),
          Container(width: 1, height: 34, color: colors.border),
          StatTile(
            value: stats.averageTime.minutesOnly,
            unit: 'min',
            caption: 'Average run',
          ),
        ],
      ),
    );
  }
}

/// Volume per day or month. Drawn with plain boxes rather than a chart library
/// so it inherits the same corners, colours and motion as everything else.
class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.stats});

  final WorkoutStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final peak = stats.busiestBucket.inSeconds;

    return BeakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume', style: context.text.titleSmall),
          const SizedBox(height: Insets.lg),
          SizedBox(
            height: 108,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in stats.buckets)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: peak == 0
                                  ? 0.02
                                  : (bucket.total.inSeconds / peak).clamp(
                                      0.02,
                                      1,
                                    ),
                              child: AnimatedContainer(
                                duration: Motion.normal,
                                curve: Motion.enter,
                                decoration: BoxDecoration(
                                  color: bucket.sessions == 0
                                      ? colors.border
                                      : colors.accent,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Corners.xs,
                                    bottom: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Insets.sm),
                          Text(
                            bucket.label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TempoBreakdown extends StatelessWidget {
  const _TempoBreakdown({required this.stats});

  final WorkoutStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = stats.timePerTempo.values.fold(
      Duration.zero,
      (sum, value) => sum + value,
    );

    if (total == Duration.zero) return const SizedBox.shrink();

    final entries = stats.timePerTempo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BeakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where the time went', style: context.text.titleSmall),
          const SizedBox(height: Insets.lg),
          ClipRRect(
            borderRadius: Corners.pillRadius,
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final entry in entries)
                    Expanded(
                      flex: entry.value.inSeconds.clamp(1, 1 << 20),
                      child: ColoredBox(
                        color: entry.key.color(colors),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Insets.lg),
          Wrap(
            spacing: Insets.lg,
            runSpacing: Insets.sm,
            children: [
              for (final entry in entries)
                _TempoLegend(
                  tempo: entry.key,
                  duration: entry.value,
                  share: entry.value.inSeconds / total.inSeconds,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TempoLegend extends StatelessWidget {
  const _TempoLegend({
    required this.tempo,
    required this.duration,
    required this.share,
  });

  final Tempo tempo;
  final Duration duration;
  final double share;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: tempo.color(colors),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Insets.sm),
        Text(
          '${tempo.label}  ${(share * 100).round()}%',
          style: context.text.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// What the runner has already managed at their best, standing regardless of
/// the window the rest of the screen is showing.
class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.sessions});

  final List<RunSession> sessions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final best = computeMilestones(sessions);

    return BeakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatTile(
                value: best.longestRun.minutesOnly,
                unit: 'min',
                caption: 'Longest run',
                accent: true,
              ),
              Container(width: 1, height: 34, color: colors.border),
              StatTile(
                value: '${best.bestStreak}',
                unit: best.bestStreak == 1 ? 'day' : 'days',
                caption: 'Best streak',
              ),
              Container(width: 1, height: 34, color: colors.border),
              StatTile(
                value: '${best.mostStages}',
                caption: 'Most stages',
                alignment: CrossAxisAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          Text(
            _caption(best),
            style: context.text.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  String _caption(Milestones best) {
    final set = best.longestRunAt;
    final routes = best.finishedRoutes == 1
        ? '1 route finished end to end'
        : '${best.finishedRoutes} routes finished end to end';

    if (set == null) return routes;

    return '$routes  ·  longest set on ${DateFormat('d MMM').format(set)}';
  }
}

/// The diary distilled into one line: how runs in this window have felt on
/// average, from the same five faces used right after a run.
class _EffortSummary extends StatelessWidget {
  const _EffortSummary({required this.stats});

  final WorkoutStats stats;

  static const _faces = [
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_very_dissatisfied_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final average = stats.averageEffort;
    if (average == null) return const SizedBox.shrink();

    final rounded = average.round().clamp(1, 5);

    return BeakCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.lg,
        vertical: Insets.md,
      ),
      child: Row(
        children: [
          Icon(_faces[rounded - 1], color: colors.accent, size: 26),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How it has felt', style: context.text.titleSmall),
                Text(
                  'On average, ${kEffortLabels[rounded - 1].toLowerCase()} '
                  'from your notes this ${stats.range == StatsRange.week ? 'week' : stats.range == StatsRange.month ? 'month' : 'year'}.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final RunSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      padding: const EdgeInsets.all(Insets.md),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: session.finishedRoute
                  ? colors.walk.withValues(alpha: 0.16)
                  : colors.surfaceMuted,
              borderRadius: Corners.cardRadius,
            ),
            child: Icon(
              session.finishedRoute
                  ? Icons.check_rounded
                  : Icons.timelapse_rounded,
              size: 20,
              color: session.finishedRoute ? colors.walk : colors.textMuted,
            ),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.workoutName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
      Text(
                  '${DateFormat('d MMM, HH:mm').format(session.startedAt)}'
                  '  ·  ${session.completedStages}/${session.totalStages} stages',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                if (session.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    session.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.actualDuration.compact,
                style: context.text.titleSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (session.effort != null) ...[
                const SizedBox(height: 2),
                Text(
                  kEffortLabels[session.effort! - 1],
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NoHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.xxxl,
        Insets.xl,
        dockClearance(context),
      ),
      children: [
        EmptyState(
          title: 'No runs recorded yet',
          message:
              'Finish a route and it will appear here with the time you spent '
              'at each tempo.',
          actionLabel: 'Go to routes',
          onAction: () => context.go(AppRoute.routes),
        ),
      ],
    );
  }
}
