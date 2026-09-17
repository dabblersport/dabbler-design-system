import 'package:flutter/material.dart';

import 'dabbler_dark_provisional.dart';
import 'dabbler_palette.dart';

/// The seven Dabbler section themes.
///
/// Transcribed from the `[data-theme]` blocks of the design source
/// `tokens/colors.css`. The list is exhaustive: `main` is the default and the
/// other six re-tint the **brand** only. `simple` and `shade` carry no brand
/// ramp of their own and resolve through the shared ink ramp.
enum DabblerTheme {
  /// `[data-theme]` unset — the `:root` default. Purple.
  main,
  /// `[data-theme="sport"]`. Green.
  sport,
  /// `[data-theme="social"]`. Blue.
  social,
  /// `[data-theme="active"]`. Pink.
  active,
  /// `[data-theme="bright"]`. Amber.
  bright,
  /// `[data-theme="simple"]`. Near-black on paper.
  simple,
  /// `[data-theme="shade"]`. Low-contrast grey, for de-emphasised surfaces.
  shade,
}

/// The four status tones of the `--color-status-*` API.
enum DabblerStatusTone {
  /// `--color-status-success-*`.
  success,
  /// `--color-status-warning-*`.
  warning,
  /// `--color-status-error-*`.
  error,
  /// `--color-status-info-*`.
  info,
}

/// One resolved status tone: the four roles the design source declares per
/// tone, carried together as a single value.
///
/// This is a **type distinct from [Color] on purpose**. A status is not a
/// colour — it is a set of four colours that only make sense together, and a
/// component that takes a status (`Badge.status`, DS-502) must not be handed
/// an arbitrary [Color], because a bare colour cannot answer "what ink goes on
/// you" or "what fill carries white text". Passing a [Color] where a
/// [DabblerStatusColor] is required is a compile error, and a
/// [DabblerStatusColor] is never `==` to a [Color], however its fields are
/// valued.
///
/// Roles, from `tokens/colors.css:118-131`:
/// * [base] — the bare indicator (`--color-status-<tone>`). An indicator only;
///   white on it measures 2.1–3.8:1, which is why [solid] exists.
/// * [surface] — the tint background (`-surface`).
/// * [strong] — the status **ink** (`-strong`). Theme- and mode-aware, legible
///   both on [surface] and on a neutral card.
/// * [solid] — the fill for solid controls carrying white text (`-solid`).
///   Fixed at the 700 shade in both brightnesses, where white clears 6.7:1.
@immutable
class DabblerStatusColor {
  /// Creates a status tone from its four roles.
  const DabblerStatusColor({
    required this.base,
    required this.surface,
    required this.strong,
    required this.solid,
  });

  /// `--color-status-<tone>` — the bare indicator.
  final Color base;

  /// `--color-status-<tone>-surface` — the tint background.
  final Color surface;

  /// `--color-status-<tone>-strong` — the status ink.
  final Color strong;

  /// `--color-status-<tone>-solid` — the fill that carries white text.
  final Color solid;

  @override
  bool operator ==(Object other) =>
      other is DabblerStatusColor &&
      other.base == base &&
      other.surface == surface &&
      other.strong == strong &&
      other.solid == solid;

  @override
  int get hashCode => Object.hash(base, surface, strong, solid);
}

/// A surface-and-ink pair: the shape of both the seven workflow **tags** and
/// the three decorative **tiles**.
///
/// Like [DabblerStatusColor] this is deliberately not a [Color]. The two uses
/// are kept apart by the field that exposes them, never by the type: a tag
/// carries workflow meaning, a tile carries none. `tokens/colors.css:92-104`
/// is explicit that the tile tones are decorative and are **not** part of the
/// `--color-status-*` API.
@immutable
class DabblerToneColor {
  /// Creates a tone from its surface and its ink.
  const DabblerToneColor({required this.surface, required this.ink});

  /// The fill.
  final Color surface;

