import 'package:flutter/foundation.dart';

import 'session.dart';
import 'tempo.dart';

/// Windows the statistics screen can show. Each one also decides the width of a
/// single bucket, so the chart always has a readable number of columns.
enum StatsRange {
  week('This week', 7),
  month('This month', 30),
  year('This year', 12);

  const StatsRange(this.label, this.buckets);

  final String label;
  final int buckets;

  DateTime startOf(DateTime now) => switch (this) {
    StatsRange.week => DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1)),
    StatsRange.month => DateTime(now.year, now.month),
    StatsRange.year => DateTime(now.year),
  };
}

@immutable
class ActivityBucket {
  const ActivityBucket({
    required this.start,
    required this.label,
    required this.total,
    required this.sessions,
  });

  final DateTime start;
  final String label;
  final Duration total;
  final int sessions;
}

/// Everything the statistics screen shows, computed on the device from the
/// stored sessions. No server, no estimates.
@immutable
class WorkoutStats {
  const WorkoutStats({
    required this.range,
    required this.sessionCount,
    required this.totalTime,
    required this.averageTime,
    required this.longestTime,
    required this.finishedRoutes,
    required this.timePerTempo,
    required this.buckets,
    required this.streakDays,
    this.averageEffort,
  });

  factory WorkoutStats.empty(StatsRange range) => WorkoutStats(
    range: range,
    sessionCount: 0,
    totalTime: Duration.zero,
    averageTime: Duration.zero,
    longestTime: Duration.zero,
    finishedRoutes: 0,
    timePerTempo: const {},
    buckets: const [],
    streakDays: 0,
  );

  final StatsRange range;
  final int sessionCount;
  final Duration totalTime;
  final Duration averageTime;
  final Duration longestTime;
  final int finishedRoutes;
  final Map<Tempo, Duration> timePerTempo;
  final List<ActivityBucket> buckets;

  /// Consecutive days with at least one run, counted back from today. Broken
  /// streaks simply reset; nothing is lost or taken away.
  final int streakDays;

  /// Mean of the diary rating across sessions that answered it, 1 to 5. Null
  /// when nobody has rated a run in this window yet.
  final double? averageEffort;

  bool get isEmpty => sessionCount == 0;

  Duration get busiestBucket => buckets.isEmpty
      ? Duration.zero
      : buckets
            .map((bucket) => bucket.total)
            .reduce((a, b) => a > b ? a : b);
}

/// Builds the statistics for [range]. [now] is injected so the calculation is
/// deterministic in tests.
WorkoutStats buildStats({
  required StatsRange range,
  required List<RunSession> sessions,
  required DateTime now,
}) {
  final windowStart = range.startOf(now);
  final inRange = sessions
      .where((session) => !session.startedAt.isBefore(windowStart))
      .toList();

  if (inRange.isEmpty) {
    return WorkoutStats.empty(range).copyWithStreak(_streak(sessions, now));
  }

  var total = Duration.zero;
  var longest = Duration.zero;
  var finished = 0;
  final perTempo = <Tempo, Duration>{};

  var effortSum = 0;
  var effortCount = 0;

  for (final session in inRange) {
    total += session.actualDuration;
    if (session.actualDuration > longest) longest = session.actualDuration;
    if (session.finishedRoute) finished++;

    final effort = session.effort;
    if (effort != null) {
      effortSum += effort;
      effortCount++;
    }

    for (final entry in session.timePerTempo.entries) {
      perTempo[entry.key] = (perTempo[entry.key] ?? Duration.zero) + entry.value;
    }
  }

  return WorkoutStats(
    range: range,
    sessionCount: inRange.length,
    totalTime: total,
    averageTime: Duration(seconds: total.inSeconds ~/ inRange.length),
    longestTime: longest,
    finishedRoutes: finished,
    timePerTempo: perTempo,
    buckets: _buckets(range, inRange, now),
    streakDays: _streak(sessions, now),
    averageEffort: effortCount == 0 ? null : effortSum / effortCount,
  );
}

extension on WorkoutStats {
  WorkoutStats copyWithStreak(int streakDays) => WorkoutStats(
    range: range,
    sessionCount: sessionCount,
    totalTime: totalTime,
    averageTime: averageTime,
    longestTime: longestTime,
    finishedRoutes: finishedRoutes,
    timePerTempo: timePerTempo,
    buckets: buckets,
    streakDays: streakDays,
    averageEffort: averageEffort,
  );
}

const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _monthLabels = [
  'J',
  'F',
  'M',
  'A',
  'M',
  'J',
  'J',
  'A',
  'S',
  'O',
  'N',
  'D',
];

List<ActivityBucket> _buckets(
  StatsRange range,
  List<RunSession> sessions,
  DateTime now,
) {
  final start = range.startOf(now);

  if (range == StatsRange.year) {
    return [
      for (var month = 1; month <= 12; month++)
        _bucketFor(
          sessions,
          DateTime(now.year, month),
          DateTime(now.year, month + 1),
          _monthLabels[month - 1],
        ),
    ];
  }

  final days = range == StatsRange.week
      ? 7
      : DateTime(now.year, now.month + 1, 0).day;

  return [
    for (var offset = 0; offset < days; offset++)
      () {
        final day = DateTime(start.year, start.month, start.day + offset);
        return _bucketFor(
          sessions,
          day,
          day.add(const Duration(days: 1)),
          range == StatsRange.week
              ? _weekdayLabels[day.weekday - 1]
              : '${day.day}',
        );
      }(),
  ];
}

ActivityBucket _bucketFor(
  List<RunSession> sessions,
  DateTime start,
  DateTime end,
  String label,
) {
  var total = Duration.zero;
  var count = 0;

  for (final session in sessions) {
    if (session.startedAt.isBefore(start)) continue;
    if (!session.startedAt.isBefore(end)) continue;
    total += session.actualDuration;
    count++;
  }

  return ActivityBucket(
    start: start,
    label: label,
    total: total,
    sessions: count,
  );
}

int _streak(List<RunSession> sessions, DateTime now) {
  if (sessions.isEmpty) return 0;

  final days = sessions
      .map(
        (session) => DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        ),
      )
      .toSet();

  var cursor = DateTime(now.year, now.month, now.day);

  // A run today is not required: the streak still counts if yesterday was the
  // last one, so opening the app in the morning does not look like a reset.
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
