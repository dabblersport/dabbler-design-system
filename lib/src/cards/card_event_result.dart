import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../forms/highlighted_text.dart';
import '../surfaces/badge.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// CardEventResult — one game or meet-up as a search result: a brand-tinted
/// date tile, a kind badge with the time, the title with the typed query
/// highlighted, the place and a trailing meta line, and an optional action.
///
/// Transcribed from `Search.dc.html` (View_all_events): a white hairline card
/// of 12 padding and `--radius-lg`, a 48-wide date tile (month 11/600 caps,
/// day 19/700, both brand, on a 10% brand tint), then the text column and a
/// small pill action.
///
/// ```dart
/// DabblerCardEventResult(
///   month: 'AUG', day: '18', kind: 'Game', kindIcon: 'game',
///   time: 'Today · 8:00 PM', title: 'Dabbler Football Night',
///   query: 'dabbler', place: 'Al Maryah Island', meta: '0/10 spots',
///   actionLabel: 'Join', onAction: () {}, onTap: () {},
/// )
/// ```
///
/// RTL: a [Row] under [Directionality]; the tile leads and the action trails
/// in both directions.
class DabblerCardEventResult extends StatelessWidget {
  /// Creates an event result card.
  const DabblerCardEventResult({
    super.key,
    required this.month,
    required this.day,
    required this.kind,
    this.kindIcon,
    required this.time,
    required this.title,
    this.query = '',
    this.place,
    this.meta,
    this.actionLabel,
    this.onAction,
    this.onTap,
  });

  /// The tile's month line (rendered upper-case).
  final String month;

  /// The tile's day number.
  final String day;

  /// The kind badge's text ("Game", "Meet-up").
  final String kind;

  /// The kind badge's glyph name; bold weight.
  final String? kindIcon;

  /// The date / time text beside the badge.
  final String time;

  /// The title.
  final String title;

  /// The typed words highlighted inside [title].
  final String query;

  /// The place line; omitted when null.
  final String? place;

  /// The semibold trailing text after the place ("0/10 spots").
  final String? meta;

  /// The pill action's label; no action when null.
  final String? actionLabel;

  /// The action's callback.
  final VoidCallback? onAction;

  /// Tapping the card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s, Color c, [FontWeight? w]) =>
        s.resolveForDirection(dir).copyWith(color: c, fontWeight: w);

    final Widget tile = DabblerSurface.brandTint(
      radius: DabblerRadius.md,
      borderWidth: 0,
      width: DabblerSizing.touchTargetMin + DabblerSpacing.space1,
      center: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            month.toUpperCase(),
            style: t(
              DabblerType.caption2,
              colors.brandPrimary,
              DabblerType.semibold,
            ),
          ),
          Text(
            day,
            style: t(
              DabblerType.headline,
              colors.brandPrimary,
              DabblerType.bold,
            ),
          ),
        ],
      ),
    );

    return DabblerCard(
      variant: DabblerCardVariant.white,
      radius: DabblerRadius.lg,
      padding: const EdgeInsets.all(DabblerSpacing.space4),
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DabblerSpacing.space4,
          children: <Widget>[
            tile,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DabblerSpacing.space1,
                children: <Widget>[
                  Row(
                    spacing: DabblerSpacing.space2,
                    children: <Widget>[
                      DabblerBadge(
                        label: kind,
                        tone: DabblerBadgeTone.warning,
                        icon: kindIcon == null
                            ? null
                            : DabblerIcon(
                                kindIcon!,
                                weight: DabblerIconWeight.bold,
                                size: DabblerSizing.iconXs,
                              ),
                      ),
                      Expanded(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t(DabblerType.caption1, colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  DabblerHighlightedText(
                    text: title,
                    query: query,
                    style: DabblerType.subheadline,
                    fontWeight: DabblerHighlightedText.matchWeight,
                    maxLines: 1,
                  ),
                  if (place != null || meta != null)
                    Row(
                      spacing: DabblerSpacing.space2,
                      children: <Widget>[
                        if (place != null) ...<Widget>[
                          DabblerIcon(
                            'location',
                            size: DabblerSizing.iconXs,
                            color: colors.textTertiary,
                          ),
                          Flexible(
                            child: Text(
                              place!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t(
                                DabblerType.caption1,
                                colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                        if (meta != null)
                          Text(
                            meta!,
                            maxLines: 1,
                            style: t(
                              DabblerType.caption1,
                              colors.textSecondary,
                              DabblerType.semibold,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (actionLabel != null)
              Center(
                child: DabblerButton(
                  label: actionLabel!,
                  size: DabblerButtonSize.small,
                  onPressed: onAction,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
