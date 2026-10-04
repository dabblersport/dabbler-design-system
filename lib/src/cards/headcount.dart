import 'package:flutter/widgets.dart';

import '../feedback/progress_bar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Headcount — who is going: a row of avatars beside a headline figure and a
/// caption, with an optional fill bar beneath.
///
/// Drawn from `Details.dc.html:79-91` (game details: five avatars, "9 of 10
/// players in", "1 spot left · closes at 6 PM", a 6px bar at 90%) and
/// `:246-253` (meetup: the same row without the bar).
///
/// ```dart
/// DabblerHeadcount(
///   avatars: DabblerAvatarGroup(people: names, overflow: 4),
///   headline: '9 of 10 players in',
///   caption: '1 spot left',
///   progress: 0.9,
/// )
/// ```
///
/// ## Slots
///
/// [avatars] is a widget — normally a `DabblerAvatarGroup` — so the component
/// does not decide how many faces show. Without it the headline and caption
/// take the whole row.
///
/// ## Type
///
/// [headline] is the design's 20/25 bold *sans* figure. The ramp's 20 step is
/// the display face (`title3`), so the component takes the sans face at the
/// ramp's `headline` step and sets its size and leading to the design's
/// values, the same override `DabblerStatTile`'s detail size records.
/// [caption] is `caption1` (12/16) in the secondary ink.
///
/// ## The bar
///
/// [progress] (0–1) draws a [DabblerProgressBar] at its default 6px height
/// under the row, [DabblerSpacing.space3] (9) below it. [critical] turns the
/// caption and the bar to the error tone — a full game.
///
/// ## RTL
///
/// The avatars sit at the inline start and the bar fills from the start.
class DabblerHeadcount extends StatelessWidget {
  /// A headcount row.
  const DabblerHeadcount({
    super.key,
    required this.headline,
    this.caption,
    this.avatars,
    this.progress,
    this.critical = false,
  });

  /// The headline figure, e.g. `9 of 10 players in`.
  final String headline;

  /// The line under [headline].
  final String? caption;

  /// The avatar cluster at the inline start.
  final Widget? avatars;

  /// The fill, 0–1. Null draws no bar.
  final double? progress;

  /// Draws the caption and the bar in the error tone.
  final bool critical;

  /// The headline's size — `20` (`Details.dc.html:84`).
  static const double headlineSize = 20;

  /// The headline's line height — `25`.
  static const double headlineLeading = 25;

  /// The gap between the avatars and the text — [DabblerSpacing.space4].
  static const double gap = DabblerSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.headline
              .resolveForDirection(direction)
              .copyWith(
                color: colors.textPrimary,
                fontSize: headlineSize,
                height: headlineLeading / headlineSize,
                fontWeight: DabblerType.bold,
              ),
        ),
        if (caption != null)
          Text(
            caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(
                  color: critical ? colors.error.strong : colors.textSecondary,
                ),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (avatars != null) ...<Widget>[
              avatars!,
              const SizedBox(width: gap),
            ],
            Expanded(child: text),
          ],
        ),
        if (progress != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space3),
          DabblerProgressBar(
            value: progress!,
            tone: critical
                ? DabblerProgressBarTone.error
                : DabblerProgressBarTone.brand,
          ),
        ],
      ],
    );
  }
}
