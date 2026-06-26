// =============================================================================
// Dabbler — ThemeData builder
// -----------------------------------------------------------------------------
// Turns a (DabblerTheme, Brightness) pair into a ready-to-use Material 3
// ThemeData:
//   • colorScheme  : dabblerColorScheme(theme, brightness)   (M3, photo-seeded)
//   • extensions   : [DabblerColors.of(theme, brightness)]   (Dabbler tokens)
//   • useMaterial3 : true
//
// The Material neutral roles (surface / onSurface / containers / outlines) are
// re-pointed at the Dabbler *tinted* neutrals so that plain Material widgets
// (Card, AppBar, Scaffold…) inherit the same faint-tint backgrounds as widgets
// that read context.dabbler. Nothing here is ever pure #FFFFFF / #000000.
//
// Screen code should read:
//   • Material roles  via Theme.of(context).colorScheme
//   • Dabbler tokens  via context.dabbler
// =============================================================================

import 'package:flutter/material.dart';

import 'dabbler_colors.dart';
import 'dabbler_material_scheme.dart';
import 'dabbler_type.dart';

/// Builds the full [ThemeData] for a [theme] at the given [brightness].
///
/// [locale] selects the typography variant — Arabic (`ar`) gets a slightly
/// taller leading (see [dabblerTextTheme]); everything else uses the Latin ramp.
ThemeData dabblerThemeData(
  DabblerTheme theme,
  Brightness brightness, {
  Locale locale = const Locale('en'),
}) {
  final tokens = DabblerColors.of(theme, brightness);
  final base = dabblerColorScheme(theme, brightness);

  // Re-point the neutral roles at the Dabbler tinted neutrals so Material
  // surfaces match the design tokens (and never go pure white/black). Brand
  // and semantic roles are left to the photo-seeded M3 scheme.
  final scheme = base.copyWith(
    surface: tokens.bgPrimary,
    onSurface: tokens.textPrimary,
    onSurfaceVariant: tokens.textSecondary,
    surfaceContainerLowest: tokens.surfaceCard,
    surfaceContainerLow: tokens.bgPrimary,
    surfaceContainer: tokens.bgSecondary,
    surfaceContainerHigh: tokens.bgSecondary,
    surfaceContainerHighest: tokens.bgTertiary,
    outline: tokens.borderStrong,
    outlineVariant: tokens.borderDefault,
  );

  // Apple HIG ramp (Readex Pro) bound to the active scheme's on-surface colour.
  final isArabic = locale.languageCode == 'ar';
  final textTheme = dabblerTextTheme(arabic: isArabic)
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: <ThemeExtension<dynamic>>[tokens],
    fontFamily: kDabblerFontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: tokens.bgPrimary,
    canvasColor: tokens.bgPrimary,
    dividerColor: tokens.borderDefault,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bgPrimary,
      foregroundColor: tokens.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      color: tokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tokens.borderDefault),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerTheme: DividerThemeData(color: tokens.borderDefault, space: 1, thickness: 1),
  );
}
