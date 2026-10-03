import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import 'sheet.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// SheetList — a bounded-height scrolling list for the body of a
/// [showDabblerSheet].
///
/// The sheet already scrolls its own content, so an unbounded `ListView`
/// inside it either fails layout or builds every row. This part gives the
/// list a height of its own — at most [maxHeightFraction] of the viewport, or
/// [maxHeight] — and lets it shrink to fit a short list, with an optional
/// pinned [header] (a search field) above the scrolling rows.
///
/// Transcribed from the location picker sheet, `Listings.dc.html:313-345`: a
/// pinned search box (`padding: 12px 18px 9px; flex-shrink: 0`) over a
/// scrolling list (`flex: 1; min-height: 0; overflow-y: auto`) of rows.
///
/// ```dart
/// showDabblerSheet<void>(
///   context: context,
///   title: 'Change location',
///   detent: DabblerSheetDetent.content,
///   builder: (_) => DabblerSheetList(
///     header: DabblerSearchField(onChanged: filter),
///     itemCount: places.length,
///     itemBuilder: (_, int i) => DabblerMenuItem(label: places[i]),
///     emptyText: 'Nothing matches that.',
///   ),
/// )
/// ```
///
/// ## States
///
/// * **loading** — a centred [DabblerSpinner] in place of the rows; the
///   header stays, so a query can still be edited.
/// * **empty** — [empty], else [emptyText] in `footnote` `--muted`, centred.
///   Nothing when both are null.
/// * **rows** — a lazily built list, shrink-wrapped up to the bound.
///
/// ## RTL
///
/// Rows lay out in the ambient direction; the part adds no horizontal paint.
class DabblerSheetList extends StatelessWidget {
  /// Creates a bounded sheet list.
  const DabblerSheetList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.loading = false,
    this.empty,
    this.emptyText,
    this.loadingLabel,
    this.maxHeight,
    this.maxHeightFraction = defaultMaxHeightFraction,
    this.controller,
  });

  /// How many rows.
  final int itemCount;

  /// Builds row [index].
  final IndexedWidgetBuilder itemBuilder;

  /// Pinned above the rows — typically a search field.
  final Widget? header;

  /// Shows the spinner instead of the rows.
  final bool loading;

  /// Shown when [itemCount] is zero and not [loading].
  final Widget? empty;

  /// Text shown when empty and [empty] is null.
  final String? emptyText;

  /// The spinner's semantics label.
  final String? loadingLabel;

  /// An absolute cap on the rows' height. Wins over [maxHeightFraction].
  final double? maxHeight;

  /// The rows' cap as a fraction of the viewport height.
  final double maxHeightFraction;

  /// An optional scroll controller for the rows.
  final ScrollController? controller;

  /// Half the viewport — leaves the sheet's title and header in view under
  /// the sheet's own 80% content cap.
  static const double defaultMaxHeightFraction = 0.5;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double cap =
        maxHeight ?? MediaQuery.sizeOf(context).height * maxHeightFraction;

    final Widget body;
    if (loading) {
      body = Padding(
        padding: const EdgeInsets.all(DabblerSpacing.space8),
        child: Center(child: DabblerSpinner(label: loadingLabel)),
      );
    } else if (itemCount == 0) {
      body =
          empty ??
          (emptyText == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(DabblerSpacing.space8),
                  child: Text(
                    emptyText!,
                    textAlign: TextAlign.center,
                    style: DabblerType.footnote
                        .resolveForDirection(Directionality.of(context))
                        .copyWith(color: colors.textTertiary),
                  ),
                ));
    } else {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap),
        child: ListView.builder(
          controller: controller,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (header != null) ...<Widget>[
          header!,
          const SizedBox(height: DabblerSpacing.space3),
        ],
        body,
      ],
    );
  }
}
