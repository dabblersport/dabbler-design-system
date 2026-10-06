import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The tones a [DabblerListingTag] is drawn in — the `TONES` table of
/// `Listings.dc.html:1781-1790`.
enum DabblerListingTagTone {
  /// `info` — the sport / activity tag. Status info surface, info strong ink.
  info,

  /// `success` — Beginner, "Instant booking", "Verified".
  success,

  /// `warning` — Intermediate, "Top rated", "Popular".
  warning,

  /// `error` — Advanced.
  error,

  /// `brand` — `--surface-sunken` fill, brand ink.
  brand,

  /// `brandTint` — brand at 12% over the card, brand ink: the format /
  /// setting tag ("Futsal 5s", "Outdoor").
  brandTint,

  /// `neutral` — `--surface-sunken` fill, `--ink-soft` ink: a requirement
  /// note ("Bring your own mat").
  neutral,

  /// The solid brand pill with on-brand ink — the venue's distance chip
  /// (`Listings.dc.html:779-781`).
  solid,
}

/// ListingTag — the small pill a listing card labels itself with: sport,
/// format, skill, a status, a distance.
///
/// Drawn from the Listings frame's own tag recipe (`Listings.dc.html:221,
/// 527, 779, 790`): `padding: 4px 10px`, `--radius-pill`, 11/15 weight 600,
/// **no hairline**. It is a different part from [DabblerBadge] (the
/// `Badge.jsx` component, 11 bold at 1.5 leading inside a 20% hairline), which
/// the listing cards used before and which drew every tag 2px taller and
/// heavier than the frame.
///
/// [DabblerListingTag.outlined] is the venue card's sport chip
/// (`Listings.dc.html:798`): `--surface-card` inside a 1px `--outline-card`
/// hairline, `padding: 5px 12px`, 12/16 weight 500 in `--ink-soft`.
///
/// ```dart
/// DabblerListingTag(label: 'Football', tone: DabblerListingTagTone.info)
/// DabblerListingTag(
///   label: '4 km away',
///   tone: DabblerListingTagTone.solid,
///   icon: 'location',
/// )
/// DabblerListingTag.outlined(label: 'Padel')
/// ```
///
/// ## Accessibility
///
/// The tag is text; it adds no semantics of its own and the label is read as
/// written. Colour only reinforces the words — "Advanced" says Advanced.
class DabblerListingTag extends StatelessWidget {
  /// A filled tag in [tone].
  const DabblerListingTag({
    super.key,
    required this.label,
    this.tone = DabblerListingTagTone.info,
    this.icon,
  }) : outlined = false;

  /// The venue card's outlined sport chip.
  const DabblerListingTag.outlined({super.key, required this.label})
    : tone = DabblerListingTagTone.neutral,
      icon = null,
      outlined = true;

  /// The words on the tag, already localised.
  final String label;

  /// The fill and ink pair.
  final DabblerListingTagTone tone;

  /// An optional leading glyph name, drawn bold at [iconSize] in the tag's
  /// ink — the distance chip's pin.
  final String? icon;

  /// Whether this is the outlined sport chip.
  final bool outlined;

  /// `padding: 4px 10px` — block.
  static const double paddingBlock = 4;

  /// `padding: 4px 10px` — inline.
  static const double paddingInline = 10;

  /// The outlined chip's `padding: 5px 12px` — block. The 1px hairline sits
  /// outside it, so the box is 28 tall.
  static const double outlinedPaddingBlock = 5;

  /// The outlined chip's `padding: 5px 12px` — inline.
  static const double outlinedPaddingInline = DabblerSpacing.space4;

  /// The glyph — `size="12"` (`Listings.dc.html:780`).
  static const double iconSize = DabblerSizing.iconXs;

  /// Glyph to label — `gap: 4px`.
  static const double iconGap = 4;

  /// The brand share of the `brandTint` fill —
  /// `color-mix(in srgb, var(--color-brand-primary) 12%, white)`.
  static const double brandTintMix = 0.12;

  /// The fill for [tone].
  static Color fillOf(DabblerColors colors, DabblerListingTagTone tone) =>
      switch (tone) {
        DabblerListingTagTone.info => colors.info.surface,
        DabblerListingTagTone.success => colors.success.surface,
        DabblerListingTagTone.warning => colors.warning.surface,
        DabblerListingTagTone.error => colors.error.surface,
        DabblerListingTagTone.brand ||
        DabblerListingTagTone.neutral => colors.surfaceSunken,
        DabblerListingTagTone.brandTint => Color.lerp(
          colors.surfaceCard,
          colors.brandPrimary,
          brandTintMix,
        )!,
        DabblerListingTagTone.solid => colors.brandPrimary,
      };

  /// The ink for [tone].
  static Color inkOf(DabblerColors colors, DabblerListingTagTone tone) =>
      switch (tone) {
        DabblerListingTagTone.info => colors.info.strong,
        DabblerListingTagTone.success => colors.success.strong,
        DabblerListingTagTone.warning => colors.warning.strong,
        DabblerListingTagTone.error => colors.error.strong,
        DabblerListingTagTone.brand ||
        DabblerListingTagTone.brandTint => colors.brandPrimary,
        DabblerListingTagTone.neutral => colors.textSecondary,
        DabblerListingTagTone.solid => colors.onBrand,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Color ink = outlined ? colors.textSecondary : inkOf(colors, tone);
    final TextStyle style =
        (outlined
                ? DabblerType.caption1
                      .resolveForDirection(direction)
                      .copyWith(fontWeight: DabblerType.medium)
                : DabblerType.tag.resolveForDirection(direction))
            .copyWith(color: ink);
    final Widget text = Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? colors.surfaceCard : fillOf(colors, tone),
        borderRadius: DabblerRadius.pillAll,
        border: outlined
            ? Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              )
            : null,
      ),
      child: Padding(
        padding: outlined
            ? const EdgeInsets.symmetric(
                vertical: outlinedPaddingBlock + DabblerSizing.borderDefault,
                horizontal: outlinedPaddingInline + DabblerSizing.borderDefault,
              )
            : const EdgeInsets.symmetric(
                vertical: paddingBlock,
                horizontal: paddingInline,
              ),
        child: icon == null
            ? text
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: iconGap,
                children: <Widget>[
                  _Glyph(name: icon!, color: ink),
                  Flexible(child: text),
                ],
              ),
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) => DabblerIcon(
    name,
    weight: DabblerIconWeight.bold,
    size: DabblerListingTag.iconSize,
    color: color,
  );
}
