import 'package:flutter/foundation.dart';

import 'stage_marker.dart';
import 'tempo.dart';

/// One timed segment of a route.
@immutable
class WorkoutStage {
  const WorkoutStage({
    required this.id,
    required this.tempo,
    required this.duration,
    this.marker = StageMarker.none,
    this.note,
    this.groupId,
    this.cadence,
  });

  /// Stable across edits so reorder animations and the running session can
  /// follow a stage even as the list changes around it.
  final String id;
  final Tempo tempo;
  final Duration duration;
  final StageMarker marker;

  /// Optional free text, for example "outer lap" or "up the stairs".
  final String? note;

  /// Target steps per minute for this stage, or null when the metronome stays
  /// quiet. Only meaningful while moving, so rest stages leave it unset.
  final int? cadence;

  /// Set when the stage belongs to a repeated block. Stages of a block are
  /// always adjacent; the repeat count lives on the workout.
  final String? groupId;

  WorkoutStage copyWith({
    String? id,
    Tempo? tempo,
    Duration? duration,
    StageMarker? marker,
    String? note,
    bool clearNote = false,
    String? groupId,
    bool clearGroup = false,
    int? cadence,
    bool clearCadence = false,
  }) {
    return WorkoutStage(
      id: id ?? this.id,
      tempo: tempo ?? this.tempo,
      duration: duration ?? this.duration,
      marker: marker ?? this.marker,
      note: clearNote ? null : (note ?? this.note),
      groupId: clearGroup ? null : (groupId ?? this.groupId),
      cadence: clearCadence ? null : (cadence ?? this.cadence),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WorkoutStage &&
      other.id == id &&
      other.tempo == tempo &&
      other.duration == duration &&
      other.marker == marker &&
      other.note == note &&
      other.groupId == groupId &&
      other.cadence == cadence;

  @override
  int get hashCode =>
      Object.hash(id, tempo, duration, marker, note, groupId, cadence);
}
