/// Part of the `text_field.dart` library — the editable variants' build.
///
/// **Why `part`.** Adding Form integration and `suffixText` (Alpha DS gaps 5,
/// item 4) would have pushed `text_field.dart` past the 500-line house rule;
/// the build moves here unchanged in behaviour, keeping private access.
part of 'text_field.dart';

/// The editable variants' paint, shared by the plain path and the [FormField]
/// path — the second differs only in where [errorText] comes from.
extension _DabblerTextFieldEditable on _DabblerTextFieldState {
  Widget _buildField(
    BuildContext context,
    String? errorText,
    bool announceError,
  ) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool disabled = !widget.enabled;
    final double radius = DabblerTextField.radiusOf(widget.variant);

    if (widget.variant == DabblerTextFieldVariant.select) {
      return _buildSelect(colors, direction, disabled, radius);
    }

    final bool multiline = widget.variant == DabblerTextFieldVariant.multiline;
    final bool password = widget.variant == DabblerTextFieldVariant.password;
    final bool showLoading = widget.loading && !password;
    final bool showClear =
        widget.variant == DabblerTextFieldVariant.search &&
        widget.clearable &&
        _hasText &&
        !disabled &&
        !showLoading;

    // `TextField.jsx:105-110` — the input's own type is `.t-body`'s metrics,
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
      errorText: errorText,
      announceError: announceError,
      focused: _focused,
      disabled: disabled,
      radius: radius,
      align: multiline ? DabblerFieldAlign.start : DabblerFieldAlign.center,
      // The port of the password toggle's `marginInlineEnd: calc(--space-2 *
      // -1)`: Flutter forbids a negative [Padding], so the shell's trailing
      // inset is reduced by the same 6 instead. The toggle's 45px target then
      // ends 6 from the box edge, as it does in the source.
      // The clear button and the password toggle follow the same inset, with
      // no block padding: their 45px target already fills the box's 45px
      // minimum height, so the box does not grow when they appear. This is the
      // design's `input[type="password"] + button { margin-block: -9px }`
      // (`Auth and Onboarding.dc.html:28-30`): the toggle keeps its 45px tap
      // target but stops stretching the field past the 45px box every other
      // field draws.
      innerPadding: showClear || showLoading || password
          ? const EdgeInsetsDirectional.fromSTEB(
              DabblerSpacing.space4,
              0,
              DabblerSpacing.space2,
              0,
            )
          : DabblerFieldShell.defaultInnerPadding,
      children: <Widget>[
        if (lead != null)
          _DabblerTextFieldState._iconSlot(lead, colors.brandPrimary),
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
              autofocus: widget.autofocus,
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
                // D-003(a): an ENABLED placeholder is text under WCAG, so
                // it takes the ink-soft-backed secondary role, never a
                // surface neutral. D-025: once the field is disabled, WCAG
                // 1.4.3 exempts an inactive component and the placeholder
                // follows the value onto the tertiary role — leaving it
                // secondary would make a disabled empty field text-identical
                // to an enabled one, which is the outcome D-025 rejects.
                hintStyle: textStyle.copyWith(
                  color: disabled ? colors.textTertiary : colors.textSecondary,
                ),
                hintMaxLines: 1,
              ),
            ),
          ),
        ),
        if (widget.suffixText != null && widget.suffixText!.isNotEmpty)
          _suffixTextSlot(widget.suffixText!, colors, direction, disabled),
        if (password)
          _PasswordToggle(
            revealed: _reveal,
            enabled: !disabled,
            color: colors.textSecondary,
            onPressed: _toggleReveal,
          )
        else if (showLoading)
          const _LoadingSlot()
        else if (showClear)
          _ClearButton(
            label: widget.clearLabel,
            color: colors.textTertiary,
            onPressed: _clear,
          )
        else if (widget.suffixIcon != null)
          _DabblerTextFieldState._iconSlot(
            widget.suffixIcon!,
            colors.textSecondary,
          ),
      ],
    );
  }

  /// [DabblerTextField.suffixText] — `.t-body` in the secondary role
  /// (tertiary once disabled), at the trailing edge inside the box, never
  /// wrapping. Directional through the row, so it sits on the left in RTL.
  Widget _suffixTextSlot(
    String text,
    DabblerColors colors,
    TextDirection direction,
    bool disabled,
  ) => Text(
    text,
    maxLines: 1,
    softWrap: false,
    style: DabblerType.body
        .resolveForDirection(direction)
        .copyWith(color: disabled ? colors.textTertiary : colors.textSecondary),
  );
}
