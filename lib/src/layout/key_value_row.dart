import 'package:flutter/widgets.dart';

import '../foundations/text.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// How a [DabblerKeyValueRow] lays its label and value out.
enum DabblerKeyValueLayout {
  /// Label at the inline start, value at the inline end, side by side. The
  /// value wraps inside the space the label leaves.
  inline,

  /// Label above, value below, both from the inline start. For a value that
  /// is a sentence or more.
  stacked,
}

/// KeyValueRow — a read-only label and its value, the line a detail sheet or
/// a summary card is made of.
///
/// It is **not** an input row: it has no tap, no chevron and no control. Use
/// `DabblerInputRow` for a row the reader acts on; use this one to state a
/// fact ("Status — Completed", "Address — Plot 12, Marina Walk").
///
/// ```dart
/// DabblerKeyValueRow(label: 'Recipient', value: 'Al Ahly Sports Club')
/// DabblerKeyValueRow(
///   label: 'Description',
///   value: 'Four covered courts with floodlights and a small café.',
///   layout: DabblerKeyValueLayout.stacked,
/// )
/// DabblerKeyValueRow(label: 'Status', trailing: DabblerBadge(label: 'PAID'))
/// ```
///
/// ## Long values wrap
///
/// In [DabblerKeyValueLayout.inline] the label keeps its natural width (up to
/// half the row) and the value takes the rest and **wraps** onto further
/// lines, aligned to the inline end; nothing is ellipsised. In
/// [DabblerKeyValueLayout.stacked] the value runs the full width.
///
/// ## Slots
///
/// Give a [value] string, or a [trailing] widget (a badge, a pill) in its
/// place. The label is [DabblerType.subheadline] in the secondary ink; the
/// value is the same step at weight 600.
///
/// ## RTL
///
/// Everything is directional: the label sits at the inline start and the
/// value at the inline end, so in Arabic they swap sides with no conditional.
class DabblerKeyValueRow extends StatelessWidget {
  /// A label/value row.
  const DabblerKeyValueRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
    this.valueTone = DabblerTextTone.primary,
    this.layout = DabblerKeyValueLayout.inline,
  }) : assert(
         value != null || trailing != null,
         'give a value or a trailing widget',
       );

  /// The key — what the value is.
  final String label;

  /// The value text. Wraps.
  final String? value;

  /// A widget shown where [value] would be (a badge, a pill).
  final Widget? trailing;

  /// The ink of [value].
  final DabblerTextTone valueTone;

  /// Side by side, or stacked.
  final DabblerKeyValueLayout layout;

  /// The gap between label and value — [DabblerSpacing.space4].
  static const double gap = DabblerSpacing.space4;

  /// The row's vertical padding — [DabblerSpacing.space3].
  static const double paddingBlock = DabblerSpacing.space3;

  @override
  Widget build(BuildContext context) {
    final Widget labelText = DabblerText(
      label,
      style: DabblerType.subheadline,
      tone: DabblerTextTone.secondary,
    );
    final Widget valueWidget =
        trailing ??
        DabblerText(
          value!,
          style: DabblerType.subheadline,
          tone: valueTone,
          weight: DabblerTextWeight.semibold,
          textAlign: layout == DabblerKeyValueLayout.inline
              ? TextAlign.end
              : TextAlign.start,
        );

    final Widget body = layout == DabblerKeyValueLayout.stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              labelText,
              const SizedBox(height: DabblerSpacing.space1),
              valueWidget,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(flex: 1, child: labelText),
              const SizedBox(width: gap),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: valueWidget,
                ),
              ),
            ],
          );

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: paddingBlock),
      child: body,
    );
  }
}
