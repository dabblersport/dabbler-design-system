import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'surface.dart';

/// The tone of a [DabblerHeroIcon].
enum DabblerHeroIconTone {
  /// The brand tint — [DabblerSurface.tintedFillOf] the brand, its tinted
  /// hairline, brand ink. The default.
  brand,

  /// `--color-status-success-surface` / `-strong`.
  success,

  /// `--color-status-warning-surface` / `-strong`.
  warning,

  /// `--color-status-error-surface` / `-strong`.
  error,

  /// `--color-status-info-surface` / `-strong`.
  info,

  /// `--surface-sunken` with the card hairline and `--ink-soft` ink.
  neutral,
}

/// HeroIcon — the large circular tile holding one glyph at the top of a
/// success, confirmation or empty screen.
///
/// It is the screen-scale sibling of [DabblerIconTile] (45px, `--radius-lg`):
/// the same "glyph in a tint" vocabulary, round, and big enough to anchor a
/// full-screen message. The onboarding finish and setup screens
/// (`Auth and Onboarding.dc.html:455-520`) carry their confirmation as a
/// `tick-circle` in `--color-brand-primary` / `--color-status-success-strong`
/// (`:466`, `:795`); this component lifts that glyph into a hero.
///
/// ```dart
/// const DabblerHeroIcon('tick-circle', tone: DabblerHeroIconTone.success)
/// ```
///
/// **Deviation:** the design files draw no circular hero tile, and no hero
/// size token exists. The nearest precedent is the 60px tinted tile of
/// `Listings.dc.html:194` (brand at 10% fill / 28% border — exactly
/// [DabblerSurface.tintedFillOf] / [DabblerSurface.tintedBorderOf]). The
/// default diameter is [defaultSize] = `space11 + space8` (72) and the glyph
/// [DabblerSizing.iconLg] (30), both composed from existing tokens.
///
/// ## Accessibility
///
/// Decorative by default — the screen's title says what happened. Pass
/// [semanticLabel] when the glyph carries meaning the text does not.
///
/// ## RTL
///
/// A centred circle; nothing mirrors. Directional glyphs are the caller's.
class DabblerHeroIcon extends StatelessWidget {
  /// Creates a hero icon tile from an icon [name].
  const DabblerHeroIcon(
    this.name, {
    super.key,
    this.tone = DabblerHeroIconTone.brand,
    this.size = defaultSize,
    this.weight = DabblerIconWeight.bold,
    this.semanticLabel,
  });

  /// The icon name.
  final String name;

  /// The fill and ink.
  final DabblerHeroIconTone tone;

  /// The circle's diameter.
  final double size;

  /// The glyph weight. Bold by default, like the design's confirmations.
  final DabblerIconWeight weight;

  /// What assistive technology reads; null keeps it decorative.
  final String? semanticLabel;

  /// The default diameter, 72.
  static const double defaultSize =
      DabblerSpacing.space11 + DabblerSpacing.space8;

  /// The fill for [tone].
  static Color fillFor(DabblerColors colors, DabblerHeroIconTone tone) =>
      switch (tone) {
        DabblerHeroIconTone.brand => DabblerSurface.tintedFillOf(
          colors,
          colors.brandPrimary,
        ),
        DabblerHeroIconTone.neutral => colors.surfaceSunken,
        _ => colors.status(_status(tone)).surface,
      };

  /// The glyph colour for [tone].
  static Color inkFor(DabblerColors colors, DabblerHeroIconTone tone) =>
      switch (tone) {
        DabblerHeroIconTone.brand => colors.brandPrimary,
        DabblerHeroIconTone.neutral => colors.textSecondary,
        _ => colors.status(_status(tone)).strong,
      };

  static DabblerStatusTone _status(DabblerHeroIconTone tone) => switch (tone) {
    DabblerHeroIconTone.success => DabblerStatusTone.success,
    DabblerHeroIconTone.warning => DabblerStatusTone.warning,
    DabblerHeroIconTone.error => DabblerStatusTone.error,
    _ => DabblerStatusTone.info,
  };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color? border = switch (tone) {
      DabblerHeroIconTone.brand => DabblerSurface.tintedBorderOf(
        colors,
        colors.brandPrimary,
      ),
      DabblerHeroIconTone.neutral => colors.borderDefault,
      _ => null,
    };
    final Widget tile = DabblerSurface(
      radius: DabblerRadius.pill,
      fill: fillFor(colors, tone),
      borderColor: border,
      borderWidth: border == null ? 0 : DabblerSizing.borderDefault,
      width: size,
      height: size,
      center: true,
      child: DabblerIcon(
        name,
        weight: weight,
        size: DabblerSizing.iconLg,
        color: inkFor(colors, tone),
      ),
    );
    if (semanticLabel == null) {
      return ExcludeSemantics(child: tile);
    }
    return Semantics(
      container: true,
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: tile),
    );
  }
}
