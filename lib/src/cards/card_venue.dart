import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sport_accent.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import '../surfaces/listing_tag.dart';
import 'card.dart';
import 'card_event_listing.dart';
import 'meta_line.dart';

/// CardVenue — a venue in a listing: a cover photo, the venue's name, where
/// it is, a row of tags (rating, distance, sports, badges), a favourite
/// action, and the price it starts from.
///
/// Drawn from the Listings screen's venue card, `Listings.dc.html:750-820`
/// (Alpha DS gaps 6, item 1).
///
/// ```dart
/// DabblerCardVenue(
///   name: 'Elite Football Arena',
///   cover: DabblerImage(url: venue.photoUrl),
///   area: 'Dubai Silicon Oasis',
///   distance: '4 km',
///   tags: <Widget>[
///     DabblerCardVenue.rating(rating: '4.8', reviews: '(126)'),
///     DabblerChip(label: 'Football'),
///   ],
///   favourite: DabblerFavouriteButton(selected: saved, semanticLabel: 'Save', onPressed: save),
///   price: 'AED 120 / hour',
///   priceCaption: 'Starting from',
///   trailing: DabblerButton(label: 'View venue', onPressed: open),
///   onTap: open,
/// )
/// ```
///
/// ## Anatomy
///
/// | Part | Source | Here |
/// |---|---|---|
/// | cover, 170 tall, `--surface-sunken` while loading | `:753-756` | [cover] in a [coverHeight] box over [DabblerColors.surfaceSunken] |
/// | name, 17/22 600, two lines | `:765` | `.t-headline`, [nameMaxLines] |
/// | location glyph + area | `:766-771` | [area] and [distance], joined by a dot |
/// | favourite, in a bordered 12-radius well | `:773-775` | the [favourite] slot, at the inline end of the name |
/// | rating, distance and badge chips, wrapping | `:777-791` | the [tags] slot, a [Wrap] |
/// | "Starting from" + price, above a hairline, beside a button | `:812-819` | [priceCaption], [price], [trailing] |
///
/// The shell — surface, border, radius, padding, press, focus and the
/// tap target — is [DabblerCard]'s; this file declares none of it.
///
/// The shell is the white card (`--surface-card` inside the 1px
/// `--outline-card` hairline, `Listings.dc.html:752`) at the listing corner,
/// `--radius-xl` (18, [DabblerCardEventListing.cardRadius]), with the body's
/// `padding: 15` inside the hairline ([DabblerCardEventListing.cardPadding]) —
/// the same shell as [DabblerCardGame], so a mixed list reads as one family.
/// (Until the Listings fidelity pass it sat on the tonal `standard` variant at
/// 16, which drew it grey-on-cream and borderless.) The design's 170px cover
/// height is transcribed as [coverHeight].
///
/// ## Slots, not data
///
/// Rating, badges and sport chips are design-system parts the app already
/// composes ([DabblerChip], [DabblerBadge]); the card takes them as widgets
/// in [tags] rather than re-modelling them. [rating] is a convenience for the
/// design's star + score + review-count group (`:780-786`).
///
/// ## RTL
///
/// Everything is directional: the favourite sits at the inline end, tags wrap
/// from the inline start, the price row puts the price at the start and the
/// [trailing] button at the end. Under Arabic all of it mirrors.
///
/// ## Accessibility
///
/// With [onTap] the whole card is one button whose name is [semanticLabel],
/// or by default the name, place and price joined. [favourite] and
/// [trailing] keep their own button semantics — they are separate targets,
/// as the design's `stop` handlers make them.
class DabblerCardVenue extends StatelessWidget {
  /// A venue card for [name].
  const DabblerCardVenue({
    super.key,
    required this.name,
    this.cover,
    this.area,
    this.distance,
    this.tags = const <Widget>[],
    this.sports = const <Widget>[],
    this.facilities = const <Widget>[],
    this.favourite,
    this.price,
    this.priceCaption,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
    this.accent,
  });

