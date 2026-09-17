import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction, TextInputType;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../overlays/menu.dart';
import '../overlays/sheet.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'date_field.dart';
import 'field_shell.dart';
import 'time_field.dart';

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
class _PickerButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      expanded: open,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: DabblerSizing.touchTargetMin,
          height: DabblerSizing.touchTargetMin,
          child: Center(
            child: DabblerIcon(
              iconName,
              size: DabblerSizing.iconMd,
              color: enabled ? color : DabblerColors.of(context).textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// PickerField — [DabblerPickerFieldShell] plus the responsive presentation
/// of the picker.
///
/// Transcribed from `components/forms/PickerField.jsx:1-119`,
/// `PickerField.d.ts`, `PickerField.prompt.md` and the specimen
/// `components/forms/fields.card.html:115-123`.
///
/// The shell above is the box and the typed input — the half `DateField` and
/// `TimeField` use, because each of those owns its own picker surface. This
/// widget is that shell **plus** the presentation branch the source writes at
/// `PickerField.jsx:97-118`: a [DabblerSheet] below
/// [DabblerMenu.sheetBreakpoint] and an anchored [DabblerMenu] above it, so a
/// call site that does not want to own an overlay does not have to. Both
/// halves are DS-700's, not a second popover and not a second sheet.
///
/// It is a composition primitive, not a screen control
/// (`PickerField.prompt.md` — *When not to use*). Why it is not
/// `TextField(variant: select)` is set out on the shell.
///
/// ```dart
/// DabblerPickerField(
///   label: 'Date',
///   text: typed,
///   onTextChanged: (String v) => setState(() => typed = v),
///   onTextCommitted: parse,
///   open: open,
///   onOpenChanged: (bool v) => setState(() => open = v),
///   child: const Placeholder(),          // the picker itself
/// )
/// ```
///
/// ## One way to open it
///
/// `PickerField.prompt.md` — *Composition rules*: *"Do not add a second way
/// to open the picker (e.g. opening on focus) — typing must stay possible."*
/// [DabblerMenu] toggles on any tap on its trigger, so the field it is given
/// is wrapped in an absorbing [GestureDetector]: the trailing button, being
/// deeper in the tree, still wins the gesture arena, and a tap on the input or
/// on blank shell area lands on the input instead of opening the picker.
class DabblerPickerField extends StatefulWidget {
  /// Creates a picker field.
  const DabblerPickerField({
    super.key,
    this.label,
    this.text = '',
    this.placeholder,
    this.onTextChanged,
    this.onTextCommitted,
    this.icon = defaultIcon,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.open = false,
    this.onOpenChanged,
    this.sheetTitle,
    this.detents = defaultDetents,
    this.openLabel = DabblerPickerFieldShell.defaultOpenSemanticsLabel,
    this.closeLabel = DabblerPickerFieldShell.defaultCloseSemanticsLabel,
    this.child,
  });

  /// `icon = 'calendar'` (`PickerField.jsx:25`).
  static const String defaultIcon = 'calendar';

  /// `detents = [0.62]` (`PickerField.jsx:31`) — taller than Menu's 0.45,
  /// because a calendar needs the room.
  static const List<double> defaultDetents = <double>[0.62];

  /// The key the trailing target carries; [DabblerPickerFieldShell]'s.
  static const Key trailingButtonKey =
      DabblerPickerFieldShell.pickerButtonKey;

  /// The label above the box.
  final String? label;

  /// The typed text shown in the field.
  final String text;

  /// The empty-state text.
  final String? placeholder;

  /// Called on every keystroke.
  final ValueChanged<String>? onTextChanged;

  /// Called on blur and on Enter — *"parse the typed text here"*
  /// (`PickerField.d.ts:10`).
  final ValueChanged<String>? onTextCommitted;

  /// Kebab-case Iconsax name for the trailing button.
  final String icon;

  /// The helper line; replaced by [errorText], which also draws the error
  /// border. Both are [DabblerFieldShell]'s.
  final String? helperText;

  /// The error line, and the trigger for the error border.
  final String? errorText;

  /// Whether the field accepts input and opens. `false` is `disabled`.
  final bool enabled;

  /// Whether the picker is showing. Controlled, as in the source.
  final bool open;

  /// Reports every open and close.
  final ValueChanged<bool>? onOpenChanged;

  /// The sheet's title below the breakpoint; falls back to [label].
  final String? sheetTitle;

  /// The sheet's detents.
  final List<double> detents;

  /// The trailing button's accessible name while closed.
  final String openLabel;

  /// The trailing button's accessible name while open.
  final String closeLabel;

  /// The picker itself — a `Calendar`, a `TimePicker`, anything.
  final Widget? child;

  @override
  State<DabblerPickerField> createState() => _DabblerPickerFieldState();
}

class _DabblerPickerFieldState extends State<DabblerPickerField> {
  final FocusNode _inputFocus = FocusNode(
    debugLabel: 'DabblerPickerField input',
  );
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final OverlayPortalController _sheetPortal = OverlayPortalController();

  /// The text last handed to [DabblerPickerField.onTextCommitted]; cleared by
  /// the next edit.
  ///
  /// The source commits on Enter *and* on blur (`PickerField.jsx:56,58`), and
  /// on the web those are two different moments. In Flutter, submitting the
  /// keyboard action also drops focus, so the shell would parse the same text
  /// twice. Committing the same string twice is the deviation, not the guard.
  String? _committed;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleEdit);
    // Shown after the first frame, never during one.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && !_sheetPortal.isShowing) {
        _sheetPortal.show();
      }
    });
  }

  @override
  void didUpdateWidget(DabblerPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The text is the owner's; the controller only mirrors it, so a commit
    // that reformats ("6pm" → "6:00 PM") shows without the field owning state.
    if (widget.text != _controller.text && !_inputFocus.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleEdit);
    _controller.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// The shell owns the input, so per-keystroke reporting is read off the
  /// controller rather than duplicating its `onChanged`.
  void _handleEdit() {
    if (_controller.text == _committed) {
      return;
    }
    _committed = null;
    widget.onTextChanged?.call(_controller.text);
  }

  void _commit(String text) {
    if (_committed == text) {
      return;
    }
    _committed = text;
    widget.onTextCommitted?.call(text);
  }

  void _toggle() {
    if (!widget.enabled) {
      return;
    }
    widget.onOpenChanged?.call(!widget.open);
  }

  void _close() => widget.onOpenChanged?.call(false);

  @override
  Widget build(BuildContext context) {
    final bool asSheet =
        MediaQuery.sizeOf(context).width < DabblerMenu.sheetBreakpoint;

    final Widget field = DabblerPickerFieldShell(
      controller: _controller,
      focusNode: _inputFocus,
      iconName: widget.icon,
      label: widget.label,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      open: widget.open,
      onOpenPressed: _toggle,
      onCommit: _commit,
      openPickerSemanticsLabel: widget.openLabel,
      closePickerSemanticsLabel: widget.closeLabel,
    );

    if (asSheet) {
      // The sheet paints its own full-viewport scrim and panel, so it cannot
      // be a sibling of the field in the layout — it would stretch the field
      // to the viewport. It goes in the [Overlay] instead, which is where the
      // source's fixed-position sheet effectively lives. The portal is shown
      // once and stays shown: [DabblerSheet] already renders itself away when
      // closed (`Visibility` + `IgnorePointer`), so nothing is ever toggled
      // during a build.
      return OverlayPortal(
        controller: _sheetPortal,
        overlayChildBuilder: (BuildContext _) => DabblerSheet(
          open: widget.open && widget.enabled,
          onClose: _close,
          title: widget.sheetTitle ?? widget.label,
          detents: widget.detents,
          child: widget.child,
        ),
        child: field,
      );
    }

    return DabblerMenu(
      // `fullWidth` (`PickerField.jsx:112`): the popover is the field's width.
      fullWidth: true,
      open: widget.open && widget.enabled,
      onOpenChanged: (bool v) => widget.onOpenChanged?.call(v),
      label: widget.label,
      // No rows: the picker is the whole content, which is what the menu's
      // header slot is — the same slot Select puts its search field in.
      items: const <DabblerMenuEntry>[],
      header: widget.child,
      trigger: GestureDetector(
        // The absorber described in the class doc: the menu must not open on
        // a tap anywhere on the field.
        behavior: HitTestBehavior.opaque,
        onTap: () => _inputFocus.requestFocus(),
        child: field,
      ),
    );
  }
}
