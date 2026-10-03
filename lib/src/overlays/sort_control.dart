import 'package:flutter/widgets.dart';

import '../controls/chip.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'menu.dart';
import 'sheet.dart';

/// One choice in a [DabblerSortControl].
@immutable
class DabblerSortOption<T> {
  /// Creates an option.
  const DabblerSortOption({
    required this.value,
    required this.label,
    this.icon,
  });

  /// The value reported to [DabblerSortControl.onChanged].
  final T value;

  /// The localised label.
  final String label;

  /// An optional leading icon name, shown in the sheet.
  final String? icon;
}

/// How a [DabblerSortControl] presents its options.
enum DabblerSortControlVariant {
  /// A compact chip — label and current value — that opens a content-sized
  /// [DabblerSheet] of option rows with a check on the selected one.
  sheet,

  /// Every option inline as a [DabblerChip], the selected one filled — the
  /// "Sort by" group of the filter sheet.
  segmented,
}

/// SortControl — how a view-all list lets the reader change its order (or one
/// single-choice filter).
///
/// Drawn from `Listings.dc.html`: the sort group is one of the filter
/// sheet's chip groups (`:291-299`, options from `:1800-1814` — *Nearest*,
/// *Starting soonest*, *Lowest price*), and the sheet itself is the
/// content-sized panel at `:283` (`max-height: 80%`). The two variants are
/// those two places.
///
/// ```dart
/// DabblerSortControl<String>(
///   label: 'Sort by',
///   value: sort,
///   options: const <DabblerSortOption<String>>[
///     DabblerSortOption(value: 'near', label: 'Nearest'),
///     DabblerSortOption(value: 'soon', label: 'Starting soonest'),
///   ],
///   onChanged: (String v) => setState(() => sort = v),
/// )
/// ```
///
/// ## Composed, not painted
///
/// * The trigger and the segmented options are [DabblerChip]s.
/// * The sheet is [showDabblerSheet] with [DabblerSheetDetent.content] — a
///   short option list gives a short sheet.
/// * The rows are [DabblerMenuList] (undecorated, `listbox` role), whose
///   selected row already carries the brand `tick-circle` (`menu.dart`,
///   `DabblerMenuItem`). Nothing here draws a row or a check.
///
/// Picking a row closes the sheet and calls [onChanged] (not called when the
/// selected option is picked again).
///
/// ## Accessibility
///
/// The trigger is one button read as "label, current value". In the sheet the
/// rows are listbox options with their selected state; the segmented chips
/// are buttons with a selected state.
///
/// ## RTL
///
/// The sheet's check sits at the inline end; the segmented chips wrap from
/// the inline start. **Deviation:** the trigger's chevron sits at the chip's
/// inline *start*, because [DabblerChip] has only a leading icon slot and
/// this control adds no paint of its own.
class DabblerSortControl<T> extends StatelessWidget {
  /// Creates a sort control.
  const DabblerSortControl({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.variant = DabblerSortControlVariant.sheet,
    this.sheetTitle,
    this.semanticLabel,
  }) : assert(options.length > 0, 'a sort control needs options');

  /// What is being chosen — "Sort by". Shown on the trigger and as the sheet
  /// title.
  final String label;

  /// The choices, in display order.
  final List<DabblerSortOption<T>> options;

  /// The selected option's value.
  final T value;

  /// Called with the newly chosen value. Null disables the control.
  final ValueChanged<T>? onChanged;

  /// Sheet or inline chips.
  final DabblerSortControlVariant variant;

  /// The sheet title. Defaults to [label].
  final String? sheetTitle;

  /// Overrides the trigger's semantics label.
  final String? semanticLabel;

  /// The chevron on the trigger.
  static const String chevronIconName = 'arrow-down-1';

  DabblerSortOption<T> get _current => options.firstWhere(
    (DabblerSortOption<T> o) => o.value == value,
    orElse: () => options.first,
  );

  void _pick(T v) {
    if (v != value) {
      onChanged?.call(v);
    }
  }

  Future<void> _open(BuildContext context) async {
    final T? picked = await showDabblerSheet<T>(
      context: context,
      title: sheetTitle ?? label,
      detent: DabblerSheetDetent.content,
      builder: (BuildContext sheetContext) => DabblerMenuList(
        decorated: false,
        role: DabblerMenuRole.listbox,
        label: sheetTitle ?? label,
        items: <DabblerMenuEntry>[
          for (int i = 0; i < options.length; i++)
            DabblerMenuEntry(
              id: '$i',
              label: options[i].label,
              icon: options[i].icon,
              selected: options[i].value == value,
            ),
        ],
        onSelected: (DabblerMenuEntry e) =>
            Navigator.of(sheetContext).pop<T>(options[int.parse(e.id!)].value),
      ),
    );
    if (picked != null) {
      _pick(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    if (variant == DabblerSortControlVariant.segmented) {
      return Semantics(
        container: true,
        label: semanticLabel ?? label,
        child: Wrap(
          spacing: DabblerSpacing.space3,
          runSpacing: DabblerSpacing.space3,
          children: <Widget>[
            for (final DabblerSortOption<T> o in options)
              DabblerChip(
                label: o.label,
                selected: o.value == value,
                onTap: enabled ? () => _pick(o.value) : null,
              ),
          ],
        ),
      );
    }

    final DabblerColors colors = DabblerColors.of(context);
    final String current = _current.label;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: semanticLabel ?? '$label, $current',
      onTap: enabled ? () => _open(context) : null,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DabblerChip(
              label: '$label: $current',
              onTap: enabled ? () => _open(context) : null,
              leadingIcon: DabblerIcon(
                chevronIconName,
                size: DabblerSizing.iconSm,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
