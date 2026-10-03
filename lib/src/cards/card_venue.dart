import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

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
///   favourite: DabblerButton.icon(icon: 'heart', semanticLabel: 'Save', onPressed: save),
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
/// **Deviation:** the design's card corner is `--radius-xl` (18) and its body
/// padding 15; the card shell's are [DabblerRadius.card] (16) and
/// [DabblerSpacing.cardPadding] (18). The shell is not re-themed per card, so
/// the venue card reads as the same family as every other card in the list.
/// The design's 170px cover height is transcribed as [coverHeight].
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
    this.favourite,
    this.price,
    this.priceCaption,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
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

    final Widget head = Row(
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
                  spacing: DabblerSpacing.iconGap,
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

    final Widget? priceRow = price == null && trailing == null
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              border: BorderDirectional(
                top: BorderSide(
                  color: colors.borderDefault,
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
                            style: DabblerType.caption2
                                .resolveForDirection(direction)
                                .copyWith(color: colors.textSecondary),
                          ),
                        if (price != null)
                          Text(
                            price!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // `16/21 600` — `.t-callout` at semibold.
                            style: DabblerType.callout
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
          if (tags.isNotEmpty)
            Wrap(
              spacing: DabblerSpacing.space2,
              runSpacing: DabblerSpacing.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: tags,
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
          spacing: DabblerSpacing.space1,
          children: <Widget>[
            DabblerIcon(
              'star',
              weight: DabblerIconWeight.bold,
              size: DabblerCardVenue.locationIconSize,
              color: colors.warning.base,
            ),
            Text(
              rating,
              style: DabblerType.footnote
                  .resolveForDirection(direction)
                  .copyWith(
                    color: colors.textPrimary,
                    fontWeight: DabblerType.semibold,
                  ),
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
