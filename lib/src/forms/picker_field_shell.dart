/// Part of the `picker_field.dart` library — the shell and its trailing
/// button.
///
/// **Why `part`, not a second library (KAN-277).** `picker_field.dart` stood
/// at 609 lines against the project's 500-line house rule, the consequence of
/// [DabblerPickerFieldShell] being rehomed here from `date_field.dart` under
/// KAN-250. [_PickerButton] and [DabblerPickerFieldShell]'s private state are
/// tightly coupled to each other and to nothing else; a plain second file
/// would have forced them public and leaked implementation detail this
/// package does not leak anywhere else. `part`/`part of` keeps one logical
/// library, keeps private access between the pieces, changes no public API at
/// all, and gets every resulting file under the rule. Same ruling as KAN-265
/// applied to `sheet.dart`.
///
/// The imports are the library's — a part file declares none of its own.
part of 'picker_field.dart';

/// PickerField — the shell every typed-or-picked field paints from.
///
/// Transcribed from `components/forms/PickerField.jsx:16-97` and
/// `PickerField.prompt.md`: a [DabblerFieldShell] carrying a real text input
/// and a trailing 45×45 brand-tinted icon button, with the field's focus state
/// held while the picker is open.
///
/// ## Internal by design
///
/// Like [DabblerFieldShell], this is a composition primitive and is not
/// exported from the package's public surface.
///
/// It was written in `date_field.dart` (KAN-246) because this path belonged to
/// KAN-250 and creating it would have been a collision. KAN-250 has now moved
/// it here unchanged, which is where its own dartdoc said it belonged and
/// which brings `date_field.dart` back under the 500-line house rule.
/// [DabblerDateField] and [DabblerTimeField] import it by path;
/// [DabblerPickerField] composes it and adds the presentation half.
///
/// ## Why this is not `DabblerTextField(variant: select)`
///
/// DS-600's `select` variant is the shared shell for pickers whose value can
/// *only* be picked, and `fields.card.html:100` is explicit that `Select`,
/// `DateField` and `TimeField` must not fork the input. This shell does not
/// fork it — it is the same [DabblerFieldShell], the same `--radius-xxl`, the
/// same four border states, the same `focused || open` rule — but it cannot be
/// the `select` variant itself, and the design source says why in three
/// places:
///
/// * `PickerField.prompt.md` → *"Do not add a second way to open the picker
///   (e.g. opening on focus) — **typing must stay possible**"*. `select`
///   renders a [Text], not an input; tapping it can only open the picker.
/// * `DateField.prompt.md` → *"Typed entry means the picker is never the only
///   path — a keyboard user can fill the field without opening it"*. That is
///   an accessibility requirement, not a convenience.
/// * The trailing affordance differs: `PickerField.jsx:60-73` is a 45×45
///   `--color-brand-primary` icon button carrying `aria-expanded`, whereas
///   `select`'s is an 18px `--color-text-secondary` `arrow-down` that rotates
///   (`TextField.jsx` / `fields.card.html:65`). `fields.card.html:122` names
///   the picker button's size and tint directly.
///
/// So: `Select` (DS-601) is `variant: select`; `DateField` and `TimeField` are
/// this. Both are the one [DabblerFieldShell].
class DabblerPickerFieldShell extends StatefulWidget {
  /// Creates the shell around a typed value and a picker button.
  const DabblerPickerFieldShell({
    super.key,
    required this.controller,
    required this.iconName,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.open = false,
    this.onOpenPressed,
    this.onCommit,
    this.focusNode,
    this.openPickerSemanticsLabel = defaultOpenSemanticsLabel,
    this.closePickerSemanticsLabel = defaultCloseSemanticsLabel,
  });

  /// The key the trailing 45×45 target carries, so a test can reach it
  /// without turning semantics on — the affordance [DabblerMenuItem.tileKey]
  /// offers in DS-700.
  static const Key pickerButtonKey = ValueKey<String>(
    'DabblerPickerFieldShell.button',
  );

  /// `aria-label="Open picker"` — `PickerField.jsx:64`.
  static const String defaultOpenSemanticsLabel = 'Open picker';

