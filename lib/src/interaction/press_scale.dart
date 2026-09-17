import 'package:flutter/widgets.dart';

/// The system's motion constants, transcribed from the design source
/// `tokens/spacing.css:58-62`.
///
/// They live here, beside the first primitive that needs them, because the
/// package has **no motion token file yet** — `lib/src/tokens/` carries colour,
/// geometry and type only. `DabblerScrim` imports them from here rather than
/// restating them. When a motion-token ticket lands they should move to
/// `lib/src/tokens/`, unchanged; the values below are the source's, not a
/// reinterpretation of them.
///
/// `guidelines/measurements.html:136-139` records what each duration is for:
/// * [fast] — press, tint change.
/// * [base] — indicator slides, expand/collapse, toast enter, overlay fade.
/// * [slow] — sheet and dialog enter.
abstract final class DabblerMotion {
  /// `--motion-fast: 80ms` — press and tint change.
  static const Duration fast = Duration(milliseconds: 80);

  /// `--motion-base: 120ms` — indicator slides, expand/collapse, overlay fade.
  static const Duration base = Duration(milliseconds: 120);

  /// `--motion-slow: 200ms` — sheet and dialog enter.
  static const Duration slow = Duration(milliseconds: 200);

  /// `--ease-out: cubic-bezier(.2, 0, .2, 1)` — the system's only easing curve.
  static const Cubic easeOut = Cubic(0.2, 0, 0.2, 1);

  /// `--press-scale: .98` — the system's **only** press transform
  /// (`guidelines/measurements.html:111`).
  static const double pressScale = 0.98;

  /// Whether the platform has asked for reduced motion.
  ///
  /// The design source drops every animation under
  /// `@media (prefers-reduced-motion: reduce)`
  /// (`components/foundations/overlay.jsx:34-45`). Reading it through
  /// [MediaQuery.maybeDisableAnimationsOf] — and defaulting to `false` when no
  /// [MediaQuery] is in scope — matches `lib/src/feedback/skeleton.dart:168`.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Press scale — the one press affordance in the system.
///
/// Transcribed from the design source's `.dbl-press` rule
/// (`tokens/spacing.css:79-80`):
///
/// ```css
/// .dbl-press { transition: transform var(--motion-fast) var(--ease-out); }
/// .dbl-press:active { transform: scale(var(--press-scale)); }
/// ```
///
/// so: scale to [DabblerMotion.pressScale] (0.98) over
/// [DabblerMotion.fast] (80ms) with [DabblerMotion.easeOut], and back on
/// release. `components/controls/Button.jsx:95-96` is the same rule applied
/// inline, which is the evidence that the value is shared rather than
/// Button's own.
///
/// ## It wraps an arbitrary child and assumes no control
///
/// This widget contains no gesture semantics, no tap callback, no ink, no
/// focus and no colour. It scales whatever it is given. That is deliberate:
/// a Button, a Chip, a Card, a Rating star and a StatTile all press, and all
/// of them already own their own gesture and semantics layer. Duplicating one
/// here would force every consumer to either fight it or bypass the primitive.
///
/// Two ways to drive it:
///
/// * **[DabblerPressScale.new]** — you own the pressed state. Pass [pressed]
///   from whatever already tracks it ([WidgetStatesController],
///   [InkWell.onHighlightChanged], a [GestureDetector] you already have).
///   This is the composable form and the one the controls in this package use.
/// * **[DabblerPressScale.gesture]** — the primitive tracks the pointer
///   itself, for a plain widget with nothing else in play. It uses a
///   [Listener], not a [GestureDetector], so it never competes in the gesture
///   arena with a tap recogniser the child already has: the child keeps its
///   own [onTap], this only paints the press.
///
/// ## Reduced motion
///
/// The scale still happens — it is the press *affordance*, and removing it
/// would leave the control with no feedback at all — but the transition is
/// instant. The source removes animation, not state
/// (`components/foundations/overlay.jsx:34-45`).
///
/// ## Disabled
///
/// With [enabled] set to `false` the child never scales, whatever [pressed]
/// says. A disabled control does not respond to press.
class DabblerPressScale extends StatefulWidget {
  /// Scales [child] whenever [pressed] is `true`.
  ///
  /// The caller owns the state. Nothing here listens to pointers.
  const DabblerPressScale({
    super.key,
    required this.child,
    required this.pressed,
    this.enabled = true,
    this.scale = DabblerMotion.pressScale,
    this.alignment = Alignment.center,
  })  : _selfDriven = false,
        assert(scale > 0 && scale <= 1, 'press scale shrinks; it never grows');

  /// Scales [child] while a pointer is down on it, tracking the pointer
  /// itself.
  ///
  /// Uses a [Listener], so the child's own tap handling is untouched.
  const DabblerPressScale.gesture({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = DabblerMotion.pressScale,
    this.alignment = Alignment.center,
  })  : _selfDriven = true,
        pressed = false,
        assert(scale > 0 && scale <= 1, 'press scale shrinks; it never grows');

  /// The widget being pressed. Any widget.
  final Widget child;

  /// Whether the child is currently pressed.
  ///
  /// Ignored by [DabblerPressScale.gesture], which tracks the pointer itself.
  final bool pressed;

  /// Whether the press affordance applies at all. `false` on a disabled or
  /// inert control.
  final bool enabled;

  /// The pressed scale. Defaults to the token
  /// ([DabblerMotion.pressScale], 0.98) and should be left alone — the design
  /// source calls this "the system's only press transform".
  final double scale;

  /// The origin the scale happens around. Centre by default.
  final Alignment alignment;

  final bool _selfDriven;

  @override
  State<DabblerPressScale> createState() => _DabblerPressScaleState();
}

class _DabblerPressScaleState extends State<DabblerPressScale> {
  bool _pointerDown = false;

  bool get _isPressed =>
      widget.enabled && (widget._selfDriven ? _pointerDown : widget.pressed);

  void _setPointerDown(bool value) {
    if (_pointerDown == value) {
      return;
    }
    setState(() => _pointerDown = value);
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion is read in build, not in initState, because it arrives
    // through the MediaQuery and can change while the widget is mounted.
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    final Widget scaled = AnimatedScale(
      scale: _isPressed ? widget.scale : 1,
      duration: reduceMotion ? Duration.zero : DabblerMotion.fast,
      curve: DabblerMotion.easeOut,
      alignment: widget.alignment,
      child: widget.child,
    );

    if (!widget._selfDriven) {
      return scaled;
    }

    return Listener(
      // Translucent, not deferToChild: a bare `SizedBox` or a transparent
      // child does not hit-test itself, and the press would never be seen.
      // Translucent also lets whatever is beneath keep receiving pointers, so
      // wrapping something in a press affordance never makes it a barrier.
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.enabled ? (_) => _setPointerDown(true) : null,
      onPointerUp: (_) => _setPointerDown(false),
      onPointerCancel: (_) => _setPointerDown(false),
      child: scaled,
    );
  }
}
