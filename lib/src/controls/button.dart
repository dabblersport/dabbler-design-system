import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// The paint of a [DabblerButton].
///
/// Transcribed from `components/controls/Button.jsx`'s `TONES` map and the
/// tone table in `components/controls/buttons.card.html`, which agree row for
/// row.
///
/// **Tone names describe the PAINT, not a semantic.** The source is explicit
/// about this (`Button.jsx:12`), and it is why the kit's original names were
/// replaced: `outline` was a filled indigo pill, `ghost` a filled neutral pill
/// and `dark` the only actually outlined tone.
///
/// ## The three legacy names are not ported
///
/// `Button.d.ts` keeps `outline` / `ghost` / `dark` as deprecated aliases that
/// warn once in the console, and `Button.jsx` carries a `TONE_ALIASES` map for
/// them. **Neither is reproduced here**: no alias, no deprecation, no warning.
/// A deprecation exists to give existing consumers a migration window, and this
/// is a greenfield Dart port with no consumer that has ever written those
/// names. Porting them would ship a warning path that can only ever fire for
/// code written *after* the rename — i.e. a mistake, which the type system
/// already catches at compile time. KAN-243 AC1 states this directly.
enum DabblerButtonTone {
  /// `--color-brand-primary` fill, `--color-on-brand` label. The default.
  primary,

  /// `--color-accent` fill, `--color-on-accent` label.
  secondary,

  /// `--accent-indigo` fill, `--surface-card` label.
  ///
  /// **A known defect pending `DECISIONS.md` D-004** — see
  /// [DabblerButton.accentFill].
  accent,

  /// `--surface-sunken` fill, `--ink` label.
  neutral,

  /// `--ink` fill, `--surface-card` label.
  filled,

  /// Transparent fill, `--ink` label, 1px `--outline-card` hairline. The only
  /// tone in the set that actually draws an outline.
  outlined,

  /// `--color-status-error-solid` fill, `--paper` label.
  ///
  /// `Button.prompt.md` records the measurement: white on the error-solid step
  /// clears 8.3:1. The `-solid` role exists for exactly this — see
  /// [DabblerStatusColor.solid].
  destructive,

  /// `--surface-sunken` fill, `--ink` label. Identical paint to [neutral]; the
  /// source keeps it a separate symbol because it names the icon-plus-label
  /// form from the Figma kit.
  iconLabel,

  /// `--ink` fill, `--surface-card` label. The icon-only form.
  icon,
}

/// The size ramp of a [DabblerButton].
///
/// `Button.jsx`'s `SIZES` map, confirmed by the size table in
/// `buttons.card.html`. Every value below is off the base-3 grid and is
/// transcribed literally, because the source states each one as a number
/// rather than through a spacing token — see [DabblerButton.paddingFor].
enum DabblerButtonSize {
  /// 320×52 fixed, 16px/600 label, an explicit 21px corner.
  full,

  /// 10/20 padding, 14px/600 label, `--radius-pill`. The default.
  medium,

  /// 8/16 padding, 12px/600 label, `--radius-pill`.
  small,
}

