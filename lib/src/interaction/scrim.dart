import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_motion.dart';

/// Scrim — the one wash behind every overlay.
///
/// The colour is [DabblerColors.scrim], which resolves `--color-scrim`:
/// ink at 45% in light, ink-950 at 65% in dark
/// (`tokens/colors.css:157` and `:203`). `guidelines/colors.html:147` states
/// the rule this primitive exists to enforce — *"overlays consume this, never
/// their own opacity"*. Sheet (`Sheet.prompt.md:34`), Dialog
/// (`Dialog.prompt.md:34`) and the mobile Menu all name the same token, so
/// there is one scrim, not three.
///
/// The scrim is **the elevation**. `Dialog.prompt.md:37` is explicit that
/// separation "comes from the scrim and the hairline, not elevation", which is
/// how a flat system with no shadows still reads as layered.
///
/// ## Fade
///
/// Appearing and disappearing is a plain opacity fade over
/// [DabblerMotion.base] (120ms) with [DabblerMotion.easeOut] — the source's
/// `dbl-fade` keyframe, `animation: dbl-fade var(--motion-base) var(--ease-out)`
/// (`components/foundations/overlay.jsx:32`), and the same motion
/// `Dialog.prompt.md:70` gives the panel. Under reduced motion the source sets
/// `.dbl-fade{animation:none}` (`overlay.jsx:43`), so the scrim here appears
/// and disappears instantly.
///
/// ## It assumes no overlay
///
/// This widget is a wash and, optionally, a dismiss target. It contains no
/// panel, no positioning, no focus trap, no scroll lock and no route. Those
/// belong to the overlay composing it — Sheet, Dialog and Menu each own their
/// own, and all three share this. Drop it into a [Stack] under the panel, or
/// give it a [child] to place content on top of the wash.
///
/// When [onDismiss] is null the scrim is inert: pointers pass through to
/// whatever is beneath it. When [onDismiss] is set the scrim absorbs them and
/// a press anywhere on it dismisses, which is the source's "scrim click
/// (pointerdown on the scrim itself) closes when `dismissible`"
/// (`Dialog.prompt.md:48`).
///
/// ## Accessibility
///
/// The wash itself is wrapped in [ExcludeSemantics] — it carries no meaning of
/// its own and would otherwise announce an empty region above the panel. When
/// [onDismiss] is set the dismiss gesture is given the [dismissLabel]
/// semantics instead, so the affordance is still reachable. Any [child] keeps
/// its own semantics untouched.
class DabblerScrim extends StatelessWidget {
  /// Creates a scrim, shown when [visible].
  const DabblerScrim({
    super.key,
    this.visible = true,
    this.onDismiss,
    this.dismissLabel,
    this.child,
  });

  /// Whether the wash is shown. Toggling it fades.
  final bool visible;

  /// Called when the scrim itself is pressed. Null makes the scrim inert and
  /// lets pointers through.
  final VoidCallback? onDismiss;

  /// The semantics label for the dismiss gesture. Supplied by the composing
  /// overlay, which knows what is being dismissed; this package ships no
  /// strings of its own.
  final String? dismissLabel;

  /// Optional content drawn on top of the wash — a panel, when the overlay
  /// prefers one widget to a [Stack].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = DabblerMotion.reduceMotion(context);

    Widget wash = ExcludeSemantics(
      child: ColoredBox(color: DabblerColors.of(context).scrim),
    );

    if (onDismiss != null) {
      wash = Semantics(
        label: dismissLabel,
        button: true,
        onTap: onDismiss,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: wash,
        ),
      );
    }

    final Widget faded = AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: reduceMotion ? Duration.zero : DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      // Two reasons to ignore pointers. A faded-out scrim must not keep
      // swallowing them on its way out, or the screen beneath stays dead
      // after the overlay has closed. And a scrim with no [onDismiss] is
      // documented as inert: the wash is painted, but it is not a barrier.
      child: IgnorePointer(
        ignoring: !visible || onDismiss == null,
        child: wash,
      ),
    );

    if (child == null) {
      return faded;
    }
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[Positioned.fill(child: faded), child!],
    );
  }
}