  /// The label colour that sits on [surface].
  final Color ink;

  @override
  bool operator ==(Object other) =>
      other is DabblerToneColor && other.surface == surface && other.ink == ink;

  @override
  int get hashCode => Object.hash(surface, ink);
}

/// The semantic colour API of the Dabbler design system.
///
/// Every component in the package resolves its colours through this extension
/// and never through [DabblerPalette], which is the primitive layer. Reach it
/// with [DabblerColors.of]:
///
/// ```dart
/// final DabblerColors colors = DabblerColors.of(context);
/// ColoredBox(color: colors.surfaceCard, child: …);
/// ```
///
/// ## 14 instances, not 14 palettes
///
/// Seven themes × two brightnesses = 14 distinct resolutions, each reachable
/// through `Theme.of(context).extension<DabblerColors>()`. They are *not* 14
/// independent colour schemes: at a given brightness all seven share one
/// background, card, ink and border ramp byte for byte. The design source
/// states the rule directly (`tokens/colors.css:64`): *"Neutrals are the Figma
/// paper ramp — literal, shared, never a brand tint"*, and
/// `tokens/colors.css:28-31`: the section themes re-tint the **brand**, never
/// the paper. Only [brandPrimary], [brandPrimaryHover], [onBrand], [accent],
/// [accentHover], [onAccent], [focusRing] and the four per-theme status
/// overrides vary across themes.
///
/// ## Dark is provisional
///
/// Every dark hex is declared once, in [DabblerProvisionalDark], and is
/// inferred rather than signed off — see [dabblerDarkRampProvisional]. The
/// *structure* is final; the values are not.
///
/// ## Deviations from a generated `ThemeExtension`
///
/// [copyWith] takes `theme` and `brightness` rather than one named argument per
/// role, and [lerp] snaps at `t == 0.5` instead of interpolating. Both are
/// deliberate: an instance is wholly determined by its `(theme, brightness)`
/// pair, so a per-field `copyWith` would let a caller assemble a combination
/// the design source does not define, and interpolating would paint colours
/// that are in no token file. A theme change is a cut, not a cross-fade.
@immutable
class DabblerColors extends ThemeExtension<DabblerColors> {
  const DabblerColors._({
    required this.theme, required this.brightness, required this.brandPrimary,
    required this.brandPrimaryHover, required this.onBrand, required this.accent,
    required this.accentHover, required this.onAccent, required this.focusRing,
    required this.bgPrimary, required this.bgSecondary, required this.bgTertiary,
    required this.surfaceCard, required this.surfaceSunken, required this.surfaceGrey,
    required this.textPrimary, required this.textSecondary, required this.textTertiary,
    required this.borderDefault, required this.borderStrong, required this.success,
    required this.warning, required this.error, required this.info,
    required this.spotlight, required this.scrim,
  });

  /// The section theme this instance resolves.
  final DabblerTheme theme;
  /// The brightness this instance resolves.
  final Brightness brightness;

  // --- Brand roles. THE ONLY ROLES THAT VARY BY THEME. ---

  /// `--color-brand-primary`.
  final Color brandPrimary;
  /// `--color-brand-primary-hover`.
  final Color brandPrimaryHover;
  /// `--color-on-brand` — the ink that sits on [brandPrimary].
  final Color onBrand;
  /// `--color-accent` (the source's `--t-secondary`).
  final Color accent;
  /// `--color-accent-hover`.
  final Color accentHover;
  /// `--color-on-accent` — the ink that sits on [accent].
  final Color onAccent;
  /// `--color-focus-ring` — the visible focus indicator.
  final Color focusRing;

  // --- Paper. Shared by all seven themes at a given brightness. ---

