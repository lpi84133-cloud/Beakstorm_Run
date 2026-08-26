import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded once during startup; every later read is served from the Riverpod
/// cache, so screens can treat it as ready.
final preferencesStoreProvider = FutureProvider<PreferencesStore>((ref) async {
  return PreferencesStore(await SharedPreferences.getInstance());
});

/// Thin wrapper around [SharedPreferences] for small scalar settings. Anything
/// list-shaped or queryable belongs in the database instead.
class PreferencesStore {
  const PreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  bool getBool(String key, {required bool fallback}) =>
      _prefs.getBool(key) ?? fallback;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  int getInt(String key, {required int fallback}) =>
      _prefs.getInt(key) ?? fallback;

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
