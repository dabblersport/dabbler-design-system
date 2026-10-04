import 'package:flutter/widgets.dart';

import '../feedback/ring.dart';
import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

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

  /// Fixed width, for a horizontal rail. Null sizes to the constraints.
  final double? width;

  /// The ring's diameter — the design's 24-tick ring.
  static const double ringDiameter =
      DabblerSizing.touchTargetMin +
      DabblerSpacing.space3 +
      DabblerSpacing.space1;

  /// The ring's tick count.
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

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Widget ring = DabblerRing.ticks(
      fraction: fraction,
      diameter: ringDiameter,
      count: ringTicks,
      track: DabblerRingTrack.faint,
      semanticValue: '$countdownValue $countdownUnit',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DabblerText(countdownValue, style: DabblerType.headline, maxLines: 1),
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
    return DabblerCard(
      width: width,
      fill: fillOf(colors, tone),
      onTap: onTap,
      semanticLabel: onTap == null ? null : (semanticLabel ?? title),
      child: Row(
        spacing: DabblerSpacing.space4,
        children: <Widget>[
          ring,
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
                if (when != null)
                  DabblerText(
                    when!,
                    style: DabblerType.caption2,
                    tone: DabblerTextTone.secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (hasPlace)
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
                          <String>[?place, ?distance].join(' · '),
                          style: DabblerType.caption1,
                          tone: DabblerTextTone.secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
