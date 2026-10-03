import 'package:flutter/material.dart' show Brightness, Color, Colors;

import 'dabbler_palette.dart';

/// The overlay scrim, available **without a [BuildContext]**.
///
/// `--color-scrim` (`tokens/colors.css`) is ink at 45% in light and
/// `--ink-950` at 65% in dark. [DabblerColors.scrim] is the themed read of it;
/// this class is the same two values for code that has no theme to read — a
/// route's `barrierColor`, for instance, which `PageRoute` asks for before any
/// widget of the route is built.
///
/// The scrim does **not** vary by [DabblerTheme]: all seven themes share it,
/// so one value per brightness is the whole token. [DabblerColors.resolve]
/// reads its scrim from here, so the two can never drift; a test asserts they
/// are equal for every theme and brightness.
///
/// These are `static final`, not `const`: they are computed from the palette
/// with [Color.withValues], which Dart cannot evaluate at compile time, and
/// writing the blended hex out would be a second source for the same value.
abstract final class DabblerScrimColors {
  /// The scrim in light: `--ink` at 45%.
  static final Color light = DabblerPalette.ink.withValues(alpha: 0.45);

  /// The scrim in dark: `--ink-950` at 65%.
  static final Color dark = DabblerPalette.ink950.withValues(alpha: 0.65);

  /// A fully transparent barrier — for a route that must keep the barrier
  /// (dismiss on tap) without dimming what is behind it.
  static const Color none = Colors.transparent;

  /// Alias of [none], for call sites that read better as "transparent".
  static const Color transparent = none;

  /// The scrim for [brightness].
  static Color colorFor(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
