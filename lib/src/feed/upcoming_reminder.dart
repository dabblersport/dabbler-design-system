import 'package:flutter/widgets.dart';

import '../feedback/ring.dart';
import '../foundations/icon.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// One game on the [DabblerUpcomingReminder]: its date tile, title, venue and
/// time line, and the countdown ring.
@immutable
class DabblerUpcomingItem {
  /// An upcoming game.
  const DabblerUpcomingItem({
    required this.month,
    required this.day,
    required this.title,
    required this.detail,
    required this.ringFraction,
    required this.ringBig,
    required this.ringSmall,
    required this.short,
    this.onTap,
  });

  /// The month, already localised and upper-cased (`OCT`).
  final String month;

  /// The day of the month (`4`).
  final String day;

  /// The game's title.
  final String title;

  /// The venue and time line (`Dubai Sports City · 7:30 PM`).
  final String detail;

  /// How much of the countdown window has elapsed, 0–1.
  final double ringFraction;

  /// The big figure in the ring (`2`).
  final String ringBig;

  /// The unit under it (`hours`).
  final String ringSmall;

  /// The short countdown in a list row and the strip (`in 2h 10m`).
  final String short;

  /// Opens the game.
  final VoidCallback? onTap;
}

/// UpcomingReminder — the Home Feed's "Upcoming" block: the next game as a card
/// with a countdown ring, the rest folded under it as a stack, or opened as a
/// list, or the whole block folded to a one-line strip.
///
/// Transcribed from `Home Feed.dc.html` `:94-262` (`reminderStrip`,
/// `reminderCard`, `multiStack`, `multiList`; the `rail` layout is not drawn
/// because the file's default `multiLayout` is `stack`). The caller owns the
/// state — [collapsed] and [expanded] — and every label, already localised.
///
/// | Design | Dart |
/// | --- | --- |
/// | `:99` strip 30 high, pill, `--faint`, dot + count, divider, text, chevron | [DabblerSurface] `grey` pill; `caption2`, `caption1`, 16 glyph |
/// | `:116` title `--font-display` 20/25 | `title3` |
/// | `:119` "See all" 13/18 brand, shown above three games | `footnote`, brand, [seeAllLabel] |
/// | `:123` close 34 box, `close-circle` 18 | 45 touch box, glyph 18 |
/// | `:133` card, padding 12, radius lg, hairline | [DabblerSurface.card] |
/// | `:134` date tile 48 wide, brand 10% | [DabblerSurface.brandTint] |
/// | `:143` ring 56, 32 ticks, 2×7 | [DabblerRing.ticks] diameter 56, count 32 |
/// | `:141-142` stack: two sheets 7 and 14 inset, 40 high | two offset surfaces |
/// | `:165` "N more this week" 13/18 + `arrow-circle-down` | [moreLabel] |
/// | `:176-230` list rows: 34 date, 13/18 title, brand "in 2h" | [DabblerSurface.card] with rows |
///
/// ## Deviations (recorded, not silent)
///
/// * **No marquee.** The strip's text scrolls in the design (`ticker`); here it
///   is one ellipsised line — the system has no continuous-motion primitive.
/// * **No swipe-to-dismiss.** The close button dismisses; the card's own
///   swipe (`:2911`) is a gesture the system does not model for a card.
/// * **Gaps.** 5px and 9px gaps take the nearest base-3 step.
///
/// RTL: every inset is directional; the date tile leads and the ring trails.
/// Figures are drawn with Western digits.
class DabblerUpcomingReminder extends StatelessWidget {
  /// The Upcoming block.
  const DabblerUpcomingReminder({
    super.key,
    required this.items,
    required this.title,
    required this.collapsed,
    required this.expanded,
    required this.onDismiss,
    required this.onExpandStrip,
    required this.onToggleExpanded,
    required this.stripLabel,
    required this.moreLabel,
    required this.showLessLabel,
    required this.dismissLabel,
    this.seeAllLabel,
    this.onSeeAll,
  });

  /// The games, soonest first. Empty draws nothing.
  final List<DabblerUpcomingItem> items;

  /// The block title (`Upcoming · 3`).
  final String title;

