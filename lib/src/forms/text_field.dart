import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'field_shell.dart';

part 'text_field_editable.dart';
part 'text_field_parts.dart';

/// The five shapes a [DabblerTextField] takes.
///
/// `components/forms/TextField.d.ts:3` (unverified: file not mirrored) — *"standard · search · password ·
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
/// Transcribed from `components/forms/TextField.jsx:83-162`,
/// `TextField.d.ts:1-40` (unverified: file not mirrored), `TextField.prompt.md` and the specimens
/// `components/forms/fields.card.html:70-100` (unverified: file not mirrored) (the five states and the five
/// variants) and `forms.card.html:28-34` (unverified: file not mirrored).
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
/// `--color-text-primary`, or `--color-text-tertiary` when disabled. No
/// literal in this file.
///
/// The placeholder is `--color-text-secondary` while the field is enabled and
/// `--color-text-tertiary` once it is disabled, in **every** variant — the
/// `hintStyle` of the editable variants and the stand-in value the `select`
/// variant draws when it has none.
///
/// **`D-003(a)`** puts the placeholder on the secondary role: a placeholder is
/// text under WCAG, so it takes the ink-soft-backed role rather than a surface
/// neutral. **`D-025`** is the exception WCAG 1.4.3 allows for an inactive
/// user-interface component, and its own reasoning is why the disabled state
/// takes it: a disabled field whose text is indistinguishable from an enabled
/// one is the worse accessibility outcome, not the better one. The exemption
/// is conditional — disabled-ness is also carried by `Semantics(enabled:
/// false)` and by [DabblerFieldShell]'s disabled fill, never by contrast
/// alone. The call sites are the authority — see [placeholder].
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
    this.clearable = false,
    this.onCleared,
    this.clearLabel = defaultClearLabel,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.suffixText,
    this.autofocus = false,
    this.loading = false,
  }) : assert(
         controller == null || initialValue == null,
         'give a controller or an initialValue, not both',
       ),
       assert(rows > 0, 'a multiline field has at least one row');

  /// `rows` default in the source (`TextField.jsx:94`).
  static const int defaultRows = 3;

  /// `search-normal` — the leading glyph of the `search` variant
  /// (`TextField.prompt.md`).
  static const String searchIconName = 'search-normal';

  /// `close-circle` — the inline clear glyph of the `search` variant
  /// (`Search.dc.html:171`), at `--icon-sm` (18).
  static const String clearIconName = 'close-circle';

  /// The clear button's default semantics label. Pass [clearLabel] to localise.
  static const String defaultClearLabel = 'Clear';

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

  /// The empty-state text.
  ///
  /// `--color-text-secondary` while the field is enabled (`D-003(a)`: a
  /// placeholder is text under WCAG, not a surface neutral), and
  /// `--color-text-tertiary` once it is disabled (`D-025`: WCAG 1.4.3 exempts
  /// an inactive user-interface component).
  ///
  /// **The rule is the same in every variant**, though two different
  /// mechanisms carry it: the editable variants pass this string to Flutter
  /// as `hintText` and colour it through `hintStyle`, while `select` draws
  /// its own stand-in value. A disabled field still renders its placeholder
  /// in both. Each state of each mechanism is pinned in
  /// `test/forms/text_field_test.dart` so this paragraph cannot drift from
  /// the paint again.
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

  /// Whether the [DabblerTextFieldVariant.search] variant shows an inline
  /// clear button while it holds text. Ignored by every other variant.
  ///
  /// The button is a 45×45 target at the inline end (left in RTL), a
  /// `close-circle` at `--icon-sm` in the tertiary (`--muted`) role, and is
  /// absent while the field is empty or disabled. Tapping it empties the
  /// controller, fires [onChanged] with `''` and [onCleared], and keeps focus.
  /// Works with an external [controller] and without.
  final bool clearable;

  /// Called after the clear button empties the field.
  final VoidCallback? onCleared;

  /// The clear button's semantics label — localisable.
  final String clearLabel;

  /// Validates the text inside an enclosing [Form], as
  /// `TextFormField.validator` does. Its message is shown in the [errorText]
  /// slot (error border included) and announced to assistive technology as a
  /// live region. Ignored by [DabblerTextFieldVariant.select].
  ///
  /// Giving this, [onSaved] or [autovalidateMode] registers the field as a
  /// [FormField], so it takes part in `Form.validate()`, `save()` and
  /// `reset()` (reset restores the initial text). With none of the three the
  /// field is the plain widget it always was.
  final FormFieldValidator<String>? validator;

  /// Called with the current text by `FormState.save()`.
  final FormFieldSetter<String>? onSaved;

  /// When the validator runs on its own — [AutovalidateMode.onUserInteraction]
  /// re-validates on every edit after the first. Defaults to the enclosing
  /// [Form]'s mode, else [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  /// Short text at the trailing edge inside the box — a unit such as `min` or
  /// `km`. `.t-body`, secondary role. Shown in every editable variant, before
  /// the password toggle, clear button or [suffixIcon]; ignored by
  /// [DabblerTextFieldVariant.select].
  final String? suffixText;

  /// Whether the field takes focus when first built, as
  /// `TextField.autofocus` does. Default `false`.
  final bool autofocus;

  /// Shows a small [DabblerSpinner] (`sm`, 18px, brand tone) in a 45×45 slot
  /// at the inline end — left in RTL — while a result is pending, e.g. a
  /// search request in flight. It **replaces** the clear button and
  /// [suffixIcon] while `true` (the password toggle is kept); the field stays
  /// editable. The slot is the clear button's size, so toggling it never
  /// moves the text. Ignored by [DabblerTextFieldVariant.select].
  final bool loading;

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
  bool _hasText = false;

  /// The text at first build — what `Form.reset()` restores.
  String _initialText = '';
  final GlobalKey<FormFieldState<String>> _formFieldKey =
      GlobalKey<FormFieldState<String>>();

  bool get _usesForm =>
      widget.variant != DabblerTextFieldVariant.select &&
      (widget.validator != null ||
          widget.onSaved != null ||
          widget.autovalidateMode != null);

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
    _initialText = _controller.text;
  }

  @override
  void didUpdateWidget(DabblerTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _handleTextChange,
      );
      _controller.addListener(_handleTextChange);
      _hasText = _controller.text.isNotEmpty;
    }
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
    _controller.removeListener(_handleTextChange);
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

  void _handleTextChange() {
    // Keep the [FormField]'s value in step with every edit, programmatic ones
    // (clear, a caller's controller) included — `TextFormField` does the same.
    final FormFieldState<String>? field = _formFieldKey.currentState;
    if (field != null && field.value != _controller.text) {
      field.didChange(_controller.text);
    }
    final bool hasText = _controller.text.isNotEmpty;
    if (!mounted || hasText == _hasText) {
      return;
    }
    setState(() => _hasText = hasText);
  }

  void _toggleReveal() => setState(() => _reveal = !_reveal);

  /// Empties the field and keeps (or takes) focus, so the keyboard stays up.
  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onCleared?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_usesForm) {
      return _buildField(context, widget.errorText, false);
    }
    return FormField<String>(
      key: _formFieldKey,
      initialValue: _initialText,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      enabled: widget.enabled,
      // `FormField` restores its value on reset; the controller follows, so
      // the text on screen is the text that was there at first build.
      onReset: () => _controller.text = _formFieldKey.currentState?.value ?? '',
      builder: (FormFieldState<String> field) => _buildField(
        context,
        // A validator's message wins; a caller's [errorText] still shows when
        // the validator passes, exactly as `InputDecoration.errorText` does
        // beside a `TextFormField` validator.
        field.errorText ?? widget.errorText,
        field.hasError,
      ),
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
