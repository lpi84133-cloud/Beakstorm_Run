// Samples dominant colours from the source art so the design tokens match the
// illustrations exactly instead of being eyeballed.
//
// Usage: dart run tool/palette.dart
import 'dart:io';

import 'package:image/image.dart';

const _sources = <String>[
  '.preview/road_segment_set_asset.png',
  '.preview/main_route_background_asset.png',
  '.preview/dark_beakstorm_background_asset.png',
  '.preview/warm_training_ground_background_asset.png',
  '.preview/tempo_indicator_set_asset.png',
  '.preview/coin_marker_set_asset.png',
  '.preview/statistics_illustration_set_asset.png',
];

void main() {
  for (final path in _sources) {
    final file = File(path);
    if (!file.existsSync()) {
      stdout.writeln('skip $path (missing)');
      continue;
    }

    final image = decodePng(file.readAsBytesSync())!;
    final counts = <int, int>{};

    for (var y = 0; y < image.height; y += 3) {
      for (var x = 0; x < image.width; x += 3) {
        final pixel = image.getPixel(x, y);
        if (pixel.a < 200) continue;

        // Quantise to 4 bits per channel so near-identical shades group together.
        final key =
            ((pixel.r.toInt() >> 4) << 8) |
            ((pixel.g.toInt() >> 4) << 4) |
            (pixel.b.toInt() >> 4);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    stdout.writeln('\n$path');
    for (final entry in ranked.take(8)) {
      final r = ((entry.key >> 8) & 0xF) * 17;
      final g = ((entry.key >> 4) & 0xF) * 17;
      final b = (entry.key & 0xF) * 17;
      final hex = '#'
          '${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
      stdout.writeln('  $hex  ${entry.value}');
    }
  }
}
