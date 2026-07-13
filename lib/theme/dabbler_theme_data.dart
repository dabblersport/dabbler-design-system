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
import 'dabbler_spacing.dart';
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

  // Flat elevation everywhere except the floating surfaces (dialogs / sheets /
  // menus), which are the ONLY things allowed to cast a shadow. surfaceTintColor
  // is forced transparent so M3's tonal-elevation tint never fights the tinted
  // neutrals. Custom floating surfaces use DabblerElevation.level2 directly.
  const flat = 0.0;
  const floating = 6.0;
  const flatButton = ButtonStyle(
    elevation: WidgetStatePropertyAll(flat),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
  );

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
    shadowColor: DabblerElevation.shadowInk,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bgPrimary,
      foregroundColor: tokens.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: flat,
      scrolledUnderElevation: flat,
    ),
    cardTheme: CardThemeData(
      color: tokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: flat,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tokens.borderDefault, width: DabblerSizing.borderHairline),
        borderRadius: DabblerRadius.lgRadius,
      ),
    ),
    // Material ListTiles inherit flat, base-3 metrics so any that slip in match
    // DabblerListTile (which is what screens should use).
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedColor: tokens.brandPrimary,
      iconColor: tokens.textSecondary,
      textColor: tokens.textPrimary,
      minVerticalPadding: DabblerSpacing.space3, // 9
      horizontalTitleGap: DabblerSpacing.space3, // 9
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space4, // 12
      ),
    ),
    // Floating surfaces — the only shadow in the system (≈ DabblerElevation.level2).
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: floating,
      shadowColor: DabblerElevation.shadowInk,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tokens.borderDefault, width: DabblerSizing.borderHairline),
        borderRadius: DabblerRadius.xlRadius,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: floating,
      modalElevation: floating,
      shadowColor: DabblerElevation.shadowInk,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DabblerRadius.xl)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: tokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: floating,
      shadowColor: DabblerElevation.shadowInk,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tokens.borderDefault, width: DabblerSizing.borderHairline),
        borderRadius: DabblerRadius.mdRadius,
      ),
    ),
    // Flat navigation surfaces — no shadow, no tint.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: flat,
      shadowColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: tokens.bgPrimary,
      elevation: flat,
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(style: flatButton),
    filledButtonTheme: const FilledButtonThemeData(style: flatButton),
    dividerTheme: DividerThemeData(
      color: tokens.borderDefault,
      space: 1,
      thickness: DabblerSizing.borderDefault,
    ),
  );
}
