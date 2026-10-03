import 'package:flutter/widgets.dart';

import 'dabbler_geometry.dart';

/// Named [EdgeInsets] built only from [DabblerSpacing] steps — app roles, so
/// the app never writes `EdgeInsets.*(<number>)`.
abstract final class DabblerInsets {
  const DabblerInsets._();

  /// App role: horizontal screen padding — [DabblerSpacing.screenGutter] on
  /// both sides.
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.screenGutter,
  );

  /// App role: card content padding — [DabblerSpacing.cardPadding] all round.
  static const EdgeInsets card = EdgeInsets.all(DabblerSpacing.cardPadding);

  /// App role: a list's closing bottom inset with no floating bar —
  /// [DabblerSpacing.listBottomInset] (24). Replaces the app's
  /// `EdgeInsets.only(bottom: 24)`.
  static const EdgeInsets listBottom = EdgeInsets.only(
    bottom: DabblerSpacing.listBottomInset,
  );

  /// App role: a list's bottom inset under the floating nav bar —
  /// [DabblerSpacing.floatingBarClearance] (96).
  static const EdgeInsets underFloatingBar = EdgeInsets.only(
    bottom: DabblerSpacing.floatingBarClearance,
  );

  /// App role: a row's vertical breathing room — [DabblerSpacing.space4] top
  /// and bottom. Replaces `EdgeInsets.symmetric(vertical: 12)`.
  static const EdgeInsets rowVertical = EdgeInsets.symmetric(
    vertical: DabblerSpacing.space4,
  );

  /// App role: the hairline gap between adjacent indicator segments —
  /// [DabblerSpacing.space1] on each side. Replaces the app's
  /// `EdgeInsets.symmetric(horizontal: 2)` (2 → 3).
  static const EdgeInsets segmentGap = EdgeInsets.symmetric(
    horizontal: DabblerSpacing.space1,
  );
}

/// A blank gap of one [DabblerSpacing] step — the DS replacement for a numeric
/// `SizedBox(height: …)` / `SizedBox(width: …)` spacer. App role.
///
/// [extent] must be a value of [DabblerSpacing.scale] or one of its named
/// aliases/extents; a debug assertion rejects anything else, so the gap cannot
/// smuggle a one-off number back in.
class DabblerGap extends StatelessWidget {
  /// A vertical gap of [extent] (in a [Column]).
  const DabblerGap.v(this.extent, {super.key})
    : axis = Axis.vertical,
      sliver = false;

  /// A horizontal gap of [extent] (in a [Row]).
  const DabblerGap.h(this.extent, {super.key})
    : axis = Axis.horizontal,
      sliver = false;

  /// A vertical gap of [extent] inside a [CustomScrollView]'s slivers.
  const DabblerGap.sliver(this.extent, {super.key})
    : axis = Axis.vertical,
      sliver = true;

  /// The gap's size along [axis].
  final double extent;

  /// Which axis the gap spans.
  final Axis axis;

  /// Whether the gap is a sliver.
  final bool sliver;

  /// Every extent a gap accepts: the scale plus the named layout extents.
  static const List<double> allowedExtents = <double>[
    ...DabblerSpacing.scale,
    DabblerSpacing.floatingBarClearance,
  ];

  @override
  Widget build(BuildContext context) {
    assert(
      allowedExtents.contains(extent),
      'DabblerGap takes a DabblerSpacing value; $extent is not one.',
    );
    final Widget box = axis == Axis.vertical
        ? SizedBox(height: extent)
        : SizedBox(width: extent);
    return sliver ? SliverToBoxAdapter(child: box) : box;
  }
}
