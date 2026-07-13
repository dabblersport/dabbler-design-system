// =============================================================================
// Dabbler — Text Field / Input component (Liquid Glass)
// -----------------------------------------------------------------------------
// The design's Search Field treatment: a glass surface (blurred translucent
// fill), radius xxl (24), the gradient hairline, the inset glass shadow, and a
// brandPrimary leading icon. Focus swaps the hairline for a 2px focusRing;
// error swaps it for the error colour. Every InputDecoration border slot is an
// explicit InputBorder.none, so Material's underline / filled default can never
// leak through — the glass surface owns fill, border, and shadow.
//
// Bilingual / RTL: prefix/suffix affordances use InputDecoration's start/end
// slots (so they mirror under RTL), Arabic gets DabblerType.arabic() leading,
// and text direction follows the ambient Directionality (the app locale).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_glass.dart';
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
    // Search: the clear (×) appears with text. maxLength: the manual counter.
    if (widget.variant == DabblerTextFieldVariant.search ||
        widget.maxLength != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = widget.enabled;
    final hasError = widget.errorText != null;

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

    // The glass surface carries fill + border + shadow; the InputDecoration is
    // stripped to content only (explicit InputBorder.none everywhere → no
    // Material underline or filled default can leak through).
    final decoration = InputDecoration(
      isDense: true,
      filled: false,
      hintText: widget.hint,
      hintStyle: hintStyle,
      errorStyle: errorStyle, // used only by Form validators
      counterText: '', // counter is rendered manually below the glass
      constraints:
          const BoxConstraints(minHeight: DabblerSizing.touchTargetMin),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space4, // 12
        vertical: DabblerSpacing.space3, // 9
      ),
      prefixIcon: _buildPrefix(d),
      suffixIcon: _buildSuffix(d),
      // start/end slots mirror automatically under RTL.
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
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

    // State-driven border: error > focus > glass gradient hairline.
    // Disabled fields get a solid quiet border on a denser fill.
    Color? borderOverride;
    double borderWidth = DabblerSizing.borderDefault;
    if (!enabled) {
      borderOverride = d.borderDefault;
    } else if (hasError) {
      borderOverride = d.error;
    } else if (_focused && !widget.readOnly) {
      borderOverride = d.focusRing;
      borderWidth = DabblerSizing.borderDefault + 1; // 2px
    }

    final glassField = DabblerGlassSurface(
      borderRadius: radius,
      blur: DabblerGlass.blurField, // 22 — the search-field scale
      fill: enabled ? null : DabblerGlass.solidFill(d, b),
      borderColor: borderOverride,
      borderWidth: borderWidth,
      shadows: DabblerGlass.insetShadows(d, b),
      child: field,
    );

    // Below the glass: error replaces helper; counter trails.
    final below = <Widget>[];
    if (hasError) {
      below.add(Text(widget.errorText!, style: errorStyle));
    } else if (widget.helperText != null) {
      below.add(Text(widget.helperText!, style: helperStyle));
    }
    Widget? belowRow;
    final counter = widget.maxLength == null
        ? null
        : Text('${_controller.text.length}/${widget.maxLength}',
            style: counterStyle);
    if (below.isNotEmpty || counter != null) {
      belowRow = Row(
        children: [
          Expanded(child: below.isEmpty ? const SizedBox.shrink() : below.first),
          if (counter != null) counter,
        ],
      );
    }

    if (widget.label == null && belowRow == null) return glassField;

    // Label sits ABOVE the field; it turns brandPrimary while focused.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: a(DabblerType.subheadline).copyWith(
              color: _focused ? d.brandPrimary : d.textSecondary,
            ),
          ),
          const SizedBox(height: DabblerSpacing.stackTight), // 6
        ],
        glassField,
        if (belowRow != null) ...[
          const SizedBox(height: DabblerSpacing.stackTight),
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: DabblerSpacing.space4),
            child: belowRow,
          ),
        ],
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

  // The search-field treatment (pen radius 24 → DabblerRadius.xxl) applies to
  // every single-line field; multiline steps down to xl.
  BorderRadius _radius(DabblerTextFieldVariant v) => switch (v) {
        DabblerTextFieldVariant.standard => DabblerRadius.xxlRadius, // 24
        DabblerTextFieldVariant.password => DabblerRadius.xxlRadius,
        DabblerTextFieldVariant.multiline => DabblerRadius.xlRadius, // 18
        DabblerTextFieldVariant.search => DabblerRadius.xxlRadius,
      };

  /// Leading slot (start side; mirrors under RTL). The design renders the
  /// leading icon in brandPrimary on the glass field.
  Widget? _buildPrefix(DabblerColors d) {
    final icon = widget.variant == DabblerTextFieldVariant.search
        ? Icons.search
        : widget.prefixIcon;
    if (icon == null) return null;
    return Icon(icon, size: DabblerSizing.iconMd, color: d.brandPrimary);
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
