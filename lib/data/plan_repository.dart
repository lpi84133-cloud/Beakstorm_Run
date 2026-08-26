import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../core/utils/id.dart';
import '../domain/auto_route.dart';
import '../domain/training_plan.dart';
import 'database.dart';
import 'entities.dart';

final planRepositoryProvider = Provider<PlanRepository>(PlanRepository.new);

/// The plan the user is currently following, or null when there is none.
final activePlanProvider = StreamProvider<TrainingPlan?>((ref) async* {
  final isar = await ref.watch(databaseProvider.future);

  yield* isar.planRecords
      .filter()
      .activeEqualTo(true)
      .watch(fireImmediately: true)
      .map((records) => records.isEmpty ? null : _toDomain(records.first));
});

class PlanRepository {
  PlanRepository(this._ref);

  final Ref _ref;

  Future<Isar> get _isar => _ref.read(databaseProvider.future);

  /// Starts a plan, replacing any plan already in progress. Only one plan can
  /// be active: two competing schedules is the same as having none.
  Future<void> start({
    required int weeks,
    required int sessionsPerWeek,
    required RouteEffort effort,
    required int baseMinutes,
  }) async {
    final isar = await _isar;

    final record = PlanRecord()
      ..uid = newId()
      ..weeks = weeks
      ..sessionsPerWeek = sessionsPerWeek
      ..effort = _effortTo(effort)
      ..baseMinutes = baseMinutes
      ..startedAt = DateTime.now()
      ..active = true;

    await isar.writeTxn(() async {
      await _deactivateAll(isar);
      await isar.planRecords.put(record);
    });
  }

  Future<void> cancel() async {
    final isar = await _isar;
    await isar.writeTxn(() => _deactivateAll(isar));
  }

  /// Records a finished session. Re-running a session already ticked off keeps
  /// the original date, so the plan reads as a history and not as a leaderboard.
  Future<void> markDone(String sessionKey) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final record = await isar.planRecords
          .filter()
          .activeEqualTo(true)
          .findFirst();
      if (record == null) return;

      final already = record.progress.any(
        (entry) => entry.sessionKey == sessionKey,
      );
      if (already) return;

      record.progress = [
        ...record.progress,
        PlanProgressRecord()
          ..sessionKey = sessionKey
          ..completedAt = DateTime.now(),
      ];

      await isar.planRecords.put(record);
    });
  }

  Future<TrainingPlan?> active() async {
    final isar = await _isar;
    final record = await isar.planRecords
        .filter()
        .activeEqualTo(true)
        .findFirst();
    return record == null ? null : _toDomain(record);
  }

  Future<void> _deactivateAll(Isar isar) async {
    final records = await isar.planRecords.filter().activeEqualTo(true).findAll();

    for (final record in records) {
      record.active = false;
      await isar.planRecords.put(record);
    }
  }
}

TrainingPlan _toDomain(PlanRecord record) {
  return buildTrainingPlan(
    weeks: record.weeks,
    sessionsPerWeek: record.sessionsPerWeek,
    effort: _effortFrom(record.effort),
    baseMinutes: record.baseMinutes,
    startedAt: record.startedAt,
    completed: {
      for (final entry in record.progress) entry.sessionKey: entry.completedAt,
    },
  );
}

RouteEffort _effortFrom(EffortValue value) => switch (value) {
  EffortValue.easy => RouteEffort.easy,
  EffortValue.moderate => RouteEffort.moderate,
  EffortValue.hard => RouteEffort.hard,
};

EffortValue _effortTo(RouteEffort effort) => switch (effort) {
  RouteEffort.easy => EffortValue.easy,
  RouteEffort.moderate => EffortValue.moderate,
  RouteEffort.hard => EffortValue.hard,
};