  /// `--color-bg-primary` — the app background.
  final Color bgPrimary;
  /// `--color-bg-secondary` — tonal background.
  final Color bgSecondary;
  /// `--color-bg-tertiary` — faint fill / divider.
  final Color bgTertiary;
  /// `--color-surface-card` — elevated card, sheet, tab bar.
  final Color surfaceCard;
  /// `--color-surface-sunken` — tonal card, list row.
  final Color surfaceSunken;
  /// `--color-surface-grey` — neutral inset panel.
  final Color surfaceGrey;
  /// `--color-text-primary`.
  final Color textPrimary;
  /// `--color-text-secondary` — muted / secondary text.
  final Color textSecondary;
  /// `--color-text-tertiary` — subtle text, placeholder.
  final Color textTertiary;
  /// `--color-border-default` — the card border outline.
  final Color borderDefault;
  /// `--color-border-strong` — emphasised outline.
  final Color borderStrong;

  // --- Status ---

  /// `--color-status-success-*`. Overridden by the `sport` theme.
  final DabblerStatusColor success;
  /// `--color-status-warning-*`. Overridden by the `bright` theme.
  final DabblerStatusColor warning;
  /// `--color-status-error-*`. Overridden by the `active` theme.
  final DabblerStatusColor error;
  /// `--color-status-info-*`. Overridden by the `social` theme.
  final DabblerStatusColor info;
  /// `--color-spotlight` — the single attention accent. Never a status.
  final Color spotlight;
  /// `--color-scrim` — the wash behind every overlay (Sheet, Dialog, mobile
  /// Menu). Ink at 45% in light, `--ink-950` at 65% in dark. Overlays consume
  /// this and never invent their own opacity.
  final Color scrim;

  /// The status tone for [tone].
  DabblerStatusColor status(DabblerStatusTone tone) => switch (tone) {
    DabblerStatusTone.success => success,
    DabblerStatusTone.warning => warning,
    DabblerStatusTone.error => error,
    DabblerStatusTone.info => info,
  };

  // --- Workflow tags. Theme- and brightness-invariant pastels. ---

  /// `--tag-pending-*`.
  static const DabblerToneColor tagPending = DabblerToneColor(
      surface: DabblerPalette.tagPendingSurface, ink: DabblerPalette.tagPendingInk);

  /// `--tag-progress-*`.
  static const DabblerToneColor tagProgress = DabblerToneColor(
      surface: DabblerPalette.tagProgressSurface, ink: DabblerPalette.tagProgressInk);

  /// `--tag-submitted-*`.
  static const DabblerToneColor tagSubmitted = DabblerToneColor(
      surface: DabblerPalette.tagSubmittedSurface, ink: DabblerPalette.tagSubmittedInk);

  /// `--tag-review-*`.
  static const DabblerToneColor tagReview = DabblerToneColor(
      surface: DabblerPalette.tagReviewSurface, ink: DabblerPalette.tagReviewInk);

  /// `--tag-success-*`.
  static const DabblerToneColor tagSuccess = DabblerToneColor(
      surface: DabblerPalette.tagSuccessSurface, ink: DabblerPalette.tagSuccessInk);

  /// `--tag-failed-*`.
  static const DabblerToneColor tagFailed = DabblerToneColor(
      surface: DabblerPalette.tagFailedSurface, ink: DabblerPalette.tagFailedInk);

  /// `--tag-expired-*`.
  static const DabblerToneColor tagExpired = DabblerToneColor(
      surface: DabblerPalette.tagExpiredSurface, ink: DabblerPalette.tagExpiredInk);

  // --- Decorative tiles. Carry no state meaning. ---

  /// `--tile-amber-*`.
  static const DabblerToneColor tileAmber = DabblerToneColor(
      surface: DabblerPalette.tileAmberSurface, ink: DabblerPalette.ink);

  /// `--tile-info-*`.
  static const DabblerToneColor tileInfo = DabblerToneColor(
      surface: DabblerPalette.tileInfoSurface, ink: DabblerPalette.socialP700);

  /// `--tile-accent-*`.
  static const DabblerToneColor tileAccent = DabblerToneColor(
      surface: DabblerPalette.tileAccentSurface, ink: DabblerPalette.activeP700);

