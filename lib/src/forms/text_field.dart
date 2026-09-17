import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'field_shell.dart';

/// The five shapes a [DabblerTextField] takes.
///
/// `components/forms/TextField.d.ts:3` — *"standard · search · password ·
/// multiline · select"*.
enum DabblerTextFieldVariant {
  /// Plain single-line input. `--radius-xxl`.
  standard,

  /// Adds a leading `search-normal` glyph. `--radius-xxl`.
  search,

  /// Obscured, with a trailing `eye` / `eye-slash` visibility toggle on a 45px
  /// target. `--radius-xxl`.
  password,

  /// Multi-line input, top-aligned. `--radius-xl` — the one variant with a
  /// different radius.
  multiline,

  /// Not an input at all: the same box rendered as a button with a trailing
  /// `arrow-down` that rotates while [DabblerTextField.open]. This is the
  /// shell every picker in the system reuses. `--radius-xxl`.
  select,
}

/// TextField — the flat input.
///
/// Transcribed from `components/forms/TextField.jsx:86-177`,
/// `TextField.d.ts:1-40`, `TextField.prompt.md` and the specimens
/// `components/forms/fields.card.html:70-100` (the five states and the five
/// variants) and `forms.card.html:28-34`.
///
/// ```dart
/// DabblerTextField(
///   label: 'Email',
///   errorText: valid ? null : 'Enter a valid email',
///   onChanged: (String v) => setState(() => email = v),
/// )
/// ```
///
/// ## It owns state; [DabblerFieldShell] owns paint
///
/// Everything visible — the label, the box, the four border states, the
/// helper / error line — is [DabblerFieldShell]. This widget contributes the
/// input itself, the variant's affordances, and the two pieces of state the
/// shell cannot know: whether the field has focus, and whether the password is
/// revealed. That split is the whole point of AC1: a field that paints its own
/// box is a fork of the input, and the specimen names that as the failure the
/// shell exists to prevent.
///
/// ## Radius per variant
///
/// `TextField.jsx:5-9`: every variant is `--radius-xxl` (24) except
/// `multiline`, which is `--radius-xl` (18).
///
/// ## Colours
///
/// The leading icon is `--color-brand-primary`; a trailing icon and the
/// password toggle are `--color-text-secondary`; the value is
/// `--color-text-primary`, or `--color-text-tertiary` when disabled; the
/// placeholder is `--color-text-tertiary`. No literal in this file.
///
/// ## Reduced motion
///
/// The only animation is the `select` arrow's 180° rotation over
/// `--motion-base` with `--ease-out`. It is dropped to [Duration.zero] under
/// [DabblerMotion.reduceMotion], as every other animation in the package is.
class DabblerTextField extends StatefulWidget {
  /// Creates a field of [variant].
  const DabblerTextField({
    super.key,
    this.variant = DabblerTextFieldVariant.standard,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.rows = 3,
    this.value,
    this.open = false,
    this.onPressed,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
  }) : assert(
         controller == null || initialValue == null,
         'give a controller or an initialValue, not both',
       ),
       assert(rows > 0, 'a multiline field has at least one row');

  /// `rows` default in the source (`TextField.jsx:89`).
  static const int defaultRows = 3;

  /// `search-normal` — the leading glyph of the `search` variant
  /// (`TextField.prompt.md`).
  static const String searchIconName = 'search-normal';

  /// `eye` / `eye-slash` — the password visibility toggle's two glyphs.
  static const String revealIconName = 'eye';

  /// The glyph shown while the password is revealed.
  static const String concealIconName = 'eye-slash';

  /// `arrow-down` — the `select` shell's trailing glyph, at `--icon-sm` (18).
  static const String selectArrowName = 'arrow-down';

  /// Which shape the field takes.
  final DabblerTextFieldVariant variant;

  /// The text being edited. Ignored by [DabblerTextFieldVariant.select], which
  /// displays [value] instead.
  final TextEditingController? controller;

  /// Seeds an internally-owned controller. Mutually exclusive with
  /// [controller] — the source's `defaultValue`.
  final String? initialValue;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the input is submitted. Not fired by the multiline variant,
  /// where Enter inserts a newline.
  final ValueChanged<String>? onSubmitted;

