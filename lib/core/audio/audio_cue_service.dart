import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioCueServiceProvider = Provider<AudioCueService>((ref) {
  final service = AudioCueService();
  ref.onDispose(service.dispose);
  return service;
});

/// Plays the short interface and session cues.
///
/// One player is kept per cue so a sound can restart instantly without a fresh
/// decode; players are created lazily and the session-critical ones are warmed
/// up during startup.
class AudioCueService {
  final Map<String, AudioPlayer> _players = {};

  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      for (final player in _players.values) {
        player.stop();
      }
    }
  }

  Future<void> warmUp(Iterable<String> cues) async {
    for (final cue in cues) {
      await _player(cue);
    }
  }

  Future<void> play(String cue) async {
    if (!_enabled) return;

    try {
      final player = await _player(cue);
      await player.seek(Duration.zero);
      await player.resume();
    } catch (error) {
      // A missing or busy audio route must never interrupt a workout.
      debugPrint('audio cue failed: $cue ($error)');
    }
  }

  Future<AudioPlayer> _player(String cue) async {
    final existing = _players[cue];
    if (existing != null) return existing;

    final player = AudioPlayer(playerId: cue);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setSource(AssetSource(cue));

    _players[cue] = player;
    return player;
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
