import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        LogicalKeyboardKey,
        TextInputFormatter,
        TextInputType;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'field_shell.dart';

/// The two control sizes a [DabblerStepper] takes — `size` in
/// `components/forms/Stepper.d.ts:9`.
enum DabblerStepperSize {
  /// `sm` — 39px controls. *"for dense rows (a ticket line inside a card), not
  /// for primary forms"* (`Stepper.prompt.md`).
  sm,

  /// `md` — 45px controls. The default.
  md,
}

/// Stepper — small bounded integers the user nudges rather than types.
///
/// Transcribed from `components/forms/Stepper.jsx`, `Stepper.d.ts`,
/// `Stepper.prompt.md` and the *Stepper* half of
/// `components/forms/value-controls.card.html`.
///
/// ```dart
/// DabblerStepper(
///   label: 'players',
///   helperText: '4 to 22 players',
///   min: 4,
///   max: 22,
///   value: players,
///   onChanged: (int v) => setState(() => players = v),
/// )
/// ```
///
/// ## A direct [DabblerFieldShell] consumer
///
/// The shell is the whole of this widget's chrome: the label, the
/// [DabblerRadius.xxl] box, the four border states and the helper / error
/// line. `fields.card.html:169` lists the Stepper among the components sharing
/// that 24 radius, *"so it lines up with `TextField` and `Select` in the same
/// form"*, and this file paints none of it itself.
///
/// **One deliberate departure from the usual consumption pattern.** Fields
/// normally hand the shell their row's items as separate `children`, so the
/// `--icon-gap` (6) between them stays the shell's. The Stepper's source does
/// the opposite on purpose — `innerStyle={{ padding: 0, gap: 0 }}`
/// (`Stepper.jsx:73`) — because the two 45×45 buttons *are* the padding: they
/// must reach the box's edge, and a gap between them and the numeral would
/// break the symmetry of the row. Passing one child is how that is expressed
/// without forking the shell: with a single child the shell inserts no gap,
/// [DabblerFieldShell.innerPadding] is set to zero, and the 45px floor, the
/// border states and the message line remain entirely the shell's.
///
/// ## Behaviour
///
/// Typing is allowed and filtered to digits, then clamped to `[min, max]`; an
/// empty field resolves to [min]. Increment and decrement clamp too, so
/// [onChanged] never fires an out-of-range value — and never fires at all when
/// the clamped result equals the current one, which is the source's
/// `if (next !== value)`.
///
/// ## Keyboard
///
/// Both buttons are tab stops, activated with Space or Enter, each drawing the
/// shared [DabblerFocusRing]; a button at a bound is genuinely disabled and is
/// skipped by the tab order, as the source's real `disabled` attribute is.
/// **Arrow Up and Arrow Down step the value** while the numeral has focus,
/// which is the keyboard affordance a number control is expected to have;
/// Arrow Left and Arrow Right are left to the caret, because the numeral is a
/// real text field in the source and moving the caret is what they do there.
///
/// ## RTL
///
/// *"The buttons sit in flow, so minus/plus swap sides in RTL exactly like the
/// rest of the row. The numeric field is pinned to `direction: ltr` so the
/// number itself never reorders, and numerals stay Western Arabic."* Both are
/// implemented literally: the row is plain flow, and the numeral is wrapped in
/// its own [Directionality] at [TextDirection.ltr] — the Flutter equivalent of
/// the source's `direction: 'ltr'` — while [DabblerType.numeralFeatures],
/// which `resolveForDirection` applies, keeps the digits Western Arabic under
/// the Arabic face.
class DabblerStepper extends StatefulWidget {
  /// Creates a controlled stepper.
  const DabblerStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.size = DabblerStepperSize.md,
    this.label,
    this.helperText,
    this.errorText,
    this.disabled = false,
    this.decreaseSemanticLabel = defaultDecreaseLabel,
    this.increaseSemanticLabel = defaultIncreaseLabel,
  });

  /// The current value. Controlled; this widget holds no number of its own.
  final int value;

  /// Called with the next, already-clamped value.
  final ValueChanged<int>? onChanged;

  /// The lower bound. `min = 0` (`Stepper.jsx:22`).
  final int min;

  /// The upper bound. `max = 99` (`Stepper.jsx:23`).
  final int max;

  /// How much one press moves the value. `step = 1` (`Stepper.jsx:24`).
  final int step;

  /// The control size. Defaults to [DabblerStepperSize.md].
  final DabblerStepperSize size;

  /// The shell's label.
  final String? label;

  /// The shell's helper line. *"Pair with `helperText` when the bounds are not
  /// obvious"*.
  final String? helperText;

  /// The shell's error line; its presence puts the shell in the error state.
  final String? errorText;

  /// Whether the whole control is inert.
  final bool disabled;

  /// `aria-label="Decrease"` (`Stepper.jsx:84`), exposed so a host can
  /// localise it — this package ships no strings of its own.
  final String decreaseSemanticLabel;

  /// `aria-label="Increase"` (`Stepper.jsx:86`).
  final String increaseSemanticLabel;

  /// The source's `aria-label` for the decrement button.
  static const String defaultDecreaseLabel = 'Decrease';

  /// The source's `aria-label` for the increment button.
  static const String defaultIncreaseLabel = 'Increase';

  /// `const box = size === 'sm' ? 39 : 45` (`Stepper.jsx:35`). `md` is
  /// [DabblerSizing.touchTargetMin]; `sm` is 39, a base-3 value the sizing
  /// tokens do not name, stated by the source for dense rows only — and below
  /// the 44 floor, which is why [DabblerStepperSize.sm] is documented as
  /// unsuitable for a primary form.
  static double boxSizeFor(DabblerStepperSize size) => switch (size) {
        DabblerStepperSize.sm => 39,
        DabblerStepperSize.md => DabblerSizing.touchTargetMin,
      };

  /// The Iconsax glyph on the decrement button (`Stepper.jsx:84`).
  static const String decreaseIcon = 'minus';

  /// The Iconsax glyph on the increment button (`Stepper.jsx:86`).
  static const String increaseIcon = 'add';

  /// Clamps [value] into `[min, max]`, which is the source's
  /// `Math.min(max, Math.max(min, v))`.
  static int clamp(int value, {required int min, required int max}) =>
      value < min ? min : (value > max ? max : value);

  @override
  State<DabblerStepper> createState() => _DabblerStepperState();
}

