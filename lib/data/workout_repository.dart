import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../domain/workout.dart';
import 'database.dart';
import 'entities.dart';
import 'mappers.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref);
});

/// Streams every saved route, newest edit first. Screens watch this instead of
/// re-reading after each change.
final savedWorkoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final isar = await ref.watch(databaseProvider.future);

  yield* isar.workoutRecords
      .where()
      .sortByUpdatedAtDesc()
      .watch(fireImmediately: true)
      .map((records) => records.map((record) => record.toDomain()).toList());
});

final workoutByIdProvider = StreamProvider.family<Workout?, String>((
  ref,
  uid,
) async* {
  final isar = await ref.watch(databaseProvider.future);

  yield* isar.workoutRecords
      .filter()
      .uidEqualTo(uid)
      .watch(fireImmediately: true)
      .map((records) => records.isEmpty ? null : records.first.toDomain());
});

class WorkoutRepository {
  WorkoutRepository(this._ref);

  final Ref _ref;

  Future<Isar> get _isar => _ref.read(databaseProvider.future);

  Future<void> save(Workout workout) async {
    final isar = await _isar;
    final record = workoutToRecord(workout);

    await isar.writeTxn(() async {
      // The uid index replaces on conflict, so this covers insert and update.
      final existing = await isar.workoutRecords
          .filter()
          .uidEqualTo(workout.id)
          .findFirst();
      if (existing != null) record.id = existing.id;

      await isar.workoutRecords.put(record);
    });
  }

  Future<Workout?> findById(String uid) async {
    final isar = await _isar;
    final record = await isar.workoutRecords
        .filter()
        .uidEqualTo(uid)
        .findFirst();
    return record?.toDomain();
  }

  Future<void> delete(String uid) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      await isar.workoutRecords.filter().uidEqualTo(uid).deleteAll();
    });
  }

  Future<int> count() async {
    final isar = await _isar;
    return isar.workoutRecords.count();
  }
}
