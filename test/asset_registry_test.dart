import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the hand-written registries against typos and against artwork that
/// was sliced but never wired up.
void main() {
  Set<String> filenamesIn(String registry) {
    final source = File(registry).readAsStringSync();
    return RegExp(r'\$_dir/([\w.]+)')
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();
  }

  group('asset registry', () {
    test('every referenced image exists on disk', () {
      final referenced = filenamesIn('lib/core/assets/app_images.dart');

      expect(referenced, isNotEmpty);
      for (final name in referenced) {
        expect(
          File('assets/images/$name').existsSync(),
          isTrue,
          reason: 'missing assets/images/$name',
        );
      }
    });

    test('every sliced image is referenced', () {
      final referenced = filenamesIn('lib/core/assets/app_images.dart');
      final onDisk = Directory('assets/images')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((name) => !name.startsWith('.'));

      for (final name in onDisk) {
        expect(referenced, contains(name), reason: '$name is unused');
      }
    });

    test('every sound cue exists on disk', () {
      final referenced = filenamesIn('lib/core/assets/app_sounds.dart');

      expect(referenced, hasLength(14));
      for (final name in referenced) {
        expect(
          File('assets/sounds/$name').existsSync(),
          isTrue,
          reason: 'missing assets/sounds/$name',
        );
      }
    });
  });
}