  /// `aria-label="Close picker"` — `PickerField.jsx:64`.
  static const String defaultCloseSemanticsLabel = 'Close picker';

  /// The shell's inner padding.
  ///
  /// `PickerField.jsx:43` overrides the shell's trailing inset to
  /// `--space-1` (3) so the 45×45 button ends 3 from the box edge; the other
  /// three sides stay at [DabblerFieldShell.defaultInnerPadding]'s `9px 12px`.
  static const EdgeInsetsDirectional innerPadding =
      EdgeInsetsDirectional.fromSTEB(
    DabblerSpacing.space4,
    DabblerSpacing.space3,
    DabblerSpacing.space1,
    DabblerSpacing.space3,
  );

  /// The text being edited. Owned by the composing field, which keeps it in
  /// sync with the typed value — the port of `text` + `onTextChange`.
  final TextEditingController controller;

  /// The trailing button's Iconsax glyph: `calendar` or `clock`
  /// (`DateField.jsx:120`, `TimeField.jsx:72`).
  final String iconName;

  /// The label above the box.
  final String? label;

  /// The empty-state text inside the box.
  final String? placeholder;

  /// The helper line below the box.
  final String? helperText;

  /// The error line below the box, and the trigger for the error border.
  final String? errorText;

  /// Whether the field accepts input and the button accepts taps.
  final bool enabled;

  /// Whether the picker this field fronts is currently open.
  ///
  /// Drives `focused={focused || open}` (`PickerField.jsx:41`) and the
  /// button's `aria-expanded`.
  final bool open;

  /// Called when the trailing button is tapped. The **overlay is the caller's**
  /// — see [DabblerDateField.onOpenPicker].
  final VoidCallback? onOpenPressed;

  /// `onTextCommit` — fired on blur and on Enter, with the current text.
  /// `PickerField.prompt.md` → *"fires on blur and Enter — parse there"*.
  final ValueChanged<String>? onCommit;

  /// An external focus node, if the caller owns focus.
  final FocusNode? focusNode;

  /// The trailing button's accessible name while the picker is closed.
  final String openPickerSemanticsLabel;

  /// The trailing button's accessible name while the picker is open.
  final String closePickerSemanticsLabel;

  @override
  State<DabblerPickerFieldShell> createState() =>
      _DabblerPickerFieldShellState();
}

class _DabblerPickerFieldShellState extends State<DabblerPickerFieldShell> {
  FocusNode? _ownedFocusNode;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(DabblerPickerFieldShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)
          ?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
      _focused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) {
      return;
    }
    final bool has = _focusNode.hasFocus;
    if (_focused == has) {
      return;
    }
    // `onBlur={() => { setFocused(false); onTextCommit(text); }}`
    // (`PickerField.jsx:50`) — losing focus commits, exactly as Enter does.
    if (!has) {
      widget.onCommit?.call(widget.controller.text);
    }
    setState(() => _focused = has);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool disabled = !widget.enabled;

    // `fontSize: 16, lineHeight: '21px'` (`PickerField.jsx:55`) — [DabblerType
    // .body]'s metrics, and with them [DabblerType.numeralFeatures], which is
    // the render half of the numerals rule (`fontVariantNumeric: lining-nums`
    // at `PickerField.jsx:56`).
    final TextStyle textStyle = DabblerType.body
        .resolveForDirection(direction)
        .copyWith(color: disabled ? colors.textTertiary : colors.textPrimary);

    return DabblerFieldShell(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      focused: _focused || widget.open,
      disabled: disabled,
      radius: DabblerRadius.xxl,
      innerPadding: DabblerPickerFieldShell.innerPadding,
      children: <Widget>[
        Expanded(
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: textStyle,
              cursorColor: colors.brandPrimary,
              maxLines: 1,
              // `inputMode="numeric"` (`PickerField.jsx:48`). **Documented
              // deviation:** a bare numeric pad cannot type `/`, `:` or `AM`,
              // so the source's own typed-entry contract is unreachable from
              // it on a touch keyboard. [TextInputType.datetime] is the
              // platform keyboard that offers digits *and* the separators
              // these two formats need, which is the intent the CSS hint was
              // reaching for.
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.done,
              // The value is a number and reads left to right in both
              // scripts. Under [TextDirection.rtl] the `/` and `:`
              // separators are bidi-neutral, so without this the run can be
              // reordered against the adjacent Arabic and `05/09/2026`
              // renders as `2026/09/05`. Pinning the editable to LTR keeps
              // the logical order the source requires — *"the date string
              // itself keeps `DD/MM/YYYY` order"* — while the chrome around
              // it still mirrors, because that is [DabblerFieldShell]'s and
              // it reads the ambient direction.
              textDirection: TextDirection.ltr,
              // …and the run is still parked at the inline start of a
              // mirrored box, so the field looks native in both scripts.
              textAlign: direction == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
              onSubmitted: widget.onCommit,
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
                hintTextDirection: TextDirection.ltr,
                hintMaxLines: 1,
              ),
            ),
          ),
        ),
        _PickerButton(
          key: DabblerPickerFieldShell.pickerButtonKey,
          iconName: widget.iconName,
          enabled: widget.enabled,
          open: widget.open,
          color: colors.brandPrimary,
          semanticsLabel: widget.open
              ? widget.closePickerSemanticsLabel
              : widget.openPickerSemanticsLabel,
          onPressed: widget.onOpenPressed,
        ),
      ],
    );
  }
}

