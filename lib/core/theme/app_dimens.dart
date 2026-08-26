import 'package:flutter/material.dart';

/// Spacing scale. Every gap in the app comes from here so rhythm stays even.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  /// Horizontal page padding, wide enough for one-handed reach.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 20);
}

abstract final class Corners {
  static const Radius xs = Radius.circular(9);
  static const Radius sm = Radius.circular(14);
  static const Radius md = Radius.circular(22);
  static const Radius lg = Radius.circular(28);
  static const Radius xl = Radius.circular(34);

  static const BorderRadius cardRadius = BorderRadius.all(md);
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: xl);
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999));
}

abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration normal = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 520);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

abstract final class Layout {
  /// Content never stretches past this, so tablets and landscape stay readable.
  static const double maxContentWidth = 520;

  /// Height reserved for the floating navigation dock.
  static const double dockHeight = 66;
  static const double dockBottomInset = 14;
}
