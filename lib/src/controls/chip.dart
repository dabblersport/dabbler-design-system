import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// Chip — the pill filter/tag control.
///
/// Transcribed from `components/controls/Chip.jsx`, `Chip.d.ts`,
/// `Chip.prompt.md` and the specimen
/// `components/surfaces/identity-status.card.html:52-66`, which is the Chip's
/// canonical reference page (*"Chips · Badges · Avatars · Ratings ·
/// Reactions"*) — **not** `controls.card.html` or `button-states.card.html`,
/// neither of which mentions Chip at all. See the class note *"What the source
/// does not have"* below.
///
/// ```dart
/// DabblerChip(
///   label: 'Tennis',
///   selected: sport == Sport.tennis,
///   onTap: () => setState(() => sport = Sport.tennis),
/// )
/// ```
///
/// ## Two states, and the label colour rule
///
/// Unselected is the plain card fill plus the 1px hairline — the
/// [DabblerSurfaceVariant.card] step, which is exactly the source's
/// `fill: var(--surface-flat)` / `borderColor: var(--surface-hairline)`.
/// Selected is the solid brand fill, [DabblerSurfaceVariant.selected], the
/// source's `fill: var(--color-brand-primary)` with `borderColor: transparent`.
///
/// The label on the selected fill is [DabblerColors.onBrand] and never a
/// hardcoded white. `Chip.jsx:14` is emphatic about this — *"Label colour on
/// the selected fill is always onBrand — dark in Bright/Sport, never a
/// hardcoded white"* — and it is load-bearing: in `bright` the brand is amber
/// and `--color-on-brand` resolves to ink, so white text would be unreadable.
///
/// ## It composes DS-200; it restates nothing
///
/// Press is [DabblerPressScale] and focus is [DabblerFocusRing]. This file
/// contains **no** scale factor, **no** press duration, **no** curve, **no**
/// ring width, offset or colour and **no** `:focus-visible` rule. Every one of
/// those lives in exactly one place, in `lib/src/interaction/`, and
/// `test/controls/chip_test.dart` asserts that none of them is restated here.
///
/// The focus ring is driven by [FocusableActionDetector.onShowFocusHighlight]
/// rather than by [DabblerFocusRing.new]'s own tracking, and the reason is
/// keyboard activation: the chip needs an [ActivateIntent] action so Enter and
/// Space fire [onTap], as the source's `role="button"` gets from the UA for
/// free — the *binding* from key to intent is the app's ([WidgetsApp]'s
/// default shortcuts); the chip supplies only the action that intent invokes.
/// [FocusableActionDetector] supplies the node, the actions *and* the
/// focus-visible signal together, so [DabblerFocusRing.visible] — the form that
/// exists for exactly this case, a control that already has its own focus node
/// — paints it. That is a composition choice, not a reimplementation: the
/// highlight rule still comes from the framework and the ring's geometry still
/// comes from DS-200.
///
/// ## Touch target
///
/// The pill's own height is [visualHeight] (38 with Latin metrics), which is
/// below the 44pt floor. A **tappable** chip is therefore laid out inside a
/// [DabblerSizing.touchTargetMin] (45) square minimum, with the gesture
/// recogniser on the outer box — so the hit area is ≥45×45 while the pill still
/// draws at its source height. `test/controls/chip_test.dart` measures both.
///
/// A chip with a null [onTap] is a static tag: it is not a touch target at all,
/// so the minimum is not applied and a row of tags stays as dense as the source
/// draws it. Growing an untappable label to 45 would buy no accessibility and
/// would break the filter rails the source builds out of these.
///
/// ## What the source does not have
///
/// `Chip.d.ts` declares exactly four props — `label`, `selected`, `onClick`,
/// `leadingIcon` (plus `style`) — and the specimen renders exactly those. There
/// is **no** removable/dismissible chip, **no** trailing icon and **no** size
/// ramp anywhere in the design source. None of the three is invented here; if
/// the product needs one it is a design-source change first. See the report on
/// KAN-230.
///
/// [leadingIcon] is an arbitrary widget slot, painted at [DabblerSizing.iconSm]
/// (18) in [iconColorFor]. The source passes `<Icon name="game" size={18} />`,
/// i.e. Iconsax, which `cto` has approved as `iconsax_flutter: ^1.0.0`
/// (`DECISIONS.md` T-083). **The dependency and the `DabblerIcon` wrapper are
/// DS-300's, not this file's** — `chip.dart` imports no icon package and names
/// no glyph, and deliberately does not substitute a Material icon as a visible
/// stand-in, because shipping the wrong glyph is a defect where an empty,
/// correctly-sized slot is not.
///
/// The slot is fixed at 18×18 and gapped by [iconGap] whether or not anything
/// is in it, so dropping a `DabblerIcon` in later moves no layout: the box and
/// the spacing are already the source's. When [leadingIcon] is null the box is
/// not built at all, so a chip with no glyph takes no icon space.
///
/// ## In a scrolling rail
///
/// `Chip.jsx:10-11` notes that inside a horizontally scrolling rail the chip
/// must not compress its label. The Dart equivalent is to let the chip size to
/// its content — which it does, via [MainAxisSize.min] — and to put it in a
/// [ListView] or a [Row] inside a [SingleChildScrollView] rather than in a
/// [Flexible]. There is no `flexShrink` prop to port.
class DabblerChip extends StatefulWidget {
  /// Creates a chip labelled [label].
  ///
  /// A null [onTap] renders a static tag: no press, no focus, no button
  /// semantics — the source's own behaviour when `onClick` is omitted
  /// (`Chip.jsx:20-23` withholds `role` and `aria-pressed` too).
  const DabblerChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
  });

  /// The chip text. `label: string` in `Chip.d.ts`.
  final String label;

  /// Whether the chip is selected, which switches it to the brand-filled
  /// treatment. `selected?: boolean`, default `false`.
  final bool selected;

  /// Called on tap. Null makes the chip a static, non-interactive tag.
  ///
  /// Named `onTap` rather than the source's `onClick` because this is Flutter
  /// and the gesture is a tap.
  final VoidCallback? onTap;

  /// Optional leading glyph, painted at [DabblerSizing.iconSm] (18).
  ///
  /// `leadingIcon?: React.ReactNode` — *"Optional leading icon node (18px)"*.
  final Widget? leadingIcon;

  /// `padding: '9px 15px'` (`Chip.jsx:31`), vertical component —
  /// [DabblerSpacing.space3].
  static const double verticalPadding = DabblerSpacing.space3;

  /// `padding: '9px 15px'`, horizontal component — [DabblerSpacing.space5].
  static const double horizontalPadding = DabblerSpacing.space5;

  /// The gap between [leadingIcon] and [label] — `gap: var(--icon-gap)`
  /// (`Chip.jsx:30`), which is [DabblerSpacing.iconGap] (6).
  static const double iconGap = DabblerSpacing.iconGap;

  /// The corner: `radius="var(--radius-pill)"` (`Chip.jsx:24`), confirmed by
  /// `guidelines/measurements.html:76`, which lists `Chip` among the
  /// `--radius-pill` users.
  ///
  /// **Not `--radius-sm`.** `measurements.html:71` glosses `--radius-sm` as
  /// *"chips, small inputs"*, which reads like the chip's token but is the
  /// token's role note, not a component assignment — and the same file assigns
  /// `Chip` to `--radius-pill` five lines later, as the component itself does.
  /// Where a role note and an implementation disagree, the implementation is
  /// the specification. [DabblerRadius.sm] is what a *small input* takes.
  static const double radius = DabblerRadius.pill;

  /// The label's type step: `fontSize: 15, lineHeight: '20px', fontWeight: 500`
  /// (`Chip.jsx:31-32`).
  ///
  /// That is [DabblerType.subheadline]'s metrics (15/20) at
  /// [DabblerType.medium] rather than its own Regular, so the step is reused
  /// and the weight overridden in [labelStyleFor] — the alternative, a new
  /// 15/20/500 constant, would put a type value outside the ramp.
  static const DabblerTypeStyle labelStyle = DabblerType.subheadline;

  /// The pill's own painted height with Latin metrics: 20 leading +
  /// 2 × [verticalPadding] = 38.
  ///
  /// The hairline adds nothing to it. [DabblerSurface] paints its border with a
  /// [DecoratedBox] and applies its padding separately, so the 1px border is
  /// drawn *inside* the box rather than inflating it — which is CSS
  /// `box-sizing: border-box`, the behaviour the source's own stylesheet has.
  ///
  /// Under Arabic the step takes 23 leading (`arabicLeading`), so the pill is
  /// 41 — still the source's own metrics, and still inside the touch target.
  static const double visualHeight = 20 + verticalPadding * 2;

  /// The label colour for [selected]: [DabblerColors.onBrand] on the brand
  /// fill, [DabblerColors.textPrimary] otherwise (`Chip.jsx:19`).
  static Color labelColorFor(DabblerColors colors, {required bool selected}) =>
      selected ? colors.onBrand : colors.textPrimary;

  /// The [leadingIcon] colour for [selected]: [DabblerColors.onBrand] on the
  /// brand fill, [DabblerColors.brandPrimary] otherwise (`Chip.jsx:20`).
  ///
  /// Note this differs from [labelColorFor] in the unselected state — the
  /// source tints the icon brand while the label stays ink.
  static Color iconColorFor(DabblerColors colors, {required bool selected}) =>
      selected ? colors.onBrand : colors.brandPrimary;

  /// The label [TextStyle] for [selected], resolved for [direction] so Arabic
  /// takes its own face and leading.
  static TextStyle labelStyleFor(
    DabblerColors colors,
    TextDirection direction, {
    required bool selected,
  }) =>
      labelStyle.resolveForDirection(direction).copyWith(
            fontWeight: DabblerType.medium,
            color: labelColorFor(colors, selected: selected),
          );

  @override
  State<DabblerChip> createState() => _DabblerChipState();
}

