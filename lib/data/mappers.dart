import '../domain/session.dart';
import '../domain/stage_marker.dart';
import '../domain/tempo.dart';
import '../domain/workout.dart';
import '../domain/workout_stage.dart';
import 'entities.dart';

/// Translation between the stored records and the domain model.
///
/// The two enums are mapped explicitly rather than by index, so a value that
/// disappears from storage falls back to something sensible instead of
/// throwing while the user is looking at their history.
Tempo _tempoFrom(TempoValue value) => switch (value) {
  TempoValue.walk => Tempo.walk,
  TempoValue.easyRun => Tempo.easyRun,
  TempoValue.run => Tempo.run,
  TempoValue.fastRun => Tempo.fastRun,
  TempoValue.recovery => Tempo.recovery,
  TempoValue.stop => Tempo.stop,
};

TempoValue tempoTo(Tempo tempo) => switch (tempo) {
  Tempo.walk => TempoValue.walk,
  Tempo.easyRun => TempoValue.easyRun,
  Tempo.run => TempoValue.run,
  Tempo.fastRun => TempoValue.fastRun,
  Tempo.recovery => TempoValue.recovery,
  Tempo.stop => TempoValue.stop,
};

StageMarker _markerFrom(MarkerValue value) => switch (value) {
  MarkerValue.none => StageMarker.none,
  MarkerValue.checkpoint => StageMarker.checkpoint,
  MarkerValue.tempoChange => StageMarker.tempoChange,
  MarkerValue.recovery => StageMarker.recovery,
};

MarkerValue _markerTo(StageMarker marker) => switch (marker) {
  StageMarker.none => MarkerValue.none,
  StageMarker.checkpoint => MarkerValue.checkpoint,
  StageMarker.tempoChange => MarkerValue.tempoChange,
  StageMarker.recovery => MarkerValue.recovery,
};

extension WorkoutRecordMapper on WorkoutRecord {
  Workout toDomain() {
    return Workout(
      id: uid,
      name: name,
      templateKey: templateKey,
      createdAt: createdAt,
      updatedAt: updatedAt,
      repeats: {for (final entry in repeats) entry.groupId: entry.times},
      stages: [
        for (final stage in stages)
          WorkoutStage(
            id: stage.uid,
            tempo: _tempoFrom(stage.tempo),
            duration: Duration(seconds: stage.durationSeconds),
            marker: _markerFrom(stage.marker),
            note: stage.note,
            groupId: stage.groupId,
            cadence: stage.cadence == 0 ? null : stage.cadence,
          ),
      ],
    );
  }
}

WorkoutRecord workoutToRecord(Workout workout) {
  return WorkoutRecord()
    ..uid = workout.id
    ..name = workout.name
    ..templateKey = workout.templateKey
    ..createdAt = workout.createdAt
    ..updatedAt = workout.updatedAt
    ..stages = [
      for (final stage in workout.stages)
        StageRecord()
          ..uid = stage.id
          ..tempo = tempoTo(stage.tempo)
          ..durationSeconds = stage.duration.inSeconds
          ..marker = _markerTo(stage.marker)
          ..note = stage.note
          ..groupId = stage.groupId
          ..cadence = stage.cadence ?? 0,
    ]
    ..repeats = [
      // Only groups that are still in use are stored, so deleting a block
      // cannot leave an orphan count behind.
      for (final entry in workout.repeats.entries)
        if (workout.stages.any((stage) => stage.groupId == entry.key))
          RepeatRecord()
            ..groupId = entry.key
            ..times = entry.value,
    ];
}

extension SessionRecordMapper on SessionRecord {
  RunSession toDomain() {
    return RunSession(
      id: id,
      workoutId: workoutUid,
      workoutName: workoutName,
      templateKey: templateKey,
      startedAt: startedAt,
      endedAt: endedAt,
      plannedDuration: Duration(seconds: plannedSeconds),
      actualDuration: Duration(seconds: actualSeconds),
      completedStages: completedStages,
      totalStages: totalStages,
      finishedRoute: finishedRoute,
      timePerTempo: {
        for (final span in spans)
          _tempoFrom(span.tempo): Duration(seconds: span.seconds),
      },
      effort: effort == 0 ? null : effort,
      note: note,
    );
  }
}

SessionRecord sessionToRecord(RunSession session) {
  return SessionRecord()
    ..workoutUid = session.workoutId
    ..workoutName = session.workoutName
    ..templateKey = session.templateKey
    ..startedAt = session.startedAt
    ..endedAt = session.endedAt
    ..plannedSeconds = session.plannedDuration.inSeconds
    ..actualSeconds = session.actualDuration.inSeconds
    ..completedStages = session.completedStages
    ..totalStages = session.totalStages
    ..finishedRoute = session.finishedRoute
    ..effort = session.effort ?? 0
    ..note = session.note
    ..spans = [
      for (final entry in session.timePerTempo.entries)
        if (entry.value > Duration.zero)
          TempoSpanRecord()
            ..tempo = tempoTo(entry.key)
            ..seconds = entry.value.inSeconds,
    ];
}
