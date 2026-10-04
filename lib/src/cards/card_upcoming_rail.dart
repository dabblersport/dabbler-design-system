import 'package:flutter/widgets.dart';

import '../feedback/ring.dart';
import '../foundations/icon.dart';
import '../foundations/text.dart';
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
/// 700, brand ink on a brand wash; the day takes `.t-headline` at bold, the
/// nearest sans step to 18/22), the title 14/19 600 over the time 11/15,
/// the venue 12/16, and a 40 tick ring with the number and unit. The single
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
    final TextDirection direction = Directionality.of(context);
    final Widget date = DabblerSurface(
      width: dateWidth,
      fill: DabblerSurface.tintedFillOf(colors, colors.brandPrimary),
      borderWidth: 0,
      radius: DabblerRadius.md,
      padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            month,
            maxLines: 1,
            style: DabblerType.caption2
                .resolveForDirection(direction)
                .copyWith(
                  color: colors.brandPrimary,
                  fontWeight: DabblerType.semibold,
                ),
          ),
          Text(
            day,
            maxLines: 1,
            style: DabblerType.headline
                .resolveForDirection(direction)
                .copyWith(
                  color: colors.brandPrimary,
                  fontWeight: DabblerType.bold,
                ),
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
                  color: colors.textSecondary,
                  fontSize: ringUnitSize,
                  height: ringUnitLeading / ringUnitSize,
                ),
          ),
        ],
      ),
    );
    return DabblerCard(
      width: width,
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
                  children: <Widget>[
                    DabblerText(
                      title,
                      style: DabblerType.subheadline,
                      weight: DabblerTextWeight.semibold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (time != null)
                      DabblerText(
                        time!,
                        style: DabblerType.caption2,
                        tone: DabblerTextTone.secondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (place != null)
            Row(
              spacing: DabblerSpacing.space1,
              children: <Widget>[
                DabblerIcon(
                  'location',
                  size: DabblerSizing.iconInline,
                  color: colors.textTertiary,
                ),
                Flexible(
                  child: DabblerText(
                    place!,
                    style: DabblerType.caption1,
                    tone: DabblerTextTone.secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          Align(child: ring),
        ],
      ),
    );
  }
}