/// Button — the one button.
///
/// Transcribed from the design source `components/controls/Button.jsx`,
/// `Button.d.ts`, `Button.prompt.md` and the specimens
/// `components/controls/buttons.card.html` (the canonical page) and
/// `components/controls/button-states.card.html` (its source-only predecessor,
/// consolidated into the former — the two render the same grid).
///
/// It merges the Figma kit's 13 standalone Button symbols into one widget with
/// modifiers: nine [DabblerButtonTone]s × three [DabblerButtonSize]s, plus
/// [icon], [fullWidth], [disabled] and [loading]. There are no separate
/// `PrimaryButton` / `SmallButton` / `IconButton` widgets, and adding one would
/// re-fragment exactly what the source merged.
///
/// ```dart
/// DabblerButton(label: 'join', onPressed: join)
/// DabblerButton(label: 'leaving…', tone: DabblerButtonTone.destructive, loading: true)
/// DabblerButton(label: 'create a game', icon: 'add', onPressed: create)
/// DabblerButton.icon(icon: 'more', semanticLabel: 'More', onPressed: openMenu)
/// ```
///
/// ## It composes DS-200 and DS-403; it restates nothing
///
/// Press is [DabblerPressScale] and focus is [DabblerFocusRing]. This file
/// contains **no** scale factor, **no** press duration, **no** curve, **no**
/// ring width, offset or colour. The loading indicator is [DabblerSpinner] at
/// [DabblerSpinnerSize.sm] — `Button.prompt.md` is emphatic that *"there is no
/// private spinner inside Button"*, and there is none here either.
///
/// ## Corner: 21 on `full`, pill on the rest
///
/// `Button.jsx:21-23` gives `full` an explicit `radius: 21` and leaves `medium`
/// and `small` on `9999`, with the note that 9999 *"resolves to ~20px effective
/// at their heights, so the three sizes read as one consistent corner"*. `cxo`
/// ruled (`DECISIONS.md` D-005) that this implementation is authoritative: 21
/// is this system's corner for a large primary action, and it is the same
/// override [DabblerFab] takes. It is a documented explicit value, not a
/// radius token — `buttons.card.html`'s measurement table lists it as
/// *"21px · explicit"*, one row apart from the `--radius-pill` entry.
///
/// ## Touch target
///
/// [DabblerButtonSize.full] is 52 tall, which clears the floor on its own.
/// `medium` and `small` take a [DabblerSizing.touchTargetMin] (45) **minimum on
/// the painted box**, which is where the source puts it (`minHeight:
/// 'var(--touch-target-min)'`, `Button.jsx:76`) — so the pill itself grows,
/// rather than sitting inside a larger invisible hit area as [DabblerChip]'s
/// does. A matching `minWidth` is applied as well; the source sets no
/// `min-width`, but KAN-243 AC5 asks for ≥44 in **both** axes and a narrow
/// icon-only `small` button is the case that would otherwise miss it.
/// `test/controls/button_test.dart` measures the rendered box at every size and
/// in both scripts rather than asserting the constraint.
///
/// ## Accessibility
///
/// The source relies on a real `<button type="button">` for Enter/Space and for
/// `disabled` removing the control from the tab order. Flutter gives neither
/// for free, so both are supplied: an [ActivateIntent] action (the *binding*
/// from key to intent belongs to the app's [WidgetsApp] shortcuts, not here),
/// and a [FocusableActionDetector] disabled while inert, which takes the
/// button out of the traversal order exactly as the native `disabled`
/// attribute does.
///
/// **An icon-only button needs an accessible name.** [DabblerButton.icon]
/// requires [semanticLabel] for that reason — the source says the same thing
/// about `aria-label`, and a tooltip is not a substitute for a label.
///
/// ## RTL
///
/// The icon and label sit in ordinary flow inside a [Row], so the icon moves to
/// the right under [TextDirection.rtl] with no directional property, which is
/// what the source gets from its plain `gap`. Padding is
/// [EdgeInsetsDirectional]; nothing here names `left` or `right`.
class DabblerButton extends StatefulWidget {
  /// Creates a labelled button.
  const DabblerButton({
    super.key,
    required this.label,
    this.tone = DabblerButtonTone.primary,
    this.size = DabblerButtonSize.medium,
    this.icon,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });

  /// Creates an icon-only button — the source's `tone="icon"` form.
  ///
  /// [semanticLabel] is required because there is no label to read.
  const DabblerButton.icon({
    super.key,
    required String this.icon,
    required String this.semanticLabel,
    this.tone = DabblerButtonTone.icon,
    this.size = DabblerButtonSize.medium,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
  })  : label = null,
        fullWidth = false;

  /// The button text. `children` in the source. Null only on
  /// [DabblerButton.icon].
  final String? label;

  /// The paint. Default [DabblerButtonTone.primary], as in `Button.d.ts`.
  final DabblerButtonTone tone;

  /// The size step. Default [DabblerButtonSize.medium], as in `Button.d.ts`.
  final DabblerButtonSize size;

  /// The leading glyph's name in the [DabblerIconRegistry] vocabulary — e.g.
  /// `'add'`, `'share'`, `'more'`, the three the specimen passes.
  ///
  /// The source's prop is `icon?: React.ReactNode`, an arbitrary slot. This is
  /// a **name**, not a widget: DS-300's [DabblerIcon] renders real Iconsax
  /// glyphs now, so the slot would only let a caller put something that is not
  /// a system icon into a system control. The specimen passes `<Icon name=…>`
  /// in every single instance.
  final String? icon;

  /// Called on tap. Named for the gesture rather than the source's `onClick`.
  ///
  /// A null [onPressed] does **not** disable the button — [disabled] does. The
  /// two are separate in the source too, and a tone-only specimen button has no
  /// handler while still drawing at full opacity.
  final VoidCallback? onPressed;

