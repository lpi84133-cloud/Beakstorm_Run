import 'package:flutter/foundation.dart';

import 'stage_marker.dart';
import 'tempo.dart';
import 'workout.dart';
import 'workout_stage.dart';

/// The five starting points that ship with the app.
///
/// They live in code rather than the database: nothing to seed, nothing to
/// migrate, and they are available on the very first launch without a network.
@immutable
class WorkoutTemplate {
  const WorkoutTemplate({
    required this.key,
    required this.name,
    required this.summary,
    required this.stages,
    this.repeats = const {},
  });

  final String key;
  final String name;
  final String summary;
  final List<WorkoutStage> stages;

  /// Repeat counts for the blocks used by [stages], keyed by group name.
  final Map<String, int> repeats;

  Workout _preview() => Workout(
    id: key,
    name: name,
    stages: stages,
    repeats: repeats,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  List<WorkoutStage> get runStages => _preview().runStages;

  Duration get totalDuration => _preview().totalDuration;

  int get stageCount => runStages.length;

  /// Builds an editable copy. Stage and group ids are regenerated so the new
  /// route owns its own identities.
  Workout toWorkout({
    required String id,
    required String Function(int index) idFor,
    required DateTime now,
    String? name,
  }) {
    final groupIds = <String, String>{};
    for (final group in repeats.keys) {
      groupIds[group] = '$id-$group';
    }

    return Workout(
      id: id,
      name: name ?? this.name,
      templateKey: key,
      createdAt: now,
      updatedAt: now,
      repeats: {
        for (final entry in repeats.entries) groupIds[entry.key]!: entry.value,
      },
      stages: [
        for (var i = 0; i < stages.length; i++)
          stages[i].copyWith(
            id: idFor(i),
            groupId: stages[i].groupId == null
                ? null
                : groupIds[stages[i].groupId],
          ),
      ],
    );
  }
}

/// Terse builder so the template definitions below stay readable.
WorkoutStage _stage(
  String id,
  Tempo tempo,
  int seconds, {
  StageMarker marker = StageMarker.none,
  String? note,
  String? group,
  int? cadence,
}) {
  return WorkoutStage(
    id: id,
    tempo: tempo,
    duration: Duration(seconds: seconds),
    marker: marker,
    note: note,
    groupId: group,
    cadence: cadence,
  );
}

final _quickRun = WorkoutTemplate(
  key: 'quick_run',
  name: 'Quick Run',
  summary: 'A short, complete session when time is tight.',
  stages: [
    _stage('quick-1', Tempo.walk, 180, note: 'Warm up'),
    _stage(
      'quick-2',
      Tempo.easyRun,
      300,
      marker: StageMarker.tempoChange,
      cadence: 165,
    ),
    _stage('quick-3', Tempo.run, 180, marker: StageMarker.checkpoint, cadence: 172),
    _stage('quick-4', Tempo.walk, 120, note: 'Cool down'),
  ],
);

final _recoveryRun = WorkoutTemplate(
  key: 'recovery_run',
  name: 'Recovery Run',
  summary: 'Gentle session for the day after something hard.',
  stages: [
    _stage('recovery-1', Tempo.walk, 300, note: 'Warm up'),
    _stage(
      'recovery-2',
      Tempo.easyRun,
      480,
      marker: StageMarker.checkpoint,
      cadence: 162,
    ),
    _stage('recovery-3', Tempo.recovery, 240, marker: StageMarker.recovery),
    _stage('recovery-4', Tempo.walk, 180, note: 'Cool down'),
  ],
);

final _intervalRun = WorkoutTemplate(
  key: 'interval_run',
  name: 'Interval Run',
  summary: 'Four working blocks with an easy stretch between each.',
  repeats: const {'work': 4},
  stages: [
    _stage('interval-warmup', Tempo.walk, 240, note: 'Warm up'),
    _stage(
      'interval-work',
      Tempo.run,
      120,
      marker: StageMarker.tempoChange,
      group: 'work',
      cadence: 174,
    ),
    _stage(
      'interval-rest',
      Tempo.recovery,
      90,
      marker: StageMarker.recovery,
      group: 'work',
    ),
    _stage('interval-cooldown', Tempo.walk, 240, note: 'Cool down'),
  ],
);

final _shortSprint = WorkoutTemplate(
  key: 'short_sprint',
  name: 'Short Sprint',
  summary: 'Six hard bursts with full rest, for a track or a straight path.',
  repeats: const {'burst': 6},
  stages: [
    _stage('sprint-warmup', Tempo.walk, 180, note: 'Warm up'),
    _stage('sprint-build', Tempo.easyRun, 180),
    _stage(
      'sprint-burst',
      Tempo.fastRun,
      30,
      marker: StageMarker.tempoChange,
      group: 'burst',
      cadence: 184,
    ),
    _stage(
      'sprint-rest',
      Tempo.recovery,
      60,
      marker: StageMarker.recovery,
      group: 'burst',
    ),
    _stage('sprint-cooldown', Tempo.walk, 180, note: 'Cool down'),
  ],
);

final _indoorCircuit = WorkoutTemplate(
  key: 'indoor_circuit',
  name: 'Indoor Circuit',
  summary: 'Short laps and standing breaks, sized for a room or a hall.',
  repeats: const {'lap': 4},
  stages: [
    _stage('indoor-warmup', Tempo.walk, 120, note: 'Warm up'),
    _stage('indoor-move', Tempo.easyRun, 90, group: 'lap'),
    _stage(
      'indoor-push',
      Tempo.run,
      45,
      marker: StageMarker.tempoChange,
      group: 'lap',
    ),
    _stage(
      'indoor-break',
      Tempo.stop,
      45,
      marker: StageMarker.checkpoint,
      group: 'lap',
    ),
    _stage('indoor-cooldown', Tempo.walk, 120, note: 'Cool down'),
  ],
);

/// Ordered from shortest to longest so the list reads as a ramp.
final List<WorkoutTemplate> workoutTemplates = [
  _quickRun,
  _indoorCircuit,
  _shortSprint,
  _recoveryRun,
  _intervalRun,
];

WorkoutTemplate? templateByKey(String? key) {
  if (key == null) return null;
  for (final template in workoutTemplates) {
    if (template.key == key) return template;
  }
  return null;
}
