import 'package:flutter/foundation.dart';

import 'session.dart';

/// The best a runner has managed so far, across their whole history.
///
/// Every figure is something that actually happened and is stored on the
/// device. Nothing is awarded, unlocked or taken away: a record simply stands
/// until a better run replaces it.
@immutable
class Milestones {
  const Milestones({
    required this.longestRun,
    required this.longestRunAt,
    required this.mostStages,
    required this.mostStagesAt,
    required this.bestStreak,
    required this.finishedRoutes,
    required this.totalSessions,
  });

  factory Milestones.empty() => const Milestones(
    longestRun: Duration.zero,
    longestRunAt: null,
    mostStages: 0,
    mostStagesAt: null,
    bestStreak: 0,
    finishedRoutes: 0,
    totalSessions: 0,
  );

  final Duration longestRun;
  final DateTime? longestRunAt;

  final int mostStages;
  final DateTime? mostStagesAt;

  /// The longest run of consecutive days with at least one session, ever. The
  /// current streak can be shorter without this number changing, so a missed
  /// day never erases what was already done.
  final int bestStreak;

  final int finishedRoutes;
  final int totalSessions;

  bool get isEmpty => totalSessions == 0;
}

Milestones computeMilestones(List<RunSession> sessions) {
  if (sessions.isEmpty) return Milestones.empty();

  var longestRun = Duration.zero;
  DateTime? longestRunAt;
  var mostStages = 0;
  DateTime? mostStagesAt;
  var finished = 0;

  for (final session in sessions) {
    if (session.actualDuration > longestRun) {
      longestRun = session.actualDuration;
      longestRunAt = session.startedAt;
    }

    if (session.completedStages > mostStages) {
      mostStages = session.completedStages;
      mostStagesAt = session.startedAt;
    }

    if (session.finishedRoute) finished++;
  }

  return Milestones(
    longestRun: longestRun,
    longestRunAt: longestRunAt,
    mostStages: mostStages,
    mostStagesAt: mostStagesAt,
    bestStreak: _bestStreak(sessions),
    finishedRoutes: finished,
    totalSessions: sessions.length,
  );
}

int _bestStreak(List<RunSession> sessions) {
  final days =
      sessions
          .map(
            (session) => DateTime(
              session.startedAt.year,
              session.startedAt.month,
              session.startedAt.day,
            ),
          )
          .toSet()
          .toList()
        ..sort();

  if (days.isEmpty) return 0;

  var best = 1;
  var current = 1;

  for (var i = 1; i < days.length; i++) {
    if (days[i].difference(days[i - 1]).inDays == 1) {
      current++;
      if (current > best) best = current;
    } else {
      current = 1;
    }
  }

  return best;
}