  /// Whether the button is disabled: inert, 45% opacity, out of the tab order.
  final bool disabled;

  /// Whether the button is loading: inert and out of the tab order like
  /// [disabled], but **not** dimmed — `opacity: disabled ? 0.45 : 1`
  /// (`Button.jsx:88`) keys off `disabled` alone. The leading slot renders a
  /// [DabblerSpinner] instead of [icon].
  final bool loading;

  /// Stretch to the container instead of the size's intrinsic width.
  final bool fullWidth;

  /// The accessible name. Defaults to [label]; required on
  /// [DabblerButton.icon].
  final String? semanticLabel;

  /// `full`'s fixed width — `width: 320` (`Button.jsx:21`).
  static const double fullWidthPx = 320;

  /// `full`'s fixed height — `height: 52` (`Button.jsx:21`).
  ///
  /// Off the base-3 grid and above [DabblerSizing.touchTargetMin], so `full`
  /// needs no minimum applied to it.
  static const double fullHeight = 52;

  /// `full`'s corner — [DabblerSpacing.space7] (21). See the class note.
  static const double fullRadius = DabblerSpacing.space7;

  /// The gap between the leading slot and the label — `gap: icon || loading ?
  /// 8 : 0` (`Button.jsx:85`), which `buttons.card.html` restates as *"Icon gap
  /// is 8px when an `icon` or a loading spinner is present."*
  ///
  /// **8 is off the base-3 grid** and is not [DabblerSpacing.iconGap] (6). The
  /// source writes it as a bare number rather than through `--icon-gap`, so it
  /// is transcribed as a bare number here; rounding it to 6 or 9 would move a
  /// value the specimen renders. Flagged in the KAN-243 report as a
  /// design-source question, not silently corrected.
  static const double iconGap = 8;

  /// The leading glyph's size — [DabblerSizing.iconSm] (18), per the
  /// measurement table's *"Button leading icons (18)"* and the specimen's
  /// `<Icon name="add" size={18} />`.
  static const double leadingIconSize = DabblerSizing.iconSm;

  /// The icon-only glyph's size — `<Icon name="more" size={20} />` in both
  /// specimens. Off the grid, and 2px larger than [leadingIconSize] because it
  /// is the button's whole content rather than a label's companion.
  static const double iconOnlyGlyphSize = 20;

  /// The opacity of a [disabled] button — `opacity: 0.45` (`Button.jsx:88`).
  static const double disabledOpacity = 0.45;

  /// How far a pressed background moves toward black.
  ///
  /// `background: color-mix(in srgb, <bg> 88%, black)` (`Button.jsx:80`), i.e.
  /// 12% black. [Color.lerp] reproduces `color-mix(in srgb, …)` including on
  /// the transparent [DabblerButtonTone.outlined] fill, where both give 12%
  /// black.
  static const double pressDarken = 0.12;

  /// The fill for [DabblerButtonTone.accent].
  ///
  /// ## A KNOWN DEFECT pending `DECISIONS.md` D-004
  ///
  /// `Button.jsx:30` paints this tone `var(--accent-indigo)` (`#5C50E6`), a
  /// token declared only in `fig-tokens.css` and never in `tokens/colors.css`.
  /// `cxo` ruled (D-004) that the omission is real and is fixed in the CSS
  /// first: the token gets declared, is transcribed to
  /// `DabblerPalette.accentIndigo`, and only then does this call site change.
  /// Until that sequence completes, `accent` resolves to
  /// [DabblerPalette.socialInfo] (`--social-info`, `#6366F1`), the nearest
  /// declared indigo — the same stand-in, for the same reason, as
  /// [DabblerAvatar]'s `indigo` badge and [DabblerFab]'s `default` tone.
  ///
  /// **That stand-in is a defect, not a close-enough approximation.** Do not
  /// treat this line as settled and do not copy the pattern.
  static const Color accentFill = DabblerPalette.socialInfo;

  /// The fill for [tone], resolved against [colors].
  static Color backgroundFor(DabblerColors colors, DabblerButtonTone tone) =>
      switch (tone) {
        DabblerButtonTone.primary => colors.brandPrimary,
        DabblerButtonTone.secondary => colors.accent,
        DabblerButtonTone.accent => accentFill,
        DabblerButtonTone.neutral ||
        DabblerButtonTone.iconLabel =>
          colors.surfaceSunken,
        DabblerButtonTone.filled || DabblerButtonTone.icon => colors.textPrimary,
        DabblerButtonTone.outlined => Colors.transparent,
        DabblerButtonTone.destructive => colors.error.solid,
      };

