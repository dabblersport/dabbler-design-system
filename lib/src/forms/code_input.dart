import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart'
    show
        AutofillHints,
        KeyDownEvent,
        KeyRepeatEvent,
        LogicalKeyboardKey,
        TextInputType;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// CodeInput — one-time-code and PIN entry.
///
/// Transcribed from `components/forms/CodeInput.jsx:1-104`,
/// `CodeInput.d.ts:3-15`, `CodeInput.prompt.md` and the specimen
/// `components/forms/fields.card.html:141-162`.
///
/// ```dart
/// DabblerCodeInput(
///   value: code,
///   onChanged: (String v) => setState(() => code = v),
///   onCompleted: verify,
/// )
/// ```
///
/// ## It does NOT compose `DabblerFieldShell`, and that is the source
///
/// Every other field in the cut paints from the shell. This one does not:
/// `CodeInput.jsx:71-101` renders a bare flex group of `<input>` boxes with
/// their own fill, hairline and radius, and no label, helper or error line at
/// all. The specimen is explicit about why the error state stops at the
/// hairline — *"the boxes themselves only carry the error hairline — pair with
/// a `Banner tone="error"` or a message below"*
/// (`fields.card.html:162`). A shell here would add a 24-radius 45-min box
/// around a grid of 12-radius boxes and a message line the component does not
/// own, so the shell is deliberately absent rather than forgotten.
///
/// The geometry it *does* share is shared through tokens, not through the
/// shell: [DabblerRadius.lg], [DabblerSizing.touchTargetMin],
/// [DabblerSizing.borderDefault] and [DabblerFocusRing] are the same values
/// `DabblerFieldShell` reads.
///
/// ## The RTL exception, implemented deliberately
///
/// **The boxes stay in LTR order under [TextDirection.rtl].** The source sets
/// `direction: 'ltr'` on the group (`CodeInput.jsx:74`) and the specimen calls
/// it *"the documented exception"*: a verification code is a number, numbers
/// read left-to-right in both scripts, and mirroring the boxes would change
/// the value the user sees (`fields.card.html:162`,
/// `CodeInput.prompt.md:47-50`).
///
/// This is the one component in the package that pins a direction. It is not a
/// missing [EdgeInsetsDirectional]: the box row is wrapped in an explicit
/// `Directionality(textDirection: TextDirection.ltr)`, so digit 1 is on the
/// left in Arabic exactly as it is in English. Arrow-key traversal follows the
/// same pinned order, so ArrowLeft always means "the previous digit".
///
/// Everything *around* the boxes still mirrors — the component occupies a
/// start-aligned row in the ambient direction, and nothing inside it uses a
/// physical `left`/`right` inset.
///
/// ## Every box is a real input
///
/// `CodeInput.prompt.md:52-55` requires it: *"Every box is a real input, so
/// screen readers and password managers behave."* Each box is therefore a
/// Material [TextField] with its own [FocusNode] and [TextEditingController],
/// carrying [TextInputType.number] and [AutofillHints.oneTimeCode] so the
/// mobile keyboard comes up numeric and OS autofill works. The group is
/// labelled *"N-digit code"* and each box *"Digit n"*.
///
/// ## Keyboard behaviour, and where each half is handled
///
/// The source does all four in one `onKeyDown` with `preventDefault`. Flutter
/// splits them, because a soft keyboard delivers an edit and a hardware
/// keyboard delivers a key:
///
/// | behaviour | handled in | source |
/// |---|---|---|
/// | typing advances | `onChanged`, one digit | `CodeInput.jsx:46-48` |
/// | paste / autofill spreads across boxes | `onChanged`, many digits | `:40-44` |
/// | backspace clears a filled box | `onChanged`, empty text | `:55` |
/// | backspace on an empty box steps back | key handler | `:56` |
/// | arrow keys move between boxes | key handler | `:59-60` |
///
/// The key handler sits on a [Focus] above each box and returns
/// [KeyEventResult.handled] for the keys it claims, which is the port of the
/// source's `e.preventDefault()`.
///
/// ## Value model
///
/// The value is a **string**, as it is in the source, and the boxes are a view
/// of it. That is why a digit typed into box 3 of an empty code lands in box 1:
/// `emit` joins the array and the string has no holes (`CodeInput.jsx:26-27`).
/// Transcribed rather than corrected — a code is entered left to right.
///
/// [value] may be driven by the caller or left to the widget. Passing it makes
/// the component controlled; omitting it lets the widget keep its own string,
/// which is the same arrangement `DabblerTextField` offers.
///
/// ## Reduced motion
///
/// There is no animation in this component, in the source or here, so there is
/// nothing for reduced motion to switch off.
class DabblerCodeInput extends StatefulWidget {
  /// Creates a [length]-box code entry.
  const DabblerCodeInput({
    super.key,
    this.length = defaultLength,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.masked = false,
    this.error = false,
    this.enabled = true,
    this.autofocus = false,
  }) : assert(length > 0, 'a code has at least one digit');