  /// The resolved colours for the enclosing theme.
  ///
  /// Throws a [FlutterError] in debug if no [DabblerColors] is installed, which
  /// is a wiring bug rather than a runtime condition to handle.
  static DabblerColors of(BuildContext context) {
    final DabblerColors? colors = Theme.of(context).extension<DabblerColors>();
    assert(colors != null, 'No DabblerColors in the enclosing ThemeData.');
    return colors!;
  }

  /// The one instance for [theme] at [brightness]. There are 14.
  static DabblerColors resolve({
    required DabblerTheme theme,
    required Brightness brightness,
  }) {
    final bool dark = brightness == Brightness.dark;
    final _Brand b = _brandOf(theme, dark);
    return DabblerColors._(
      theme: theme,
      brightness: brightness,
      brandPrimary: b.primary,
      brandPrimaryHover: b.primaryHover,
      onBrand: b.onBrand,
      accent: b.accent,
      accentHover: b.accentHover,
      onAccent: b.onAccent,
      focusRing: b.focus,
      bgPrimary: dark ? DabblerProvisionalDark.bgPrimary : DabblerPalette.surfacePage,
      bgSecondary: dark ? DabblerProvisionalDark.bgSecondary
          : DabblerPalette.surfaceSunken,
      bgTertiary: dark ? DabblerProvisionalDark.bgTertiary : DabblerPalette.faint,
      surfaceCard: dark ? DabblerProvisionalDark.surfaceCard
          : DabblerPalette.surfaceCard,
      surfaceSunken: dark ? DabblerProvisionalDark.surfaceSunken
          : DabblerPalette.surfaceSunken,
      surfaceGrey: dark ? DabblerProvisionalDark.surfaceGrey
          : DabblerPalette.surfaceGrey,
      textPrimary: dark ? DabblerProvisionalDark.textPrimary : DabblerPalette.ink,
      textSecondary: dark ? DabblerProvisionalDark.textSecondary
          : DabblerPalette.muted,
      textTertiary: dark ? DabblerProvisionalDark.textTertiary
          : DabblerPalette.subtle,
      borderDefault: dark ? DabblerProvisionalDark.borderDefault
          : DabblerPalette.outlineCard,
      borderStrong: dark ? DabblerProvisionalDark.borderStrong
          : DabblerPalette.outlineStrong,
      success: _success(theme, dark),
      warning: _warning(theme, dark),
      error: _error(theme, dark),
      info: _info(theme, dark),
      spotlight: DabblerPalette.spotlight500,
      scrim: dark
          ? DabblerPalette.ink950.withValues(alpha: 0.65)
          : DabblerPalette.ink.withValues(alpha: 0.45),
    );
  }

  /// All 14 instances, in `(theme, brightness)` order.
  static List<DabblerColors> get all => <DabblerColors>[
    for (final DabblerTheme t in DabblerTheme.values)
      for (final Brightness br in Brightness.values)
        resolve(theme: t, brightness: br),
  ];

  @override
  DabblerColors copyWith({DabblerTheme? theme, Brightness? brightness}) =>
      resolve(
        theme: theme ?? this.theme,
        brightness: brightness ?? this.brightness,
      );

  @override
  DabblerColors lerp(ThemeExtension<DabblerColors>? other, double t) {
    if (other is! DabblerColors) return this;
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) =>
      other is DabblerColors &&
      other.theme == theme &&
      other.brightness == brightness;

  @override
  int get hashCode => Object.hash(theme, brightness);
}

/// The seven brand role sets, at one brightness.
typedef _Brand = ({
  Color primary,
  Color primaryHover,
  Color onBrand,
  Color accent,
  Color accentHover,
  Color onAccent,
  Color focus,
});

