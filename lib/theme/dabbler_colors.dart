// =============================================================================
// Dabbler — Color Token System (7 Themes)
// Version 3.0 · color themes reseeded from the Material 3 reference photo
// -----------------------------------------------------------------------------
// The five color themes now carry the photo's exact palettes:
//   Main <- violet · Social <- blue · Sport <- green · Active <- magenta · Bright <- orange
// Ramps are tint/shade generated from each photo seed (core 600 = photo tone-40).
// Simple / Shade remain neutral. Error is the photo's #BA1A1A.
// Mirrors dabbler_tokens.css. Pairs with dabbler_material_scheme.dart (M3).
// =============================================================================

import 'package:flutter/material.dart';

abstract final class DabblerPalette {
  DabblerPalette._();

  // Ink — shared violet-cool neutral
  static const paper  = Color(0xFFFFFFFF);
  static const ink50  = Color(0xFFF5F5F7);
  static const ink100 = Color(0xFFECEBEF);
  static const ink200 = Color(0xFFDCDAE2);
  static const ink300 = Color(0xFFC2BFCB);
  static const ink400 = Color(0xFF9C98A8);
  static const ink500 = Color(0xFF787484);
  static const ink600 = Color(0xFF595663);
  static const ink700 = Color(0xFF3E3B47);
  static const ink800 = Color(0xFF28252F);
  static const ink900 = Color(0xFF1B1B1B);
  static const ink950 = Color(0xFF171123);

  // Brand palettes — generated from the photo seeds
  static const mainP300 = Color(0xFFB289E4);
  static const mainP400 = Color(0xFF9760DB);
  static const mainP600 = Color(0xFF7328CE);
  static const mainP700 = Color(0xFF5A1FA1);
  static const mainS400 = Color(0xFFBC42AC);
  static const mainS600 = Color(0xFFA4008F);
  static const mainS700 = Color(0xFF800070);
  static const socialP300 = Color(0xFF8FB2E9);
  static const socialP400 = Color(0xFF6997E1);
  static const socialP600 = Color(0xFF3473D7);
  static const socialP700 = Color(0xFF295AA8);
  static const socialS400 = Color(0xFF8DBFFF);
  static const socialS600 = Color(0xFF65A8FF);
  static const socialS700 = Color(0xFF4F83C7);
  static const sportP300 = Color(0xFF8FBC92);
  static const sportP400 = Color(0xFF69A56C);
  static const sportP600 = Color(0xFF348638);
  static const sportP700 = Color(0xFF29692C);
  static const sportS400 = Color(0xFF92CE91);
  static const sportS600 = Color(0xFF6CBD6A);
  static const sportS700 = Color(0xFF549353);
  static const activeP300 = Color(0xFFE592BE);
  static const activeP400 = Color(0xFFDB6CA8);
  static const activeP600 = Color(0xFFCF3989);
  static const activeP700 = Color(0xFFA12C6B);
  static const activeS400 = Color(0xFFF04285);
  static const activeS600 = Color(0xFFEB005A);
  static const activeS700 = Color(0xFFB70046);
  static const brightP300 = Color(0xFFFAD09E);
  static const brightP400 = Color(0xFFF8C07D);
  static const brightP600 = Color(0xFFF6AA4F);
  static const brightP700 = Color(0xFFC0853E);
  static const brightS400 = Color(0xFF956C42);
  static const brightS600 = Color(0xFF703900);
  static const brightS700 = Color(0xFF572C00);

  // Semantics (error = photo #BA1A1A)
  static const success100 = Color(0xFFD8EAE0);
  static const success500 = Color(0xFF2E7D5A);
  static const success700 = Color(0xFF1E5640);
  static const warning100 = Color(0xFFFCE7D0);
  static const warning500 = Color(0xFFC2570C);
  static const warning700 = Color(0xFF8A3D08);
  static const error100 = Color(0xFFF6D6D6);
  static const error500 = Color(0xFFBA1A1A);
  static const error700 = Color(0xFF7A0F0F);
  static const info100 = Color(0xFFDBE5FA);
  static const info500 = Color(0xFF2563EB);
  static const info700 = Color(0xFF1A47A8);
  static const spotlight500 = Color(0xFFFF5A1F);

  // Per-theme collision nudges (still apply against the new primaries)
  static const sportSuccess  = Color(0xFF138A66);
  static const socialInfo    = Color(0xFF6366F1);
  static const activeError   = Color(0xFFE5484D);
  static const brightWarning = Color(0xFFA8420A);
}

