// Slices the delivered sprite sheets into individual, tightly cropped images.
//
// Sheets are cut along fully transparent gutters rather than a fixed grid, so
// each piece keeps its own proportions and nothing important gets clipped.
// Large flat artwork (backgrounds, splash art, wordmark) is copied through as
// webp because Flutter decodes it natively and it stays far smaller.
//
// Usage: dart run tool/slice_assets.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const _sourceDir = 'assets/Beakstorm_Run_APPLICATION_gameplay_assets';
const _extraDir = 'assets/Beakstorm_Run_APPLICATION_additional_assets';
const _soundDir = 'assets/Beakstorm_Run_APPLICATION_sounds_assets';
const _outImages = 'assets/images';
const _outSounds = 'assets/sounds';

/// Alpha at or below this counts as empty space when looking for gutters.
const _alphaFloor = 12;

/// Transparent margin kept around each slice, in source pixels.
const _padding = 6;

class Sheet {
  const Sheet(
    this.file, {
    required this.rows,
    required this.columns,
    required this.names,
    this.maxSize = 512,
  });

  final String file;
  final int rows;
  final int columns;

  /// Row-major names for the produced slices.
  final List<String> names;
  final int maxSize;
}

const _sheets = <Sheet>[
  Sheet(
    'chicken_marker_set_asset.webp',
    rows: 3,
    columns: 1,
    names: ['chicken_idle', 'chicken_running', 'chicken_finished'],
  ),
  Sheet(
    'egg_marker_set_asset.webp',
    rows: 3,
    columns: 1,
    names: ['egg_pending', 'egg_active', 'egg_passed'],
  ),
  Sheet(
    'coin_marker_set_asset.webp',
    rows: 3,
    columns: 1,
    names: ['coin_pending', 'coin_active', 'coin_passed'],
  ),
  Sheet(
    'feather_marker_set_asset.webp',
    rows: 3,
    columns: 1,
    names: ['feather_light', 'feather_cream', 'feather_gold'],
  ),
  Sheet(
    'checkpoint_set_asset.webp',
    rows: 4,
    columns: 1,
    names: [
      'checkpoint_pending',
      'checkpoint_active',
      'checkpoint_done',
      'checkpoint_finish',
    ],
  ),
  Sheet(
    'tempo_indicator_set_asset.webp',
    rows: 4,
    columns: 1,
    names: ['tempo_walk', 'tempo_easy_run', 'tempo_run', 'tempo_fast_run'],
  ),
  Sheet(
    'road_segment_set_asset.webp',
    rows: 2,
    columns: 2,
    names: ['road_straight', 'road_curve', 'road_loop', 'road_finish'],
    maxSize: 640,
  ),
  Sheet(
    'run_direction_arrows_asset.webp',
    rows: 2,
    columns: 2,
    names: ['arrow_ahead', 'arrow_left', 'arrow_right', 'arrow_turnaround'],
    maxSize: 320,
  ),
  Sheet(
    'statistics_illustration_set_asset.webp',
    rows: 3,
    columns: 1,
    names: ['stat_trend', 'stat_share', 'stat_volume'],
  ),
  // Rows only: the dashed connectors would be shredded by column detection.
  Sheet(
    'workout_illustration_set_asset.webp',
    rows: 4,
    columns: 1,
    names: [
      'route_start_finish',
      'route_checkpoint',
      'route_tempo',
      'route_recovery',
    ],
    maxSize: 720,
  ),
  Sheet(
    'empty_state_illustration_asset.webp',
    rows: 1,
    columns: 1,
    names: ['illustration_empty'],
    maxSize: 720,
  ),
  Sheet(
    'completion_illustration_asset.webp',
    rows: 1,
    columns: 1,
    names: ['illustration_complete'],
    maxSize: 720,
  ),
];

/// Full-bleed artwork that is copied unchanged.
const _passThrough = <String, String>{
  '$_sourceDir/dark_beakstorm_background_asset.webp': 'bg_night_route.webp',
  '$_sourceDir/main_route_background_asset.webp': 'bg_route.webp',
  '$_sourceDir/warm_training_ground_background_asset.webp': 'bg_track.webp',
  '$_extraDir/Vertical_Loading_Screen.webp': 'launch_portrait.webp',
  '$_extraDir/Horizontal_Loading_Screen.webp': 'launch_landscape.webp',
  '$_extraDir/Game_Name.webp': 'wordmark.webp',
};

void main() {
  Directory(_outImages).createSync(recursive: true);
  Directory(_outSounds).createSync(recursive: true);

  for (final sheet in _sheets) {
    _slice(sheet);
  }

  for (final entry in _passThrough.entries) {
    final source = File(entry.key);
    if (!source.existsSync()) {
      stdout.writeln('missing ${entry.key}');
      continue;
    }
    source.copySync('$_outImages/${entry.value}');
    stdout.writeln('copied ${entry.value}');
  }

  _copySounds();
}

