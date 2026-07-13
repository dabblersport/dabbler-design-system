// =============================================================================
// Dabbler — Text Field / Input component
// -----------------------------------------------------------------------------
// A flat, token-driven text field. Every colour, size, radius, and weight is
// read from the design tokens (context.dabbler / DabblerType / DabblerSizing /
// DabblerRadius / DabblerSpacing) — nothing is hardcoded.
//
// Flat by design: no shadow, and every InputDecoration border slot is set
// explicitly to an OutlineInputBorder so Material's default underline / filled
// decoration never leaks through.
//
// Bilingual / RTL: prefix/suffix affordances use InputDecoration's start/end
// slots (so they mirror under RTL), Arabic gets DabblerType.arabic() leading,
// and text direction follows the ambient Directionality (the app locale).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';

/// Field shapes. `standard`/`password` use radius sm, `multiline` md, `search`
/// pill.
enum DabblerTextFieldVariant { standard, multiline, search, password }

class DabblerTextField extends StatefulWidget {
  const DabblerTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.validator,
    this.variant = DabblerTextFieldVariant.standard,
  });

  /// Search field: leading search icon + a trailing clear (×) when non-empty,
  /// pill radius.
  const DabblerTextField.search({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
  })  : variant = DabblerTextFieldVariant.search,
        errorText = null,
        obscureText = false,
        prefixIcon = null,
        suffixIcon = null,
        onSuffixTap = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        validator = null;

  /// Password field: obscured, with a trailing visibility toggle.
  const DabblerTextField.password({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.validator,
  })  : variant = DabblerTextFieldVariant.password,
        readOnly = false,
        obscureText = true,
        prefixIcon = null,
        suffixIcon = null,
        onSuffixTap = null,
        maxLines = 1,
        minLines = null,
        maxLength = null;

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final DabblerTextFieldVariant variant;

  @override
  State<DabblerTextField> createState() => _DabblerTextFieldState();
}

class _DabblerTextFieldState extends State<DabblerTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _obscured = false;
  bool _focused = false;

  bool get _ownsFocusNode => widget.focusNode == null;
  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
    // The search clear button appears/disappears with the text.
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _onTextChange() {
    if (widget.variant == DabblerTextFieldVariant.search) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = widget.enabled;

    // Arabic takes DabblerType's taller leading.
    TextStyle a(TextStyle s) => rtl ? DabblerType.arabic(s) : s;

    final inputStyle = a(DabblerType.body).copyWith(
      color: enabled ? d.textPrimary : d.textTertiary,
    );
    final hintStyle = a(DabblerType.body).copyWith(color: d.textTertiary);
    final helperStyle = a(DabblerType.footnote).copyWith(color: d.textSecondary);
    final errorStyle = a(DabblerType.footnote).copyWith(color: d.error);
    final counterStyle = a(DabblerType.footnote).copyWith(color: d.textTertiary);

    final radius = _radius(widget.variant);

    // Every border slot is explicit → no Material underline, ever. Flat.
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    final decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: enabled ? d.bgSecondary : d.bgTertiary,
      hintText: widget.hint,
      hintStyle: hintStyle,
      helperText: widget.helperText,
      helperStyle: helperStyle,
      errorText: widget.errorText,
      errorStyle: errorStyle,
      counterStyle: counterStyle,
      // Single-line fields clear the 45 tap-target floor; multiline grows above.
      constraints:
          const BoxConstraints(minHeight: DabblerSizing.touchTargetMin),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space4, // 12
        vertical: DabblerSpacing.space3, // 9
      ),
      prefixIcon: _buildPrefix(d),
      suffixIcon: _buildSuffix(d),
      // start/end slots mirror automatically under RTL.
      // Border per state — focus = 2px focusRing, error = 1px error, else 1px
      // borderDefault. No shadow anywhere.
      border: border(d.borderDefault, DabblerSizing.borderDefault),
      enabledBorder: border(d.borderDefault, DabblerSizing.borderDefault),
      focusedBorder: border(d.focusRing, DabblerSizing.borderDefault + 1),
      errorBorder: border(d.error, DabblerSizing.borderDefault),
      focusedErrorBorder: border(d.error, DabblerSizing.borderDefault),
      disabledBorder: border(d.borderDefault, DabblerSizing.borderDefault),
    );

    final field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: enabled,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      style: inputStyle,
      cursorColor: d.brandPrimary,
      maxLines: _obscured ? 1 : _resolveMaxLines(),
      minLines: widget.variant == DabblerTextFieldVariant.multiline
          ? (widget.minLines ?? 3)
          : widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: _resolveKeyboardType(),
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted:
          widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
      decoration: decoration,
    );

    if (widget.label == null) return field;

    // Label sits ABOVE the field; it turns brandPrimary while focused.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: a(DabblerType.subheadline).copyWith(
            color: _focused ? d.brandPrimary : d.textSecondary,
          ),
        ),
        const SizedBox(height: DabblerSpacing.stackTight), // 6
        field,
      ],
    );
  }

  int? _resolveMaxLines() => switch (widget.variant) {
        DabblerTextFieldVariant.multiline => widget.maxLines, // null → grows
        _ => widget.maxLines ?? 1,
      };

  TextInputType? _resolveKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;
    if (widget.variant == DabblerTextFieldVariant.multiline) {
      return TextInputType.multiline;
    }
    return null;
  }

  BorderRadius _radius(DabblerTextFieldVariant v) => switch (v) {
        DabblerTextFieldVariant.standard => DabblerRadius.smRadius, // 6
        DabblerTextFieldVariant.password => DabblerRadius.smRadius,
        DabblerTextFieldVariant.multiline => DabblerRadius.mdRadius, // 9
        DabblerTextFieldVariant.search => DabblerRadius.pillRadius, // 999
      };

  /// Leading slot (start side; mirrors under RTL).
  Widget? _buildPrefix(DabblerColors d) {
    final icon = widget.variant == DabblerTextFieldVariant.search
        ? Icons.search
        : widget.prefixIcon;
    if (icon == null) return null;
    return Icon(icon, size: DabblerSizing.iconMd, color: d.textSecondary);
  }

  /// Trailing slot (end side; mirrors under RTL). Password → visibility toggle,
  /// search → clear (×) when non-empty, otherwise the caller's suffix icon.
  Widget? _buildSuffix(DabblerColors d) {
    if (widget.variant == DabblerTextFieldVariant.password) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: DabblerSizing.iconMd,
          color: d.textSecondary,
        ),
        onPressed: widget.enabled
            ? () => setState(() => _obscured = !_obscured)
            : null,
        tooltip: _obscured ? 'Show password' : 'Hide password',
      );
    }

    if (widget.variant == DabblerTextFieldVariant.search &&
        _controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.close, size: DabblerSizing.iconMd, color: d.textSecondary),
        onPressed: widget.enabled
            ? () {
                _controller.clear();
                widget.onChanged?.call('');
              }
            : null,
        tooltip: 'Clear',
      );
    }

    final icon = widget.suffixIcon;
    if (icon == null) return null;
    final child =
        Icon(icon, size: DabblerSizing.iconMd, color: d.textSecondary);
    if (widget.onSuffixTap == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: DabblerSpacing.space3),
        child: child,
      );
    }
    return IconButton(icon: child, onPressed: widget.onSuffixTap);
  }
}
