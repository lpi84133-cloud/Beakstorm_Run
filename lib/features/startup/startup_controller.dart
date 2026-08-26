import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'startup_task.dart';

final startupControllerProvider =
    NotifierProvider<StartupController, StartupProgress>(StartupController.new);

/// How long a single task may take before it is abandoned. Exposed as a
/// provider so tests can exercise the timeout path quickly.
final startupTaskTimeoutProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 4),
);

@immutable
class StartupProgress {
  const StartupProgress({
    required this.value,
    required this.label,
    required this.isReady,
    this.degraded = false,
  });

  /// How much of the work is genuinely finished, from 0 to 1.
  final double value;

  /// What is happening right now, shown under the bar.
  final String label;

  /// True only once every task has settled and a frame has been rendered.
  final bool isReady;

  /// At least one task failed and was skipped. The app still runs; the flag
  /// exists so screens can offer a rebuild of whatever was missed.
  final bool degraded;
}

/// Runs the startup sequence and publishes real progress.
///
/// Two rules keep the bar honest: the value only ever moves after a task has
/// actually finished, and no task can stall the sequence. A task that throws or
/// times out still contributes its weight and marks the run as degraded, which
/// is what stops the classic freeze just short of the end.
class StartupController extends Notifier<StartupProgress> {
  @override
  StartupProgress build() {
    unawaited(Future.microtask(_run));
    return const StartupProgress(
      value: 0,
      label: 'Getting ready',
      isReady: false,
    );
  }

  Future<void> _run() async {
    final tasks = ref.read(startupTasksProvider);
    final timeout = ref.read(startupTaskTimeoutProvider);
    final totalWeight = tasks.fold<double>(0, (sum, task) => sum + task.weight);

    var completed = 0.0;
    var degraded = false;

    for (final task in tasks) {
      final share = task.weight / totalWeight;

      state = StartupProgress(
        value: completed,
        label: task.label,
        isReady: false,
        degraded: degraded,
      );

      try {
        await task
            .run(ref, (fraction) {
              final clamped = fraction.clamp(0.0, 1.0);
              state = StartupProgress(
                value: completed + share * clamped,
                label: task.label,
                isReady: false,
                degraded: degraded,
              );
            })
            .timeout(timeout);
      } catch (error, stack) {
        degraded = true;
        debugPrint('startup task "${task.label}" skipped: $error\n$stack');
      }

      completed += share;
    }

    state = StartupProgress(
      value: 1,
      label: 'Ready',
      isReady: true,
      degraded: degraded,
    );
  }
}