  /// `length = 6` (`CodeInput.jsx:12`, `CodeInput.prompt.md:18`).
  static const int defaultLength = 6;

  /// Each box's width — `width: 45` (`CodeInput.jsx:90`).
  ///
  /// This *is* [DabblerSizing.touchTargetMin], which the specimen's token
  /// table states outright: `--touch-target-min` applies to *"each CodeInput
  /// box (45×54)"* (`fields.card.html:171`). No deviation.
  static const double boxWidth = DabblerSizing.touchTargetMin;

  /// Each box's height — `height: 54` (`CodeInput.jsx:90`).
  ///
  /// 54 is on the base-3 grid but is not a step of [DabblerSpacing], and there
  /// is no sizing token for a code box, so there is nothing to snap to. Stated
  /// here once, the way `card_house.dart` states its own 64.
  static const double boxHeight = 54;

  /// The gap between boxes — `gap: var(--space-2)` (`CodeInput.jsx:74`), which
  /// the prompt writes out as *"6px gap"*.
  static const double boxGap = DabblerSpacing.space2;

  /// Each box's corner radius — `borderRadius: var(--radius-lg)`
  /// (`CodeInput.jsx:97`). The specimen's token table gives `--radius-lg` as
  /// *"CodeInput boxes"* (`fields.card.html:170`).
  static const double boxRadius = DabblerRadius.lg;

  /// The character drawn in place of a digit while [masked].
  ///
  /// The source uses `type="password"`, which leaves the glyph to the browser
  /// (`CodeInput.jsx:79`); Flutter makes it explicit and defaults to the same
  /// bullet the platform uses. The prompt calls the masked rendering *"dots"*
  /// (`CodeInput.prompt.md:22`).
  static const String maskCharacter = '•';

  /// Number of boxes.
  final int length;

  /// The code. Null lets the widget own its own string; see the class doc.
  final String? value;

  /// Called with the whole code on every edit — the source's `onChange`.
  final ValueChanged<String>? onChanged;

  /// Called with the code once every box is filled — the source's
  /// `onComplete`. Fires in the same edit as the final [onChanged], after it.
  ///
  /// `CodeInput.prompt.md:65-66`: verification is triggered from here rather
  /// than from a separate submit button.
  final ValueChanged<String>? onCompleted;

  /// Renders [maskCharacter] instead of the digit — a PIN rather than a code.
  final bool masked;

  /// Swaps every hairline for `--color-status-error`.
  ///
  /// The boxes carry **only** the hairline: there is no message line here, and
  /// `fields.card.html:162` says to pair the component with a `DabblerBanner`
  /// in the error tone for *"that code didn't work"*.
  final bool error;

  /// Whether the boxes accept input. `false` is the source's `disabled`.
  final bool enabled;

  /// Focuses the first box on mount.
  final bool autofocus;

  /// The code as the component will accept it: digits only, capped at
  /// [length].
  ///
  /// `String(value).replace(/[^0-9]/g, '').slice(0, length)`
  /// (`CodeInput.jsx:23`). Public because a caller validating a pasted code
  /// needs the same rule the component applies.
  static String sanitize(String? raw, int length) {
    if (raw == null) {
      return '';
    }
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length <= length ? digits : digits.substring(0, length);
  }

  /// The accessible name of the group — `aria-label={`${length}-digit code`}`
  /// (`CodeInput.jsx:72`).
  static String groupLabel(int length) => '$length-digit code';

  /// The accessible name of box [index] — `aria-label={`Digit ${i + 1}`}`
  /// (`CodeInput.jsx:87`).
  static String boxLabel(int index) => 'Digit ${index + 1}';

  /// The hairline colour for the current state.
  ///
  /// `border: 1px solid ${error ? 'var(--color-status-error)' :
  /// 'var(--outline-card)'}` (`CodeInput.jsx:96`). `--outline-card` is the
  /// card surface's own hairline, so it is read off [DabblerSurface] rather
  /// than named again here.
  static Color? borderColorFor(DabblerColors colors, {required bool hasError}) =>
      hasError
          ? colors.status(DabblerStatusTone.error).base
          : DabblerSurface.borderOf(colors, DabblerSurfaceVariant.card);

