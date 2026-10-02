import 'package:flutter/widgets.dart';

import '../forms/checkbox.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// One row of a [DabblerChecklistPanel].
@immutable
class DabblerChecklistItem {
  /// A row.
  const DabblerChecklistItem({required this.label, this.done = false});

  /// The task text.
  final String label;

  /// Whether the task is done; a done row goes muted.
  final bool done;
}

/// ChecklistPanel — the task rows inside a `PanelCard`. Checked rows go muted.
///
/// Ported from the live design project's
/// `components/cards/ChecklistPanel.jsx` (design system 1.2.0). Each row is a
/// [DabblerCheckbox] and a one-line label; rows are 6 apart. [dark] is the ink
/// panel treatment (page-coloured text), the same flag `PanelCard` takes.
///
/// Type: the label is `subheadline` (15/20) at weight 500 — the ramp has no
/// 15/500, so this is a weight override on a named step, recorded in the
/// type-override register.
class DabblerChecklistPanel extends StatelessWidget {
  /// A checklist.
  const DabblerChecklistPanel({
    super.key,
    this.items = const <DabblerChecklistItem>[],
    this.onToggle,
    this.dark = false,
  });

  /// The rows.
  final List<DabblerChecklistItem> items;

  /// Called with the row index when a checkbox is toggled.
  final ValueChanged<int>? onToggle;

  /// The ink-panel treatment.
  final bool dark;

  /// Gap between rows — `gap: 6`.
  static const double rowGap = DabblerSpacing.space2;

  /// Gap between checkbox and label — `gap: 12`.
  static const double columnGap = DabblerSpacing.space4;

  /// The label's weight — `fontWeight: 500`.
  static const FontWeight labelWeight = FontWeight.w500;

  /// The label colour of a row.
  static Color labelColorFor(
    DabblerColors colors, {
    required bool done,
    required bool dark,
  }) {
    if (done) return colors.textSecondary;
    return dark ? DabblerPalette.surfacePage : colors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: rowGap),
          Row(
            children: <Widget>[
              DabblerCheckbox(
                checked: items[i].done,
                onChanged: onToggle == null ? null : (bool _) => onToggle!(i),
                semanticLabel: items[i].label,
              ),
              const SizedBox(width: columnGap),
              Expanded(
                child: Text(
                  items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.subheadline
                      .resolveForDirection(direction)
                      .copyWith(
                        fontWeight: labelWeight,
                        color: labelColorFor(
                          colors,
                          done: items[i].done,
                          dark: dark,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
