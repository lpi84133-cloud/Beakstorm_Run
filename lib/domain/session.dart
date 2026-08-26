import 'package:flutter/foundation.dart';

import 'tempo.dart';

/// A finished run, stored on the device.
///
/// The workout name and the tempo breakdown are copied in rather than
/// referenced, so history stays truthful even after the route is edited or
/// deleted.
@immutable
class RunSession {
  const RunSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startedAt,
    required this.endedAt,
    required this.plannedDuration,
    required this.actualDuration,
    required this.completedStages,
    required this.totalStages,
    required this.finishedRoute,
    required this.timePerTempo,
    this.templateKey,
    this.effort,
    this.note,
  });

  final int id;
  final String workoutId;
  final String workoutName;
  final DateTime startedAt;
  final DateTime endedAt;

  /// What the route asked for, versus what was actually spent moving.
  final Duration plannedDuration;
  final Duration actualDuration;

  final int completedStages;
  final int totalStages;

  /// True when every stage was reached, false when the run was ended early.
  /// Ending early is a normal outcome, not a loss.
  final bool finishedRoute;

  final Map<Tempo, Duration> timePerTempo;
  final String? templateKey;

  /// How the run felt, from 1 (very easy) to 5 (all-out). Set right after
  /// finishing, and optional: a run with nothing filled in still counts.
  final int? effort;

  /// A short note about anything that might explain how the run went: sleep,
  /// food, weather. Free text, kept for the runner and never interpreted.
  final String? note;

  Duration get effortDuration => timePerTempo.entries
      .where((entry) => entry.key.isEffort)
      .fold(Duration.zero, (total, entry) => total + entry.value);

  double get stageCompletion =>
      totalStages == 0 ? 0 : completedStages / totalStages;

  RunSession copyWith({int? id, int? effort, String? note}) {
    return RunSession(
      id: id ?? this.id,
      workoutId: workoutId,
      workoutName: workoutName,
      templateKey: templateKey,
      startedAt: startedAt,
      endedAt: endedAt,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration,
      completedStages: completedStages,
      totalStages: totalStages,
      finishedRoute: finishedRoute,
      timePerTempo: timePerTempo,
      effort: effort ?? this.effort,
      note: note ?? this.note,
    );
  }
}

/// Five rungs from "barely worked" to "everything I had", the same scale
/// coaches call RPE. Kept short on purpose: a picker with more choices than
/// this gets guessed at rather than felt.
const List<String> kEffortLabels = [
  'Very easy',
  'Easy',
  'Moderate',
  'Hard',
  'All-out',
];
