part of 'bottom_bar.dart';

/// The unread dot and count pill on a [DabblerNavigationItem] (KAN-412 W1 gap
/// 6).
///
/// Both are the system's own [DabblerBadge]: the dot is [DabblerBadge.dot]
/// (7px, KAN-411) and the count is a [DabblerBadge] pill. They are anchored on
/// the icon's top-inline-end corner with [PositionedDirectional], so they sit
/// top-right in English and top-left in Arabic.
///
/// **Ring.** The bar's inactive icons sit on the brand-filled pill, so a brand
/// dot straight onto it would vanish. Each indicator therefore carries a
/// [ringWidth] ring in [DabblerColors.surfaceCard] — the same device as the top
/// bar's page-coloured ring (`DabblerNavigationUnreadDot`) — which separates it
/// from the pill and is invisible on the active chip, which is already
/// `surfaceCard`.
///
/// **Not read from the design.** The Home Feed file the bar is drawn in is
/// truncated and no readable design draws a bar indicator; the offsets below
/// are this system's, anchored to the glyph, and recorded as such rather than
/// transcribed.
abstract final class DabblerNavigationItemBadge {
  /// The ring around an indicator, matching the top bar's 2px ring.
  static const double ringWidth = 2;

  /// How far the dot's ring overhangs the glyph's top-end corner.
  static const double dotInset = -3;

  /// The count pill's overhang from the glyph's top edge.
  static const double countTopInset = -14;

  /// The count pill's overhang from the glyph's end edge.
  static const double countEndInset = -16;

  /// The largest count drawn as a number; above it the pill reads `99+`.
  static const int maxCount = 99;

  /// Finds the dot in a test.
  static const Key dotKey = ValueKey<String>('dabbler-bottom-bar-dot');

  /// Finds the count pill in a test.
  static const Key countKey = ValueKey<String>('dabbler-bottom-bar-count');

  /// The count's text: the number, or `99+`.
  static String countText(int count) =>
      count > maxCount ? '$maxCount+' : '$count';

  static bool _hasCount(DabblerNavigationItem item) =>
      item.count != null && item.count! > 0;

  /// Whether [item] draws any indicator.
  static bool hasIndicator(DabblerNavigationItem item) =>
      _hasCount(item) || item.unread;

  /// The item's accessible name: its label, plus its
  /// [DabblerNavigationItem.badgeLabel] while an indicator shows
  /// (`Inbox, 3 unread`).
  static String semanticLabel(DabblerNavigationItem item) {
    if (!hasIndicator(item)) return item.label;
    final String? extra = item.badgeLabel;
    if (extra != null && extra.isNotEmpty) return '${item.label}, $extra';
    return _hasCount(item)
        ? '${item.label}, ${countText(item.count!)}'
        : item.label;
  }

  /// [glyph] with [item]'s indicator on its top-inline-end corner.
  static Widget wrap({
    required DabblerNavigationItem item,
    required DabblerColors colors,
    required Widget glyph,
  }) {
    if (!hasIndicator(item)) return glyph;
    final bool count = _hasCount(item);
    final Widget indicator = DecoratedBox(
      key: count ? countKey : dotKey,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ringWidth),
        child: count
            ? DabblerBadge(label: countText(item.count!))
            : const DabblerBadge.dot(),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        glyph,
        PositionedDirectional(
          top: count ? countTopInset : dotInset,
          end: count ? countEndInset : dotInset,
          child: indicator,
        ),
      ],
    );
  }
}