class _DabblerStepperState extends State<DabblerStepper> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');
  late final FocusNode _fieldNode = FocusNode()..addListener(_handleFocus);
  bool _focused = false;

  @override
  void didUpdateWidget(DabblerStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The value is owned by the caller, so an externally-changed value must
    // reach the field — but rewriting the text while the user is mid-edit
    // would fight the caret, so it is only written when it actually differs
    // from what is shown.
    final String next = '${widget.value}';
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _fieldNode.removeListener(_handleFocus);
    _fieldNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focused != _fieldNode.hasFocus) {
      setState(() => _focused = _fieldNode.hasFocus);
    }
    if (!_fieldNode.hasFocus) {
      // `if (digits === '') { set(min); }` resolved on the way out, so the box
      // never rests empty.
      _commit(_controller.text);
      _controller.text = '${widget.value}';
    }
  }

  bool get _enabled => !widget.disabled && widget.onChanged != null;
  bool get _atMin => widget.value <= widget.min;
  bool get _atMax => widget.value >= widget.max;

  void _set(int raw) {
    if (!_enabled) {
      return;
    }
    final int next =
        DabblerStepper.clamp(raw, min: widget.min, max: widget.max);
    if (next != widget.value) {
      widget.onChanged!(next);
    }
  }

  /// The source's `onChange` on the input: strip non-digits, empty → [min],
  /// otherwise parse and clamp.
  void _commit(String text) {
    final String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    _set(digits.isEmpty ? widget.min : int.parse(digits));
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final double box = DabblerStepper.boxSizeFor(widget.size);

    return DabblerFieldShell(
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      focused: _focused,
      disabled: widget.disabled,
      // `innerStyle={{ padding: 0, gap: 0 }}` — see the class note.
      innerPadding: EdgeInsetsDirectional.zero,
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              _StepperButton(
                icon: DabblerStepper.decreaseIcon,
                semanticLabel: widget.decreaseSemanticLabel,
                size: box,
                enabled: _enabled && !_atMin,
                colors: colors,
                onPressed: () => _set(widget.value - widget.step),
              ),
              Expanded(child: _numeral(colors, direction, box)),
              _StepperButton(
                icon: DabblerStepper.increaseIcon,
                semanticLabel: widget.increaseSemanticLabel,
                size: box,
                enabled: _enabled && !_atMax,
                colors: colors,
                onPressed: () => _set(widget.value + widget.step),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The centred numeric field: `.t-callout` at weight 500
  /// (`Stepper.jsx:92-96` — `fontSize: 17, lineHeight: '22px', fontWeight:
  /// 500`, which is the `.t-callout` step), tertiary while disabled.
  Widget _numeral(
    DabblerColors colors,
    TextDirection direction,
    double box,
  ) {
    final TextStyle style = DabblerType.callout
        .resolveForDirection(direction)
        .copyWith(
          fontWeight: DabblerType.medium,
          color: widget.disabled ? colors.textTertiary : colors.textPrimary,
        );

    return SizedBox(
      height: box,
      child: Shortcuts(
        // Arrow Up / Arrow Down step the value; left and right stay with the
        // caret. See the class note.
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _StepIntent: CallbackAction<_StepIntent>(
              onInvoke: (_StepIntent intent) {
                _set(widget.value + widget.step * intent.direction);
                return null;
              },
            ),
          },
          child: Directionality(
            // `direction: 'ltr'` (`Stepper.jsx:96`) — the numeral itself never
            // reorders, whatever the surrounding script.
            textDirection: TextDirection.ltr,
            child: Material(
              // As in [DabblerTextField]: a transparent Material so text
              // editing works without putting a second surface under the
              // shell's box.
              type: MaterialType.transparency,
              child: TextField(
                controller: _controller,
                focusNode: _fieldNode,
                enabled: _enabled,
                style: style,
                textAlign: TextAlign.center,
                cursorColor: colors.brandPrimary,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: _commit,
                maxLines: 1,
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One step of [DabblerStepper.step], in [direction] (+1 or −1).
class _StepIntent extends Intent {
  const _StepIntent(this.direction);

  final int direction;
}

/// One of the stepper's two icon buttons: a square target at pill radius, the
/// glyph at [DabblerSizing.iconMd], dropping to
/// [DabblerColors.textTertiary] at a bound (`Stepper.jsx:38-56`).
class _StepperButton extends StatefulWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticLabel,
    required this.size,
    required this.enabled,
    required this.colors,
    required this.onPressed,
  });

  final String icon;
  final String semanticLabel;
  final double size;
  final bool enabled;
  final DabblerColors colors;
  final VoidCallback onPressed;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _ringVisible = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.enabled,
      onTap: widget.enabled ? widget.onPressed : null,
      container: true,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.enabled,
          onShowFocusHighlight: (bool visible) {
            if (_ringVisible != visible) {
              setState(() => _ringVisible = visible);
            }
          },
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onPressed();
                return null;
              },
            ),
          },
          mouseCursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onPressed : null,
            child: DabblerFocusRing.visible(
              visible: _ringVisible,
              enabled: widget.enabled,
              borderRadius: DabblerRadius.pillAll,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(
                  child: DabblerIcon(
                    widget.icon,
                    size: DabblerSizing.iconMd,
                    color: widget.enabled
                        ? widget.colors.textPrimary
                        : widget.colors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
