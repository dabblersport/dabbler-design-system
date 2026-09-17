import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'card.dart';

/// CardPricing — one subscription plan as a selectable tile: the plan's name
/// and a selection indicator on one line, the price beneath it, the billing
/// note under that, and an optional trial pill straddling the top edge.
///
/// Transcribed from `components/cards/CardPricingDefault.jsx` (Figma node
/// `8:39 Card/Pricing/Default`) and `components/cards/CardPricingSelected.jsx`
/// (node `8:40 Card/Pricing/Selected`), with their two `.d.ts` files. Neither
/// symbol ships a `.prompt.md`, so the JSX and the declarations are the whole
/// specification and every deviation below is annotated with its reason.
///
/// ```dart
/// DabblerCardPricing(
///   plan: 'yearly',
///   price: r'$59.99/yr',
///   priceNote: r'($5.00/mo)',
///   billingNote: 'billed annually',
///   trialLabel: '7d free trial',
///   selected: true,
///   onTap: () {},
/// )
/// ```
///
/// ## One widget, two states (KAN-249 AC1)
///
/// The kit ships `CardPricingDefault` and `CardPricingSelected` as two symbols.
/// They are **not** two components: they are the same tree, the same text slots
/// and the same trial pill, differing only in the shell they are drawn on and
/// in how the indicator is painted. Porting them as two widgets would duplicate
/// that tree and let the copies drift, so they are one widget with a [selected]
/// flag, and the whole chrome difference is the single expression [variantOf].
///
/// `card_pricing_selected.dart` exists because the ticket's `Surfaces:` line
/// names it. It declares no second widget — it re-exports this one and records
/// why. See that file.
///
/// ## The kit's two symbol names are inverted, and are not followed
///
/// This is the one place the source is not transcribed literally, so it is
/// spelled out in full.
///
/// | Figma symbol | What it actually paints |
/// |---|---|
/// | `Card/Pricing/`**`Default`** | white shell, 2px `--purple-600` border, **filled purple disc with a tick** |
/// | `Card/Pricing/`**`Selected`** | `--neutral-200` shell, 2px `--neutral-400` border, **empty grey ring** |
///
/// A filled tick is the universal mark of the chosen option and an empty ring
/// the universal mark of the unchosen one, so the symbol named *Selected*
/// paints the unselected state and the one named *Default* paints the selected
/// state. `selected: true` therefore resolves to [DabblerCardVariant.pricing] —
/// the `Default` symbol's shell — and `selected: false` to
/// [DabblerCardVariant.pricingSelected].
///
/// **[DabblerCardVariant.pricingSelected] is consequently a misleading name**:
/// DS-800 transcribed the kit's labels faithfully, which was the right call for
/// a shell enum, but it means the variant called `pricingSelected` is the one an
/// *unselected* plan is drawn on. That enum is another ticket's surface and is
/// not renamed here; it is reported to the orchestrator with KAN-249.
///
/// ## It composes [DabblerCard] and adds no chrome
///
/// Fill, border colour, border width, radius, padding, the press scale and the
/// focus ring all come from [DabblerCard]; this file supplies content and the
/// indicator only. Both pricing shells were already declared there —
/// `--surface-card` + 2px `--color-brand-primary`, and `--surface-sunken` + 2px
/// `--outline-card` — which is exactly what the two JSX dumps paint, so no card
/// colour is restated here.
///
/// ## There is no call-to-action, and no `DabblerButton`
///
/// Worth recording, because a button is the obvious expectation of a pricing
/// card: neither JSX file draws a button, a link or any other action, and the
/// specimen `cards.card.html` renders both symbols bare. The card *is* the
/// control — the whole tile is tappable and the indicator reports the result —
/// so `lib/src/controls/button.dart` is deliberately not composed. A per-plan
/// CTA would be a change to the design source and a new ticket, not a gap in
/// this port.
///
/// ## Deviations, all of them token-over-literal
///
/// | Source literal | Taken here | Why |
/// |---|---|---|
/// | `borderRadius: 16` | [DabblerCard.defaultRadius] (12) | 16 is not a step of the base-3 ramp; `--radius-lg` is annotated *"cards"*. [DabblerCard]'s own ruling |
/// | `padding: "16px"` | [DabblerCard.defaultPadding] (18) | `--card-padding` is `--space-6` |
/// | `width: 186, height: 123` | neither is fixed | Figma frame measurements; see [width] |
/// | the wrappers' `4px` / `8px` vertical paddings | one [slotGap] of 6 | see below |
/// | trial pill `left: 14` | [trialInset] — [DabblerSpacing.space5] (15) | 14 is not a base-3 step; 15 is `--space-5`, one pixel away |
/// | trial pill `top: -10` | a half-height translation | see [trialLabel] |
/// | trial pill fill `--purple-700` | [DabblerBadgeTone.defaultTone] (`--color-brand-primary`, purple-600) | see below |
/// | the tick's inline `<path>` | [DabblerIcon] `check` | this package carries no raw Figma paths — DS-300 is the icon layer |
///
/// ### The vertical rhythm
///
/// The source has no gap property. It stacks its blocks and spaces them with
/// each block's own wrapper padding: nothing above the plan name, `4px` around
/// the price, nothing around the price note, `8px` around the billing note.
/// Two ad-hoc values, neither a token. [DabblerCard] gaps its slots by one
/// number, so [slotGap] is [DabblerSpacing.stackTight] (6) — the base-3 step
/// between the source's 4 and 8 — and [priceNote] sits inside the price slot
/// with no gap at all, which is what the source's zero-padding wrapper means.
///
/// ### The trial pill's fill
///
/// The source fills it `--purple-700`, one ramp step darker than the brand.
/// [DabblerBadge] is the system's pill and its brand tone is
/// `--color-brand-primary` (purple-600); it exposes no fill override, by
/// design. A one-off hue is not worth bypassing the badge layer for, so the
/// badge is used as it stands and the one-step difference is recorded here
/// rather than a private pill being drawn beside it.
///
/// ## Accessibility
///
/// * The tile reports `selected` to assistive technology, and
///   `inMutuallyExclusiveGroup` — a plan tile is a radio, not a checkbox. That
///   flag and [DabblerCard]'s button node are merged into one node, so a screen
///   reader announces *"yearly, $59.99/yr, …, selected"* rather than two nodes.
/// * [semanticLabel] defaults to the tile's own text joined with commas
///   ([defaultSemanticLabel]), so an unlabelled tile reads its plan, price and
///   billing terms rather than an unnamed button.
/// * The whole tile is the target, so it clears 44×44 by a wide margin — the
///   24px indicator is never the hit area. Measured in
///   `test/cards/card_pricing_test.dart`.
/// * Colour is not the only carrier of selection: the indicator changes from an
///   empty ring to a filled tick, and the semantic flag changes with it.
///
/// ## RTL
///
/// Every inset is directional. The indicator trails the text column, and the
/// trial pill's inset is a `start` inset, so in Arabic the pill straddles the
/// top-trailing corner and the indicator sits on the left. Prices keep Western
/// Arabic numerals through the resolved styles' [DabblerType.numeralFeatures].
class DabblerCardPricing extends StatelessWidget {
  /// A pricing tile for [plan].
  const DabblerCardPricing({
    super.key,
    required this.plan,
    required this.price,
    this.priceNote,
    this.billingNote,
    this.trialLabel,
    this.selected = false,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.width,
  });

