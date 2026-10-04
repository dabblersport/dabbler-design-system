import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// ActionBar — the bar pinned to the bottom of a detail screen: a price on the
/// inline start and the screen's actions beside it.
///
/// Drawn from the three Details frames (`Details.dc.html:178-190` game,
/// `:354-366` meetup, `:517-529` venue): a page-coloured bar with a hairline on
/// top, `15 18 24` padding, the price as a 20/26 bold figure over an 11/15
/// caption, then the call to action filling the rest of the row — on the venue
/// frame a secondary button sits between them.
///
/// ```dart
/// DabblerPage(
///   bottomBar: DabblerActionBar(
///     price: 'AED 40',
///     caption: 'per player',
///     primary: DabblerButton(
///       label: 'Join game',
///       size: DabblerButtonSize.full,
///       fullWidth: true,
///       onPressed: join,
///     ),
///   ),
///   body: ...,
/// )
/// ```
///
/// ## Slots
///
/// * [price] / [caption] — the figure and its unit. Either may be null; with
///   neither the actions take the whole bar.
/// * [secondary] — an optional button between the price and [primary].
/// * [primary] — the call to action; it takes the remaining width. Null leaves
///   the bar as a price alone.
///
/// ## Where it goes
///
/// As a `DabblerPage.bottomBar`: the page shrinks the body above it. The bar
/// pads its own bottom edge by the larger of [bottomInset] (24, the design's
/// value) and the device's home-indicator inset.
///
/// ## Type
///
/// [price] is the design's 20/26 bold *sans* figure: the ramp's 20 is the
/// display face, so the sans `headline` step is taken at the design's size and
/// leading (the override `DabblerHeadcount` and `DabblerStatTile`'s detail size
/// also record). [caption] is `caption2` (11/15) in the secondary ink.
///
/// ## RTL
///
/// The price sits at the inline start and [primary] fills towards the inline
/// end; both mirror with the ambient direction.
class DabblerActionBar extends StatelessWidget {
  /// An action bar.
  const DabblerActionBar({
    super.key,
    this.price,
    this.caption,
    this.secondary,
    this.primary,
  });

  /// The price figure, e.g. `AED 120`.
  final String? price;

  /// The unit under [price], e.g. `per hour`.
  final String? caption;

  /// An optional secondary action between the price and [primary].
  final Widget? secondary;

  /// The call to action. Takes the remaining width.
  final Widget? primary;

  /// The price's size — `20` (`Details.dc.html:180`).
  static const double priceSize = 20;

  /// The price's line height — `26`.
  static const double priceLeading = 26;

  /// The side padding — [DabblerSpacing.space6] (18).
  static const double paddingInline = DabblerSpacing.space6;

  /// The top padding — [DabblerSpacing.space5] (15).
  static const double paddingTop = DabblerSpacing.space5;

  /// The bottom padding — [DabblerSpacing.space8] (24), raised to the safe-area
  /// inset where that is larger.
  static const double bottomInset = DabblerSpacing.space8;

  /// The gap between the price, [secondary] and [primary] —
  /// [DabblerSpacing.space5] (15).
  static const double gap = DabblerSpacing.space5;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    final Widget? priceBlock = price == null && caption == null
        ? null
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (price != null)
                Text(
                  price!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.headline
                      .resolveForDirection(direction)
                      .copyWith(
                        color: colors.textPrimary,
                        fontSize: priceSize,
                        height: priceLeading / priceSize,
                        fontWeight: DabblerType.bold,
                      ),
                ),
              if (caption != null)
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.caption2
                      .resolveForDirection(direction)
                      .copyWith(color: colors.textSecondary),
                ),
            ],
          );

    final List<Widget> row = <Widget>[
      if (priceBlock != null) Flexible(child: priceBlock),
      if (priceBlock != null && (secondary != null || primary != null))
        const SizedBox(width: gap),
      if (secondary != null) ...<Widget>[
        secondary!,
        if (primary != null) const SizedBox(width: DabblerSpacing.space3),
      ],
      if (primary != null) Expanded(child: primary!),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: BorderDirectional(
          top: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          paddingInline,
          paddingTop,
          paddingInline,
          math.max(bottomInset, safeBottom),
        ),
        child: Row(children: row),
      ),
    );
  }
}
