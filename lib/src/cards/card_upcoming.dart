import 'package:flutter/widgets.dart';

import '../feedback/ring.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';
import 'meta_line.dart';

/// The decorative tile tone an [DabblerCardUpcoming] is tinted with.
enum DabblerCardUpcomingTone {
  /// `--tile-amber-surface`.
  amber,

  /// `--tile-info-surface`.
  info,

  /// `--tile-accent-surface`.
  accent,
}

/// CardUpcoming — a game the viewer is in, on a tinted tile: a countdown
/// ring, the title, the date line and the place.
///
/// Drawn from the Listings screen's Upcoming rail, `Listings.dc.html:139-170`
/// (Alpha fidelity rebuild, KAN-426): a [DabblerRing.ticks] counting down to
/// the start with the big number and unit in its centre.
///
/// ```dart
/// DabblerCardUpcoming(
///   tone: DabblerCardUpcomingTone.amber,
///   fraction: 0.4,
///   countdownValue: '3',
///   countdownUnit: 'hours',
///   title: 'Tuesday 5-a-side',
///   when: 'Sep 2 · 7:30 PM · 60 min',
///   place: 'Dubai Sports City',
///   distance: '3.1 km',
///   onTap: open,
/// )
/// ```
///
/// ## Anatomy
///
/// | Part | Source | Here |
/// |---|---|---|
/// | tinted tile | `:123` | [DabblerCard] with a tile-tone fill |
/// | tick ring, 24 ticks, number in display 18, unit 8 | `:144-151` | [DabblerRing.ticks], [ringDiameter], [ringTicks] |
/// | title 14/19 600, one line | `:152` | `.t-subheadline` semibold |
/// | date line 11/15 muted | `:153` | [when] |
/// | pin, place, dot, distance | `:153-160` | [place] and [distance] |
///
/// ## RTL
///
/// The ring leads at the inline start and the text follows; the ring itself
/// is a clock face and does not mirror.
class DabblerCardUpcoming extends StatelessWidget {
  /// An upcoming-game tile.
  const DabblerCardUpcoming({
    super.key,
    required this.title,
    required this.fraction,
    required this.countdownValue,
    required this.countdownUnit,
    this.tone = DabblerCardUpcomingTone.amber,
    this.when,
    this.place,
    this.distance,
    this.onTap,
    this.semanticLabel,
    this.width,
    this.rail = false,
  });

  /// The game's title.
  final String title;

  /// How far through the countdown window the game is, 0–1.
  final double fraction;

  /// The centre number — `3`.
  final String countdownValue;

  /// The centre unit — `hours`.
  final String countdownUnit;

  /// The tile tone.
  final DabblerCardUpcomingTone tone;

  /// The date line — `Sep 2 · 7:30 PM · 60 min`.
  final String? when;

  /// The venue.
  final String? place;

  /// The distance, already formatted.
  final String? distance;

  /// Makes the tile tappable.
  final VoidCallback? onTap;

  /// The accessible label of a tappable tile.
  final String? semanticLabel;

  /// Fixed width, for a horizontal rail. Null sizes to the constraints, or —
  /// under unbounded width, inside a horizontal scroller — to the content, as
  /// the frame's rail cards do (`flex-shrink: 0`, no width).
  final double? width;

  /// The rail metrics (`Listings.dc.html:143-167`): a 24-tick ring, a 14/19
  /// title over an 11/15 time line, 1 apart. False is the single card
  /// (`:427-449`): a 32-tick ring, a 15/20 title over a 12/16 time line, 3
  /// apart.
  final bool rail;

  /// The ring's diameter — `width: 62px; height: 62px`.
  static const double ringDiameter = 62;

  /// A tick's length — `height: 7px`.
  static const double tickLength = 7;

  /// The single card's tick count — `gaugeLg`, 32.
  static const int singleRingTicks = 32;

  static const int ringTicks = 24;

  /// The share of the amber tile kept over the card surface —
  /// `color-mix(in srgb, var(--tile-amber-surface) 22%, #FFFFFF)`
  /// (`Listings.dc.html`, `PASTEL_TINTS`).
  static const double amberMix = 0.22;

  /// The tile's fill for [tone], resolved against [colors].
  static Color fillOf(DabblerColors colors, DabblerCardUpcomingTone tone) =>
      switch (tone) {
        DabblerCardUpcomingTone.amber => Color.lerp(
          colors.surfaceCard,
          DabblerColors.tileAmber.surface,
          amberMix,
        )!,
        DabblerCardUpcomingTone.info => DabblerColors.tileInfo.surface,
        DabblerCardUpcomingTone.accent => DabblerColors.tileAccent.surface,
      };

  /// The shell's corner — `--radius-lg` (12).
  static const double radius = DabblerRadius.lg;

  /// The shell's padding — `padding: 12px` inside the 1px hairline.
  static const EdgeInsets padding = EdgeInsets.all(
    DabblerSpacing.space4 + DabblerSizing.borderDefault,
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget ring = DabblerRing.ticks(
      fraction: fraction,
      diameter: ringDiameter,
      count: rail ? ringTicks : singleRingTicks,
      tickLength: tickLength,
      track: DabblerRingTrack.faint,
      semanticValue: '$countdownValue $countdownUnit',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The numeral is the display face — `font-family: var(--font-display);
          // font-size: 18px` (`:150`, `:433`).
          DabblerText(
            countdownValue,
            style: DabblerType.displayLabel,
            maxLines: 1,
          ),
          DabblerText(
            countdownUnit,
            style: DabblerType.caption2,
            tone: DabblerTextTone.secondary,
            maxLines: 1,
          ),
        ],
      ),
    );
    final bool hasPlace = place != null || distance != null;
    Widget column() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: rail ? DabblerSizing.borderDefault : DabblerSpacing.space1,
      children: <Widget>[
        DabblerText(
          title,
          style: rail ? DabblerType.smallTight : DabblerType.subheadline,
          weight: DabblerTextWeight.semibold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (when != null)
          if (rail)
            Text(
              when!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // `11/15` — the tag step at regular weight.
              style: DabblerType.tag
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(
                    color: colors.textSecondary,
                    fontWeight: DabblerType.regular,
                  ),
            )
          else
            DabblerText(
              when!,
              style: DabblerType.caption1,
              tone: DabblerTextTone.secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        if (hasPlace)
          DabblerMetaLine(
            items: <String>[?place, ?distance],
            size: DabblerMetaLineSize.compact,
          ),
      ],
    );
    return DabblerCard(
      width: width,
      variant: DabblerCardVariant.outlined,
      radius: radius,
      padding: padding,
      fill: fillOf(colors, tone),
      onTap: onTap,
      semanticLabel: onTap == null ? null : (semanticLabel ?? title),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool bounded = c.hasBoundedWidth;
          return Row(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            spacing: rail ? DabblerSpacing.space3 : DabblerSpacing.space4,
            children: <Widget>[
              ring,
              if (bounded) Expanded(child: column()) else column(),
            ],
          );
        },
      ),
    );
  }
}
