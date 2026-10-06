import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/text.dart';
import '../interaction/expanded_hit_area.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'chip.dart';
import 'text_link.dart';

/// One applied filter in a [DabblerFilterRail].
@immutable
class DabblerFilterRailItem {
  /// An applied filter shown as [label]; [onRemove] clears it.
  const DabblerFilterRailItem({
    required this.label,
    required this.onRemove,
    this.removeSemanticLabel,
  });

  /// The filter's value, already localised — `Within 5 km`.
  final String label;

  /// Clears this filter.
  final VoidCallback onRemove;

  /// The remove control's accessible name; defaults to the chip's own.
  final String? removeSemanticLabel;
}

/// FilterRail — the applied-filters rail under a listing's tabs: one solid
/// brand pill per filter with its own remove glyph, then a "Clear all" text
/// action.
///
/// Drawn from `Listings.dc.html:97-107`: each pill 32 tall ([pillHeight]),
/// `padding: 7px 9px 7px 14px`, 13/18 weight 500 on-brand, a bold 16px
/// `close-circle` at 80% ([removeIconSize]); pills `gap: 6`. (Until the
/// Listings fidelity pass the pills were the small [DabblerChip], 34 tall with
/// an 18px glyph.)
///
/// ```dart
/// DabblerFilterRail(
///   items: <DabblerFilterRailItem>[
///     DabblerFilterRailItem(label: 'Within 5 km', onRemove: clearDistance),
///   ],
///   clearAllLabel: 'Clear all',
///   onClearAll: clearAll,
/// )
/// ```
///
/// Renders nothing when [items] is empty. The rail scrolls horizontally when
/// the pills overflow; each remove glyph is a button with a 45 target.
///
/// ## RTL
///
/// Chips start at the inline start and "Clear all" follows the last chip;
/// the scroll starts at the inline start.
class DabblerFilterRail extends StatelessWidget {
  /// A rail for [items].
  const DabblerFilterRail({
    super.key,
    required this.items,
    required this.clearAllLabel,
    this.onClearAll,
    this.padding = EdgeInsetsDirectional.zero,
  });

  /// The applied filters, in order.
  final List<DabblerFilterRailItem> items;

  /// The trailing action's text.
  final String clearAllLabel;

  /// Clears every filter. Null hides the action.
  final VoidCallback? onClearAll;

  /// Padding around the rail (a screen gutter, say).
  final EdgeInsetsGeometry padding;

  /// Finds the clear-all action in a test.
  static const Key clearAllKey = ValueKey<String>('dabbler-filter-rail-clear');

  /// An applied filter's pill height — `padding: 7px` around the 18px line
  /// (`Listings.dc.html:100`): 32.
  static const double pillHeight = 32;

  /// The pill's padding at its inline start — `14px`.
  static const double pillPaddingStart = 14;

  /// The pill's padding at its inline end, before the remove glyph — `9px`.
  static const double pillPaddingEnd = DabblerSpacing.space3;

  /// The remove glyph — `close-circle`, bold, `size="16"`, at 80% opacity.
  static const double removeIconSize = 16;

  /// See [removeIconSize].
  static const double removeIconOpacity = 0.8;

  /// Key of each applied pill, by label.
  static Key pillKeyFor(String label) =>
      ValueKey<String>('dabbler-filter-rail-pill/$label');

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        spacing: DabblerSpacing.space2,
        children: <Widget>[
          for (final DabblerFilterRailItem item in items)
            _AppliedPill(item: item),
          if (onClearAll != null)
            DabblerTextLink(
              key: clearAllKey,
              label: clearAllLabel,
              underline: false,
              muted: true,
              style: DabblerType.footnote
                  .resolveForDirection(Directionality.of(context))
                  .copyWith(fontWeight: DabblerType.semibold),
              onPressed: onClearAll,
            ),
        ],
      ),
    );
  }
}

/// FilterGroup — a labelled group of option chips inside a filter sheet.
///
/// Drawn from `Listings.dc.html:291-299`: a caption over a wrapping row of
/// [DabblerChip]s, the chosen one selected.
///
/// ```dart
/// DabblerFilterGroup(
///   label: 'Date',
///   children: <Widget>[
///     DabblerChip(label: 'Today', selected: true, onTap: pick),
///     DabblerChip(label: 'Tomorrow', onTap: pick),
///   ],
/// )
/// ```
class DabblerFilterGroup extends StatelessWidget {
  /// A group captioned [label] holding [children].
  const DabblerFilterGroup({
    super.key,
    required this.label,
    required this.children,
  });

  /// The group's caption.
  final String label;

  /// The option chips. Wraps.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        Semantics(
          header: true,
          child: DabblerText(
            label,
            style: DabblerType.footnote,
            weight: DabblerTextWeight.semibold,
            tone: DabblerTextTone.secondary,
          ),
        ),
        Wrap(
          spacing: DabblerSpacing.space3,
          runSpacing: DabblerSpacing.space3,
          children: children,
        ),
      ],
    );
  }
}

/// One applied filter (`Listings.dc.html:100-104`): a solid brand pill,
/// 13/18 weight 500 on-brand, `gap: 6` to a bold `close-circle` at 16 and 80%
/// opacity. The glyph is its own button with a 45 hit-test-only target.
class _AppliedPill extends StatelessWidget {
  const _AppliedPill({required this.item});

  final DabblerFilterRailItem item;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Container(
      key: DabblerFilterRail.pillKeyFor(item.label),
      height: DabblerFilterRail.pillHeight,
      padding: const EdgeInsetsDirectional.only(
        start: DabblerFilterRail.pillPaddingStart,
        end: DabblerFilterRail.pillPaddingEnd,
      ),
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DabblerSpacing.space2,
        children: <Widget>[
          Text(
            item.label,
            maxLines: 1,
            softWrap: false,
            style: DabblerType.footnote
                .resolveForDirection(direction)
                .copyWith(
                  color: colors.onBrand,
                  fontWeight: DabblerType.medium,
                ),
          ),
          Semantics(
            button: true,
            label:
                item.removeSemanticLabel ??
                DabblerChip.defaultRemoveLabelFor(item.label),
            onTap: item.onRemove,
            excludeSemantics: true,
            child: DabblerExpandedHitArea(
              minimum: const Size.square(DabblerSizing.touchTargetMin),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: item.onRemove,
                child: Opacity(
                  opacity: DabblerFilterRail.removeIconOpacity,
                  child: DabblerIcon(
                    DabblerChip.removeIconName,
                    weight: DabblerIconWeight.bold,
                    size: DabblerFilterRail.removeIconSize,
                    color: colors.onBrand,
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
