// =============================================================================
// Dabbler — Forui adapter
// -----------------------------------------------------------------------------
// Maps the active Material [ThemeData] (its photo-seeded ColorScheme + the
// DabblerColors token extension) into a Forui [FThemeData], so Forui widgets
// and Material widgets render with the *same* colours for a given theme.
//
// Wire it once in MaterialApp.builder:
//
//   builder: (context, child) => FTheme(
//     data: dabblerForuiThemeData(Theme.of(context)),
//     child: child!,
//   ),
//
// Because it reads straight from Theme.of(context), it automatically tracks
// section / user-override / light-dark changes — there is a single source of
// truth (the Material ThemeData built by dabblerThemeData()).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'dabbler_colors.dart';
import 'dabbler_type.dart';

/// Builds an [FThemeData] that mirrors the colours of [material].
FThemeData dabblerForuiThemeData(ThemeData material) {
  final scheme = material.colorScheme;
  final tokens = material.extension<DabblerColors>()!;
  final dark = material.brightness == Brightness.dark;

  final colors = FColors(
    brightness: material.brightness,
    systemOverlayStyle:
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    // Modal scrim — a translucent tint of the theme's own ink, never pure black.
    barrier: tokens.textPrimary.withValues(alpha: 0.5),
    background: tokens.bgPrimary,
    foreground: tokens.textPrimary,
    primary: scheme.primary,
    primaryForeground: scheme.onPrimary,
    secondary: scheme.secondaryContainer,
    secondaryForeground: scheme.onSecondaryContainer,
    muted: tokens.bgTertiary,
    mutedForeground: tokens.textSecondary,
    destructive: scheme.error,
    destructiveForeground: scheme.onError,
    error: scheme.error,
    errorForeground: scheme.onError,
    card: tokens.surfaceCard,
    border: tokens.borderDefault,
  );

  // Forui needs to know whether this is a touch device to pick its hit targets.
  const touchPlatforms = <TargetPlatform>{
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.fuchsia,
  };
  final touch = touchPlatforms.contains(material.platform);

  // Make Forui text use the same family as the Material text theme (Readex Pro)
  // so Forui and Material widgets render with matching type. Forui keeps its own
  // size scale; only the family is swapped onto it.
  final typeface = FTypeface.inherit(
    colors: colors,
    touch: touch,
    fontFamily: kDabblerFontFamily,
  );
  final typography = FTypography(display: typeface, body: typeface);

  return FThemeData(
    colors: colors,
    touch: touch,
    typography: typography,
  );
}