/// The trailing picker button — 45×45, brand-tinted, `aria-expanded`.
///
/// `PickerField.jsx:60-73`: `width`/`height` are `--touch-target-min`, the
/// tint is `--color-brand-primary`, the glyph is 24, and the hit shape is
/// `--radius-pill`. `fields.card.html:122` restates the size and the tint.
///
/// ## Keyboard (KAN-276)
///
/// `PickerField.jsx:59` gives this button `className="dbl-focus"` — the
/// design system's shared focus-ring class — and on the web a `<button>`
/// element gets Enter/Space activation from the user agent for free. The
/// first port dropped both: a bare [GestureDetector] with `onTap` only, which
/// left a 45×45 control that could neither be reached nor operated from a
/// keyboard.
///
/// The fix is the package's standing pattern for a pressable that is not a
/// [DabblerButton] — the same composition [DabblerIconTile] uses:
/// [FocusableActionDetector] to take focus and to bind [ActivateIntent]
/// (Enter *and* Space, which Flutter does not supply the way a button role
/// does), and [DabblerFocusRing.visible] driven from
/// [FocusableActionDetector.onShowFocusHighlight], which is the
/// `:focus-visible` rule `.dbl-focus` is written against. The ring traces the
/// pill hit shape, so it matches what the source outlines.
///
/// Typed entry still means a keyboard user never *has* to open the picker
/// (`DateField.prompt.md`); this is what lets them.
class _PickerButton extends StatefulWidget {
  const _PickerButton({
    super.key,
    required this.iconName,
    required this.enabled,
    required this.open,
    required this.color,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final String iconName;
  final bool enabled;
  final bool open;
  final Color color;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  State<_PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<_PickerButton> {
  bool _focused = false;

  void _setFocused(bool value) {
    if (!mounted || _focused == value) {
      return;
    }
    setState(() => _focused = value);
  }

  void _activate() {
    if (!widget.enabled) {
      return;
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Widget target = SizedBox(
      width: DabblerSizing.touchTargetMin,
      height: DabblerSizing.touchTargetMin,
      child: Center(
        child: DabblerIcon(
          widget.iconName,
          size: DabblerSizing.iconMd,
          color: widget.enabled
              ? widget.color
              : DabblerColors.of(context).textTertiary,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: widget.open,
      label: widget.semanticsLabel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.enabled,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: _setFocused,
          actions: <Type, Action<Intent>>{
            // Enter and Space, which the source's `<button>` role gets from
            // the user agent and Flutter does not.
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                _activate();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onPressed : null,
            child: DabblerFocusRing.visible(
              visible: _focused,
              enabled: widget.enabled,
              borderRadius: DabblerRadius.pillAll,
              child: target,
            ),
          ),
        ),
      ),
    );
  }
}
