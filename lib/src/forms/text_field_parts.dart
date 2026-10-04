/// Part of the `text_field.dart` library — the `select` variant's build and
/// the two trailing buttons.
///
/// **Why `part`, not a second library.** `text_field.dart` stood at 514 lines
/// against the project's 500-line house rule before the clear button (KAN-412)
/// was added. The `select` shell, the password toggle and the clear button are
/// tightly coupled to [_DabblerTextFieldState]'s private members; a part file
/// keeps private access, changes no public API, and brings every file under
/// the rule (same approach as `picker_field_shell.dart`, KAN-277).
///
/// The imports are the library's — a part file declares none of its own.
part of 'text_field.dart';

/// The `select` variant's paint, moved out of the state class unchanged.
extension _DabblerTextFieldSelect on _DabblerTextFieldState {
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
      borderOutside: widget.borderOutside,
      radius: radius,
      onTap: widget.onPressed,
      semanticsLabel: widget.label,
      expanded: widget.open,
      children: <Widget>[
        if (widget.prefixIcon != null)
          _DabblerTextFieldState._iconSlot(
            widget.prefixIcon!,
            colors.brandPrimary,
          ),
        Expanded(
          child: Text(
            filled ? shown : (widget.placeholder ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.body
                .resolveForDirection(direction)
                .copyWith(
                  // D-003(a): the unfilled placeholder is text and takes
                  // [DabblerColors.textSecondary]. The disabled value keeps
                  // the tertiary role — WCAG 1.4.3 exempts an inactive
                  // user-interface component.
                  color: disabled
                      ? colors.textTertiary
                      : (filled ? colors.textPrimary : colors.textSecondary),
                ),
          ),
        ),
        if (widget.circledSelectArrow)
          DabblerIcon(
            widget.open
                ? DabblerTextField.selectArrowOpenCircledName
                : DabblerTextField.selectArrowCircledName,
            size: DabblerSizing.iconSm,
            color: colors.textSecondary,
          )
        else
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
}

/// The password visibility toggle — a 45×45 target, which
/// `fields.card.html:99` (unverified: file not mirrored) calls out explicitly.
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

/// The search variant's inline clear button — a 45×45 target at the inline
/// end holding a `close-circle` at `--icon-sm`, `--muted` (tertiary role)
/// (`Search.dc.html:171`). Directional, so it sits on the left in RTL.
class _ClearButton extends StatelessWidget {
  const _ClearButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: DabblerSizing.touchTargetMin,
          height: DabblerSizing.touchTargetMin,
          child: Center(
            child: DabblerIcon(
              DabblerTextField.clearIconName,
              size: DabblerSizing.iconSm,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// [DabblerTextField.loading]'s trailing slot — a `sm` [DabblerSpinner] in
/// the brand tone, centred in the clear button's 45×45 box so swapping one for
/// the other never shifts the text. The spinner is its own live region.
class _LoadingSlot extends StatelessWidget {
  const _LoadingSlot();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: DabblerSizing.touchTargetMin,
    height: DabblerSizing.touchTargetMin,
    child: Center(child: DabblerSpinner(size: DabblerSpinnerSize.sm)),
  );
}