  /// The plan's name — `text1`, *"yearly"* / *"monthly"* in the two dumps.
  ///
  /// Required: a pricing tile with no plan name is not a state the product has.
  final String plan;

  /// The headline price — `text2`, `$59.99/yr` / `$5.99/mo`.
  final String price;

  /// The equivalent price in the other cadence — `text3` of the `Default`
  /// dump, `($5.00/mo)`. Null drops the line.
  ///
  /// Optional rather than a second required field because the `Selected` dump
  /// has no such line: a monthly plan has no monthly equivalent to show.
  final String? priceNote;

  /// The billing terms — *"billed annually"* / *"billed monthly"* (`text4` on
  /// the `Default` dump, `text3` on `Selected`). Null drops the line.
  final String? billingNote;

  /// The pill straddling the top edge — *"7d free trial"*. Null drops it.
  ///
  /// The source hard-codes the string on the `Default` symbol and exposes it as
  /// `text4` on `Selected`; the exposed form wins, because a trial is a
  /// property of the plan and not of the tile's selection state.
  ///
  /// The pill is centred on the card's top edge by a half-height translation
  /// rather than the source's `top: -10`. -10 against that pill's ~19px box is
  /// the Figma dump's way of writing *"straddle the edge"*, and the translation
  /// says so while depending on no measurement — which matters here, because
  /// [DabblerBadge]'s box is the system's (11px Bold, 4/10 padding), not the
  /// 10px one Figma measured.
  final String? trialLabel;

