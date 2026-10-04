import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// HueTone — a four-colour tint family generated from one hue: the pale
/// [surface] a card is filled with, its [edge] stroke, the saturated [solid]
/// used for the selected border and check, and the [deep] glyph colour.
///
/// The onboarding sport tiles, the primary-sport rows and the gender cards
/// are each tinted with their own hue rather than the brand
/// (`Auth and Onboarding.dc.html:1171-1185`, the `SPORT_HUE` table and the
/// `tone()` function; `:1975-1985` for the two gender hues). The source
/// pins these as `oklch()` literals because the token set has no per-sport
/// or per-gender colour; this class is that role. It holds the four
/// lightness/chroma pairs and the hue tables, and converts to sRGB once, so
/// no screen carries a colour literal.
///
/// ```dart
/// final tone = DabblerHueTone.forSport(DabblerSport.padel);
/// ```
///
/// | role | oklch L C | source |
/// |---|---|---|
/// | [surface] | 0.945 0.052 | `tone().surface` (`:1178`) |
/// | [edge] | 0.882 0.078 | `tone().edge` (`:1179`) |
/// | [solid] | 0.455 0.135 | `tone().solid` (`:1180`) |
/// | [deep] | 0.42 0.13 | `tone().deep` (`:1181`) |
///
/// The gender tints use a lower surface chroma (0.035) and edge chroma
/// (0.06) than the sport family (`:1983-1985`); [DabblerHueTone.gender]
/// carries those.
///
/// **Light only.** The source defines no dark values for either family; the
/// light colours are used in dark mode too, as the source's inline literals
/// would be.
@immutable
class DabblerHueTone {
  /// A tone from explicit colours.
  const DabblerHueTone({
    required this.surface,
    required this.edge,
    required this.solid,
    required this.deep,
    Color? idle,
  }) : idle = idle ?? deep;

  /// A tone tinted from a palette ramp, for cards that follow a persona's
  /// ramp rather than a hue: [base] (the ramp's 600 step) mixed over
  /// [card] at 12% for the surface and 30% for the edge, [deep] (the 700
  /// step) for the selected stroke and glyph, and [base] at 45% for the idle
  /// radio (`Auth and Onboarding.dc.html:1999-2016`, `personaCards`).
  factory DabblerHueTone.ramp({
    required Color base,
    required Color deep,
    required Color card,
  }) => DabblerHueTone(
    surface: Color.alphaBlend(base.withValues(alpha: 0.12), card),
    edge: Color.alphaBlend(base.withValues(alpha: 0.30), card),
    solid: deep,
    deep: deep,
    idle: Color.alphaBlend(base.withValues(alpha: 0.45), card),
  );

  /// The tone for an oklch [hue] (degrees) with the sport-family
  /// lightness and chroma.
  factory DabblerHueTone.hue(double hue) => DabblerHueTone(
    surface: _oklch(0.945, 0.052, hue),
    edge: _oklch(0.882, 0.078, hue),
    solid: _oklch(0.455, 0.135, hue),
    deep: _oklch(0.42, 0.13, hue),
  );

  /// The tone for a gender card; [hue] is [maleHue] or [femaleHue].
  factory DabblerHueTone.gender(double hue) => DabblerHueTone(
    surface: _oklch(0.96, 0.035, hue),
    edge: _oklch(0.882, 0.06, hue),
    solid: _oklch(0.455, 0.135, hue),
    deep: _oklch(0.455, 0.135, hue),
  );

  /// The tone for a sport by its kebab-case key (`padel`, `table-tennis`).
  /// A sport the table does not know takes [fallbackHue], as the source's
  /// `tone()` does for an unknown id.
  factory DabblerHueTone.forSportKey(String? key) =>
      DabblerHueTone.hue(sportHues[key] ?? fallbackHue);

  /// The pale card fill.
  final Color surface;

  /// The idle 1px stroke.
  final Color edge;

  /// The selected 2px stroke and the check.
  final Color solid;

  /// The glyph colour.
  final Color deep;

  /// The unselected radio colour; [deep] unless a ramp tone sets it.
  final Color idle;

  /// The hue of the male gender card, `233`.
  static const double maleHue = 233;

  /// The hue of the female gender card, `350`.
  static const double femaleHue = 350;

  /// The hue of a sport the table does not list, `268` (`:1176`).
  static const double fallbackHue = 268;

  /// The source's `SPORT_HUE` (`:1171-1174`), keyed by sport key.
  static const Map<String, double> sportHues = <String, double>{
    'football': 152,
    'padel': 196,
    'tennis': 118,
    'cricket': 62,
    'basketball': 38,
    'volleyball': 12,
    'badminton': 330,
    'running': 268,
    'cycling': 242,
    'gym': 300,
    'swimming': 218,
    'boxing': 358,
  };

  /// Converts an oklch colour to sRGB, clipping to the gamut.
  static Color _oklch(double l, double c, double hueDegrees) {
    final double h = hueDegrees * math.pi / 180;
    final double a = c * math.cos(h);
    final double b = c * math.sin(h);
    final double l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    final double m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    final double s_ = l - 0.0894841775 * a - 1.2914855480 * b;
    final double ll = l_ * l_ * l_;
    final double mm = m_ * m_ * m_;
    final double ss = s_ * s_ * s_;
    final double r = 4.0767416621 * ll - 3.3077115913 * mm + 0.2309699292 * ss;
    final double g = -1.2684380046 * ll + 2.6097574011 * mm - 0.3413193965 * ss;
    final double bl =
        -0.0041960863 * ll - 0.7034186147 * mm + 1.7076147010 * ss;
    double enc(double v) {
      final double x = v.clamp(0.0, 1.0);
      return x <= 0.0031308 ? 12.92 * x : 1.055 * math.pow(x, 1 / 2.4) - 0.055;
    }

    return Color.from(alpha: 1, red: enc(r), green: enc(g), blue: enc(bl));
  }

  @override
  bool operator ==(Object other) =>
      other is DabblerHueTone &&
      other.surface == surface &&
      other.edge == edge &&
      other.solid == solid &&
      other.deep == deep;

  @override
  int get hashCode => Object.hash(surface, edge, solid, deep);
}