  /// The empty-state text, in `--color-text-tertiary`.
  final String? placeholder;

  /// The label above the box.
  final String? label;

  /// The helper line below the box. Replaced by [errorText] when that is set.
  final String? helperText;

  /// The error line below the box, and the trigger for the error border.
  final String? errorText;

  /// Whether the field accepts input. `false` is the source's `disabled`.
  final bool enabled;

  /// A leading icon. Ignored by [DabblerTextFieldVariant.search], which
  /// supplies its own.
  final Widget? prefixIcon;

  /// A trailing icon. Ignored by [DabblerTextFieldVariant.password], whose
  /// trailing slot is the visibility toggle, and by
  /// [DabblerTextFieldVariant.select], whose trailing slot is the arrow.
  final Widget? suffixIcon;

  /// Visible rows for [DabblerTextFieldVariant.multiline].
  final int rows;

  /// The displayed value of [DabblerTextFieldVariant.select]. Null or empty
  /// shows [placeholder] in the placeholder colour.
  final String? value;

  /// Whether the picker this `select` shell fronts is open: holds the focus
  /// state and rotates the arrow.
  final bool open;

  /// Tap handler for [DabblerTextFieldVariant.select].
  final VoidCallback? onPressed;

  /// An external focus node, if the caller owns focus.
  final FocusNode? focusNode;

  /// Keyboard type. Defaults to [TextInputType.multiline] for the multiline
  /// variant and [TextInputType.text] otherwise.
  final TextInputType? keyboardType;

  /// The action key. Defaults to [TextInputAction.newline] for multiline.
  final TextInputAction? textInputAction;

  /// Autofill hints, e.g. `AutofillHints.password`.
  final Iterable<String>? autofillHints;

  /// The corner radius of [variant] — `TextField.jsx:5-9`.
  static double radiusOf(DabblerTextFieldVariant variant) =>
      variant == DabblerTextFieldVariant.multiline
      ? DabblerRadius.xl
      : DabblerRadius.xxl;

  @override
  State<DabblerTextField> createState() => _DabblerTextFieldState();
}

