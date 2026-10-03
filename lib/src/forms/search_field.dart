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

  @override
  Widget build(BuildContext context) {
    return DabblerTextField(
      variant: DabblerTextFieldVariant.search,
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
    );
  }
}
