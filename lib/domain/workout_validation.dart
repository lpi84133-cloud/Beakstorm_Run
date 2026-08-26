import 'package:flutter/foundation.dart';

import 'workout.dart';
import 'workout_stage.dart';

/// Longest route the builder accepts. Past this the strip stops being readable
/// on a phone, which is the whole point of the visual layout.
const int kMaxStages = 40;

/// Shortest stage that can still be followed while moving.
const Duration kMinStageDuration = Duration(seconds: 5);

const Duration kMaxStageDuration = Duration(minutes: 60);

/// Ceiling on the route once repeated blocks are unrolled. Well past any real
/// session, but it stops a stray repeat count from producing a route nobody
/// could finish.
const int kMaxRunStages = 150;

@immutable
class RouteIssue {
  const RouteIssue(this.message, {this.stageId});

  /// Written as an instruction, not a failure notice: the user is meant to fix
  /// it and carry on.
  final String message;

  /// Set when the problem belongs to one stage, so the builder can point at it.
  final String? stageId;
}

/// Checks a route is worth starting. Nothing here is a penalty or a score; the
/// rules only stop a timer that would sit at zero or run through an empty list.
List<RouteIssue> validateRoute({
  required String name,
  required List<WorkoutStage> stages,
  int? expandedCount,
}) {
  final issues = <RouteIssue>[];

  if (name.trim().isEmpty) {
    issues.add(
      const RouteIssue('Give the route a name so you can find it later.'),
    );
  }

  if (stages.isEmpty) {
    issues.add(const RouteIssue('Add at least one stage before starting.'));
    return issues;
  }

  if (stages.length > kMaxStages) {
    issues.add(
      const RouteIssue(
        'A route can hold up to $kMaxStages stages. '
        'Remove a few or split it in two.',
      ),
    );
  }

  if (expandedCount != null && expandedCount > kMaxRunStages) {
    issues.add(
      const RouteIssue(
        'With the repeats applied this route runs past $kMaxRunStages stages. '
        'Lower a repeat count.',
      ),
    );
  }

  if (!stages.any((stage) => stage.tempo.isActive)) {
    issues.add(
      const RouteIssue(
        'This route is all rest. Add a walking or running stage.',
      ),
    );
  }

  for (final stage in stages) {
    if (stage.duration < kMinStageDuration) {
      issues.add(
        RouteIssue(
          '${stage.tempo.label} is too short to follow. '
          'Give it at least ${kMinStageDuration.inSeconds} seconds.',
          stageId: stage.id,
        ),
      );
    } else if (stage.duration > kMaxStageDuration) {
      issues.add(
        RouteIssue(
          '${stage.tempo.label} is longer than ${kMaxStageDuration.inMinutes} minutes. '
          'Split it into shorter stages.',
          stageId: stage.id,
        ),
      );
    }
  }

  return issues;
}

extension WorkoutValidation on Workout {
  List<RouteIssue> get issues => validateRoute(
    name: name,
    stages: stages,
    expandedCount: runStages.length,
  );

  bool get canStart => issues.isEmpty;
}
