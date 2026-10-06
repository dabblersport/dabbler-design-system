import 'package:flutter/widgets.dart';

import '../feedback/ring.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';
import 'card_upcoming.dart';

/// CardUpcomingRail — the narrow upcoming tile for a horizontal rail, used when
/// the viewer has more than one upcoming meetup: a date block and the title and
/// time beside it, the venue under them, and a small countdown ring.
///
/// Drawn from the Listings `Upcoming` multi state, `Listings.dc.html:454-486`
/// (one tile is 210 wide): a 44-wide date block (month 11/14 600 over day 18/22
/// 700 — `.t-tag-tight` over [DabblerType.figure] — brand ink on a brand
/// wash), the title 14/19 600 over the time 11/15, the venue 12/16 with no
/// glyph, and a 40 tick ring with the number and unit; the shell is
/// [DabblerCardUpcoming]'s (1px hairline, 12 corner, 12 padding). The single
/// state is [DabblerCardUpcoming].
///
/// ```dart
/// DabblerCardUpcomingRail(
///   month: 'SEP',
///   day: '2',
///   title: 'Sunrise run',
///   time: '6:00 AM',
///   place: 'Kite Beach',
///   fraction: 0.4,
///   countdownValue: '3',
///   countdownUnit: 'hours',
/// )
/// ```
///
/// ## Tones
///
/// The fill is a [DabblerCardUpcomingTone], the same three tiles
/// [DabblerCardUpcoming] takes.
///
/// ## RTL
///
/// The date block leads at the inline start. The ring is a clock face and does
/// not mirror. Title and place carry their own direction, so an Arabic title
/// beside a Latin place stays readable.
///
/// ## Accessibility
///
/// With [onTap] the tile is one button named [semanticLabel], or the title,
/// time and place joined.
class DabblerCardUpcomingRail extends StatelessWidget {
  /// A rail tile.
  const DabblerCardUpcomingRail({
    super.key,
    required this.month,
    required this.day,
    required this.title,
    required this.fraction,
    required this.countdownValue,
    required this.countdownUnit,
    this.tone = DabblerCardUpcomingTone.amber,
    this.time,
    this.place,
    this.onTap,
    this.semanticLabel,
    this.width = defaultWidth,
  });

  /// The month, already localised and cased — `SEP`.
  final String month;

  /// The day of the month — `2`.
  final String day;

  /// The title. One line, then an ellipsis.
  final String title;

  /// How far through the countdown window the start is, 0-1.
  final double fraction;

  /// The big number in the ring — `3`.
  final String countdownValue;

  /// The unit under it — `hours`.
  final String countdownUnit;

  /// The tile's fill.
  final DabblerCardUpcomingTone tone;

  /// The start time — `6:00 AM`.
  final String? time;

  /// The venue.
  final String? place;

  /// Makes the tile a button.
  final VoidCallback? onTap;

  /// The accessible label of a tappable tile.
  final String? semanticLabel;

  /// The tile's width — `width: 210`.
  final double width;

  /// The design's `width: 210`.
  static const double defaultWidth = 210;

  /// The date block's width — `width: 44`.
  static const double dateWidth = 44;

  /// The ring's diameter — `40`, [DabblerSizing.resultTile].
  static const double ringDiameter = DabblerSizing.resultTile;

  /// The ring's number size and leading — `12/13`.
  static const double ringValueSize = 12;
  static const double ringValueLeading = 13;

  /// The ring's unit size and leading — `6/7`.
  static const double ringUnitSize = 6;
  static const double ringUnitLeading = 7;

  /// The ring's tick count — `24`.
  static const int ringTicks = DabblerCardUpcoming.ringTicks;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerColors ink = DabblerCardUpcoming.inkOf(
      colors,
      DabblerCardUpcoming.fillOf(colors, tone),
    );
    final TextDirection direction = Directionality.of(context);
    final Widget date = DabblerSurface(
      width: dateWidth,
      fill: DabblerSurface.tintedFillOf(ink, ink.brandPrimary),
      borderWidth: 0,
      radius: DabblerRadius.md,
      padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            month,
            maxLines: 1,
            // `11/14 600` — `.t-tag-tight`.
            style: DabblerType.tagTight
                .resolveForDirection(direction)
                .copyWith(color: ink.brandPrimary),
          ),
          Text(
            day,
            maxLines: 1,
            // `18/22 700` — the figure step.
            style: DabblerType.figure
                .resolveForDirection(direction)
                .copyWith(color: ink.brandPrimary),
          ),
        ],
      ),
    );
    final Widget ring = DabblerRing.ticks(
      fraction: fraction,
      diameter: ringDiameter,
      count: ringTicks,
      track: DabblerRingTrack.faint,
      semanticValue: '$countdownValue $countdownUnit',
      // A large text scale shrinks the countdown into the fixed ring.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              countdownValue,
              maxLines: 1,
              // `12/13`, display face (`Listings.dc.html:476`).
              style: DabblerType.footnote
                  .resolveForDirection(direction)
                  .copyWith(
                    color: ink.textPrimary,
                    fontSize: ringValueSize,
                    height: ringValueLeading / ringValueSize,
                  ),
            ),
            Text(
              countdownUnit,
              maxLines: 1,
              // `6/7`, muted (`Listings.dc.html:477`): the ring is 40 wide.
              style: DabblerType.caption2
                  .resolveForDirection(direction)
                  .copyWith(
                    color: ink.textSecondary,
                    fontSize: ringUnitSize,
                    height: ringUnitLeading / ringUnitSize,
                  ),
            ),
          ],
        ),
      ),
    );
    return DabblerCard(
      width: width,
      // The frame's tile: 1px `--outline-card`, `--radius-lg`, `padding: 12`
      // (`Listings.dc.html:455`) — the same shell as [DabblerCardUpcoming].
      variant: DabblerCardVariant.outlined,
      radius: DabblerCardUpcoming.radius,
      padding: DabblerCardUpcoming.padding,
      fill: DabblerCardUpcoming.fillOf(colors, tone),
      onTap: onTap,
      semanticLabel: onTap == null
          ? null
          : (semanticLabel ?? <String>[title, ?time, ?place].join(', ')),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DabblerSpacing.space3,
        children: <Widget>[
          Row(
            spacing: DabblerSpacing.space3,
            children: <Widget>[
              date,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // `gap: 1px`.
                  spacing: DabblerSizing.borderDefault,
                  children: <Widget>[
                    // `14/19 600` (`:462`).
                    Text(
                      DabblerType.toWesternDigits(title),
                      style: DabblerType.smallTight
                          .resolveForDirection(Directionality.of(context))
                          .copyWith(
                            color: ink.textPrimary,
                            fontWeight: DabblerType.semibold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (time != null)
                      // `11/15` (`:463`) — the tag step at regular weight.
                      Text(
                        DabblerType.toWesternDigits(time!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DabblerType.tag
                            .resolveForDirection(direction)
                            .copyWith(
                              color: ink.textSecondary,
                              fontWeight: DabblerType.regular,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // `:466-468` — the venue alone, 12/16 in `--ink-soft`; no glyph.
          if (place != null)
            Text(
              DabblerType.toWesternDigits(place!),
              style: DabblerType.caption1
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(color: ink.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Align(child: ring),
        ],
      ),
    );
  }
}
