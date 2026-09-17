import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'card.dart';
import 'card_event_large.dart';

/// CardEventSmall — the densest event row: a small cover thumbnail, the title,
/// and the date/time on one line beneath it.
///
/// ```dart
/// DabblerCardEventSmall(
///   title: 'Sunday five-a-side at Al Barsha Pond Park',
///   sport: DabblerSport.football,
///   dateTime: 'Sun 21 Sep · 18:00',
///   onTap: () {},
/// )
/// ```
///
/// ## Derived from Large, not re-derived (KAN-252 AC2)
///
/// Identical in kind to [DabblerCardEventMedium]: the image treatment, the
/// truncation rule, the metadata row and the type steps are all
/// [DabblerCardEventLarge]'s, and the shell is [DabblerCard]'s. See
/// [DabblerCardEventMedium]'s table, which applies here unchanged.
///
/// Its geometry is ruled by `DECISIONS.md` **D-006** and declared in
/// [DabblerCardEventGeometry], not in this file — [thumbSide] and
/// [thumbRadius] are re-exports of that block.
///
/// This size adds two decisions of its own:
///
/// * [thumbSide] is **48** ([DabblerCardEventGeometry.smallThumbSide]).
///   KAN-252 first proposed 45 — [DabblerSizing.touchTargetMin] — and `cxo`
///   rejected it: that token is a *hit-target floor*, not a thumbnail scale,
///   and 45 is off the 4dp grid and off every scale in the system. The
///   rejection is kept written down because the mistake is an easy one to
///   make again.
/// * **the sport-icon overlay is not drawn** (`DECISIONS.md` **D-022**).
///
///   D-006 ruled one overlay geometry — a 24 mark in a 32 `--surface-card`
///   well, inset 8 — and did not carve out the smaller sizes. KAN-252 held
///   that position in this file rather than complying quietly, and `cxo`
///   upheld it in **D-022**, recording the gap as D-006's own omission rather
///   than non-compliance here, and extending the exemption to
///   [DabblerCardEventMedium] as well.
///
///   The arithmetic at this size: the well spans 8→40 of a 48pt thumbnail —
///   83% of its width, **44% of its area**. At that proportion the mark is
///   not an overlay *on* the cover, it is what the cover has been replaced
///   by, and the image treatment AC1 makes the family's defining feature
///   stops being visible here at all. The sport is still carried — by the
///   artwork itself, whenever [DabblerSportBackground] has any for it.
///
///   The rule D-022 states is deliberately not a size ladder: *the overlay
///   exists where the cover is large enough to still read as a cover
///   underneath it.* There is no second, smaller geometry to invent, and a
///   licensed sport glyph set shipping does not reopen this — see
///   [DabblerCardEventLarge]'s overlay section.

class DabblerCardEventSmall extends StatelessWidget {
  /// A dense event row for [title].
  const DabblerCardEventSmall({
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

  /// The event's sport — selects the fallback artwork. No overlay is drawn at
  /// this size; see the class doc.
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

  /// Fixed width. Null sizes to the incoming constraints.
  final double? width;

  /// The leading thumbnail's side — **48**, ruled by D-006
  /// ([DabblerCardEventGeometry.smallThumbSide]). See the class doc for why
  /// it is not 45.
  static const double thumbSide = DabblerCardEventGeometry.smallThumbSide;

  /// The thumbnail's corner radius — [DabblerRadius.lg] (12), the step
  /// [DabblerCardEventMedium.thumbRadius] takes.
  ///
  /// D-006 rules Medium's radius and is silent on Small's; the ruled step is
  /// carried across rather than a second one invented, and D-018 confirms 12
  /// as the corner of a tile inside a card — which is what this thumbnail is.
  /// See [DabblerCardEventGeometry.rowThumbRadius].
  static const double thumbRadius = DabblerCardEventGeometry.rowThumbRadius;

  /// One line, then an ellipsis.
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
