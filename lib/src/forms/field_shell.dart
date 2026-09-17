import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// How the shell's row aligns its content on the cross axis.
///
/// The source's `align` prop (`components/forms/TextField.jsx:37`), which is
/// `'center'` everywhere except the multiline variant, where the label-side
/// content must sit against the first line rather than float in the middle of
/// a grown box.
enum DabblerFieldAlign {
  /// `align="center"` — `alignItems: center`. The default.
  center,

  /// `align="start"` — `alignItems: flex-start`. Multiline only.
  start,
}

/// FieldShell — the field chrome every field in the system paints from.
///
/// Transcribed from `components/forms/TextField.jsx:14-84` (the `FieldShell`
/// function and its `RADIUS` table), `components/forms/TextField.d.ts:41-54`
/// (`FieldShellProps`) and the specimen `components/forms/fields.card.html:68`,
/// which states the rule this file exists to enforce: *"**Every field in the
/// system paints from it**, which is why no picker can drift into a visual fork
/// of the input."*
///
/// The structure is three parts in a column, `--stack-tight` (6) apart:
///
/// 1. the **label**, `.t-subheadline`, `--color-text-secondary` at rest and
///    `--color-brand-primary` while focused;
/// 2. the **box** — a flat [DabblerSurface] at `--radius-xxl` by default,
///    carrying the rest / focus / error / disabled border states, with an
///    inner row padded `9px 12px`, gapped `--icon-gap` (6) and floored at
///    `--touch-target-min` (45);
/// 3. the **helper / error line**, `.t-footnote`, indented `--space-4` (12) on
///    the inline-start side. `errorText` replaces `helperText` — the source
///    renders one line, never two.
///
/// ## Internal by design (AC1)
///
/// This is a **composition primitive, not a public control**. It is not
/// exported from the package's public surface: DS-601 (Select / PickerField),
/// DS-602 (DateField / TimeField), DS-603 (Stepper) and DS-605 (InputRow)
/// import it by its `src/` path and wrap it, exactly as [DabblerTextField]
/// does. Nothing in an app should place a bare `DabblerFieldShell` in a
/// screen; there is no state in it that a field does not own.
///
/// ## The four border states, and where each colour comes from
///
/// `TextField.jsx:33-37`, in this precedence — disabled first, then error,
/// then focus, then rest:
///
/// | state | border | width |
/// |---|---|---|
/// | disabled | `--color-border-default` | 1 |
/// | error | `--color-status-error` | 1 |
/// | focused | `--color-focus-ring` | 2 |
/// | rest | the surface hairline (`--color-border-default`) | 1 |
///
/// Note the precedence is **not** a severity order: a disabled field shows the
/// plain hairline even when it also carries `errorText`, because the source
/// tests `disabled` first. That is transcribed rather than corrected.
///
/// The widths differ, so the box's *painted* size is unchanged but its inner
/// content shifts by 1px when focus lands. The source has exactly the same
/// behaviour (`border-width: 1px → 2px` on a `box-sizing: border-box` element
/// moves the content box in by 1px), so it is kept: the alternative — a 2px
/// transparent border at rest — would be a deviation from the hairline the
/// flat system is built on.
///
/// ## Focus is shown twice, and that is the source, not a duplication
///
/// The border swap above is the *field's* focus expression, in every variant.
/// The system focus ring — [DabblerFocusRing], DS-200 — is additionally drawn
/// only when [focusRingVisible] is set, which is the port of the source
/// applying its `.dbl-focus` class **only to the `as="button"` inner element**
/// (`TextField.jsx:52`). A text input never gets the outline ring in the
/// source, and does not get one here; the `select` shell, which is a real
/// button, gets both. This file defines no ring width, offset or colour of its
/// own — all three live in `lib/src/interaction/focus_ring.dart`.
///
/// ## Helper and error colour — D-003
///
/// Helper text is [DabblerColors.textSecondary] and error text is the error
/// tone's `--color-status-error`, which is what `TextField.jsx:81` already
/// says. `cxo`'s ruling D-003 — that `--muted` and `--subtle` are surface
/// neutrals wrongly exposed as text roles, and that `--subtle` at 2.15:1 must
/// never be used as a text colour — therefore costs this file nothing: the
/// forms source never puts helper text on either. The one `var(--muted)` in
/// the whole forms area is a specimen's inline `AED` suffix label
/// (`fields.card.html:56`), which is demo content and not part of the shell.
class DabblerFieldShell extends StatelessWidget {
  /// Creates the chrome around [children].
  const DabblerFieldShell({
    super.key,
    required this.children,
    this.label,
    this.helperText,
    this.errorText,
    this.focused = false,
    this.disabled = false,
    this.focusRingVisible = false,
    this.radius = DabblerRadius.xxl,
    this.align = DabblerFieldAlign.center,
    this.innerPadding = defaultInnerPadding,
    this.onTap,
    this.semanticsLabel,
  });