enum DabblerTheme { main, sport, social, active, bright, simple, shade }
enum DabblerSection { home, sport, social, active }

const Map<DabblerSection, DabblerTheme> kSectionDefaults = {
  DabblerSection.home:   DabblerTheme.main,
  DabblerSection.sport:  DabblerTheme.sport,
  DabblerSection.social: DabblerTheme.social,
  DabblerSection.active: DabblerTheme.active,
};

DabblerTheme resolveTheme(DabblerSection section, {DabblerTheme? userOverride}) =>
    userOverride ?? kSectionDefaults[section] ?? DabblerTheme.main;

@immutable
class DabblerColors extends ThemeExtension<DabblerColors> {
  const DabblerColors({
    required this.theme,
    required this.brandPrimary, required this.brandPrimaryHover, required this.onBrand,
    required this.accent, required this.accentHover, required this.onAccent,
    required this.bgPrimary, required this.bgSecondary, required this.bgTertiary, required this.surfaceCard,
    required this.textPrimary, required this.textSecondary, required this.textTertiary,
    required this.borderDefault, required this.borderStrong, required this.focusRing,
    required this.success, required this.successSurface, required this.onSuccess,
    required this.warning, required this.warningSurface, required this.onWarning,
    required this.error, required this.errorSurface, required this.onError,
    required this.info, required this.infoSurface, required this.onInfo,
    required this.spotlight,
  });

  final DabblerTheme theme;
  final Color brandPrimary, brandPrimaryHover, onBrand;
  final Color accent, accentHover, onAccent;
  final Color bgPrimary, bgSecondary, bgTertiary, surfaceCard;
  final Color textPrimary, textSecondary, textTertiary;
  final Color borderDefault, borderStrong, focusRing;
  final Color success, successSurface, onSuccess;
  final Color warning, warningSurface, onWarning;
  final Color error, errorSurface, onError;
  final Color info, infoSurface, onInfo;
  final Color spotlight;

  static const _mainLight = DabblerColors(
    theme: DabblerTheme.main,
    brandPrimary: _P.mainP600, brandPrimaryHover: _P.mainP700, onBrand: _P.paper,
    accent: _P.mainS600, accentHover: _P.mainS700, onAccent: _P.paper,
    bgPrimary: _P.paper, bgSecondary: _P.ink50, bgTertiary: _P.ink100, surfaceCard: _P.paper,
    textPrimary: _P.ink900, textSecondary: _P.ink600, textTertiary: _P.ink400,
    borderDefault: _P.ink200, borderStrong: _P.ink300, focusRing: _P.mainP400,
    success: _P.success500, successSurface: _P.success100, onSuccess: _P.success700,
    warning: _P.warning500, warningSurface: _P.warning100, onWarning: _P.warning700,
    error: _P.error500, errorSurface: _P.error100, onError: _P.error700,
    info: _P.info500, infoSurface: _P.info100, onInfo: _P.info700,
    spotlight: _P.spotlight500,
  );

  static const _mainDark = DabblerColors(
    theme: DabblerTheme.main,
    brandPrimary: _P.mainP400, brandPrimaryHover: _P.mainP300, onBrand: _P.paper,
    accent: _P.mainS400, accentHover: _P.mainS700, onAccent: _P.paper,
    bgPrimary: _P.ink950, bgSecondary: _P.ink900, bgTertiary: _P.ink800, surfaceCard: _P.ink900,
    textPrimary: _P.ink50, textSecondary: _P.ink300, textTertiary: _P.ink500,
    borderDefault: _P.ink700, borderStrong: _P.ink600, focusRing: _P.mainP400,
    success: _P.success500, successSurface: Color(0xFF14332A), onSuccess: _P.success100,
    warning: _P.warning500, warningSurface: Color(0xFF3A1E08), onWarning: _P.warning100,
    error: _P.error500, errorSurface: Color(0xFF3A1717), onError: _P.error100,
    info: _P.info500, infoSurface: Color(0xFF16243F), onInfo: _P.info100,
    spotlight: _P.spotlight500,
  );

