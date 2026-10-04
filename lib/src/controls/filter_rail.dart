import 'package:flutter/widgets.dart';

import '../foundations/text.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'button.dart';
import 'chip.dart';

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

/// FilterRail — the applied-filters rail under a listing's tabs: one selected
/// removable [DabblerChip] per filter, then a "Clear all" text action.
///
/// Drawn from `Listings.dc.html:101-111` (Alpha fidelity rebuild, KAN-426).
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
/// the chips overflow; the chips keep their own press and focus.
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
            DabblerChip(
              label: item.label,
              selected: true,
              onRemove: item.onRemove,
              removeSemanticLabel: item.removeSemanticLabel,
            ),
          if (onClearAll != null)
            DabblerButton(
              key: clearAllKey,
              label: clearAllLabel,
              tone: DabblerButtonTone.neutral,
              size: DabblerButtonSize.small,
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