  /// The venue's name. Two lines, then an ellipsis.
  final String name;

  /// The cover photo — typically a [DabblerImage]. Null draws no cover at
  /// all, as the design does for a venue without a photo (`v.hasPhoto`).
  final Widget? cover;

  /// The neighbourhood — `Dubai Silicon Oasis`.
  final String? area;

  /// The distance, already formatted — `4 km`.
  final String? distance;

  /// The tag row: rating, distance and badge chips, sport chips. Wraps.
  final List<Widget> tags;

  /// The sports row under [tags] — outlined chips (`Listings.dc.html:795-799`).
  final List<Widget> sports;

  /// The facilities row — [facility] entries (`Listings.dc.html:801-808`).
  /// Wraps.
  final List<Widget> facilities;

  /// The favourite action, at the inline end of the name.
  final Widget? favourite;

  /// The price, already formatted — `AED 120 / hour`.
  final String? price;

  /// The caption over [price] — `Starting from`.
  final String? priceCaption;

  /// The action beside the price — `View venue`.
  final Widget? trailing;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  /// Whether a tappable card currently accepts input.
  final bool enabled;

  /// Tints the card by sport: the card fill takes [DabblerSportAccent.base]
  /// at [DabblerSportAccent.surfaceAlpha] over the card's own fill — the recipe
  /// the persona and sport cards use (`Auth and Onboarding.dc.html:1999-2016`).
  /// A derivation, not a frame: no Listings frame tints a card by sport.
  /// Null keeps the plain card. Additive.
  final DabblerSportAccent? accent;

  /// The accessible label of a tappable card.
  final String? semanticLabel;

  /// Fixed width. Null sizes to the incoming constraints.
  final double? width;

  /// The cover's height — `height: 170px` (`Listings.dc.html:754`).
  static const double coverHeight = 170;

  /// The name's line cap — `class="clamp-2"` (`Listings.dc.html:765`).
  static const int nameMaxLines = 2;

  /// The location glyph's size — `size="14"` (`Listings.dc.html:768`).
  static const double locationIconSize = 14;

  /// The design's rating group: a warning-toned star, the score, and the
  /// review count (`Listings.dc.html:780-786`). The star is decorative; the
  /// group reads as "[rating] [reviews]".
  static Widget rating({
    Key? key,
    required String rating,
    String? reviews,
    String? semanticLabel,
  }) => _Rating(
    key: key,
    rating: rating,
    reviews: reviews,
    semanticLabel: semanticLabel,
  );

  /// The facility glyph — `size="16"` (`Listings.dc.html:806`).
  static const double facilityIconSize = 16;

  /// Facility glyph to caption — `gap: 5px` (`Listings.dc.html:804`).
  static const double facilityGap = 5;

  /// The design's distance chip: a solid brand [DabblerListingTag] with a
  /// bold pin (`Listings.dc.html:779-781`). Pass the formatted label —
  /// `4 km away`.
  static Widget distanceTag({Key? key, required String label}) =>
      DabblerListingTag(
        key: key,
        label: label,
        tone: DabblerListingTagTone.solid,
        icon: 'location',
      );

  /// One facility: a brand-ink glyph and a caption (`Listings.dc.html:803-806`).
  static Widget facility({
    Key? key,
    required String icon,
    required String label,
  }) => _Facility(key: key, icon: icon, label: label);