  /// Whether the block is folded to the strip.
  final bool collapsed;

  /// Whether the stack is opened as a list.
  final bool expanded;

  /// Folds the block to the strip.
  final VoidCallback onDismiss;

  /// Opens the block from the strip.
  final VoidCallback onExpandStrip;

  /// Opens or closes the list under the first game.
  final VoidCallback onToggleExpanded;

  /// The strip's count label (`3 upcoming`).
  final String stripLabel;

  /// The toggle under the stack (`2 more this week`).
  final String moreLabel;

  /// The toggle under the open list (`Show less`).
  final String showLessLabel;

  /// The accessible name of the close button.
  final String dismissLabel;

  /// The list footer (`See all 5 upcoming`); drawn when more than three games.
  final String? seeAllLabel;

  /// Opens every upcoming game.
  final VoidCallback? onSeeAll;

  /// The ring's side — `56` (`:143`).
  static const double ringSize = 56;

  /// The more / less toggle's height — `height:32px` (`:165`).
  static const double toggleHeight = 32;

  /// The date tile's width — `48` (`:134`).
  static const double dateTileWidth = 48;

  /// How many games the open list shows after the first — `slice(1, 4)`.
  static const int listRest = 3;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    if (collapsed) return _strip(colors, t);
    final bool multi = items.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                DabblerType.toWesternDigits(title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t(
                  DabblerType.title3,
                ).copyWith(color: colors.textPrimary),
              ),
            ),
            if (items.length > 3 && seeAllLabel != null)
              DabblerFeedTappable(
                onTap: onSeeAll,
                child: Text(
                  DabblerType.toWesternDigits(seeAllLabel!),
                  style: t(
                    DabblerType.footnote,
                  ).copyWith(color: colors.brandPrimary),
                ),
              ),
            DabblerFeedAction(
              icon: 'close-circle',
              iconSize: 18,
              onTap: onDismiss,
              semanticLabel: dismissLabel,
            ),
          ],
        ),
        if (!multi)
          _card(items.first, colors, t)
        else if (!expanded) ...<Widget>[
          _stack(colors, t),
          _toggle(moreLabel, 'arrow-circle-down', colors, t),
        ] else ...<Widget>[
          _card(items.first, colors, t),
          const SizedBox(height: DabblerSpacing.space2),
          _list(colors, t),
          _toggle(showLessLabel, 'arrow-circle-up', colors, t),
        ],
      ],
    );
  }

  Widget _strip(DabblerColors colors, TextStyle Function(DabblerTypeStyle) t) {
    final String text = items
        .map((DabblerUpcomingItem i) => '${i.title} · ${i.detail} · ${i.short}')
        .join('   ·   ');
    return DabblerFeedTappable(
      onTap: onExpandStrip,
      semanticLabel: stripLabel,
      excludeChildSemantics: true,
      child: DabblerSurface.grey(
        radius: DabblerRadius.pill,
        padding: const EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space3,
          DabblerSpacing.space2,
          DabblerSpacing.space2,
          DabblerSpacing.space2,
        ),
        child: Row(
          children: <Widget>[
            Text(
              DabblerType.toWesternDigits(stripLabel),
              style: t(
                DabblerType.caption2,
              ).copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(
              child: Text(
                DabblerType.toWesternDigits(text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t(
                  DabblerType.caption1,
                ).copyWith(color: colors.textSecondary),
              ),
            ),
            DabblerIcon(
              'arrow-circle-down',
              size: 16,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    DabblerUpcomingItem u,
    DabblerColors colors,
    TextStyle Function(DabblerTypeStyle) t,
  ) {
    return DabblerFeedTappable(
      onTap: u.onTap,
      child: DabblerSurface.card(
        radius: DabblerRadius.lg,
        padding: const EdgeInsets.all(DabblerSpacing.space4),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: dateTileWidth,
              child: DabblerSurface.brandTint(
                radius: DabblerRadius.md,
                borderWidth: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: DabblerSpacing.space2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      DabblerType.toWesternDigits(u.month),
                      style: t(
                        DabblerType.caption2,
                      ).copyWith(color: colors.brandPrimary),
                    ),
                    Text(
                      DabblerType.toWesternDigits(u.day),
                      style: t(
                        DabblerType.headline,
                      ).copyWith(color: colors.brandPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: DabblerSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    u.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t(
                      DabblerType.subheadline,
                    ).copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    DabblerType.toWesternDigits(u.detail),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t(
                      DabblerType.caption1,
                    ).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DabblerSpacing.space4),
            DabblerRing.ticks(
              fraction: u.ringFraction,
              diameter: ringSize,
              count: 32,
              track: DabblerRingTrack.faint,
              semanticValue: '${u.ringBig} ${u.ringSmall}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    DabblerType.toWesternDigits(u.ringBig),
                    style: t(
                      DabblerType.title3,
                    ).copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    u.ringSmall,
                    style: t(
                      DabblerType.caption2,
                    ).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The first game over two sheets peeking out below it (`:141-142`).
  Widget _stack(DabblerColors colors, TextStyle Function(DabblerTypeStyle) t) {
    final Color hairline = colors.borderDefault;
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: DabblerSpacing.space4,
          end: DabblerSpacing.space4,
          bottom: DabblerSpacing.space2,
          height: DabblerSpacing.space10,
          child: const DabblerSurface.card(radius: DabblerRadius.lg),
        ),
        PositionedDirectional(
          start: DabblerSpacing.space2,
          end: DabblerSpacing.space2,
          bottom: 0,
          height: DabblerSpacing.space10,
          child: DabblerSurface.sunken(
            radius: DabblerRadius.lg,
            borderColor: hairline,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: DabblerSpacing.space5,
          ),
          child: _card(items.first, colors, t),
        ),
      ],
    );
  }

  Widget _toggle(
    String label,
    String icon,
    DabblerColors colors,
    TextStyle Function(DabblerTypeStyle) t,
  ) {
    return DabblerFeedTappable(
      onTap: onToggleExpanded,
      child: SizedBox(
        height: toggleHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DabblerType.toWesternDigits(label),
              style: t(
                DabblerType.footnote,
              ).copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: DabblerSpacing.space2),
            DabblerIcon(icon, size: 16, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _list(DabblerColors colors, TextStyle Function(DabblerTypeStyle) t) {
    final List<DabblerUpcomingItem> rest = items
        .skip(1)
        .take(listRest)
        .toList();
    return DabblerSurface.card(
      radius: DabblerRadius.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < rest.length; i++)
            DabblerFeedTappable(
              onTap: rest[i].onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(
                          top: BorderSide(
                            color: colors.bgTertiary,
                            width: DabblerSizing.borderDefault,
                          ),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: DabblerSpacing.space4,
                    vertical: DabblerSpacing.space2,
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: DabblerSpacing.space10,
                        child: DabblerSurface.sunken(
                          radius: DabblerRadius.sm,
                          padding: const EdgeInsets.symmetric(
                            vertical: DabblerSpacing.space1,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                DabblerType.toWesternDigits(rest[i].month),
                                style: t(
                                  DabblerType.caption2,
                                ).copyWith(color: colors.textSecondary),
                              ),
                              Text(
                                DabblerType.toWesternDigits(rest[i].day),
                                style: t(
                                  DabblerType.subheadline,
                                ).copyWith(color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: DabblerSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              rest[i].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t(
                                DabblerType.footnote,
                              ).copyWith(color: colors.textPrimary),
                            ),
                            Text(
                              DabblerType.toWesternDigits(rest[i].detail),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t(
                                DabblerType.caption2,
                              ).copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DabblerType.toWesternDigits(rest[i].short),
                        style: t(
                          DabblerType.caption1,
                        ).copyWith(color: colors.brandPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (items.length > 3 && seeAllLabel != null)
            DabblerFeedTappable(
              onTap: onSeeAll,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.bgTertiary,
                      width: DabblerSizing.borderDefault,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: DabblerSizing.touchTargetMin,
                  child: Center(
                    child: Text(
                      DabblerType.toWesternDigits(seeAllLabel!),
                      style: t(
                        DabblerType.caption1,
                      ).copyWith(color: colors.brandPrimary),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