  /// Whether this plan is the chosen one. Drives the shell ([variantOf]), the
  /// indicator, and the `selected` semantic flag together.
  final bool selected;

  /// Tapping the tile — choosing the plan. Null leaves it inert.
  final VoidCallback? onTap;

  /// Whether the tile accepts input. `false` withholds the handler, the press
  /// scale and the focus ring together, so a disabled tile has no pressed state
  /// that could stick.
  final bool enabled;

  /// The tile's accessible label. Null builds one from the tile's own text —
  /// see [defaultSemanticLabel].
  final String? semanticLabel;

  /// Fixed width. Null sizes to the incoming constraints.
  ///
  /// The source's `width: 186` is a Figma frame measurement, not a
  /// specification: two plan tiles side by side take half a screen each.
  final double? width;

  /// The gap between the card's slots — [DabblerSpacing.stackTight] (6). See
  /// the class doc's rhythm note.
  static const double slotGap = DabblerSpacing.stackTight;

  /// The selection indicator's side — `width: 24, height: 24` on both dumps,
  /// which is [DabblerSizing.iconMd], the native icon grid. No deviation.
  static const double indicatorSide = DabblerSizing.iconMd;

  /// The indicator's ring width — `2px` on both dumps, expressed as two
  /// hairlines so no raw number is written.
  static const double indicatorBorderWidth = DabblerSizing.borderDefault * 2;

  /// The tick's size inside the disc.
  ///
  /// The source draws an 8×5.5 path in a 10×8 box. Neither is an icon step and
  /// neither is square; [DabblerSizing.iconSm] (18) is the ramp step that fits
  /// a 24px disc with the source's margin left around it.
  static const double tickSize = DabblerSizing.iconSm;

  /// The trial pill's inset from the leading edge — [DabblerSpacing.space5]
  /// (15), for the source's off-grid `left: 14`.
  static const double trialInset = DabblerSpacing.space5;

  /// [plan]'s style: `.t-subheadline` at [DabblerType.bold].
  ///
  /// The source sets `--font-size-body-lg` (15, `tokens/figma/fig-tokens.css`)
  /// at `fontWeight: 700`. 15 is `.t-subheadline`'s size exactly; the ramp step
  /// carries weight 400, so the source's weight is applied on top of the step
  /// rather than a new step being invented — the precedent
  /// `lib/src/surfaces/badge.dart` set and `card_house.dart` followed.
  static TextStyle planStyleFor(TextDirection direction) =>
      DabblerType.subheadline
          .resolveForDirection(direction)
          .copyWith(fontWeight: DabblerType.bold);

  /// [price]'s style: `.t-footnote`, unmodified.
  ///
  /// `--font-size-body-sm` is 13 at weight 400, which is the footnote step
  /// exactly.
  static TextStyle priceStyleFor(TextDirection direction) =>
      DabblerType.footnote.resolveForDirection(direction);

