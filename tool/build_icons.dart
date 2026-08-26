// Prepares launcher icon layers from the single delivered Icon.png.
//
// iOS needs one opaque 1024 square. Android's adaptive icon needs separate
// layers, and only the middle 66% of the foreground is guaranteed to survive
// the OEM mask, so the artwork is scaled into that safe circle and feathered
// into a matching navy backdrop instead of being cropped by the mask.
//
// Usage: dart run tool/build_icons.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const _source =
    'assets/Beakstorm_Run_APPLICATION_additional_assets/Icon.png';
const _outDir = 'assets/icon';

const _canvas = 1024;

/// Android guarantees the middle 66% of the adaptive foreground is visible.
const _safeZone = 0.66;

/// Width of the alpha falloff at the edge of the safe circle, in pixels.
const _feather = 46.0;

void main() {
  final file = File(_source);
  if (!file.existsSync()) {
    stderr.writeln('missing $_source');
    exitCode = 1;
    return;
  }

  final art = decodeImage(file.readAsBytesSync())!;
  Directory(_outDir).createSync(recursive: true);

  _writeIosIcon(art);
  _writeAdaptiveBackground(art);
  _writeAdaptiveForeground(art);
  _writeLaunchImages();
}

/// The native launch screen shows the wordmark on the same navy the Flutter
/// loading screen uses, so the handover has no white flash.
void _writeLaunchImages() {
  final source = File('assets/images/wordmark.webp');
  if (!source.existsSync()) {
    stderr.writeln('missing ${source.path}; run tool/slice_assets.dart first');
    return;
  }

  final wordmark = _trimTransparent(decodeImage(source.readAsBytesSync())!);

  const targets = <String, int>{
    'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png': 240,
    'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png': 480,
    'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png': 720,
    'android/app/src/main/res/drawable/launch_image.png': 480,
  };

  for (final entry in targets.entries) {
    final resized = copyResize(
      wordmark,
      width: entry.value,
      interpolation: Interpolation.cubic,
    );
    File(entry.key)
      ..createSync(recursive: true)
      ..writeAsBytesSync(encodePng(resized, level: 9));
    stdout.writeln('${entry.key.split('/').last} ${resized.width}px');
  }
}

Image _trimTransparent(Image image) {
  var minX = image.width, minY = image.height, maxX = 0, maxY = 0;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a <= 8) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  if (minX > maxX) return image;

  return copyCrop(
    image,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}

/// App Store rejects icons with an alpha channel, so the art is flattened onto
/// its own dominant backdrop colour.
void _writeIosIcon(Image art) {
  final scaled = copyResize(
    art,
    width: _canvas,
    height: _canvas,
    interpolation: Interpolation.cubic,
  );

  final backdrop = _cornerColour(art);
  final flat = Image(width: _canvas, height: _canvas, numChannels: 3);
  fill(flat, color: backdrop);
  compositeImage(flat, scaled);

  File('$_outDir/app_icon.png').writeAsBytesSync(encodePng(flat, level: 9));
  stdout.writeln('app_icon.png ${_canvas}x$_canvas (opaque)');
}

/// A plain vertical gradient taken from the artwork's own corners, so the
/// foreground blends into it no matter how aggressively the mask crops.
void _writeAdaptiveBackground(Image art) {
  // Only the outer edges are sampled; the middle holds the subject and would
  // drag warm gold into what should stay a calm navy backdrop.
  final edge = art.width ~/ 10;
  final top = _sampleRegion(art, 0, 0, edge, art.height ~/ 3);
  final bottom = _sampleRegion(
    art,
    0,
    art.height * 2 ~/ 3,
    edge,
    art.height,
  );

  final background = Image(width: _canvas, height: _canvas, numChannels: 3);
  for (var y = 0; y < _canvas; y++) {
    final t = y / (_canvas - 1);
    final r = _lerp(top.$1, bottom.$1, t);
    final g = _lerp(top.$2, bottom.$2, t);
    final b = _lerp(top.$3, bottom.$3, t);
    for (var x = 0; x < _canvas; x++) {
      background.setPixelRgb(x, y, r, g, b);
    }
  }

  File(
    '$_outDir/adaptive_background.png',
  ).writeAsBytesSync(encodePng(background, level: 9));
  stdout.writeln('adaptive_background.png gradient $top -> $bottom');
}

void _writeAdaptiveForeground(Image art) {
  final diameter = (_canvas * _safeZone).round();
  final scaled = copyResize(
    art,
    width: diameter,
    height: diameter,
    interpolation: Interpolation.cubic,
  );

  final foreground = Image(width: _canvas, height: _canvas, numChannels: 4);
  final offset = (_canvas - diameter) ~/ 2;
  compositeImage(foreground, scaled, dstX: offset, dstY: offset);

  const centre = _canvas / 2;
  final radius = diameter / 2;
  for (var y = 0; y < _canvas; y++) {
    for (var x = 0; x < _canvas; x++) {
      final distance = math.sqrt(
        math.pow(x - centre, 2) + math.pow(y - centre, 2),
      );
      final falloff = ((radius - distance) / _feather).clamp(0.0, 1.0);
      if (falloff == 1.0) continue;

      final pixel = foreground.getPixel(x, y);
      foreground.setPixelRgba(
        x,
        y,
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
        (pixel.a * falloff).round(),
      );
    }
  }

  File(
    '$_outDir/adaptive_foreground.png',
  ).writeAsBytesSync(encodePng(foreground, level: 9));
  stdout.writeln('adaptive_foreground.png art inside ${diameter}px safe circle');
}

(int, int, int) _sampleRegion(Image image, int x0, int y0, int x1, int y1) {
  var r = 0, g = 0, b = 0, count = 0;
  for (var y = y0; y < y1; y += 2) {
    for (var x = x0; x < x1; x += 2) {
      final pixel = image.getPixel(x, y);
      if (pixel.a < 200) continue;
      r += pixel.r.toInt();
      g += pixel.g.toInt();
      b += pixel.b.toInt();
      count++;
    }
  }
  if (count == 0) return (14, 26, 44);
  return (r ~/ count, g ~/ count, b ~/ count);
}

ColorRgb8 _cornerColour(Image image) {
  final (r, g, b) = _sampleRegion(image, 0, 0, image.width ~/ 8, image.height);
  return ColorRgb8(r, g, b);
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();