  /// The label and glyph colour for [tone], resolved against [colors].
  static Color foregroundFor(DabblerColors colors, DabblerButtonTone tone) =>
      switch (tone) {
        DabblerButtonTone.primary => colors.onBrand,
        DabblerButtonTone.secondary => colors.onAccent,
        DabblerButtonTone.accent ||
        DabblerButtonTone.filled ||
        DabblerButtonTone.icon =>
          colors.surfaceCard,
        DabblerButtonTone.neutral ||
        DabblerButtonTone.outlined ||
        DabblerButtonTone.iconLabel =>
          colors.textPrimary,
        // `--paper`, a fixed white, and not `surfaceCard`: the measured 8.3:1
        // in `Button.prompt.md` is white on the error-solid step, and
        // `surfaceCard` is not white in dark mode.
        DabblerButtonTone.destructive => DabblerPalette.paper,
      };

  /// The hairline colour for [tone], or null where the tone draws no border.
  ///
  /// Only [DabblerButtonTone.outlined] has one: `border: '1px solid
  /// var(--outline-card)'`, every other row of the `TONES` map being
  /// `border: null`.
  static Color? borderColorFor(DabblerColors colors, DabblerButtonTone tone) =>
      tone == DabblerButtonTone.outlined ? colors.borderDefault : null;

  /// The corner for [size]: [fullRadius] on `full`, [DabblerRadius.pill]
  /// otherwise.
  static double radiusFor(DabblerButtonSize size) =>
      size == DabblerButtonSize.full ? fullRadius : DabblerRadius.pill;

  /// The padding for [size].
  ///
  /// `full` carries none — it is a fixed 320×52 box with centred content
  /// (`padding: s.padding || 0`, and `full` declares no `padding`). `medium` is
  /// `'10px 20px'` and `small` `'8px 16px'`.
  ///
  /// **All four numbers are off the base-3 grid** (the scale has 9/12 and
  /// 18/21, not 8/10 and 16/20) and none of them is written as a spacing token
  /// in the source. They are transcribed literally rather than snapped to the
  /// nearest step, because snapping would change what the specimen renders.
  /// Raised in the KAN-243 report.
  static EdgeInsetsDirectional paddingFor(DabblerButtonSize size) =>
      switch (size) {
        DabblerButtonSize.full => EdgeInsetsDirectional.zero,
        DabblerButtonSize.medium =>
          const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 20),
        DabblerButtonSize.small =>
          const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16),
      };

  /// The label size for [size] — 16 / 14 / 12, all at weight 600.
  static double fontSizeFor(DabblerButtonSize size) => switch (size) {
        DabblerButtonSize.full => 16,
        DabblerButtonSize.medium => 14,
        DabblerButtonSize.small => 12,
      };

  /// `line-height: 1.4` (`Button.jsx:83`) — a multiplier, which is already what
  /// [TextStyle.height] is, so it is used directly.
  static const double lineHeightFactor = 1.4;

  /// The type step the label's face and role come from.
  ///
  /// [DabblerType.label] is *"the button/label convenience"* by its own
  /// dartdoc, and this widget takes its **role** (sans) and therefore its font
  /// family and fallback from it — not its metrics. The button's own ramp is
  /// 16/14/12 at weight 600, which the type ramp does not carry at all: there
  /// is no 14 step, and semibold appears only at `headline`'s 17. Overriding
  /// one step's size and weight keeps a single, stated provenance for the face;
  /// inventing three new ramp constants would put three type values outside
  /// `tokens/typography.css`.
  static const DabblerTypeStyle labelStyle = DabblerType.label;

  /// The label [TextStyle] for [size] and [tone], resolved for [direction] so
  /// Arabic takes its own face.
  static TextStyle labelStyleFor(
    DabblerColors colors,
    TextDirection direction, {
    required DabblerButtonSize size,
    required DabblerButtonTone tone,
  }) {
    final double fontSize = fontSizeFor(size);
    return labelStyle.resolveForDirection(direction).copyWith(
          fontSize: fontSize,
          height: lineHeightFactor,
          fontWeight: DabblerType.semibold,
          color: foregroundFor(colors, tone),
        );
  }

  @override
  State<DabblerButton> createState() => _DabblerButtonState();
}

