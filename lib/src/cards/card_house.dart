import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// CardHouse — a house (a recurring room series) as one row: a brand-filled
/// icon well beside the house's name and its cadence, over a full-width pill
/// that joins it.
///
/// Transcribed from `components/cards/CardHouse.jsx` (Figma node `8:34
/// Card/House`) and its `CardHouse.d.ts`. That file ships no `.prompt.md`, so
/// the JSX and the type declaration are the whole specification; every
/// deviation below is annotated with the reason.
///
/// ```dart
/// DabblerCardHouse(
///   name: 'Dabbler Design House',
///   meta: '25–50 rooms / week',
///   actionLabel: 'join house',
///   onAction: () {},
/// )
/// ```
///
/// ## It composes [DabblerCard] and adds no chrome (KAN-233 AC1)
///
/// The fill, the border, the radius, the padding, the press affordance and the
/// focus ring all come from [DabblerCard]; this file supplies content only.
/// `CardHouse.jsx` paints `backgroundColor: var(--neutral-200)` with no border,
/// which is exactly [DabblerCardVariant.standard] — `--surface-sunken`, the
/// tonal card fill — so the default variant is taken rather than restated.
///
/// ## The join pill lives in [DabblerCard.footer], not in `child`
///
/// DS-800's published slot map suggested `child: Row(icon well, title/meta)`
/// and stopped there. The design source does not: `CardHouse.jsx` draws a
/// **second** block below that row — a full-bleed-to-the-gutter pill filled
/// `var(--purple-600)` carrying `"join house"` in white. It is the card's only
/// action and the reason the Figma frame is 153 tall rather than ~96.
///
/// The source is authoritative over the slot map, so the row goes in
/// [DabblerCard.child] and the pill in [DabblerCard.footer] — which is the slot
/// DS-800 documents as *"a price beside its actions, a status row"*, i.e. the
/// action slot. Nothing about the map's intent is lost; it was simply written
/// from the card's top half. Reported to the orchestrator with KAN-233.
///
/// ## The three geometry deviations, all of them token-over-literal
///
/// Same direction as [DabblerCard]'s own two, and for the same stated reason —
/// the Figma dump is a dump, the token file is the system:
///
/// | Source literal | Taken here | Why |
/// |---|---|---|
/// | `borderRadius: 16` on the card | [DabblerCard.defaultRadius] (12) | 16 is not a step of the base-3 ramp; `--radius-lg` is annotated *"cards"* |
/// | `padding: "16px"` on the row | [DabblerCard.defaultPadding] (18) | `--card-padding` is `--space-6` |
/// | pill `height: 41` | [DabblerSizing.touchTargetMin] (45) | `--touch-target-min` is 45 and clears Apple's 44pt floor; 41 does not |
///
/// The row's own `gap: 12` needs no deviation: it is [DabblerSpacing.stackDefault]
/// exactly, and so is the gap [DabblerCard] already puts between its slots.
///
/// ## The glyph is an Iconsax name, not the Figma path
///
/// The source inlines a 32×36 `<svg><path>` of a stylised house, drawn with
/// `fill: currentColor` inside the well. This package does not carry raw Figma
/// paths: DS-300's [DabblerIcon] is the icon layer, and `home-2` is the
/// vocabulary's house. It renders at [DabblerSizing.iconLg] (30), the ramp step
/// nearest the source's 32×36 box — 32 and 36 are neither icon steps nor
/// base-3, and an icon that is 32 wide and 36 tall is not square at all, which
/// is a Figma bounding box rather than a specified size.
///
/// Callers who genuinely need a different mark pass [icon].
///
/// ## The join pill is drawn here, pending `DabblerButton`
///
/// `lib/src/controls/button.dart` landed while KAN-233 was being written and is
/// another ticket's surface, so the pill is the source's own — brand fill,
/// `--color-on-brand` label, pill radius — wrapped in the system's press and
/// focus primitives rather than inventing an interaction language. Replacing it
/// with a `DabblerButton` is a reported hand-off, shared with `CardTicket`.
class DabblerCardHouse extends StatelessWidget {
  /// A house card for [name].
  const DabblerCardHouse({
    super.key,
    required this.name,
    this.meta,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
  });

  /// The house's name — `text1`, defaulting to *"Dabbler Design House"* in the
  /// source. Required here: a house card with no name is not a state the
  /// product has.
  final String name;

  /// The cadence line beneath [name] — `text2`, *"25–50 rooms / week"*. Null
  /// drops the line and the row closes up.
  final String? meta;

  /// The mark inside the well. Null draws `home-2` at
  /// [DabblerSizing.iconLg]; see the class doc for why the source's inline SVG
  /// is not transcribed.
  ///
  /// Supplied widgets are tinted by the enclosing [IconTheme], which this
  /// component sets to [DabblerColors.onBrand] — the well is brand-filled, so
  /// a mark that inherits reads correctly without the caller knowing that.
  final Widget? icon;

