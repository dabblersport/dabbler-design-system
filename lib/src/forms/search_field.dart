import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import 'text_field.dart';

/// SearchField — the `search` text field with its inline clear button.
///
/// `Search.dc.html:162-173`: a 45px-tall `--radius-xxl` box, a leading
/// `search-normal` glyph, the query, and — at the inline end — a `close-circle`
/// at 18px in `--muted`. This is [DabblerTextField] in its
/// [DabblerTextFieldVariant.search] variant with [DabblerTextField.clearable]
/// on by default, which is the design's behaviour; nothing is painted here.
///
/// ```dart
/// DabblerSearchField(
///   placeholder: 'Search people, games, posts',
///   onChanged: (String q) => setState(() => query = q),
///   onCleared: () => setState(() => query = ''),
///   clearLabel: 'مسح',
/// )
/// ```
///
/// ## The clear button
///
/// * Shown only while the field holds text (and is enabled) — an empty field
///   has nothing to clear.
/// * A 45×45 target on the inline end: **right in LTR, left in RTL.**
/// * Tapping it empties the field, calls `onChanged('')` then [onCleared], and
///   **keeps focus** (or takes it), so the keyboard stays up for the next query.
/// * Works with an external [controller] — the controller is the source of
///   truth, so text set from outside shows or hides the button too — and with
///   none.
/// * Its semantics label is [clearLabel]; pass the localised word, as the
///   package carries no strings of its own beyond the English default.
///
/// ## Loading, focus and forms
///
/// [loading] swaps the clear button for an 18px brand spinner in the same
/// 45×45 slot while a query is in flight; [autofocus] opens the screen on the
/// keyboard; [validator], [autovalidateMode], [onSaved] and [suffixText] are
/// forwarded unchanged to [DabblerTextField].
class DabblerSearchField extends StatelessWidget {
  /// Creates a search field.
  const DabblerSearchField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.placeholder,
    this.label,
    this.helperText,
    this.enabled = true,
    this.clearable = true,
    this.clearLabel = DabblerTextField.defaultClearLabel,
    this.focusNode,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
    this.autofocus = false,
    this.loading = false,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.suffixText,
    this.borderOutside = false,
  });

  /// The text being edited; see [DabblerTextField.controller].
  final TextEditingController? controller;

  /// Seeds an internally-owned controller. Not with [controller].
  final String? initialValue;

  /// Called on every edit, and with `''` when the clear button is used.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard's search action is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear button empties the field.
  final VoidCallback? onCleared;

  /// The empty-state text.
  final String? placeholder;

  /// An optional label above the box.
  final String? label;

  /// An optional helper line below the box.
  final String? helperText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the inline clear button is offered. On by default, as designed.
  final bool clearable;

  /// The clear button's semantics label — pass the localised string.
  final String clearLabel;

  /// An external focus node, if the caller owns focus.
  final FocusNode? focusNode;

  /// Keyboard type. Defaults to text.
  final TextInputType? keyboardType;

  /// The action key. Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// Whether the field takes focus when first built — a search screen that
  /// opens straight onto the keyboard. Default `false`.
  final bool autofocus;

  /// While `true`, a small brand spinner takes the inline-end slot in place
  /// of the clear button (a query in flight). The field stays editable. See
  /// [DabblerTextField.loading].
  final bool loading;

  /// Forwarded to [DabblerTextField.validator] — registers the field in an
  /// enclosing [Form].
  final FormFieldValidator<String>? validator;

  /// Forwarded to [DabblerTextField.autovalidateMode].
  final AutovalidateMode? autovalidateMode;

  /// Forwarded to [DabblerTextField.onSaved].
  final FormFieldSetter<String>? onSaved;

  /// Forwarded to [DabblerTextField.suffixText] — short trailing text such as
  /// a result count.
  final String? suffixText;

  /// Forwarded to [DabblerTextField.borderOutside]: the hairline adds to the
  /// box (47 high, as the Auth frame draws the search field) instead of eating
  /// into it. Default false.
  final bool borderOutside;

  @override
  Widget build(BuildContext context) {
    return DabblerTextField(
      variant: DabblerTextFieldVariant.search,
      borderOutside: borderOutside,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onCleared: onCleared,
      placeholder: placeholder,
      label: label,
      helperText: helperText,
      enabled: enabled,
      clearable: clearable,
      clearLabel: clearLabel,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      loading: loading,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onSaved: onSaved,
      suffixText: suffixText,
    );
  }
}