  /// The style of [priceNote] and [billingNote]: `.t-caption-2`, unmodified.
  ///
  /// `--font-size-overline` is 11 at weight 400, which is the caption-2 step
  /// exactly.
  static TextStyle noteStyleFor(TextDirection direction) =>
      DabblerType.caption2.resolveForDirection(direction);

  /// Which [DabblerCard] shell a tile in state [selected] is drawn on.
  ///
  /// **This single expression is the whole chrome difference between the kit's
  /// two symbols**, and the reason KAN-249 AC1 asks for one file. Note the
  /// inversion the class doc explains: a selected tile takes the variant the kit
  /// calls `pricing` (its `Default` symbol), and an unselected tile the one it
  /// calls `pricingSelected`.
  static DabblerCardVariant variantOf({required bool selected}) => selected
      ? DabblerCardVariant.pricing
      : DabblerCardVariant.pricingSelected;

  /// The label a tile falls back to when [semanticLabel] is null: its own text,
  /// joined with `, ` in reading order, with the trial pill last.
  static String defaultSemanticLabel({
    required String plan,
    required String price,
    String? priceNote,
    String? billingNote,
    String? trialLabel,
  }) =>
      <String>[plan, price, ?priceNote, ?billingNote, ?trialLabel].join(', ');

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget card = DabblerCard(
      variant: variantOf(selected: selected),
      width: width,
      gap: slotGap,
      onTap: onTap,
      enabled: enabled,
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              plan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: planStyleFor(direction).copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: DabblerSpacing.iconGap),
          _indicator(colors),
        ],
      ),
      footer: billingNote == null
          ? null
          : Text(
              billingNote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  noteStyleFor(direction).copyWith(color: colors.textSecondary),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: priceStyleFor(direction).copyWith(color: colors.textPrimary),
          ),
          if (priceNote != null)
            Text(
              priceNote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  noteStyleFor(direction).copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );

    final bool interactive = onTap != null && enabled;

    return Semantics(
      container: true,
      button: interactive,
      enabled: interactive,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      onTap: interactive ? onTap : null,
      label: semanticLabel ??
          defaultSemanticLabel(
            plan: plan,
            price: price,
            priceNote: priceNote,
            billingNote: billingNote,
            trialLabel: trialLabel,
          ),
      // One node, built here. The tile's own texts, and [DabblerCard]'s button
      // node, are excluded rather than merged: merging would append every line
      // of the card to an explicit [semanticLabel], so an author who supplied
      // one would not get the label they asked for.
      child: ExcludeSemantics(
        child: trialLabel == null ? card : _withTrialPill(card),
      ),
    );
  }

  /// The selection indicator: a filled brand disc carrying a tick when
  /// [selected], an empty `--outline-strong` ring when not.
  ///
  /// The two branches differ in fill and border colour only — the box, the
  /// radius and the ring width are shared, which is the same
  /// one-difference-one-expression discipline [variantOf] applies to the shell.
  /// `--neutral-500` is `--outline-strong`, hence [DabblerColors.borderStrong].
  Widget _indicator(DabblerColors colors) {
    return Container(
      width: indicatorSide,
      height: indicatorSide,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.brandPrimary : null,
        border: Border.all(
          color: selected ? colors.brandPrimary : colors.borderStrong,
          width: indicatorBorderWidth,
        ),
      ),
      child: selected
          ? DabblerIcon(
              'check',
              weight: DabblerIconWeight.bold,
              size: tickSize,
              color: colors.onBrand,
            )
          : null,
    );
  }

  /// [card] with the trial pill straddling its top edge.
  ///
  /// [Clip.none] is deliberate: the pill is specified to overhang, so the stack
  /// must not clip it. A caller laying tiles out in a tight row should leave
  /// half a pill of headroom above them — the overhang is the source's design,
  /// not an accident of this port.
  Widget _withTrialPill(Widget card) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        card,
        PositionedDirectional(
          top: 0,
          start: trialInset,
          child: FractionalTranslation(
            translation: const Offset(0, -0.5),
            child: DabblerBadge(label: trialLabel!),
          ),
        ),
      ],
    );
  }
}
