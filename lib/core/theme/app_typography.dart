import 'package:flutter/material.dart';

/// Bundled locally so text renders identically offline and on first launch.
const String kFontFamily = 'PlusJakartaSans';

/// Digits that never shift width, so the running timer does not jitter.
const List<FontFeature> kTabularFigures = [FontFeature.tabularFigures()];

abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle base(
      double size,
      FontWeight weight, {
      double? height,
      double? spacing,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: kFontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      // Timer and other large read-at-a-glance numbers.
      displayLarge: base(
        64,
        FontWeight.w800,
        height: 1.0,
        spacing: -1.5,
      ).copyWith(fontFeatures: kTabularFigures),
      displayMedium: base(
        44,
        FontWeight.w800,
        height: 1.05,
        spacing: -1,
      ).copyWith(fontFeatures: kTabularFigures),
      displaySmall: base(
        32,
        FontWeight.w800,
        height: 1.1,
        spacing: -0.6,
      ).copyWith(fontFeatures: kTabularFigures),

      headlineMedium: base(28, FontWeight.w800, height: 1.12, spacing: -0.6),
      headlineSmall: base(22, FontWeight.w800, height: 1.18, spacing: -0.3),

      titleLarge: base(18, FontWeight.w700, height: 1.25),
      titleMedium: base(16, FontWeight.w600, height: 1.3),
      titleSmall: base(14, FontWeight.w600, height: 1.35),

      bodyLarge: base(16, FontWeight.w500, height: 1.45, color: secondary),
      bodyMedium: base(14, FontWeight.w500, height: 1.5, color: secondary),
      bodySmall: base(12.5, FontWeight.w500, height: 1.45, color: secondary),

      labelLarge: base(15, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelMedium: base(13, FontWeight.w600, height: 1.2, spacing: 0.2),
      // Section eyebrows and dock captions.
      labelSmall: base(
        11,
        FontWeight.w800,
        height: 1.2,
        spacing: 1.2,
        color: secondary,
      ),
    );
  }
}
