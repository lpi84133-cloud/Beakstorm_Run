import 'package:flutter/foundation.dart';

import 'stage_marker.dart';
import 'tempo.dart';
import 'workout_stage.dart';

/// A saved route: an ordered list of timed stages with a name.
///
/// [stages] is the edited shape, where a repeated block appears once. [runStages]
/// is what the timer actually walks through, with every block unrolled.
@immutable
class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.stages,
    required this.createdAt,
    required this.updatedAt,
    this.repeats = const {},
    this.templateKey,
  });

  final String id;
  final String name;
  final List<WorkoutStage> stages;

  /// Group id to the number of times that block runs. A group with no entry, or
  /// a count below two, behaves as a plain sequence of stages.
  final Map<String, int> repeats;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Which built-in template this route started from, kept so statistics can
  /// show which structures actually get used.
  final String? templateKey;

  int repeatsFor(String? groupId) {
    if (groupId == null) return 1;
    final times = repeats[groupId] ?? 1;
    return times < 1 ? 1 : times;
  }

  /// The flattened route. Repeated stages get suffixed ids so the running
  /// session can tell one lap from another.
  List<WorkoutStage> get runStages {
    final expanded = <WorkoutStage>[];
    var index = 0;

    while (index < stages.length) {
      final group = stages[index].groupId;

      if (group == null) {
        expanded.add(stages[index]);
        index++;
        continue;
      }

      var end = index;
      while (end < stages.length && stages[end].groupId == group) {
        end++;
      }

      final block = stages.sublist(index, end);
      final times = repeatsFor(group);

      for (var round = 1; round <= times; round++) {
        for (final stage in block) {
          expanded.add(
            times == 1
                ? stage
                : stage.copyWith(
                    id: '${stage.id}#$round',
                    note: stage.note == null
                        ? 'Round $round of $times'
                        : '${stage.note} · $round/$times',
                  ),
          );
        }
      }

      index = end;
    }

    return expanded;
  }

  Duration get totalDuration => runStages.fold(
    Duration.zero,
    (total, stage) => total + stage.duration,
  );

  Duration get activeDuration => runStages
      .where((stage) => stage.tempo.isActive)
      .fold(Duration.zero, (total, stage) => total + stage.duration);

  int get stageCount => runStages.length;

  int get markerCount =>
      stages.where((stage) => stage.marker != StageMarker.none).length;

  /// Distinct modes in route order, used for the compact tempo strip on cards.
  List<Tempo> get tempoSequence {
    final sequence = <Tempo>[];
    for (final stage in runStages) {
      if (sequence.isEmpty || sequence.last != stage.tempo) {
        sequence.add(stage.tempo);
      }
    }
    return sequence;
  }

  Workout copyWith({
    String? name,
    List<WorkoutStage>? stages,
    Map<String, int>? repeats,
    DateTime? updatedAt,
    String? templateKey,
  }) {
    return Workout(
      id: id,
      name: name ?? this.name,
      stages: stages ?? this.stages,
      repeats: repeats ?? this.repeats,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      templateKey: templateKey ?? this.templateKey,
    );
  }
}

/// Repairs grouping after an edit.
///
/// A block only means anything while its stages sit next to each other, so a
/// drag that splits one keeps the longest run and releases the strays.
List<WorkoutStage> normalizeGroups(List<WorkoutStage> stages) {
  final runs = <String, List<List<int>>>{};

  for (var i = 0; i < stages.length; i++) {
    final group = stages[i].groupId;
    if (group == null) continue;

    final existing = runs[group];
    if (existing != null && existing.last.last == i - 1) {
      existing.last.add(i);
    } else {
      (runs[group] ??= []).add([i]);
    }
  }

  final keep = <int>{};
  for (final entry in runs.entries) {
    final longest = entry.value.reduce((a, b) => b.length > a.length ? b : a);
    if (longest.length > 1) keep.addAll(longest);
  }

  return [
    for (var i = 0; i < stages.length; i++)
      stages[i].groupId == null || keep.contains(i)
          ? stages[i]
          : stages[i].copyWith(clearGroup: true),
  ];
}