  /// `padding: '9px 12px'` (`TextField.jsx:58`) — `--space-3` block,
  /// `--space-4` inline. Directional so it mirrors in RTL.
  static const EdgeInsetsDirectional defaultInnerPadding =
      EdgeInsetsDirectional.fromSTEB(
    DabblerSpacing.space4,
    DabblerSpacing.space3,
    DabblerSpacing.space4,
    DabblerSpacing.space3,
  );

  /// `paddingInlineStart: 12` on the helper / error line
  /// (`TextField.jsx:80`), so it lines up with the text inside the box.
  static const EdgeInsetsDirectional messagePadding =
      EdgeInsetsDirectional.only(start: DabblerSpacing.space4);

  /// The row's contents: leading icon, the input or value, trailing
  /// affordances. Laid out in order with [DabblerSpacing.iconGap] between
  /// them, which is the source's `gap: var(--icon-gap)`.
  final List<Widget> children;

  /// The label above the box. `.t-subheadline`. Omitted when null.
  final String? label;

  /// The helper line below the box. `.t-footnote`. Hidden while [errorText]
  /// is set — the source renders one line, not both.
  final String? helperText;

  /// The error line below the box. Its presence is what puts the shell in the
  /// error state, exactly as `hasError = !!errorText` does in the source.
  final String? errorText;

  /// Whether the field holds focus. Drives the label colour and the 2px
  /// focus-ring border. The shell does not track focus; the field that owns
  /// the input does, and tells it.
  final bool focused;

  /// Whether the field is inert. Drives the tinted fill, the plain hairline
  /// and the muted content colours the composing field applies.
  final bool disabled;

  /// Whether to additionally paint the system [DabblerFocusRing] around the
  /// box. Only an interactive shell — the `select` variant and the pickers
  /// built on it — sets this; see the class note.
  final bool focusRingVisible;

  /// The box's corner radius. `--radius-xxl` (24) for every field shell;
  /// `--radius-xl` (18) for multiline. `fields.card.html:169` lists the 24
  /// as shared by *"TextField, Select, PickerField, DateField, TimeField,
  /// Stepper"*.
  final double radius;

  /// Cross-axis alignment of the row.
  final DabblerFieldAlign align;

  /// The box's inner padding. Overridable because the source's `innerStyle`
  /// prop is, and because the password toggle needs it: see
  /// [DabblerTextField].
  final EdgeInsetsDirectional innerPadding;

  /// Makes the box itself the tap target — the port of `as="button"`. Null
  /// leaves the box inert chrome, which is the `as="div"` default.
  final VoidCallback? onTap;

  /// The accessible name for the box when [onTap] is set. Defaults to [label].
  final String? semanticsLabel;