  /// The join pill's label — `text3`, *"join house"*. Null drops the pill
  /// entirely, which is the right card for a house the viewer has already
  /// joined.
  final String? actionLabel;

  /// Tapping the join pill. A label with no callback renders an inert pill,
  /// which is how a disabled action reads.
  final VoidCallback? onAction;

  /// Makes the whole card tappable — opening the house. Passed straight to
  /// [DabblerCard.onTap], so the press scale and focus ring are the system's.
  final VoidCallback? onTap;

  /// Whether the card and its pill accept input.
  final bool enabled;

  /// The accessible label of a tappable card. Ignored when [onTap] is null.
  final String? semanticLabel;

  /// Fixed width. Null sizes to the incoming constraints.
  ///
  /// The source's `width: 417.5` is a Figma frame measurement, not a
  /// specification — a card in a list takes its column's width.
  final double? width;

  /// The icon well's side — `width: 64, height: 64` (`CardHouse.jsx`).
  ///
  /// **Off the base-3 grid, and transcribed anyway.** 64 is not a step of
  /// [DabblerSpacing] and there is no sizing token for a card's icon well, so
  /// there is nothing to snap to; inventing 63 or 66 to satisfy the ramp would
  /// change the row's height for no source-backed reason.
  static const double wellSide = 64;

  /// The well's corner radius — `borderRadius: 12`, which *is*
  /// [DabblerRadius.lg] exactly, annotated *"cards, icon tiles"*. No deviation.
  static const double wellRadius = DabblerRadius.lg;

  /// The gap between the well and the text column — `gap: 12`
  /// ([DabblerSpacing.stackDefault]).
  static const double rowGap = DabblerSpacing.stackDefault;

  /// The join pill's height.
  ///
  /// [DabblerSizing.touchTargetMin] (45), not the source's `height: 41`. See
  /// the class doc's deviation table.
  static const double actionHeight = DabblerSizing.touchTargetMin;

  /// [name]'s style: `.t-subheadline` at [DabblerType.bold].
  ///
  /// The source sets `--font-size-body-lg` (15, `tokens/figma/fig-tokens.css:6`)
  /// at `fontWeight: 700`. 15 is `.t-subheadline`'s size exactly; the ramp step
  /// carries weight 400, so the source's own weight is applied on top of the
  /// step rather than a new step being invented — the precedent
  /// `lib/src/surfaces/badge.dart` set for `Badge`'s 11px Bold.
  static TextStyle nameStyleFor(TextDirection direction) =>
      DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(fontWeight: DabblerType.bold);

  /// [meta]'s style: `.t-footnote`, unmodified.
  ///
  /// The source's `--font-size-body-sm` is 13 at weight 400
  /// (`fig-tokens.css:7`), which is the footnote step exactly.
  static TextStyle metaStyleFor(TextDirection direction) =>
      DabblerType.footnote.resolveForDirection(direction);

  /// The join pill's label style: `.t-label`.
  ///
  /// The source writes `--font-size-body` (14) at `fontWeight: 600`. **The ramp
  /// has no 14.** `.t-label` is the ramp's own button/label convenience —
  /// headline metrics at Medium — so the label takes the step the system names
  /// for exactly this job rather than the nearest size with a borrowed weight.
  static TextStyle actionStyleFor(TextDirection direction) =>
      DabblerType.label.resolveForDirection(direction);

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return DabblerCard(
      width: width,
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel,
      footer: actionLabel == null ? null : _action(colors, direction),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _well(colors),
          const SizedBox(width: rowGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyleFor(direction)
                      .copyWith(color: colors.textPrimary),
                ),
                if (meta != null)
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: metaStyleFor(direction)
                        .copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The brand-filled icon well.
  Widget _well(DabblerColors colors) {
    return Container(
      width: wellSide,
      height: wellSide,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: const BorderRadius.all(Radius.circular(wellRadius)),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.onBrand),
        child: icon ??
            DabblerIcon(
              'home-2',
              size: DabblerSizing.iconLg,
              color: colors.onBrand,
            ),
      ),
    );
  }

  /// The full-width join pill.
  Widget _action(DabblerColors colors, TextDirection direction) {
    final bool live = onAction != null && enabled;

    final Widget pill = Container(
      height: actionHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Text(
        actionLabel!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: actionStyleFor(direction).copyWith(color: colors.onBrand),
      ),
    );

    if (!live) return pill;

    return Semantics(
      button: true,
      label: actionLabel,
      onTap: onAction,
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.pillAll,
        child: DabblerPressScale.gesture(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: pill,
            ),
          ),
        ),
      ),
    );
  }
}
