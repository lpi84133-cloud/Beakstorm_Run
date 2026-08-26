import 'package:flutter/foundation.dart';

import 'auto_route.dart';
import 'workout.dart';
import 'workout_stage.dart';

/// What a single session in the week is for.
enum PlanFocus {
  steady('Steady', 'One continuous effort, split by checkpoints'),
  intervals('Intervals', 'Repeats with recovery in between'),
  easy('Easy', 'Short and conversational, on purpose');

  const PlanFocus(this.label, this.description);

  final String label;
  final String description;
}

/// One session of a plan, ready to run.
@immutable
class PlannedSession {
  const PlannedSession({
    required this.week,
    required this.position,
    required this.focus,
    required this.stages,
    required this.repeats,
  });

  /// One-based, counted from the start of the plan.
  final int week;

  /// One-based, counted from the start of the week.
  final int position;

  final PlanFocus focus;
  final List<WorkoutStage> stages;
  final Map<String, int> repeats;

  /// Stable across regenerations, which is what completion is recorded against.
  String get key => 'w$week-s$position';

  String get title => 'Week $week · ${focus.label}';

  /// A throwaway route the run screen can walk through. Plan sessions are not
  /// stored as saved routes, so this is built fresh each time and never lands
  /// in the user's route list.
  Workout toWorkout(DateTime now) {
    return Workout(
      id: 'plan-$key',
      name: title,
      stages: stages,
      repeats: repeats,
      createdAt: now,
      updatedAt: now,
    );
  }

  Duration get duration => toWorkout(DateTime.now()).totalDuration;
}

/// A multi-week schedule: the reason to come back tomorrow rather than to
/// improvise another run.
///
/// Sessions are derived from the settings rather than stored, so only the
/// settings and the completion marks have to survive a restart.
@immutable
class TrainingPlan {
  const TrainingPlan({
    required this.weeks,
    required this.sessionsPerWeek,
    required this.effort,
    required this.baseMinutes,
    required this.startedAt,
    required this.sessions,
    required this.completed,
  });

  final int weeks;
  final int sessionsPerWeek;
  final RouteEffort effort;

  /// Length of a session in the first week. Later weeks grow from here.
  final int baseMinutes;

  final DateTime startedAt;
  final List<PlannedSession> sessions;

  /// Session key to the moment it was finished.
  final Map<String, DateTime> completed;

  int get totalSessions => sessions.length;

  int get doneCount =>
      sessions.where((session) => completed.containsKey(session.key)).length;

  double get progress => totalSessions == 0 ? 0 : doneCount / totalSessions;

  bool get isComplete => doneCount >= totalSessions;

  bool isDone(PlannedSession session) => completed.containsKey(session.key);

  /// The first unfinished session, or null once the plan is done. Sessions are
  /// taken in order: a plan that can be cherry-picked is just a route list.
  PlannedSession? get nextSession {
    for (final session in sessions) {
      if (!completed.containsKey(session.key)) return session;
    }
    return null;
  }

  int get currentWeek => nextSession?.week ?? weeks;

  List<PlannedSession> sessionsIn(int week) =>
      sessions.where((session) => session.week == week).toList();

  int doneIn(int week) =>
      sessionsIn(week).where((session) => completed.containsKey(session.key)).length;

  Duration get weeklyLoad {
    final week = sessionsIn(currentWeek);
    return week.fold(Duration.zero, (sum, session) => sum + session.duration);
  }
}

/// Repeating shape of a week. A hard day is never followed by another hard day.
const _weekPattern = [
  PlanFocus.steady,
  PlanFocus.intervals,
  PlanFocus.easy,
  PlanFocus.intervals,
  PlanFocus.steady,
  PlanFocus.easy,
];

/// Builds the whole schedule from a handful of settings.
///
/// Volume climbs by about a tenth each week, and a plan of three weeks or more
/// finishes lighter than it peaks, because ending on the hardest week is how
/// people get hurt and stop.
TrainingPlan buildTrainingPlan({
  required int weeks,
  required int sessionsPerWeek,
  required RouteEffort effort,
  required int baseMinutes,
  required DateTime startedAt,
  Map<String, DateTime> completed = const {},
}) {
  final weekCount = weeks.clamp(2, 8);
  final perWeek = sessionsPerWeek.clamp(2, 5);
  final base = baseMinutes.clamp(15, 90);

  final sessions = <PlannedSession>[];

  for (var week = 1; week <= weekCount; week++) {
    final taper = weekCount >= 3 && week == weekCount;
    final growth = taper ? 0.9 : 1 + 0.1 * (week - 1);

    for (var position = 1; position <= perWeek; position++) {
      final focus = _weekPattern[(position - 1) % _weekPattern.length];
      final minutes = (base * growth * _focusScale(focus)).round();

      var counter = 0;
      final route = buildAutoRoute(
        total: Duration(minutes: minutes),
        effort: focus == PlanFocus.easy ? RouteEffort.easy : effort,
        intervals: focus == PlanFocus.intervals,
        // Ids are derived from the slot so a regenerated plan is identical to
        // the one the user saw yesterday.
        idFor: () => 'w$week-s$position-${counter++}',
      );

      sessions.add(
        PlannedSession(
          week: week,
          position: position,
          focus: focus,
          stages: route.stages,
          repeats: route.repeats,
        ),
      );
    }
  }

  return TrainingPlan(
    weeks: weekCount,
    sessionsPerWeek: perWeek,
    effort: effort,
    baseMinutes: base,
    startedAt: startedAt,
    sessions: sessions,
    completed: completed,
  );
}

double _focusScale(PlanFocus focus) => switch (focus) {
  PlanFocus.steady => 1,
  PlanFocus.intervals => 1.05,
  PlanFocus.easy => 0.75,
};
