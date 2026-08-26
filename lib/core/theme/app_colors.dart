import 'package:flutter/material.dart';

/// Raw palette sampled from the illustration set so the interface and the
/// artwork share the same colours. See `tool/palette.dart`.
abstract final class Palette {
  // Deep Navy — road surface, dark backdrops, primary text on cream.
  static const navy900 = Color(0xFF0E1A2C);
  static const navy800 = Color(0xFF13233A);
  static const navy700 = Color(0xFF1B2A4A);
  static const navy600 = Color(0xFF243758);
  static const navy500 = Color(0xFF2F4670);
  static const navy400 = Color(0xFF43598A);

  // Warm Cream — training ground backdrop, light surfaces.
  static const cream50 = Color(0xFFFFF8EC);
  static const cream100 = Color(0xFFFFEFD8);
  static const cream200 = Color(0xFFF6E3C6);
  static const cream300 = Color(0xFFE8D3AE);

  // Bright Yellow — route line, primary action, active tempo.
  static const yellow300 = Color(0xFFFFE066);
  static const yellow400 = Color(0xFFFFD233);
  static const yellow500 = Color(0xFFF5C518);
  static const yellow600 = Color(0xFFE0A800);
  static const yellow700 = Color(0xFFC08800);

  // Accents.
  static const orange = Color(0xFFFF8A1F);
  static const orangeDeep = Color(0xFFEE6A11);
  static const green = Color(0xFF8FBF4F);
  static const greenDeep = Color(0xFF6F9C36);
  static const blue = Color(0xFF7EB6E0);
  static const blueDeep = Color(0xFF4E88BC);

  // Neutrals.
  static const white = Color(0xFFFFFFFF);
  static const gray400 = Color(0xFFA9B2C2);
  static const gray500 = Color(0xFF8A93A5);
  static const gray600 = Color(0xFF6B7488);
  static const red = Color(0xFFE4573D);
}

/// Semantic colours, resolved per theme mode. Widgets read these instead of the
/// raw palette so a single switch keeps light and dark consistent.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.canvasElevated,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentAlt,
    required this.accentSoft,
    required this.onAccent,
    required this.route,
    required this.routeLine,
    required this.danger,
    required this.walk,
    required this.easyRun,
    required this.run,
    required this.fastRun,
    required this.recovery,
    required this.stop,
    required this.shadow,
  });

  /// Dark mode: the night-road look of the artwork, used as the default.
  factory AppColors.dark() => const AppColors(
    canvas: Palette.navy900,
    canvasElevated: Palette.navy800,
    surface: Palette.navy700,
    surfaceMuted: Palette.navy600,
    border: Color(0x1FFFFFFF),
    borderStrong: Color(0x33FFFFFF),
    textPrimary: Palette.cream50,
    textSecondary: Color(0xFFBFC9DA),
    textMuted: Palette.gray500,
    accent: Palette.yellow500,
    accentAlt: Palette.orange,
    accentSoft: Color(0x29F5C518),
    onAccent: Palette.navy900,
    route: Palette.navy600,
    routeLine: Palette.yellow500,
    danger: Palette.red,
    walk: Palette.green,
    easyRun: Palette.blue,
    run: Palette.yellow500,
    fastRun: Palette.orange,
    recovery: Palette.cream200,
    stop: Palette.gray500,
    shadow: Color(0x66000000),
  );

  /// Light mode: the warm training-ground look.
  factory AppColors.light() => const AppColors(
    canvas: Palette.cream50,
    canvasElevated: Palette.cream100,
    surface: Palette.white,
    surfaceMuted: Palette.cream100,
    border: Color(0x1A1B2A4A),
    borderStrong: Color(0x331B2A4A),
    textPrimary: Palette.navy800,
    textSecondary: Palette.navy500,
    textMuted: Palette.gray600,
    accent: Palette.yellow500,
    accentAlt: Palette.orange,
    accentSoft: Color(0x24F5C518),
    onAccent: Palette.navy900,
    route: Palette.navy700,
    routeLine: Palette.yellow600,
    danger: Palette.red,
    walk: Palette.greenDeep,
    easyRun: Palette.blueDeep,
    run: Palette.yellow600,
    fastRun: Palette.orangeDeep,
    recovery: Palette.cream300,
    stop: Palette.gray500,
    shadow: Color(0x1A1B2A4A),
  );

  final Color canvas;
  final Color canvasElevated;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentAlt;
  final Color accentSoft;
  final Color onAccent;
  final Color route;
  final Color routeLine;
  final Color danger;
  final Color walk;
  final Color easyRun;
  final Color run;
  final Color fastRun;
  final Color recovery;
  final Color stop;
  final Color shadow;

  /// Warm sweep used on primary actions and highlights. Two stops rather than a
  /// flat fill so the moulded artwork and the interface share a light source.
  LinearGradient get accentSweep => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentAlt],
  );

  /// Barely-there sheen on panels, which keeps large cards from reading flat.
  LinearGradient surfaceSheen({Color? base}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.alphaBlend(Colors.white.withValues(alpha: 0.05), base ?? surface),
      base ?? surface,
    ],
  );

  @override
  AppColors copyWith({
    Color? canvas,
    Color? canvasElevated,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentAlt,
    Color? accentSoft,
    Color? onAccent,
    Color? route,
    Color? routeLine,
    Color? danger,
    Color? walk,
    Color? easyRun,
    Color? run,
    Color? fastRun,
    Color? recovery,
    Color? stop,
    Color? shadow,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      canvasElevated: canvasElevated ?? this.canvasElevated,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      route: route ?? this.route,
      routeLine: routeLine ?? this.routeLine,
      danger: danger ?? this.danger,
      walk: walk ?? this.walk,
      easyRun: easyRun ?? this.easyRun,
      run: run ?? this.run,
      fastRun: fastRun ?? this.fastRun,
      recovery: recovery ?? this.recovery,
      stop: stop ?? this.stop,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      canvas: mix(canvas, other.canvas),
      canvasElevated: mix(canvasElevated, other.canvasElevated),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      accent: mix(accent, other.accent),
      accentAlt: mix(accentAlt, other.accentAlt),
      accentSoft: mix(accentSoft, other.accentSoft),
      onAccent: mix(onAccent, other.onAccent),
      route: mix(route, other.route),
      routeLine: mix(routeLine, other.routeLine),
      danger: mix(danger, other.danger),
      walk: mix(walk, other.walk),
      easyRun: mix(easyRun, other.easyRun),
      run: mix(run, other.run),
      fastRun: mix(fastRun, other.fastRun),
      recovery: mix(recovery, other.recovery),
      stop: mix(stop, other.stop),
      shadow: mix(shadow, other.shadow),
    );
  }
}
