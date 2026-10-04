import 'package:flutter/widgets.dart';

import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';

/// TileGrid — equal-width tiles in a fixed number of columns, where the tiles
/// of a row take the height of the tallest in it.
///
/// The sport step of `Auth and Onboarding.dc.html:401-413` lays its tiles in
/// `grid-template-columns:repeat(4,1fr);gap:9px`, and a grid row is as tall as
/// its tallest cell. A Flutter `GridView` fixes one height for every cell, so
/// a two-line label (*Table Tennis*) would either clip or leave every
/// single-line tile too tall. This builds the rows instead: each is a [Row] of
/// [columns] [Expanded] cells, stretched to the row's intrinsic height.
///
/// ```dart
/// DabblerTileGrid(
///   columns: 4,
///   children: [for (final s in sports) DabblerSelectableCard(layout: tile, …)],
/// )
/// ```
///
/// A last row with fewer than [columns] tiles leaves the remaining cells empty
/// at the same width, so its tiles line up with the rows above.
///
/// It does not scroll: put it in a scrolling body. [gap] defaults to
/// [DabblerSpacing.space3] (9), the source's `gap`, both across and down.
///
/// ## RTL
///
/// Rows fill from the inline start, so the first tile is at the right in RTL.
class DabblerTileGrid extends StatelessWidget {
  /// Creates a grid of [columns] columns.
  const DabblerTileGrid({
    super.key,
    required this.children,
    this.columns = 4,
    this.gap = DabblerSpacing.space3,
  }) : assert(columns > 0, 'a grid has at least one column');

  /// The tiles, in reading order.
  final List<Widget> children;

  /// How many tiles a row holds.
  final int columns;

  /// The space between tiles, across and down.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int start = 0; start < children.length; start += columns) {
      if (rows.isNotEmpty) rows.add(DabblerGap.v(gap));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int c = 0; c < columns; c++) ...<Widget>[
                if (c > 0) DabblerGap.h(gap),
                Expanded(
                  child: start + c < children.length
                      ? children[start + c]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