  /// The default accessible name: name, place and price.
  String get defaultSemanticLabel => <String>[
    name,
    ?area,
    ?distance,
    if (price != null) <String>[?priceCaption, price!].join(' '),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextStyle meta = DabblerType.footnote
        .resolveForDirection(direction)
        .copyWith(color: colors.textSecondary);
    final String place = <String>[?area, ?distance].join(' · ');

    final Widget nameRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DabblerSpacing.space1,
            children: <Widget>[
              Text(
                name,
                maxLines: nameMaxLines,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.headline
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textPrimary),
              ),
              if (place.isNotEmpty)
                Row(
                  // `gap: 5px` (`Listings.dc.html:767`).
                  spacing: DabblerMetaLine.gap,
                  children: <Widget>[
                    DabblerIcon(
                      'location',
                      size: locationIconSize,
                      color: colors.textTertiary,
                    ),
                    Flexible(
                      child: Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: meta,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        ?favourite,
      ],
    );

    // Name block and tag row share one column at `gap: 7`
    // (`Listings.dc.html:763`); the sections below sit at the card's 12.
    final Widget head = tags.isEmpty
        ? nameRow
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DabblerSpacing.space2,
            children: <Widget>[
              nameRow,
              Wrap(
                spacing: DabblerSpacing.space2,
                runSpacing: DabblerSpacing.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: tags,
              ),
            ],
          );

    final Widget? priceRow = price == null && trailing == null
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              border: BorderDirectional(
                top: BorderSide(
                  // `border-top: 1px solid var(--faint)` (`:813`).
                  color: colors.bgTertiary,
                  width: DabblerSizing.borderDefault,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: DabblerSpacing.space4,
              ),
              child: Row(
                spacing: DabblerSpacing.space4,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (priceCaption != null)
                          Text(
                            priceCaption!,
                            maxLines: 1,
                            // `11/15` — the tag step at regular weight.
                            style: DabblerType.tag
                                .resolveForDirection(direction)
                                .copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: DabblerType.regular,
                                ),
                          ),
                        if (price != null)
                          Text(
                            price!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // `16/21 600` — `.t-body` at semibold.
                            style: DabblerType.body
                                .resolveForDirection(direction)
                                .copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: DabblerType.semibold,
                                ),
                          ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          );

    return DabblerCard(
      variant: DabblerCardVariant.white,
      radius: DabblerCardEventListing.cardRadius,
      padding: DabblerCardEventListing.cardPadding,
      fill: accent?.surfaceOver(
        DabblerCard.fillOf(colors, DabblerCardVariant.white),
      ),
      width: width,
      onTap: onTap,
      enabled: enabled,
      semanticLabel: onTap == null
          ? null
          : (semanticLabel ?? defaultSemanticLabel),
      media: cover == null
          ? null
          : SizedBox(
              height: coverHeight,
              child: ColoredBox(
                color: colors.surfaceSunken,
                child: SizedBox.expand(child: cover),
              ),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DabblerSpacing.stackDefault,
        children: <Widget>[
          head,
          if (sports.isNotEmpty)
            Wrap(
              spacing: DabblerSpacing.space2,
              runSpacing: DabblerSpacing.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: sports,
            ),
          if (facilities.isNotEmpty)
            Wrap(
              spacing: DabblerSpacing.space5,
              runSpacing: DabblerSpacing.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: facilities,
            ),
          ?priceRow,
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({
    super.key,
    required this.rating,
    this.reviews,
    this.semanticLabel,
  });

  final String rating;
  final String? reviews;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Semantics(
      container: true,
      label: semanticLabel ?? <String>[rating, ?reviews].join(' '),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DabblerListingTag.iconGap,
          children: <Widget>[
            DabblerIcon(
              'star',
              weight: DabblerIconWeight.bold,
              size: DabblerCardVenue.locationIconSize,
              color: colors.warning.base,
            ),
            Text(
              rating,
              // `13/17 600` — `.t-footnote-tight`.
              style: DabblerType.footnoteTight
                  .resolveForDirection(direction)
                  .copyWith(color: colors.textPrimary),
            ),
            if (reviews != null)
              Text(
                reviews!,
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _Facility extends StatelessWidget {
  const _Facility({super.key, required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: DabblerCardVenue.facilityGap,
      children: <Widget>[
        DabblerIcon(
          icon,
          size: DabblerCardVenue.facilityIconSize,
          color: colors.brandPrimary,
        ),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
