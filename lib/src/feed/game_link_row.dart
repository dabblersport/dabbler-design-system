import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../surfaces/badge.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// GameLinkRow — one game in the "Link a game" sheet: a date tile, the title
/// with its sport glyph, the place and time, a status badge and a check when
/// chosen.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 889-912: card fill, 1px hairline (brand when selected), `--radius-lg`,
/// padding 12, `gap:12`; date tile 44 wide, 6px block padding, `--radius-md`,
/// brand tint, month 11/13 and day 17/22 600 in the brand ink; title 15/20
/// after a 13px sport glyph; place 12/16, a 3px dot, time 12/16, all muted;
/// status pill 2/8 11/13 (success tint when live, sunken and muted
/// otherwise); `tick-circle` 18 bold brand when selected.
///
/// ## Deviations
///
/// * **Glyph.** The design's sport emoji becomes a [DabblerSportIcon].
/// * **Type.** 11/13 and 12/16 take `caption1`, 15/20 `subheadline`.
///
/// RTL: the date tile leads, the status and check trail.
/// Accessibility: one button named [title], selected when [selected].
class DabblerGameLinkRow extends StatelessWidget {
  /// A game row.
  const DabblerGameLinkRow({
    super.key,
    required this.month,
    required this.day,
    required this.title,
    required this.onTap,
    this.sportKey,
    this.place,
    this.time,
    this.status,
    this.live = false,
    this.selected = false,
  });

  /// The month abbreviation (`Aug`).
  final String month;

  /// The day of the month (`18`).
  final String day;

  /// The game's title.
  final String title;

  /// Chooses the game.
  final VoidCallback? onTap;

  /// The sport's key (`football`) for the glyph; null draws none.
  final String? sportKey;

  /// Where it is played.
  final String? place;

  /// When (`Today · 8:00 PM`).
  final String? time;

  /// The status badge text (`Live`, `Joined`); null hides it.
  final String? status;

  /// Whether the status is live (success tint).
  final bool live;

  /// Whether this game is the chosen one.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle caption = DabblerType.caption1
        .resolveForDirection(dir)
        .copyWith(color: colors.textSecondary);
    final Widget dot = ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.textTertiary,
        ),
        child: const SizedBox(width: 3, height: 3),
      ),
    );
    final Widget dateTile = DabblerSurface.brandTint(
      radius: DabblerRadius.md,
      borderWidth: 0,
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: DabblerSpacing.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            month,
            maxLines: 1,
            style: caption.copyWith(color: colors.brandPrimary),
          ),
          Text(
            DabblerType.toWesternDigits(day),
            maxLines: 1,
            style: DabblerType.headline
                .resolveForDirection(dir)
                .copyWith(
                  color: colors.brandPrimary,
                  fontWeight: DabblerType.semibold,
                ),
          ),
        ],
      ),
    );
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (sportKey != null) ...<Widget>[
              DabblerSportIcon.fromKey(
                sportKey!,
                size: 14,
                color: colors.textSecondary,
              ),
              const SizedBox(width: DabblerSpacing.space2),
            ],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.subheadline
                    .resolveForDirection(dir)
                    .copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: DabblerSpacing.space1),
        Row(
          children: <Widget>[
            if (place != null)
              Flexible(
                child: Text(
                  place!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: caption,
                ),
              ),
            if (place != null && time != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space2),
              dot,
              const SizedBox(width: DabblerSpacing.space2),
            ],
            if (time != null)
              Flexible(
                child: Text(
                  DabblerType.toWesternDigits(time!),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: caption,
                ),
              ),
          ],
        ),
      ],
    );
    final Widget trailing = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (status != null)
          DabblerBadge(
            label: status!,
            status: live ? colors.success : null,
            tone: DabblerBadgeTone.warning,
          ),
        if (selected) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space1),
          DabblerIcon(
            'tick-circle',
            size: DabblerSizing.iconSm,
            weight: DabblerIconWeight.bold,
            color: colors.brandPrimary,
          ),
        ],
      ],
    );
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: title,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.lgAll,
      child: DabblerSurface.card(
        radius: DabblerRadius.lg,
        borderColor: selected ? colors.brandPrimary : null,
        padding: const EdgeInsets.all(DabblerSpacing.space4),
        child: Row(
          children: <Widget>[
            dateTile,
            const SizedBox(width: DabblerSpacing.space4),
            Expanded(child: body),
            const SizedBox(width: DabblerSpacing.space4),
            trailing,
          ],
        ),
      ),
    );
  }
}
