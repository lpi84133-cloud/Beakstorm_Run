import 'package:isar_community/isar.dart';

part 'entities.g.dart';

/// Stored shape of a route.
///
/// Every field carries a default rather than being `late`: a record written by
/// an older build that lacks a newer field then reads back as the default
/// instead of throwing while the user is mid-workout. Enums persist by name so
/// reordering the Dart enums cannot silently rewrite saved data.
@collection
class WorkoutRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uid = '';

  String name = '';
  DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(0);

  @Index()
  DateTime updatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  String? templateKey;

  List<StageRecord> stages = [];

  /// Repeat counts for the blocks referenced by [StageRecord.groupId].
  List<RepeatRecord> repeats = [];
}

@embedded
class RepeatRecord {
  String groupId = '';
  int times = 1;
}

@embedded
class StageRecord {
  String uid = '';

  @Enumerated(EnumType.name)
  TempoValue tempo = TempoValue.run;

  int durationSeconds = 0;

  @Enumerated(EnumType.name)
  MarkerValue marker = MarkerValue.none;

  String? note;

  String? groupId;

  /// Steps per minute, or zero when the stage carries no cadence target.
  int cadence = 0;
}

/// Stored shape of a training plan.
///
/// Only the settings and the completion marks are kept: the sessions themselves
/// are regenerated from these, so the schedule cannot drift out of sync with
/// the generator.
@collection
class PlanRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uid = '';

  int weeks = 4;
  int sessionsPerWeek = 3;

  @Enumerated(EnumType.name)
  EffortValue effort = EffortValue.moderate;

  int baseMinutes = 30;
  DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// A finished or abandoned plan stays on disk but stops being the current one.
  @Index()
  bool active = true;

  List<PlanProgressRecord> progress = [];
}

@embedded
class PlanProgressRecord {
  String sessionKey = '';
  DateTime completedAt = DateTime.fromMillisecondsSinceEpoch(0);
}

@collection
class SessionRecord {
  Id id = Isar.autoIncrement;

  String workoutUid = '';
  String workoutName = '';

  @Index()
  DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime endedAt = DateTime.fromMillisecondsSinceEpoch(0);
  int plannedSeconds = 0;
  int actualSeconds = 0;
  int completedStages = 0;
  int totalStages = 0;
  bool finishedRoute = false;
  String? templateKey;

  List<TempoSpanRecord> spans = [];

  /// 1 to 5, or zero when the runner skipped the diary for this session.
  int effort = 0;

  String? note;
}

@embedded
class TempoSpanRecord {
  @Enumerated(EnumType.name)
  TempoValue tempo = TempoValue.run;

  int seconds = 0;
}

/// Persisted mirrors of the domain enums, so the storage format is not hostage
/// to presentation-side renaming.
enum TempoValue { walk, easyRun, run, fastRun, recovery, stop }

enum MarkerValue { none, checkpoint, tempoChange, recovery }

enum EffortValue { easy, moderate, hard }