class _DabblerTextFieldState extends State<DabblerTextField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  bool _focused = false;
  bool _reveal = false;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(DabblerTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(
        _handleFocusChange,
      );
      _focusNode.addListener(_handleFocusChange);
      _focused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownedFocusNode?.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted || _focused == _focusNode.hasFocus) {
      return;
    }
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool disabled = !widget.enabled;
    final double radius = DabblerTextField.radiusOf(widget.variant);

    if (widget.variant == DabblerTextFieldVariant.select) {
      return _buildSelect(colors, direction, disabled, radius);
    }

    final bool multiline = widget.variant == DabblerTextFieldVariant.multiline;
    final bool password = widget.variant == DabblerTextFieldVariant.password;

    // `TextField.jsx:100-107` — the input's own type is `.t-body`'s metrics,
    // 16/21, which is exactly [DabblerType.body].
    final TextStyle textStyle = DabblerType.body
        .resolveForDirection(direction)
        .copyWith(color: disabled ? colors.textTertiary : colors.textPrimary);

    final Widget? lead = widget.variant == DabblerTextFieldVariant.search
        ? DabblerIcon(
            DabblerTextField.searchIconName,
            size: DabblerSizing.iconMd,
            color: colors.brandPrimary,
          )
        : widget.prefixIcon;

    return DabblerFieldShell(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      focused: _focused,
      disabled: disabled,
      radius: radius,
      align: multiline ? DabblerFieldAlign.start : DabblerFieldAlign.center,
      // The port of the password toggle's `marginInlineEnd: calc(--space-2 *
      // -1)`: Flutter forbids a negative [Padding], so the shell's trailing
      // inset is reduced by the same 6 instead. The toggle's 45px target then
      // ends 6 from the box edge, as it does in the source.
      innerPadding: password
          ? const EdgeInsetsDirectional.fromSTEB(
              DabblerSpacing.space4,
              DabblerSpacing.space3,
              DabblerSpacing.space2,
              DabblerSpacing.space3,
            )
          : DabblerFieldShell.defaultInnerPadding,
      children: <Widget>[
        if (lead != null) _iconSlot(lead, colors.brandPrimary),
        Expanded(
          // Material's text-editing behaviour needs a [Material] ancestor for
          // its selection toolbar. `MaterialType.transparency` supplies one
          // that paints nothing at all — no fill, no shape, no elevation — so
          // the field works in a bare [WidgetsApp] without putting a second
          // surface under the shell's own box.
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: textStyle,
              cursorColor: colors.brandPrimary,
              obscureText: password && !_reveal,
              maxLines: multiline ? widget.rows : 1,
              minLines: multiline ? widget.rows : 1,
              keyboardType:
                  widget.keyboardType ??
                  (multiline ? TextInputType.multiline : TextInputType.text),
              textInputAction:
                  widget.textInputAction ??
                  (multiline ? TextInputAction.newline : TextInputAction.done),
              autofillHints: widget.autofillHints,
              onChanged: widget.onChanged,
              onSubmitted: multiline ? null : widget.onSubmitted,
              // Material's decoration is stripped to nothing: the box, the
              // border, the label and the helper line are all
              // [DabblerFieldShell]'s, and a second set underneath them would be
              // exactly the visual fork AC1 forbids. What is kept is the
              // *behaviour* — tap to focus, selection handles, the platform
              // keyboard, autofill and obscuring — which is why this is Material's
              // [TextField] and not a bare [EditableText].
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.placeholder,
                hintStyle: textStyle.copyWith(color: colors.textTertiary),
                hintMaxLines: 1,
              ),
            ),
          ),
        ),
        if (password)
          _PasswordToggle(
            revealed: _reveal,
            enabled: !disabled,
            color: colors.textSecondary,
            onPressed: () => setState(() => _reveal = !_reveal),
          )
        else if (widget.suffixIcon != null)
          _iconSlot(widget.suffixIcon!, colors.textSecondary),
      ],
    );
  }

  Widget _buildSelect(
    DabblerColors colors,
    TextDirection direction,
    bool disabled,
    double radius,
  ) {
    final String? shown = widget.value;
    final bool filled = shown != null && shown.isNotEmpty;

    return DabblerFieldShell(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      // `focused={focused || open}` — an open picker holds the field's focus
      // state even though focus itself has moved into the popup.
      focused: _focused || widget.open,
      focusRingVisible: _focused,
      disabled: disabled,
      radius: radius,
      onTap: widget.onPressed,
      semanticsLabel: widget.label,
      children: <Widget>[
        if (widget.prefixIcon != null)
          _iconSlot(widget.prefixIcon!, colors.brandPrimary),
        Expanded(
          child: Text(
            filled ? shown : (widget.placeholder ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.body
                .resolveForDirection(direction)
                .copyWith(
                  color: disabled
                      ? colors.textTertiary
                      : (filled ? colors.textPrimary : colors.textTertiary),
                ),
          ),
        ),
        AnimatedRotation(
          turns: widget.open ? 0.5 : 0,
          duration: DabblerMotion.reduceMotion(context)
              ? Duration.zero
              : DabblerMotion.base,
          curve: DabblerMotion.easeOut,
          child: DabblerIcon(
            DabblerTextField.selectArrowName,
            size: DabblerSizing.iconSm,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// A 24×24 slot, which is the source's `width: 24, height: 24, flexShrink: 0`
  /// around every icon in the row, tinted through [IconTheme] so a caller's
  /// plain [Icon] picks the role colour up.
  static Widget _iconSlot(Widget icon, Color color) => SizedBox(
    width: DabblerSizing.iconMd,
    height: DabblerSizing.iconMd,
    child: IconTheme.merge(
      data: IconThemeData(color: color, size: DabblerSizing.iconMd),
      child: Center(child: icon),
    ),
  );
}

/// The password visibility toggle — a 45×45 target, which
/// `fields.card.html:99` calls out explicitly.
class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({
    required this.revealed,
    required this.enabled,
    required this.color,
    required this.onPressed,
  });

  final bool revealed;
  final bool enabled;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: revealed ? 'Hide password' : 'Show password',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: DabblerSizing.touchTargetMin,
          height: DabblerSizing.touchTargetMin,
          child: Center(
            child: DabblerIcon(
              revealed
                  ? DabblerTextField.concealIconName
                  : DabblerTextField.revealIconName,
              size: DabblerSizing.iconMd,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
