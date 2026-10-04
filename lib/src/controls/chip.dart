import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/vibes.dart';
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
/// `components/surfaces/identity-status.card.html:52-66` (unverified: file not mirrored), which is the Chip's
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
/// hardcoded white. `Chip.jsx:6-8` is emphatic about this — *"Label colour on
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
  /// (`Chip.jsx:22-24` withholds `role` and `aria-pressed` too).
  const DabblerChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
    this.onLongPress,
    this.onRemove,
    this.removeSemanticLabel,
    this.vibe,
    this.count,
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

  /// Called on a long press. Additive (DS gaps 5, item 7); the web source
  /// has none. Only takes effect on an interactive chip ([onTap] non-null),
  /// and is exposed as a semantics long-press action.
  final VoidCallback? onLongPress;

  /// Shows a trailing [removeIconName] glyph with its own hit target and its
  /// own button semantics node, labelled [removeSemanticLabel]. Additive
  /// (DS gaps 5, item 7) — the removable-tag pattern of the Post composer's
  /// tagged-people row. Works on static and interactive chips alike; a tap
  /// on the glyph calls this and never [onTap].
  ///
  /// **Deviation:** the glyph's hit box is [DabblerSizing.touchTargetMin]
  /// wide but only as tall as the pill ([visualHeight], 38): the remaining
  /// 7px of the 45 floor belong to the chip's own target. The box also
  /// absorbs the trailing padding, so the visible gap after the glyph is
  /// `45 - iconGap - iconSm` (21) rather than [horizontalPadding] (15).
  final VoidCallback? onRemove;

  /// The remove glyph's accessible name. Null reads `Remove <label>`.
  final String? removeSemanticLabel;

  /// Tints the chip with a vibe's colours instead of the card/brand pair:
  /// [DabblerVibeColors.surface]/[DabblerVibeColors.border] unselected and
  /// [DabblerVibeColors.selectedSurface]/[DabblerVibeColors.selectedBorder]
  /// selected, with the label (and icon) in [DabblerVibeColors.ink] in both
  /// states. Resolved through [DabblerVibe.resolve]; no new colour values.
  final DabblerVibe? vibe;

  /// A small count pill after the label (`Notifications.dc.html:58`), already
  /// localised. Omitted when null.
  final String? count;

  /// The trailing remove glyph — `close-circle`, the same glyph
  /// `DabblerTextField`'s inline clear uses.
  static const String removeIconName = 'close-circle';

  /// `padding: '9px 15px'` (`Chip.jsx:28`), vertical component —
  /// [DabblerSpacing.space3].
  static const double verticalPadding = DabblerSpacing.space3;

  /// `padding: '9px 15px'`, horizontal component — [DabblerSpacing.space5].
  static const double horizontalPadding = DabblerSpacing.space5;

  /// The gap between [leadingIcon] and [label] — `gap: var(--icon-gap)`
  /// (`Chip.jsx:27`), which is [DabblerSpacing.iconGap] (6).
  static const double iconGap = DabblerSpacing.iconGap;

  /// The corner: `radius="var(--radius-pill)"` (`Chip.jsx:18`), confirmed by
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
  /// (`Chip.jsx:28-29`).
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
  /// fill, [DabblerColors.textPrimary] otherwise (`Chip.jsx:14`).
  static Color labelColorFor(DabblerColors colors, {required bool selected}) =>
      selected ? colors.onBrand : colors.textPrimary;

  /// The [leadingIcon] colour for [selected]: [DabblerColors.onBrand] on the
  /// brand fill, [DabblerColors.brandPrimary] otherwise (`Chip.jsx:15`).
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
  }) => labelStyle
      .resolveForDirection(direction)
      .copyWith(
        fontWeight: DabblerType.medium,
        color: labelColorFor(colors, selected: selected),
      );

  /// The default accessible name for the remove glyph.
  static String defaultRemoveLabelFor(String label) => 'Remove $label';

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
    final DabblerVibeColors? vibe = widget.vibe?.resolve(colors);
    final Color iconColor =
        vibe?.ink ??
        DabblerChip.iconColorFor(colors, selected: widget.selected);
    final TextStyle labelStyle = DabblerChip.labelStyleFor(
      colors,
      direction,
      selected: widget.selected,
    );
    final bool removable = widget.onRemove != null;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.leadingIcon != null) ...<Widget>[
          ExcludeSemantics(
            child: SizedBox(
              width: DabblerSizing.iconSm,
              height: DabblerSizing.iconSm,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: iconColor,
                  size: DabblerSizing.iconSm,
                ),
                child: Center(child: widget.leadingIcon),
              ),
            ),
          ),
          const SizedBox(width: DabblerChip.iconGap),
        ],
        // The chip node already carries [label]; with a remove glyph the
        // outer ExcludeSemantics is lifted, so the text must not read twice.
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: vibe == null
                ? labelStyle
                : labelStyle.copyWith(color: vibe.ink),
            maxLines: 1,
            softWrap: false,
          ),
        ),
        if (widget.count != null) ...<Widget>[
          const SizedBox(width: DabblerChip.iconGap),
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.selected
                    ? colors.onBrand.withValues(alpha: 0.22)
                    : colors.surfaceSunken,
                borderRadius: DabblerRadius.pillAll,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: DabblerSpacing.space2,
                ),
                child: Text(
                  DabblerType.toWesternDigits(widget.count!),
                  style: DabblerType.caption1
                      .resolveForDirection(direction)
                      .copyWith(
                        fontWeight: DabblerType.semibold,
                        color: widget.selected
                            ? colors.onBrand
                            : colors.textSecondary,
                      ),
                ),
              ),
            ),
          ),
        ],
        if (removable)
          Semantics(
            container: true,
            button: true,
            label:
                widget.removeSemanticLabel ??
                DabblerChip.defaultRemoveLabelFor(widget.label),
            onTap: widget.onRemove,
            child: GestureDetector(
              key: const ValueKey<String>('dabbler-chip-remove'),
              behavior: HitTestBehavior.opaque,
              onTap: widget.onRemove,
              child: SizedBox(
                width: DabblerSizing.touchTargetMin,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: DabblerChip.iconGap,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    child: DabblerIcon(
                      DabblerChip.removeIconName,
                      size: DabblerSizing.iconSm,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
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
      // `Chip.jsx:20`). Keeping it transparent rather than absent is what makes
      // the two states the same height: without this, selecting a chip would
      // shrink it by 2px and shift the whole rail.
      fill: vibe == null
          ? null
          : (widget.selected ? vibe.selectedSurface : vibe.surface),
      borderColor: vibe != null
          ? (widget.selected ? vibe.selectedBorder : vibe.border)
          : (widget.selected ? Colors.transparent : null),
      padding: EdgeInsetsDirectional.only(
        top: DabblerChip.verticalPadding,
        bottom: DabblerChip.verticalPadding,
        start: DabblerChip.horizontalPadding,
        // The remove box absorbs the trailing padding — see [onRemove].
        end: removable ? 0 : DabblerChip.horizontalPadding,
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
        child: ExcludeSemantics(excluding: !removable, child: interactive),
      );
    }

    return Semantics(
      container: removable,
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ExcludeSemantics(
        excluding: !removable,
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
            onLongPress: widget.onLongPress,
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
