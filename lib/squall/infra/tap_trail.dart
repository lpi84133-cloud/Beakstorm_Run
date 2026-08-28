import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class TapTrailReader {
  static const String dartKey = 'bsr_tap_trail';

  static Future<String?> consume() async {
    if (!Platform.isIOS) return null;
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(dartKey)?.trim();
      if (value == null || value.isEmpty) return null;
      await preferences.remove(dartKey);
      return value;
    } catch (_) {
      return null;
    }
  }
}