  /// The disabled fill.
  ///
  /// The source is `color-mix(in srgb, var(--color-brand-primary) 4%, white)`
  /// (`TextField.jsx:45`) — the same construction as
  /// [DabblerSurface.brandTintFill], at half its light-mode strength.
  ///
  /// **Deviation, documented:** the source declares no dark-mode value for
  /// this mix, and mixing toward literal white in dark mode would produce a
  /// disabled field brighter than the page. The only dark rule the source
  /// states for a brand `color-mix` is the tint's 8% → 22% pair, so this takes
  /// the same relationship: half of each, 4% toward white in light and 11%
  /// toward black in dark. It stays opaque by construction, as the flat system
  /// requires.
  static Color disabledFill(DabblerColors colors) {
    final bool dark = colors.brightness == Brightness.dark;
    return Color.lerp(
      dark ? Colors.black : Colors.white,
      colors.brandPrimary,
      dark ? 0.11 : 0.04,
    )!;
  }

  /// The border colour for the current state, or null to keep the surface's
  /// own hairline. `TextField.jsx:33-37`.
  static Color? borderColorFor(
    DabblerColors colors, {
    required bool disabled,
    required bool hasError,
    required bool focused,
  }) {
    if (disabled) {
      return colors.borderDefault;
    }
    if (hasError) {
      return colors.status(DabblerStatusTone.error).base;
    }
    if (focused) {
      return colors.focusRing;
    }
    return null;
  }

  /// The border width for the current state: 2 while focused and not disabled
  /// or errored, 1 otherwise.
  static double borderWidthFor({
    required bool disabled,
    required bool hasError,
    required bool focused,
  }) =>
      !disabled && !hasError && focused
          ? DabblerFocusRing.ringWidth
          : DabblerSizing.borderDefault;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool hasError = errorText != null;

    final BorderRadius borderRadius =
        BorderRadius.all(Radius.circular(radius));

    Widget box = DabblerSurface(
      radius: radius,
      fill: disabled ? disabledFill(colors) : DabblerSurface.fillOf(
        colors,
        DabblerSurfaceVariant.card,
      ),
      borderColor: borderColorFor(
        colors,
        disabled: disabled,
        hasError: hasError,
        focused: focused,
      ),
      borderWidth: borderWidthFor(
        disabled: disabled,
        hasError: hasError,
        focused: focused,
      ),
      child: ConstrainedBox(
        // `minHeight: var(--touch-target-min)` — the box is never shorter than
        // 45, however short its content is, and it grows past it freely, which
        // is what the multiline variant relies on. The constraint sits outside
        // the padding because a [BoxDecoration] border is painted, not laid
        // out: the box's height is its child's height, so 45 here is 45 on
        // screen.
        constraints: const BoxConstraints(
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Padding(
          padding: innerPadding,
          child: Row(
            crossAxisAlignment: align == DabblerFieldAlign.start
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: _gapped(children),
          ),
        ),
      ),
    );

    if (onTap != null) {
      box = Semantics(
        button: true,
        enabled: !disabled,
        label: semanticsLabel ?? label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: disabled ? null : onTap,
          child: box,
        ),
      );
    }

    if (focusRingVisible || onTap != null) {
      box = DabblerFocusRing.visible(
        visible: focusRingVisible,
        enabled: !disabled,
        borderRadius: borderRadius,
        child: box,
      );
    }

    final String? message = errorText ?? helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(
            label!,
            style: DabblerType.subheadline.resolveForDirection(direction).copyWith(
                  color: focused ? colors.brandPrimary : colors.textSecondary,
                ),
          ),
          const SizedBox(height: DabblerSpacing.stackTight),
        ],
        box,
        if (message != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.stackTight),
          Padding(
            padding: messagePadding,
            child: Text(
              message,
              style: DabblerType.footnote.resolveForDirection(direction).copyWith(
                    color: hasError
                        ? colors.status(DabblerStatusTone.error).base
                        : colors.textSecondary,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  /// The row with `--icon-gap` inserted between every pair, which is what CSS
  /// `gap` does and what a [Row] does not do on its own.
  static List<Widget> _gapped(List<Widget> items) {
    if (items.length < 2) {
      return items;
    }
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        out.add(const SizedBox(width: DabblerSpacing.iconGap));
      }
      out.add(items[i]);
    }
    return out;
  }
}
