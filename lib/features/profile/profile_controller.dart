import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/audio/audio_cue_service.dart';
import '../../core/storage/preferences_store.dart';

/// Everything the user sets about themselves and how the app behaves.
///
/// All of it lives on the device; there is no account and nothing is uploaded.
@immutable
class Profile {
  const Profile({
    this.name = '',
    this.avatarPath,
    this.weeklyGoalMinutes = 90,
    this.themeMode = ThemeMode.dark,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final String name;
  final String? avatarPath;
  final int weeklyGoalMinutes;
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticsEnabled;

  Profile copyWith({
    String? name,
    String? avatarPath,
    bool clearAvatar = false,
    int? weeklyGoalMinutes,
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return Profile(
      name: name ?? this.name,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, Profile>(
  ProfileController.new,
);

class ProfileController extends Notifier<Profile> {
  static const _name = 'profile.name';
  static const _avatar = 'profile.avatar';
  static const _goal = 'profile.goalMinutes';
  static const _theme = 'settings.themeMode';
  static const _sound = 'settings.sound';
  static const _haptics = 'settings.haptics';

  PreferencesStore? get _store => ref.read(preferencesStoreProvider).value;

  @override
  Profile build() {
    // Watched rather than read: if the store is still loading, the profile
    // rebuilds with the saved values as soon as it arrives.
    final store = ref.watch(preferencesStoreProvider).value;
    if (store == null) return const Profile();

    final profile = Profile(
      name: store.getString(_name) ?? '',
      avatarPath: store.getString(_avatar),
      weeklyGoalMinutes: store.getInt(_goal, fallback: 90),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == store.getString(_theme),
        orElse: () => ThemeMode.dark,
      ),
      soundEnabled: store.getBool(_sound, fallback: true),
      hapticsEnabled: store.getBool(_haptics, fallback: true),
    );

    ref.read(audioCueServiceProvider).enabled = profile.soundEnabled;
    return profile;
  }

  void setName(String value) {
    state = state.copyWith(name: value);
    _store?.setString(_name, value);
  }

  void setWeeklyGoal(int minutes) {
    state = state.copyWith(weeklyGoalMinutes: minutes);
    _store?.setInt(_goal, minutes);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _store?.setString(_theme, mode.name);
  }

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    ref.read(audioCueServiceProvider).enabled = value;
    _store?.setBool(_sound, value);
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    _store?.setBool(_haptics, value);
  }

  /// Copies the picked image into the app's own directory, so the avatar
  /// survives the photo being deleted from the library and never needs the
  /// gallery permission again.
  Future<void> setAvatar(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final target = File(
      '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await File(sourcePath).copy(target.path);
    await _deleteAvatarFile();

    state = state.copyWith(avatarPath: target.path);
    await _store?.setString(_avatar, target.path);
  }

  Future<void> removeAvatar() async {
    await _deleteAvatarFile();
    state = state.copyWith(clearAvatar: true);
    await _store?.remove(_avatar);
  }

  Future<void> _deleteAvatarFile() async {
    final previous = state.avatarPath;
    if (previous == null) return;

    try {
      final file = File(previous);
      if (file.existsSync()) await file.delete();
    } on FileSystemException catch (error) {
      // dart format off
      assert(() { debugPrint('could not remove the old avatar: $error'); return true; }());
      // dart format on
    }
  }
}