class _DabblerChipState extends State<DabblerChip> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) {
      return;
    }
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.leadingIcon != null) ...<Widget>[
          SizedBox(
            width: DabblerSizing.iconSm,
            height: DabblerSizing.iconSm,
            child: IconTheme.merge(
              data: IconThemeData(
                color: DabblerChip.iconColorFor(colors,
                    selected: widget.selected),
                size: DabblerSizing.iconSm,
              ),
              child: Center(child: widget.leadingIcon),
            ),
          ),
          const SizedBox(width: DabblerChip.iconGap),
        ],
        Text(
          widget.label,
          style: DabblerChip.labelStyleFor(colors, direction,
              selected: widget.selected),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );

    final Widget pill = DabblerSurface(
      variant: widget.selected
          ? DabblerSurfaceVariant.selected
          : DabblerSurfaceVariant.card,
      radius: DabblerChip.radius,
      // The selected step is borderless, and the source keeps a *transparent*
      // border on it rather than dropping it (`borderColor: 'transparent'`,
      // `Chip.jsx:26`). Keeping it transparent rather than absent is what makes
      // the two states the same height: without this, selecting a chip would
      // shrink it by 2px and shift the whole rail.
      borderColor: widget.selected ? Colors.transparent : null,
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: DabblerChip.verticalPadding,
        horizontal: DabblerChip.horizontalPadding,
      ),
      child: content,
    );

    // DS-200 supplies both of these. Nothing about the scale, the duration, the
    // curve, the ring width, the ring offset or the ring colour is stated here.
    final Widget interactive = DabblerFocusRing.visible(
      visible: _focused,
      enabled: _interactive,
      borderRadius: DabblerRadius.pillAll,
      child: DabblerPressScale(
        pressed: _pressed,
        enabled: _interactive,
        child: pill,
      ),
    );

    if (!_interactive) {
      // A static tag: no gesture, no focus, no button semantics, and no touch
      // target to clear.
      return Semantics(
        container: true,
        label: widget.label,
        child: ExcludeSemantics(child: interactive),
      );
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: _setFocused,
          actions: <Type, Action<Intent>>{
            // Enter and Space, which the source's `role="button"` gets from the
            // user agent and Flutter does not.
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => _setPressed(true),
            onTapUp: (TapUpDetails _) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: DabblerSizing.touchTargetMin,
                minHeight: DabblerSizing.touchTargetMin,
              ),
              // heightFactor/widthFactor 1 so the box hugs the pill in the axis
              // the minimum is not binding on, instead of expanding to fill.
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: interactive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
