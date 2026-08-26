import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../domain/milestones.dart';
import '../domain/recovery_advisor.dart';
import '../domain/session.dart';
import '../domain/statistics.dart';
import 'database.dart';
import 'entities.dart';
import 'mappers.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref);
});

/// Every finished run, most recent first.
final sessionHistoryProvider = StreamProvider<List<RunSession>>((ref) async* {
  final isar = await ref.watch(databaseProvider.future);

  yield* isar.sessionRecords
      .where()
      .sortByStartedAtDesc()
      .watch(fireImmediately: true)
      .map((records) => records.map((record) => record.toDomain()).toList());
});

/// Whether recent training suggests easing off today, recomputed whenever
/// history changes.
final recoveryAdviceProvider = Provider<AsyncValue<RecoveryAdvice>>((ref) {
  return ref.watch(sessionHistoryProvider).whenData(
    (sessions) => buildRecoveryAdvice(sessions: sessions, now: DateTime.now()),
  );
});

/// All-time personal bests, recomputed whenever history changes.
final milestonesProvider = Provider<AsyncValue<Milestones>>((ref) {
  return ref.watch(sessionHistoryProvider).whenData(computeMilestones);
});

/// Statistics for a window, recomputed whenever history changes.
final statisticsProvider = Provider.family<AsyncValue<WorkoutStats>, StatsRange>(
  (ref, range) {
    return ref
        .watch(sessionHistoryProvider)
        .whenData(
          (sessions) => buildStats(
            range: range,
            sessions: sessions,
            now: DateTime.now(),
          ),
        );
  },
);

class SessionRepository {
  SessionRepository(this._ref);

  final Ref _ref;

  Future<Isar> get _isar => _ref.read(databaseProvider.future);

  Future<int> add(RunSession session) async {
    final isar = await _isar;
    final record = sessionToRecord(session);

    return isar.writeTxn(() => isar.sessionRecords.put(record));
  }

  /// Fills in the diary for a session already saved. Split from [add] because
  /// the diary is answered from the summary sheet, a moment after the run
  /// itself has been written to history.
  Future<void> updateDiary(int id, {int? effort, String? note}) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final record = await isar.sessionRecords.get(id);
      if (record == null) return;

      record
        ..effort = effort ?? 0
        ..note = (note == null || note.isEmpty) ? null : note;

      await isar.sessionRecords.put(record);
    });
  }

  Future<void> delete(int id) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.sessionRecords.delete(id));
  }

  Future<List<RunSession>> all() async {
    final isar = await _isar;
    final records = await isar.sessionRecords
        .where()
        .sortByStartedAtDesc()
        .findAll();
    return records.map((record) => record.toDomain()).toList();
  }

  Future<int> count() async {
    final isar = await _isar;
    return isar.sessionRecords.count();
  }
}
