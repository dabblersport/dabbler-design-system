// =============================================================================
// Dabbler — Material 3 ColorScheme (seeded from the reference photo)
// Version 3.0 · the five photo palettes are now canonical for color themes
// -----------------------------------------------------------------------------
// Each color theme is keyed on the EXACT colors pixel-sampled from the Material
// Theme Builder reference photo, then expanded by Flutter's own M3 tonal
// algorithm — so the full role set (containers, surfaces, fixed, inverse)
// reproduces the photo rather than being hand-mapped.
//
//   Main   <- violet palette   (#7328CE / #A4008F / #FF3376)
//   Social <- blue palette     (#3473D7 / #65A8FF / #855BE2)
//   Sport  <- green palette     (#348638 / #6CBD6A / #0050B6)
//   Active <- magenta palette   (#CF3989 / #EB005A / #ADB4FF)
//   Bright <- orange palette    (#F6AA4F / #703900 / #AD8A67)
//   Simple / Shade -> neutral (no photo palette)
//
// Requires Flutter >= 3.22.2 (key-color overrides on ColorScheme.fromSeed).
//
//   ThemeData(useMaterial3: true,
//             colorScheme: dabblerColorScheme(theme, brightness));
//
// NOTE: this supersedes the custom brand palettes in dabbler_colors.dart /
// dabbler_tokens.css for color purposes. Those files should be re-synced to
// these five palettes so every layer agrees.
// =============================================================================

import 'package:flutter/material.dart';
import 'dabbler_colors.dart' show DabblerTheme, DabblerSection, resolveTheme;

class _Palette {
  final Color primary, secondary, tertiary, error;
  const _Palette(this.primary, this.secondary, this.tertiary, this.error);
}

// Exact tone-40 role values sampled from the photo.
const Color _photoError = Color(0xFFBA1A1A);

const Map<DabblerTheme, _Palette> _photo = {
  DabblerTheme.main:   _Palette(Color(0xFF7328CE), Color(0xFFA4008F), Color(0xFFFF3376), _photoError),
  DabblerTheme.social: _Palette(Color(0xFF3473D7), Color(0xFF65A8FF), Color(0xFF855BE2), _photoError),
  DabblerTheme.sport:  _Palette(Color(0xFF348638), Color(0xFF6CBD6A), Color(0xFF0050B6), _photoError),
  DabblerTheme.active: _Palette(Color(0xFFCF3989), Color(0xFFEB005A), Color(0xFFADB4FF), _photoError),
  DabblerTheme.bright: _Palette(Color(0xFFF6AA4F), Color(0xFF703900), Color(0xFFAD8A67), _photoError),
};

ColorScheme dabblerColorScheme(DabblerTheme theme, Brightness brightness) {
  final p = _photo[theme];

  // Neutral themes (Simple / Shade) — no photo palette.
  if (p == null) {
    final seed = theme == DabblerTheme.simple
        ? const Color(0xFF5B5B66) // near-neutral, high-contrast
        : const Color(0xFF8E8B97); // softer grey-violet
    return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  }

  // Color themes — key M3 on the exact photo colors so all roles match.
  return ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: brightness,
    primary: p.primary,
    secondary: p.secondary,
    tertiary: p.tertiary,
    error: p.error,
  );
}

// Resolve via section + optional user override.
ColorScheme dabblerColorSchemeFor(
  DabblerSection section,
  Brightness brightness, {
  DabblerTheme? userOverride,
}) =>
    dabblerColorScheme(resolveTheme(section, userOverride: userOverride), brightness);