void _slice(Sheet sheet) {
  final source = File('$_sourceDir/${sheet.file}');
  if (!source.existsSync()) {
    stdout.writeln('missing ${sheet.file}');
    return;
  }

  final image = decodeImage(source.readAsBytesSync());
  if (image == null) {
    stdout.writeln('undecodable ${sheet.file}');
    return;
  }

  final rowBands = _bands(image, Axis.vertical, sheet.rows, _fullRect(image));
  var index = 0;

  for (final rowBand in rowBands) {
    final rowRect = Rect(0, rowBand.start, image.width, rowBand.end);
    final colBands = sheet.columns == 1
        ? [Band(0, image.width)]
        : _bands(image, Axis.horizontal, sheet.columns, rowRect);

    for (final colBand in colBands) {
      if (index >= sheet.names.length) break;

      final region = Rect(
        colBand.start,
        rowBand.start,
        colBand.end,
        rowBand.end,
      );
      final cropped = _trim(image, region);
      if (cropped == null) {
        stdout.writeln('empty slice in ${sheet.file}');
        index++;
        continue;
      }

      final scaled = _fit(cropped, sheet.maxSize);
      final name = sheet.names[index++];
      File(
        '$_outImages/$name.png',
      ).writeAsBytesSync(encodePng(scaled, level: 9));
      stdout.writeln('sliced $name (${scaled.width}x${scaled.height})');
    }
  }
}

enum Axis { vertical, horizontal }

class Band {
  const Band(this.start, this.end);
  final int start;
  final int end;
  int get size => end - start;
}

class Rect {
  const Rect(this.left, this.top, this.right, this.bottom);
  final int left;
  final int top;
  final int right;
  final int bottom;
}

Rect _fullRect(Image image) => Rect(0, 0, image.width, image.height);

/// Finds [expected] content bands inside [area], splitting on transparent
/// gutters. Falls back to an even split when the sheet has no clean gaps.
List<Band> _bands(Image image, Axis axis, int expected, Rect area) {
  final length = axis == Axis.vertical
      ? area.bottom - area.top
      : area.right - area.left;
  final occupied = List<bool>.filled(length, false);

  for (var i = 0; i < length; i++) {
    final cross = axis == Axis.vertical
        ? _rowHasContent(image, area.top + i, area.left, area.right)
        : _columnHasContent(image, area.left + i, area.top, area.bottom);
    occupied[i] = cross;
  }

  final runs = <Band>[];
  var start = -1;
  for (var i = 0; i < length; i++) {
    if (occupied[i] && start == -1) start = i;
    if (!occupied[i] && start != -1) {
      runs.add(Band(start, i));
      start = -1;
    }
  }
  if (start != -1) runs.add(Band(start, length));

  final offset = axis == Axis.vertical ? area.top : area.left;
  final shifted = runs
      .map((b) => Band(b.start + offset, b.end + offset))
      .toList();

  if (shifted.length == expected) return shifted;

  // Merge the smallest neighbouring runs until the expected count is reached;
  // this rescues sheets where a shape has a detached highlight or shadow.
  while (shifted.length > expected) {
    var mergeAt = 0;
    var smallestGap = 1 << 30;
    for (var i = 0; i < shifted.length - 1; i++) {
      final gap = shifted[i + 1].start - shifted[i].end;
      if (gap < smallestGap) {
        smallestGap = gap;
        mergeAt = i;
      }
    }
    shifted[mergeAt] = Band(shifted[mergeAt].start, shifted[mergeAt + 1].end);
    shifted.removeAt(mergeAt + 1);
  }

  if (shifted.length == expected) return shifted;

  final step = length ~/ expected;
  return List.generate(
    expected,
    (i) => Band(
      offset + i * step,
      offset + (i == expected - 1 ? length : (i + 1) * step),
    ),
  );
}

bool _rowHasContent(Image image, int y, int left, int right) {
  for (var x = left; x < right; x++) {
    if (image.getPixel(x, y).a > _alphaFloor) return true;
  }
  return false;
}

bool _columnHasContent(Image image, int x, int top, int bottom) {
  for (var y = top; y < bottom; y++) {
    if (image.getPixel(x, y).a > _alphaFloor) return true;
  }
  return false;
}

Image? _trim(Image image, Rect region) {
  var minX = region.right;
  var minY = region.bottom;
  var maxX = region.left;
  var maxY = region.top;

  for (var y = region.top; y < region.bottom; y++) {
    for (var x = region.left; x < region.right; x++) {
      if (image.getPixel(x, y).a <= _alphaFloor) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  if (minX > maxX || minY > maxY) return null;

  final left = math.max(0, minX - _padding);
  final top = math.max(0, minY - _padding);
  final right = math.min(image.width - 1, maxX + _padding);
  final bottom = math.min(image.height - 1, maxY + _padding);

  return copyCrop(
    image,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );
}

Image _fit(Image image, int maxSize) {
  final longest = math.max(image.width, image.height);
  if (longest <= maxSize) return image;

  final scale = maxSize / longest;
  return copyResize(
    image,
    width: (image.width * scale).round(),
    height: (image.height * scale).round(),
    interpolation: Interpolation.cubic,
  );
}

void _copySounds() {
  final dir = Directory(_soundDir);
  if (!dir.existsSync()) return;

  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.mp3')) continue;
    final name = file.uri.pathSegments.last.replaceAll('_asset.mp3', '.mp3');
    file.copySync('$_outSounds/$name');
    stdout.writeln('sound $name');
  }
}
