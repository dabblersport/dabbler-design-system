part of 'bottom_bar.dart';

/// The plate behind a create-menu tile's glyph (DSG-NEW-001).
///
/// The Home Feed design overrides the bar's neutral plate per tile:
/// `[role="menu"] > button:nth-child(1..3) > span:first-child` take
/// `--tile-info-surface`, `--color-status-success-surface` and
/// `--tile-accent-surface`. Each value maps to an existing [DabblerColors]
/// role; the glyph ink is unchanged ([DabblerColors.textPrimary]), because the
/// design overrides only the background.
enum DabblerNavigationIconTone {
  /// [DabblerColors.surfaceSunken] — today's plate, and the default.
  neutral,

  /// [DabblerColors.tileInfo] surface — `--tile-info-surface`.
  info,

  /// [DabblerStatusColor.surface] of `success` —
  /// `--color-status-success-surface`.
  success,

  /// [DabblerColors.tileAccent] surface — `--tile-accent-surface`.
  accent,

  /// [DabblerColors.tileAmber] surface — `--tile-amber-surface`. Not used by
  /// the Home Feed design; offered because it is the third decorative tile
  /// role and completes the set.
  amber,
}

/// The plate fill for [tone], resolved off [colors].
///
/// The decorative `--tile-*-surface` values are light-only pastels. Under the
/// dark ramp the glyph ink ([DabblerColors.textPrimary]) is light, so a pale
/// plate would leave it at about 1.2:1; the dark ramp therefore takes each
/// tile's dark surface ([DabblerProvisionalDark.tileInfoSurface] and its
/// siblings), the depth of the success plate's dark status surface.
/// `test/navigation/bottom_bar_tone_contrast_test.dart` pins the glyph's
/// contrast on every plate in both brightnesses.
Color dabblerNavigationIconPlateFor(
  DabblerNavigationIconTone tone,
  DabblerColors colors,
) {
  final bool dark = colors.brightness == Brightness.dark;
  return switch (tone) {
    DabblerNavigationIconTone.neutral => colors.surfaceSunken,
    DabblerNavigationIconTone.info =>
      dark
          ? DabblerProvisionalDark.tileInfoSurface
          : DabblerColors.tileInfo.surface,
    DabblerNavigationIconTone.success => colors.success.surface,
    DabblerNavigationIconTone.accent =>
      dark
          ? DabblerProvisionalDark.tileAccentSurface
          : DabblerColors.tileAccent.surface,
    DabblerNavigationIconTone.amber =>
      dark
          ? DabblerProvisionalDark.tileAmberSurface
          : DabblerColors.tileAmber.surface,
  };
}
