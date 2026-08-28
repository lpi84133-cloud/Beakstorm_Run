import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../assets/app_sounds.dart';

final cadenceMetronomeProvider = Provider<CadenceMetronome>((ref) {
  final metronome = CadenceMetronome();
  ref.onDispose(metronome.dispose);
  return metronome;
});

/// Cadence range the picker offers. Below 140 the tick is not useful, above 200
/// it stops being a running cadence.
const int kMinCadence = 140;
const int kMaxCadence = 200;
const int kCadenceStep = 5;

/// Ticks out a step rhythm during a run.
///
/// Cadence is the one piece of running technique that can be trained without a
/// sensor: hear the beat, land on it. The beat is scheduled against a running
/// stopwatch instead of by accumulating timer callbacks, so it cannot drift
/// over a long stage.
class CadenceMetronome {
  CadenceMetronome({this.beatsPerBar = 4});

  /// Every fourth beat gets a haptic accent, which is enough to follow the
  /// rhythm with the phone in a pocket and the sound off.
  final int beatsPerBar;

  final _stopwatch = Stopwatch();

  AudioPlayer? _player;
  Timer? _timer;
  int _beat = 0;
  int _cadence = 0;

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  bool get isRunning => _timer != null;
  int get cadence => _cadence;

  Future<void> start(int stepsPerMinute) async {
    if (stepsPerMinute < kMinCadence || stepsPerMinute > kMaxCadence) {
      stop();
      return;
    }

    if (_cadence == stepsPerMinute && isRunning) return;

    stop();
    _cadence = stepsPerMinute;
    _beat = 0;

    await _prepare();

    final interval = Duration(microseconds: 60000000 ~/ stepsPerMinute);
    _stopwatch
      ..reset()
      ..start();

    // A short polling tick keeps the beat aligned to elapsed time: a late
    // callback catches up instead of pushing every later beat back.
    _timer = Timer.periodic(const Duration(milliseconds: 8), (_) {
      final due = _stopwatch.elapsedMicroseconds ~/ interval.inMicroseconds;
      if (due <= _beat) return;

      _beat = due;
      _pulse();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    _cadence = 0;
  }

  void _pulse() {
    if (hapticsEnabled && _beat % beatsPerBar == 0) {
      HapticFeedback.lightImpact();
    }

    if (!soundEnabled) return;

    final player = _player;
    if (player == null) return;

    // Fire and forget: a tick that arrives late is worse than one that is
    // dropped, so failures are ignored rather than awaited.
    player.seek(Duration.zero).then((_) => player.resume()).catchError((
      Object error,
    ) {
      // dart format off
      assert(() { debugPrint('cadence tick failed: $error'); return true; }());
      // dart format on
    });
  }

  Future<void> _prepare() async {
    if (_player != null) return;

    try {
      final player = AudioPlayer(playerId: 'cadence');
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setSource(AssetSource(AppSounds.buttonTap));
      await player.setVolume(0.55);

      _player = player;
    } catch (error) {
      // Without audio the haptic accent still carries the rhythm, so a busy or
      // unavailable audio route degrades instead of stopping the run.
      // dart format off
      assert(() { debugPrint('cadence audio unavailable: $error'); return true; }());
      // dart format on
    }
  }

  Future<void> dispose() async {
    stop();
    await _player?.dispose();
    _player = null;
  }
}
