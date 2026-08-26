import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/assets/app_images.dart';
import '../../core/assets/app_sounds.dart';
import '../../core/audio/audio_cue_service.dart';
import '../../core/storage/preferences_store.dart';
import '../../data/database.dart';
import '../../data/session_repository.dart';
import '../../data/workout_repository.dart';

/// Reports how far along a task is, from 0 to 1.
typedef TaskProgress = void Function(double fraction);

/// One unit of real initialisation work.
///
/// [weight] is relative, not a percentage: the controller normalises the list,
/// so tasks can be added later without rebalancing the existing numbers.
@immutable
class StartupTask {
  const StartupTask({
    required this.label,
    required this.weight,
    required this.run,
  });

  final String label;
  final double weight;
  final Future<void> Function(Ref ref, TaskProgress report) run;
}

/// The startup sequence. Later iterations append their own work here rather
/// than reaching into the controller.
final startupTasksProvider = Provider<List<StartupTask>>((ref) {
  return [
    StartupTask(
      label: 'Reading your settings',
      weight: 0.10,
      run: (ref, report) async {
        await ref.read(preferencesStoreProvider.future);
        report(1);
      },
    ),
    StartupTask(
      label: 'Opening your routes',
      weight: 0.20,
      run: (ref, report) async {
        await ref.read(databaseProvider.future);
        // Touching both collections warms the query paths, so the first screen
        // does not pay for it.
        await ref.read(workoutRepositoryProvider).count();
        await ref.read(sessionRepositoryProvider).count();
        report(1);
      },
    ),
    StartupTask(
      label: 'Preparing artwork',
      weight: 0.45,
      run: (ref, report) async {
        const paths = AppImages.preloadOnStartup;
        for (var i = 0; i < paths.length; i++) {
          await _decodeIntoCache(paths[i]);
          report((i + 1) / paths.length);
        }
      },
    ),
    StartupTask(
      label: 'Loading sound cues',
      weight: 0.25,
      run: (ref, report) async {
        const cues = AppSounds.warmUpOnStartup;
        final audio = ref.read(audioCueServiceProvider);
        for (var i = 0; i < cues.length; i++) {
          await audio.warmUp([cues[i]]);
          report((i + 1) / cues.length);
        }
      },
    ),
    StartupTask(
      label: 'Almost there',
      weight: 0.10,
      run: (ref, report) async {
        // The bar only reaches the end once a frame has actually been rendered
        // with everything in place.
        await WidgetsBinding.instance.endOfFrame;
        report(1);
      },
    ),
  ];
});

/// Decodes an asset into the global image cache without needing a
/// [BuildContext], so the work can live in a controller.
Future<void> _decodeIntoCache(String path) async {
  final provider = AssetImage(path);
  final stream = provider.resolve(ImageConfiguration.empty);
  final completer = Completer<void>();

  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      if (!completer.isCompleted) completer.complete();
      stream.removeListener(listener);
    },
    onError: (error, stack) {
      if (!completer.isCompleted) completer.complete();
      stream.removeListener(listener);
    },
  );

  stream.addListener(listener);
  await completer.future;
}
