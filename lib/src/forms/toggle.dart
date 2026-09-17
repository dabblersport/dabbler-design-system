import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../interaction/focus_ring.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// Toggle — the binary switch.
///
/// Transcribed from `components/forms/Toggle.jsx`, `Toggle.d.ts`,
/// `Toggle.prompt.md` and the specimen `components/forms/selection.card.html`
/// (the *Toggle* section and the closing token table).
///
/// ```dart
/// DabblerToggle(checked: notify, onChanged: (bool v) => setState(() => notify = v));
/// ```
///
/// ## What it is, and what it is not
///
/// The specimen states the distinction this widget exists to hold:
/// *"Toggle is a switch: the state change takes effect immediately, so it
/// belongs in settings-style rows. Checkbox is a form value the user is
/// collecting."* It therefore has **no label and no size prop** — the source
/// has neither — and the label belongs to the row around it.
///
/// ## Geometry
///
/// A 48×28 track at pill radius with a 24px knob at a 2px inset
/// (`Toggle.jsx:16-31`, and the specimen's token table: *"24px — the Checkbox
/// box, the Radio circle, the Toggle knob"*, *"48×28 — the Toggle track"*).
/// [trackWidth] is [DabblerSpacing.space11] and the knob is
/// [DabblerSizing.iconMd], so both sit on the base-3 grid by construction;
/// [trackHeight] (28) and [knobInset] (2) are the two numbers the source states
/// outright and no token in `tokens/spacing.css` carries, so they are declared
/// here with their origin rather than borrowed from an unrelated token that
/// happens to share a value.
///
/// ## Motion
///
/// *"The track colour transitions over 120ms and the knob slides — no
/// bounce."* Both use [DabblerMotion.base] and [DabblerMotion.easeOut]; this
/// file defines no duration or curve of its own. Under
/// [DabblerMotion.reduceMotion] the two changes snap, which is the system's
/// reduced-motion rule and not a second design.
///
/// ## Target, keyboard and semantics
///
/// The painted track is 28 tall, which is below the floor, so the switch is
/// wrapped in a [DabblerSizing.touchTargetMin] hit area — laid out, not
/// painted, so the visual geometry above is unchanged. It is a real focus
/// stop: Space and Enter flip it (the port of the source's `<button
/// role="switch">`, where both keys activate natively), the shared
/// [DabblerFocusRing] is drawn on keyboard focus only, and the node leaves the
/// tab order while [disabled], as the source's native `disabled` attribute
/// does. Semantically it is a switch — [Semantics.toggled], not `checked` —
/// so assistive technology announces "on"/"off" rather than "ticked".
class DabblerToggle extends StatefulWidget {
  /// Creates a controlled switch.
  const DabblerToggle({
    super.key,
    required this.checked,
    this.onChanged,
    this.disabled = false,
    this.semanticLabel,
  });

  /// Whether the switch is on. Controlled: this widget never holds the value.
  final bool checked;

  /// Called with the next value. Null, like [disabled], makes the switch
  /// inert — but only [disabled] dims it, which is the source's split between
  /// a read-only switch and a disabled one.
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is disabled: 45% opacity, no pointer or key handling,
  /// out of the tab order (`Toggle.jsx:20`, and the specimen's *"Disabled
  /// drops to 45% opacity"*).
  final bool disabled;

  /// The accessible name. The source has no label prop because the label lives
  /// in the surrounding row; pass that row's text here so the switch is not
  /// announced as an unnamed control.
  final String? semanticLabel;

  /// `width: 48` (`Toggle.jsx:17`) — [DabblerSpacing.space11].
  static const double trackWidth = DabblerSpacing.space11;

  /// `height: 28` (`Toggle.jsx:17`). Stated by the source and by the
  /// specimen's token table; no `--space-*` step is 28.
  static const double trackHeight = 28;

  /// `padding: 2` (`Toggle.jsx:17`) — the gap between knob and track edge.
  static const double knobInset = 2;

  /// `width: 24, height: 24` (`Toggle.jsx:28`) — [DabblerSizing.iconMd], the
  /// same 24 the Checkbox box and the Radio circle take.
  static const double knobSize = DabblerSizing.iconMd;

  /// `opacity: disabled ? 0.45 : 1` (`Toggle.jsx:21`).
  static const double disabledOpacity = 0.45;

  /// The track colour: `--color-brand-primary` when on, `--outline-card` when
  /// off (`Toggle.jsx:19`; `--outline-card` is [DabblerColors.borderDefault],
  /// `tokens/colors.css:36`).
  static Color trackColorFor(DabblerColors colors, {required bool checked}) =>
      checked ? colors.brandPrimary : colors.borderDefault;

  @override
  State<DabblerToggle> createState() => _DabblerToggleState();
}

class _DabblerToggleState extends State<DabblerToggle> {
  bool _ringVisible = false;

  bool get _enabled => !widget.disabled && widget.onChanged != null;

  void _toggle() {
    if (!_enabled) {
      return;
    }
    widget.onChanged!(!widget.checked);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool reduceMotion = DabblerMotion.reduceMotion(context);
    final Duration duration =
        reduceMotion ? Duration.zero : DabblerMotion.base;

    final Widget track = AnimatedContainer(
      duration: duration,
      curve: DabblerMotion.easeOut,
      width: DabblerToggle.trackWidth,
      height: DabblerToggle.trackHeight,
      padding: const EdgeInsets.all(DabblerToggle.knobInset),
      decoration: BoxDecoration(
        color: DabblerToggle.trackColorFor(colors, checked: widget.checked),
        borderRadius: DabblerRadius.pillAll,
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: DabblerMotion.easeOut,
        // `justifyContent: checked ? 'flex-end' : 'flex-start'`
        // (`Toggle.jsx:21`) — a *flex* alignment, so it is directional in the
        // source too. The specimen is explicit that the switch "needs no
        // mirroring": under RTL the knob sits on the physical left when on,
        // which is the same "towards the end of the row" reading.
        alignment: widget.checked
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: DabblerToggle.knobSize,
          height: DabblerToggle.knobSize,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: DabblerRadius.pillAll,
          ),
        ),
      ),
    );

    final Widget ringed = DabblerFocusRing.visible(
      visible: _ringVisible,
      enabled: _enabled,
      borderRadius: DabblerRadius.pillAll,
      child: track,
    );

    return Semantics(
      label: widget.semanticLabel,
      toggled: widget.checked,
      enabled: _enabled,
      onTap: _enabled ? _toggle : null,
      container: true,
      child: FocusableActionDetector(
        enabled: _enabled,
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
              _toggle();
              return null;
            },
          ),
        },
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _toggle : null,
          child: Opacity(
            opacity: widget.disabled ? DabblerToggle.disabledOpacity : 1,
            child: SizedBox(
              // The hit area, not the switch: 45 square around a 48×28 track,
              // so the target clears the floor without the painted geometry
              // moving. The specimen puts Checkbox and Radio "inside a
              // --touch-target-min row" for the same reason.
              height: DabblerSizing.touchTargetMin,
              child: Center(widthFactor: 1, child: ringed),
            ),
          ),
        ),
      ),
    );
  }
}