  /// The box fill for the current state.
  ///
  /// `background: disabled ? 'var(--color-bg-secondary)' : 'var(--surface-card)'`
  /// (`CodeInput.jsx:95`).
  static Color fillFor(DabblerColors colors, {required bool disabled}) =>
      disabled
          ? colors.bgSecondary
          : DabblerSurface.fillOf(colors, DabblerSurfaceVariant.card);

  /// The digit's style — `.t-title-3` metrics with lining numerals.
  ///
  /// `fontFamily: var(--font-display), fontSize: 20, lineHeight: '25px',
  /// fontVariantNumeric: 'lining-nums'` (`CodeInput.jsx:92-93`) is
  /// [DabblerType.title3] exactly: 20/25, display role. The lining-numeral
  /// request is [DabblerType.numeralFeatures], which is also the package's
  /// Western-digits rule — a code is digits, and they must not render as
  /// Arabic-Indic forms under an Arabic face.
  static TextStyle digitStyle(TextDirection direction) =>
      DabblerType.title3
          .resolveForDirection(direction)
          .copyWith(fontFeatures: DabblerType.numeralFeatures);

  @override
  State<DabblerCodeInput> createState() => _DabblerCodeInputState();
}

class _DabblerCodeInputState extends State<DabblerCodeInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _nodes;
  late String _code;
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _buildBoxState();
  }

  /// Seeds [_code] and one controller and focus node per box. Called on mount
  /// and again whenever [DabblerCodeInput.length] changes, which is a
  /// different number of boxes rather than a different value in them.
  void _buildBoxState() {
    _code = DabblerCodeInput.sanitize(widget.value, widget.length);
    _focusedIndex = -1;
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (int i) => TextEditingController(text: _digitAt(i)),
    );
    _nodes = List<FocusNode>.generate(widget.length, (int i) {
      final FocusNode node = FocusNode(debugLabel: 'CodeInput digit ${i + 1}');
      node.addListener(() => _handleFocusChange(i, node));
      return node;
    });
  }

  @override
  void didUpdateWidget(DabblerCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.length != oldWidget.length) {
      _disposeBoxState();
      _buildBoxState();
      return;
    }
    if (widget.value != null && widget.value != oldWidget.value) {
      _code = DabblerCodeInput.sanitize(widget.value, widget.length);
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _disposeBoxState();
    super.dispose();
  }

  void _disposeBoxState() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode n in _nodes) {
      n.dispose();
    }
  }

  String _digitAt(int index) =>
      index < _code.length ? _code[index] : '';

  /// The current code as the source's dense array: [widget.length] entries,
  /// each a digit or the empty string.
  List<String> get _digits =>
      List<String>.generate(widget.length, _digitAt);

  void _handleFocusChange(int index, FocusNode node) {
    if (!mounted) {
      return;
    }
    final int next = node.hasFocus ? index : (_focusedIndex == index ? -1 : _focusedIndex);
    if (next != _focusedIndex) {
      setState(() => _focusedIndex = next);
    }
  }

  /// Puts every controller back in step with [_code] without disturbing a
  /// controller that already agrees — reassigning `text` moves the caret.
  void _syncControllers() {
    for (int i = 0; i < widget.length; i++) {
      final String want = _digitAt(i);
      if (_controllers[i].text != want) {
        _controllers[i].value = TextEditingValue(
          text: want,
          selection: TextSelection.collapsed(offset: want.length),
        );
      }
    }
  }

  /// `emit` (`CodeInput.jsx:25-29`) — join, cap, notify, and fire
  /// [DabblerCodeInput.onCompleted] on a full code.
  void _emit(List<String> next) {
    final String joined = next.join();
    final String str = joined.length <= widget.length
        ? joined
        : joined.substring(0, widget.length);
    setState(() => _code = str);
    _syncControllers();
    widget.onChanged?.call(str);
    if (str.length == widget.length) {
      widget.onCompleted?.call(str);
    }
  }

  /// `focusBox` (`CodeInput.jsx:31-34`) — clamped to the box range.
  void _focusBox(int index) {
    final int i = index < 0
        ? 0
        : (index > widget.length - 1 ? widget.length - 1 : index);
    _nodes[i].requestFocus();
  }

  /// `onBoxChange` (`CodeInput.jsx:36-49`), plus the clear that the source
  /// gets from its own `onKeyDown` instead.
  void _handleChanged(int index, String raw) {
    final String typed = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final List<String> next = _digits;

    if (typed.isEmpty) {
      // The source returns early here, because backspace never reaches
      // `onChange` in the browser — it is cancelled in `onKeyDown`. In Flutter
      // a deletion on a filled box arrives as an empty edit from both the soft
      // and the hardware keyboard, so this is where `CodeInput.jsx:55` lands:
      // clear this box and drop any digit after it, since the value is a
      // string and cannot carry a hole.
      if (next[index].isEmpty) {
        _syncControllers();
        return;
      }
      next[index] = '';
      _emit(<String>[
        for (int k = 0; k < next.length; k++)
          if (k < index || next[k].isNotEmpty) next[k],
      ]);
      return;
    }

    if (typed.length > 1) {
      // Paste or multi-character autofill: spread across the boxes from here,
      // then land after the last digit written.
      for (int k = 0; k < typed.length; k++) {
        if (index + k < widget.length) {
          next[index + k] = typed[k];
        }
      }
      _emit(next);
      _focusBox(index + typed.length);
      return;
    }

    next[index] = typed;
    _emit(next);
    _focusBox(index + 1);
  }

  /// `onKeyDown` (`CodeInput.jsx:51-61`), less the branch that `onChanged`
  /// already covers. Returning [KeyEventResult.handled] is the port of
  /// `e.preventDefault()`.
  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.backspace) {
      // A filled box is deleted by the editable itself and arrives as an empty
      // edit; only the already-empty case is this handler's, and it steps back
      // and clears the previous box.
      if (_digitAt(index).isNotEmpty) {
        return KeyEventResult.ignored;
      }
      if (index > 0) {
        final List<String> next = _digits;
        next[index - 1] = '';
        _emit(next.sublist(0, index - 1));
        _focusBox(index - 1);
      }
      return KeyEventResult.handled;
    }

    // The boxes are pinned LTR (see the class doc), so ArrowLeft is always the
    // previous digit and ArrowRight always the next one, in both scripts.
    if (key == LogicalKeyboardKey.arrowLeft) {
      _focusBox(index - 1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _focusBox(index + 1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool disabled = !widget.enabled;

    // The one place in the package that pins a direction, and the reason is in
    // the class doc: a code is a number, and numbers do not mirror.
    return Semantics(
      container: true,
      label: DabblerCodeInput.groupLabel(widget.length),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < widget.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: DabblerCodeInput.boxGap),
              _buildBox(colors, i, disabled),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBox(DabblerColors colors, int index, bool disabled) {
    final TextStyle style = DabblerCodeInput.digitStyle(TextDirection.ltr)
        .copyWith(
          color: disabled ? colors.textTertiary : colors.textPrimary,
        );

    return DabblerFocusRing.visible(
      visible: _focusedIndex == index,
      enabled: !disabled,
      borderRadius: DabblerRadius.lgAll,
      child: Semantics(
        label: DabblerCodeInput.boxLabel(index),
        child: DabblerSurface(
          width: DabblerCodeInput.boxWidth,
          height: DabblerCodeInput.boxHeight,
          radius: DabblerCodeInput.boxRadius,
          fill: DabblerCodeInput.fillFor(colors, disabled: disabled),
          borderColor: DabblerCodeInput.borderColorFor(
            colors,
            hasError: widget.error,
          ),
          borderWidth: DabblerSizing.borderDefault,
          center: true,
          // The same reasoning as `lib/src/forms/text_field.dart`: Material's
          // text-editing behaviour wants a [Material] ancestor for its
          // selection toolbar, and `transparency` supplies one that paints
          // nothing — no fill, no shape, no elevation — so the box above stays
          // the only surface.
          child: Material(
            type: MaterialType.transparency,
            child: Focus(
              onKeyEvent: (FocusNode _, KeyEvent event) =>
                  widget.enabled ? _handleKey(index, event) : KeyEventResult.ignored,
              child: TextField(
                controller: _controllers[index],
                focusNode: _nodes[index],
                enabled: widget.enabled,
                autofocus: widget.autofocus && index == 0,
                style: style,
                textAlign: TextAlign.center,
                cursorColor: colors.brandPrimary,
                obscureText: widget.masked,
                obscuringCharacter: DabblerCodeInput.maskCharacter,
                // `maxLength={length}`, **not** 1 (`CodeInput.jsx:82`): a box
                // has to be able to receive the whole pasted code before it is
                // spread across its neighbours.
                maxLength: widget.length,
                maxLines: 1,
                keyboardType: TextInputType.number,
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                onChanged: (String v) => _handleChanged(index, v),
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
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
