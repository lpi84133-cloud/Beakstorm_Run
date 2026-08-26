import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'entities.dart';

/// The device-local database. Opened once during startup; there is no remote
/// counterpart and no sync.
final databaseProvider = FutureProvider<Isar>((ref) async {
  final directory = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [WorkoutRecordSchema, SessionRecordSchema, PlanRecordSchema],
    directory: directory.path,
    name: 'beakstorm',
  );

  ref.onDispose(isar.close);
  return isar;
});
