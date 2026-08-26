import 'package:beakstorm_run/features/startup/startup_controller.dart';
import 'package:beakstorm_run/features/startup/startup_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The loading bar is the first thing a reviewer sees, so its two guarantees
/// are pinned down here: it never moves backwards, and nothing can leave it
/// stranded short of the end.
void main() {
  Future<List<StartupProgress>> runSequence(List<StartupTask> tasks) async {
    final container = ProviderContainer(
      overrides: [
        startupTasksProvider.overrideWithValue(tasks),
        startupTaskTimeoutProvider.overrideWithValue(
          const Duration(milliseconds: 60),
        ),
      ],
    );
    addTearDown(container.dispose);

    final seen = <StartupProgress>[];
    container.listen(
      startupControllerProvider,
      (_, next) => seen.add(next),
      fireImmediately: true,
    );

    while (!seen.last.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return seen;
  }

  StartupTask instant(String label, double weight) => StartupTask(
    label: label,
    weight: weight,
    run: (ref, report) async => report(1),
  );

  test('progress rises monotonically and finishes at exactly 1', () async {
    final seen = await runSequence([
      instant('one', 1),
      StartupTask(
        label: 'stepped',
        weight: 2,
        run: (ref, report) async {
          for (var i = 1; i <= 4; i++) {
            report(i / 4);
          }
        },
      ),
      instant('three', 1),
    ]);

    for (var i = 1; i < seen.length; i++) {
      expect(
        seen[i].value,
        greaterThanOrEqualTo(seen[i - 1].value),
        reason: 'progress went backwards at index $i',
      );
    }

    expect(seen.last.value, 1.0);
    expect(seen.last.isReady, isTrue);
    expect(seen.last.degraded, isFalse);
  });

  test('a throwing task does not stall the sequence', () async {
    final seen = await runSequence([
      instant('before', 1),
      StartupTask(
        label: 'broken',
        weight: 1,
        run: (ref, report) async => throw StateError('boom'),
      ),
      instant('after', 1),
    ]);

    expect(seen.last.value, 1.0);
    expect(seen.last.isReady, isTrue);
    expect(seen.last.degraded, isTrue);
  });

  test('a hanging task is abandoned once it times out', () async {
    final seen = await runSequence([
      instant('before', 1),
      StartupTask(
        label: 'hangs',
        weight: 1,
        run: (ref, report) => Future<void>.delayed(const Duration(seconds: 30)),
      ),
      instant('after', 1),
    ]);

    expect(seen.last.value, 1.0);
    expect(seen.last.isReady, isTrue);
    expect(seen.last.degraded, isTrue);
  });
}