/// The brand role set for one `(theme, brightness)` pair.
///
/// The seven themes are laid out as a table rather than derived from a rule,
/// because the design source is not regular: `simple` and `shade` map onto the
/// ink ramp with their own step choices, and `shade`'s dark accent hover is
/// `--ink-600` where every other theme's is its own `s-700`. A rule would have
/// to carry more exceptions than entries.
///
/// Rows are hand-wrapped two roles to a line to keep this file inside the
/// 500-line limit; `dart format` would expand each to nine lines.
_Brand _brandOf(DabblerTheme theme, bool dark) => switch ((theme, dark)) {
  (DabblerTheme.main, false) => (
    primary: DabblerPalette.mainP600, primaryHover: DabblerPalette.mainP700,
    accent: DabblerPalette.mainS600, accentHover: DabblerPalette.mainS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.paper, focus: DabblerPalette.mainP400),
  (DabblerTheme.main, true) => (
    primary: DabblerPalette.mainP400, primaryHover: DabblerPalette.mainP300,
    accent: DabblerPalette.mainS400, accentHover: DabblerPalette.mainS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.paper, focus: DabblerPalette.mainP400),
  (DabblerTheme.sport, false) => (
    primary: DabblerPalette.sportP600, primaryHover: DabblerPalette.sportP700,
    accent: DabblerPalette.sportS600, accentHover: DabblerPalette.sportS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.ink900, focus: DabblerPalette.sportP400),
  (DabblerTheme.sport, true) => (
    primary: DabblerPalette.sportP400, primaryHover: DabblerPalette.sportP300,
    accent: DabblerPalette.sportS400, accentHover: DabblerPalette.sportS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.ink900, focus: DabblerPalette.sportP400),
  (DabblerTheme.social, false) => (
    primary: DabblerPalette.socialP600, primaryHover: DabblerPalette.socialP700,
    accent: DabblerPalette.socialS600, accentHover: DabblerPalette.socialS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.ink900, focus: DabblerPalette.socialP400),
  (DabblerTheme.social, true) => (
    primary: DabblerPalette.socialP400, primaryHover: DabblerPalette.socialP300,
    accent: DabblerPalette.socialS400, accentHover: DabblerPalette.socialS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.ink900, focus: DabblerPalette.socialP400),
  (DabblerTheme.active, false) => (
    primary: DabblerPalette.activeP600, primaryHover: DabblerPalette.activeP700,
    accent: DabblerPalette.activeS600, accentHover: DabblerPalette.activeS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.paper, focus: DabblerPalette.activeP400),
  (DabblerTheme.active, true) => (
    primary: DabblerPalette.activeP400, primaryHover: DabblerPalette.activeP300,
    accent: DabblerPalette.activeS400, accentHover: DabblerPalette.activeS700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.paper, focus: DabblerPalette.activeP400),
  (DabblerTheme.bright, false) => (
    primary: DabblerPalette.brightP600, primaryHover: DabblerPalette.brightP700,
    accent: DabblerPalette.brightS600, accentHover: DabblerPalette.brightS700,
    onBrand: DabblerPalette.ink900, onAccent: DabblerPalette.paper, focus: DabblerPalette.brightP400),
  (DabblerTheme.bright, true) => (
    primary: DabblerPalette.brightP400, primaryHover: DabblerPalette.brightP300,
    accent: DabblerPalette.brightS400, accentHover: DabblerPalette.brightS700,
    onBrand: DabblerPalette.ink900, onAccent: DabblerPalette.paper, focus: DabblerPalette.brightP400),
  (DabblerTheme.simple, false) => (
    primary: DabblerPalette.ink900, primaryHover: DabblerPalette.ink700,
    accent: DabblerPalette.ink600, accentHover: DabblerPalette.ink700,
    onBrand: DabblerPalette.paper, onAccent: DabblerPalette.paper, focus: DabblerPalette.ink700),
  (DabblerTheme.simple, true) => (
    primary: DabblerPalette.ink50, primaryHover: DabblerPalette.ink200,
    accent: DabblerPalette.ink300, accentHover: DabblerPalette.ink200,
    onBrand: DabblerPalette.ink900, onAccent: DabblerPalette.ink900, focus: DabblerPalette.ink300),
  (DabblerTheme.shade, false) => (
    primary: DabblerPalette.ink300, primaryHover: DabblerPalette.ink400,
    accent: DabblerPalette.ink200, accentHover: DabblerPalette.ink300,
    onBrand: DabblerPalette.ink600, onAccent: DabblerPalette.ink600, focus: DabblerPalette.ink600),
  (DabblerTheme.shade, true) => (
    primary: DabblerPalette.ink600, primaryHover: DabblerPalette.ink500,
    accent: DabblerPalette.ink700, accentHover: DabblerPalette.ink600,
    onBrand: DabblerPalette.ink200, onAccent: DabblerPalette.ink300, focus: DabblerPalette.ink500),
};

