import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'card.dart';
import 'card_event_large.dart';

/// CardEventMedium — the same event as a row: a square cover thumbnail
/// carrying the sport's mark, beside the title and the date/time and place.
///
/// ```dart
/// DabblerCardEventMedium(
///   title: 'Sunday five-a-side at Al Barsha Pond Park',
///   sport: DabblerSport.football,
///   dateTime: 'Sun 21 Sep · 18:00',
///   location: 'Al Barsha Pond Park',
///   onTap: () {},
/// )
/// ```
///
/// ## Derived from Large, not re-derived (KAN-252 AC2)
///
/// This file declares **no** image resolution order, no overlay geometry, no
/// truncation rule, no metadata layout and no type step of its own. Every one
/// of those comes from [DabblerCardEventLarge]:
///
/// | Concern | Where it lives |
/// |---|---|
/// | ruled geometry (thumbnail, radius, row gap) | [DabblerCardEventGeometry] |
/// | image treatment, and the null-artwork case | [DabblerCardEventLarge.mediaContent] |
/// | title truncation | [DabblerCardEventLarge.titleText] |
/// | date/time and place | [DabblerCardEventLarge.metaRow] |
/// | title and metadata styles | [DabblerCardEventLarge.compactTitleStyleFor], [DabblerCardEventLarge.metaStyleFor] |
/// | shell, radius, padding, press, focus | [DabblerCard] |
///
/// What this size adds is exactly three decisions, and nothing else: the image
/// is a [thumbSide] square in the row rather than a full-bleed
/// [DabblerCard.media], the title takes [titleMaxLines] line instead of two,
/// and **the sport-icon overlay is not drawn** (`DECISIONS.md` **D-022**).
///
/// On that last point: D-006 ruled one overlay geometry — a 24 mark in a 32
/// `--surface-card` well — and did not carve out the row sizes. `cxo` closed
/// that as its own omission in D-022 and exempted **both** row sizes, not
/// only the smallest. At 64 the well is 50% of the thumbnail's width and 25%
/// of its area: the same defect [DabblerCardEventSmall] argued, one step less
/// severe, and ruling one size and not the other would have left D-006
/// incoherent across its own family.
///
/// The rule is not a size ladder and no second, smaller geometry exists to
/// invent — *the overlay exists where the cover is large enough to still read
/// as a cover underneath it*. See [DabblerCardEventLarge]'s overlay section,
/// including why a licensed glyph set shipping does not reopen it. The reasons for both, and the fact that the exported Figma node for
/// this component is a mis-labelled settings row, are recorded once in
/// [DabblerCardEventLarge]'s class doc — read it before changing anything
/// here.
///
/// ## Its geometry is ruled, and it is not declared here
///
/// The design bundle carries no event card — see [DabblerCardEventLarge]'s
/// class doc — so this size's thumbnail side, thumbnail radius and row gap
/// come from `DECISIONS.md` **D-006** and live in
/// [DabblerCardEventGeometry], not in this file. [thumbSide], [thumbRadius]
/// and the row gap below are re-exports of that block, so a caller reads the
/// same constants the widget does and an amendment to D-006 is an edit in one
/// place.
class DabblerCardEventMedium extends StatelessWidget {
  /// A row-sized event card for [title].
  const DabblerCardEventMedium({
    super.key,
    required this.title,
    this.sport,
    this.cover,
    this.dateTime,
    this.location,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
  });

  /// The event's title. Truncated to [titleMaxLines] line with an ellipsis.
  final String title;

  /// The event's sport — selects the fallback artwork and the overlay mark.
  final DabblerSport? sport;

  /// An explicit cover image, taking precedence over the sport artwork.
  final Widget? cover;

  /// The event's date and time, already formatted. See the DS-602 seam in
  /// [DabblerCardEventLarge]'s class doc.
  final String? dateTime;

  /// The event's place, already formatted.
  final String? location;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  /// Whether a tappable card currently accepts input.
  final bool enabled;

  /// The accessible label of a tappable card.
  final String? semanticLabel;

  /// Fixed width. Null sizes to the incoming constraints — the source's
  /// `width: 855` is a Figma frame measurement.
  final double? width;

  /// The leading thumbnail's side — **64**, ruled by D-006
  /// ([DabblerCardEventGeometry.mediumThumbSide]).
  static const double thumbSide = DabblerCardEventGeometry.mediumThumbSide;

  /// The thumbnail's corner radius — **12**, ruled by D-006
  /// ([DabblerCardEventGeometry.mediumThumbRadius]), and [DabblerRadius.lg]
  /// exactly: the step `tokens/spacing.css:27` annotates *"cards, icon
  /// tiles"* and the one `CardHouse`'s well already takes.
  static const double thumbRadius =
      DabblerCardEventGeometry.mediumThumbRadius;

  /// One line, then an ellipsis. See [DabblerCardEventLarge]'s truncation
  /// section for why the row sizes cap at one.
  static const int titleMaxLines = 1;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final Widget? meta = DabblerCardEventLarge.metaRow(
      direction,
      colors,
      dateTime: dateTime,
      location: location,
    );

    return DabblerCard(
      width: width,
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(thumbRadius)),
            child: SizedBox(
              width: thumbSide,
              height: thumbSide,
              child: DabblerCardEventLarge.mediaContent(
                context,
                cover: cover,
                sport: sport,
                // D-022: the overlay is Large's only. See the class doc.
                overlay: false,
              ),
            ),
          ),
          const SizedBox(width: DabblerCardEventGeometry.rowGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DabblerCardEventLarge.titleText(
                  title,
                  direction,
                  colors,
                  maxLines: titleMaxLines,
                  style:
                      DabblerCardEventLarge.compactTitleStyleFor(direction),
                ),
                if (meta != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.stackTight),
                  meta,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