class _DabblerButtonState extends State<DabblerButton> {
  bool _pressed = false;
  bool _focused = false;

  /// `const inert = disabled || loading` (`Button.jsx:64`).
  bool get _inert => widget.disabled || widget.loading;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  void _activate() {
    if (_inert) return;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool isFull = widget.size == DabblerButtonSize.full;

    final Color foreground =
        DabblerButton.foregroundFor(colors, widget.tone);
    final Color background =
        DabblerButton.backgroundFor(colors, widget.tone);
    final double radius = DabblerButton.radiusFor(widget.size);

    // `color-mix(in srgb, <bg> 88%, black)` while pressed and interactive.
    final Color fill = _pressed && !_inert
        ? Color.lerp(background, Colors.black, DabblerButton.pressDarken)!
        : background;

    final bool iconOnly = widget.label == null;
    final Widget? leading = widget.loading
        ? const DabblerSpinner(
            size: DabblerSpinnerSize.sm,
            tone: DabblerSpinnerTone.inherit,
          )
        : (widget.icon != null
            ? DabblerIcon(
                widget.icon!,
                size: iconOnly
                    ? DabblerButton.iconOnlyGlyphSize
                    : DabblerButton.leadingIconSize,
                color: foreground,
              )
            : null);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ?leading,
        // The gap exists only when something occupies the leading slot, which
        // is the source's `gap: icon || loading ? 8 : 0`.
        if (leading != null && widget.label != null)
          const SizedBox(width: DabblerButton.iconGap),
        if (widget.label != null)
          Text(
            widget.label!,
            style: DabblerButton.labelStyleFor(
              colors,
              direction,
              size: widget.size,
              tone: widget.tone,
            ),
            // `whiteSpace: 'nowrap'` (`Button.jsx:86`).
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
      ],
    );

    Widget pill = DabblerSurface(
      variant: DabblerSurfaceVariant.card,
      fill: fill,
      // Transparent rather than absent on the borderless tones, so switching
      // tone never changes the box by the hairline's 1px.
      borderColor: DabblerButton.borderColorFor(colors, widget.tone) ??
          Colors.transparent,
      radius: radius,
      padding: DabblerButton.paddingFor(widget.size),
      width: isFull
          ? (widget.fullWidth ? double.infinity : DabblerButton.fullWidthPx)
          : (widget.fullWidth ? double.infinity : null),
      height: isFull ? DabblerButton.fullHeight : null,
      center: true,
      // `tone="inherit"` on the spinner reads this, and so does any glyph that
      // was not handed an explicit colour.
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: content,
      ),
    );

    if (!isFull) {
      // The source's `minHeight: 'var(--touch-target-min)'`, on the painted box
      // itself. `minWidth` is this port's addition for AC5 — see the class doc.
      pill = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: DabblerSizing.touchTargetMin,
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: pill,
      );
    }

    // DS-200 supplies both of these. Nothing about the scale, the duration, the
    // curve, the ring width, the ring offset or the ring colour is stated here.
    Widget interactive = DabblerFocusRing.visible(
      visible: _focused,
      enabled: !_inert,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: DabblerPressScale(
        pressed: _pressed,
        enabled: !_inert,
        child: pill,
      ),
    );

    if (widget.disabled) {
      interactive = Opacity(
        opacity: DabblerButton.disabledOpacity,
        child: interactive,
      );
    }

    return Semantics(
      button: true,
      enabled: !_inert,
      label: widget.semanticLabel ?? widget.label,
      onTap: _inert ? null : _activate,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: !_inert,
          // `disabled` removes the native button from the tab order; Flutter
          // needs telling.
          descendantsAreFocusable: !_inert,
          mouseCursor: _inert
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onShowFocusHighlight: _setFocused,
          actions: <Type, Action<Intent>>{
            // Enter and Space, which the source's real `<button>` gets from the
            // user agent. The binding from key to intent is the app's.
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                _activate();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _inert ? null : _activate,
            onTapDown: _inert ? null : (TapDownDetails _) => _setPressed(true),
            onTapUp: _inert ? null : (TapUpDetails _) => _setPressed(false),
            onTapCancel: _inert ? null : () => _setPressed(false),
            child: interactive,
          ),
        ),
      ),
    );
  }
}