DabblerStatusColor _success(DabblerTheme theme, bool dark) {
  if (theme == DabblerTheme.sport) {
    return DabblerStatusColor(
        base: DabblerPalette.sportSuccess,
        surface: dark ? DabblerProvisionalDark.sportSuccessSurface
                      : DabblerThemeStatusTints.sportSuccessSurface,
        strong: dark ? DabblerProvisionalDark.sportSuccessInk
                     : DabblerThemeStatusTints.sportSuccessInk,
        solid: DabblerPalette.success700);
  }
  return DabblerStatusColor(
      base: DabblerPalette.success500,
      surface: dark ? DabblerProvisionalDark.successSurface : DabblerPalette.success100,
      strong: dark ? DabblerPalette.success100 : DabblerPalette.success700,
      solid: DabblerPalette.success700);
}

DabblerStatusColor _warning(DabblerTheme theme, bool dark) {
  if (theme == DabblerTheme.bright) {
    return DabblerStatusColor(
        base: DabblerPalette.brightWarning,
        surface: dark ? DabblerProvisionalDark.brightWarningSurface
                      : DabblerThemeStatusTints.brightWarningSurface,
        strong: dark ? DabblerProvisionalDark.brightWarningInk
                     : DabblerThemeStatusTints.brightWarningInk,
        solid: DabblerPalette.warning700);
  }
  return DabblerStatusColor(
      base: DabblerPalette.warning500,
      surface: dark ? DabblerProvisionalDark.warningSurface : DabblerPalette.warning100,
      strong: dark ? DabblerPalette.warning100 : DabblerPalette.warning700,
      solid: DabblerPalette.warning700);
}

DabblerStatusColor _error(DabblerTheme theme, bool dark) => DabblerStatusColor(
  // `active` overrides only the base indicator; its surface and ink stay the
  // shared ramp (`tokens/colors.css:176-180` declares no `--t-error-surface`).
  base: theme == DabblerTheme.active
      ? DabblerPalette.activeError
      : DabblerPalette.error500,
  surface: dark ? DabblerProvisionalDark.errorSurface : DabblerPalette.error100,
  strong: dark ? DabblerPalette.error100 : DabblerPalette.error700,
  solid: DabblerPalette.error700,
);

DabblerStatusColor _info(DabblerTheme theme, bool dark) {
  if (theme == DabblerTheme.social) {
    return DabblerStatusColor(
        base: DabblerPalette.socialInfo,
        surface: dark ? DabblerProvisionalDark.socialInfoSurface
                      : DabblerThemeStatusTints.socialInfoSurface,
        strong: dark ? DabblerProvisionalDark.socialInfoInk
                     : DabblerThemeStatusTints.socialInfoInk,
        solid: DabblerPalette.info700);
  }
  return DabblerStatusColor(
      base: DabblerPalette.info500,
      surface: dark ? DabblerProvisionalDark.infoSurface : DabblerPalette.info100,
      strong: dark ? DabblerPalette.info100 : DabblerPalette.info700,
      solid: DabblerPalette.info700);
}