  // Neutral tint seed per theme — backgrounds/surfaces/text derive from this,
  // so nothing is ever pure white or pure black.
  static const Map<DabblerTheme, Color> _neutralSeed = {
    DabblerTheme.main:   Color(0xFF7328CE),
    DabblerTheme.social: Color(0xFF3473D7),
    DabblerTheme.sport:  Color(0xFF348638),
    DabblerTheme.active: Color(0xFFCF3989),
    DabblerTheme.bright: Color(0xFFF6AA4F),
    DabblerTheme.simple: Color(0xFF595663),
    DabblerTheme.shade:  Color(0xFF787484),
  };

  static DabblerColors of(DabblerTheme theme, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = dark ? _mainDark : _mainLight;

    // 1. Brand + nudges per theme (neutrals are replaced in step 2).
    late DabblerColors r;
    switch (theme) {
      case DabblerTheme.main:
        r = base;
      case DabblerTheme.sport:
        r = base.copyWith(
          theme: DabblerTheme.sport,
          brandPrimary: dark ? _P.sportP400 : _P.sportP600,
          brandPrimaryHover: dark ? _P.sportP300 : _P.sportP700,
          onBrand: _P.paper,
          accent: dark ? _P.sportS400 : _P.sportS600,
          accentHover: _P.sportS700, onAccent: _P.ink900,
          focusRing: _P.sportP400,
          success: _P.sportSuccess,
          successSurface: dark ? const Color(0xFF0E3A2E) : const Color(0xFFD2EEE4),
          onSuccess: dark ? const Color(0xFFCDEFE2) : const Color(0xFF0B4A38),
        );
      case DabblerTheme.social:
        r = base.copyWith(
          theme: DabblerTheme.social,
          brandPrimary: dark ? _P.socialP400 : _P.socialP600,
          brandPrimaryHover: dark ? _P.socialP300 : _P.socialP700,
          onBrand: _P.paper,
          accent: dark ? _P.socialS400 : _P.socialS600,
          accentHover: _P.socialS700, onAccent: _P.ink900,
          focusRing: _P.socialP400,
          info: _P.socialInfo,
          infoSurface: dark ? const Color(0xFF1E2150) : const Color(0xFFE0E1FB),
          onInfo: dark ? const Color(0xFFD7D8FB) : const Color(0xFF3A3D9E),
        );
      case DabblerTheme.active:
        r = base.copyWith(
          theme: DabblerTheme.active,
          brandPrimary: dark ? _P.activeP400 : _P.activeP600,
          brandPrimaryHover: dark ? _P.activeP300 : _P.activeP700,
          onBrand: _P.paper,
          accent: dark ? _P.activeS400 : _P.activeS600,
          accentHover: _P.activeS700, onAccent: _P.paper,
          focusRing: _P.activeP400,
          error: _P.activeError,
          errorSurface: dark ? const Color(0xFF3A1717) : _P.error100,
          onError: dark ? _P.error100 : _P.error700,
        );
      case DabblerTheme.bright:
        r = base.copyWith(
          theme: DabblerTheme.bright,
          brandPrimary: dark ? _P.brightP400 : _P.brightP600,
          brandPrimaryHover: dark ? _P.brightP300 : _P.brightP700,
          onBrand: _P.ink900,
          accent: dark ? _P.brightS400 : _P.brightS600,
          accentHover: _P.brightS700, onAccent: _P.paper,
          focusRing: _P.brightP400,
          warning: _P.brightWarning,
          warningSurface: dark ? const Color(0xFF3A1A06) : const Color(0xFFF7DCC8),
          onWarning: dark ? const Color(0xFFF6D9C2) : const Color(0xFF7A2F06),
        );
      case DabblerTheme.simple:
        r = base.copyWith(
          theme: DabblerTheme.simple,
          brandPrimary: dark ? _P.ink50 : _P.ink900,
          brandPrimaryHover: dark ? _P.ink200 : _P.ink700,
          onBrand: dark ? _P.ink900 : _P.ink50,
          accent: dark ? _P.ink300 : _P.ink600,
          accentHover: dark ? _P.ink200 : _P.ink700,
          onAccent: dark ? _P.ink900 : _P.ink50,
          focusRing: dark ? _P.ink300 : _P.ink700,
        );
      case DabblerTheme.shade:
        r = base.copyWith(
          theme: DabblerTheme.shade,
          brandPrimary: dark ? _P.ink600 : _P.ink300,
          brandPrimaryHover: dark ? _P.ink500 : _P.ink400,
          onBrand: dark ? _P.ink200 : _P.ink600,
          accent: dark ? _P.ink700 : _P.ink200,
          accentHover: dark ? _P.ink600 : _P.ink300,
          onAccent: dark ? _P.ink300 : _P.ink600,
          focusRing: dark ? _P.ink500 : _P.ink400,
        );
    }

    // 2. Tinted neutral derived from the theme's own hue — never pure #FFF/#000.
    final seed = _neutralSeed[theme]!;
    Color l(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    const w = Color(0xFFFFFFFF), k = Color(0xFF000000);
    return r.copyWith(
      bgPrimary:     dark ? l(seed, k, .92) : l(seed, w, .975),
      bgSecondary:   dark ? l(seed, k, .88) : l(seed, w, .95),
      bgTertiary:    dark ? l(seed, k, .82) : l(seed, w, .91),
      surfaceCard:   dark ? l(seed, k, .88) : l(seed, w, .99),
      textPrimary:   dark ? l(seed, w, .92) : l(seed, k, .86),
      textSecondary: dark ? l(seed, w, .70) : l(seed, k, .62),
      textTertiary:  dark ? l(seed, w, .50) : l(seed, k, .46),
      borderDefault: dark ? l(seed, k, .78) : l(seed, w, .86),
      borderStrong:  dark ? l(seed, k, .66) : l(seed, w, .74),
    );
  }

  @override
  DabblerColors copyWith({
    DabblerTheme? theme,
    Color? brandPrimary, Color? brandPrimaryHover, Color? onBrand,
    Color? accent, Color? accentHover, Color? onAccent,
    Color? bgPrimary, Color? bgSecondary, Color? bgTertiary, Color? surfaceCard,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? borderDefault, Color? borderStrong, Color? focusRing,
    Color? success, Color? successSurface, Color? onSuccess,
    Color? warning, Color? warningSurface, Color? onWarning,
    Color? error, Color? errorSurface, Color? onError,
    Color? info, Color? infoSurface, Color? onInfo,
    Color? spotlight,
  }) {
    return DabblerColors(
      theme: theme ?? this.theme,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryHover: brandPrimaryHover ?? this.brandPrimaryHover,
      onBrand: onBrand ?? this.onBrand,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      onAccent: onAccent ?? this.onAccent,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      focusRing: focusRing ?? this.focusRing,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      errorSurface: errorSurface ?? this.errorSurface,
      onError: onError ?? this.onError,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      onInfo: onInfo ?? this.onInfo,
      spotlight: spotlight ?? this.spotlight,
    );
  }

  @override
  DabblerColors lerp(ThemeExtension<DabblerColors>? other, double t) {
    if (other is! DabblerColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DabblerColors(
      theme: t < 0.5 ? theme : other.theme,
      brandPrimary: l(brandPrimary, other.brandPrimary),
      brandPrimaryHover: l(brandPrimaryHover, other.brandPrimaryHover),
      onBrand: l(onBrand, other.onBrand),
      accent: l(accent, other.accent),
      accentHover: l(accentHover, other.accentHover),
      onAccent: l(onAccent, other.onAccent),
      bgPrimary: l(bgPrimary, other.bgPrimary),
      bgSecondary: l(bgSecondary, other.bgSecondary),
      bgTertiary: l(bgTertiary, other.bgTertiary),
      surfaceCard: l(surfaceCard, other.surfaceCard),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      borderDefault: l(borderDefault, other.borderDefault),
      borderStrong: l(borderStrong, other.borderStrong),
      focusRing: l(focusRing, other.focusRing),
      success: l(success, other.success),
      successSurface: l(successSurface, other.successSurface),
      onSuccess: l(onSuccess, other.onSuccess),
      warning: l(warning, other.warning),
      warningSurface: l(warningSurface, other.warningSurface),
      onWarning: l(onWarning, other.onWarning),
      error: l(error, other.error),
      errorSurface: l(errorSurface, other.errorSurface),
      onError: l(onError, other.onError),
      info: l(info, other.info),
      infoSurface: l(infoSurface, other.infoSurface),
      onInfo: l(onInfo, other.onInfo),
      spotlight: l(spotlight, other.spotlight),
    );
  }
}

extension DabblerColorsX on BuildContext {
  DabblerColors get dabbler => Theme.of(this).extension<DabblerColors>()!;
}

// Short alias used throughout DabblerColors to reach the palette primitives.
// A type alias (rather than `const _P = DabblerPalette`) is required so that
// `_P.mainP600` resolves to the static member instead of a `Type` value.
typedef _P = DabblerPalette;
