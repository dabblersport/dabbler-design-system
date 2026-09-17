import 'package:flutter/widgets.dart';

/// The system's motion tokens, transcribed from the design source
/// `tokens/spacing.css:55-74`.
///
/// Motion is a token, not a component's opinion: the source declares one
/// duration scale and exactly one easing curve, and nothing in the package may
/// invent another. `guidelines/measurements.html:136-139` records what each
/// duration is for:
///
/// * [fast] — press, tint change.
/// * [base] — indicator slides, expand/collapse, toast enter, overlay fade.
/// * [slow] — sheet and dialog enter.
///
/// ## Why this file exists
///
/// These constants were declared inside `lib/src/interaction/press_scale.dart`
/// when DS-200 landed, because `lib/src/tokens/` carried colour, geometry and
/// type only and that ticket would not invent a token file mid-flight. Its
/// dartdoc said they should move once a motion-token ticket landed. This is
/// that file, and the values below are unchanged — the move is a relocation,
/// not a reinterpretation.
///
/// The focus-ring width and offset that sit beside these in the same CSS block
/// (`--focus-ring-width: 2px`, `--focus-ring-offset: 2px`) are **not** here:
/// they are tagged `@kind spacing` in the source and belong to the geometry
/// layer, not to motion.
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
  ///
  /// One documented exception exists and is deliberate: `DabblerFab` presses to
  /// `0.96`, transcribed from `FAB.jsx` (`transform: scale(0.96)`). It owns
  /// that value itself and must not be normalised onto this one.
  static const double pressScale = 0.98;

  /// Whether the platform has asked for reduced motion.
  ///
  /// The design source drops every animation under
  /// `@media (prefers-reduced-motion: reduce)`
  /// (`components/foundations/overlay.jsx:34-45`). Reading it through
  /// [MediaQuery.maybeDisableAnimationsOf] — and defaulting to `false` when no
  /// [MediaQuery] is in scope — matches `lib/src/feedback/skeleton.dart`.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// The source keyframe `dbl-pulse` —
  /// `0%,100%{opacity:1} 50%{opacity:.55}` — eased in and out and sampled at
  /// [t] cycles (fractional; values outside `[0, 1)` wrap).
  ///
  /// [minOpacity] is the keyframe's 50% value. It is a parameter rather than a
  /// constant here because each component states its own floor as part of its
  /// public API ([DabblerSkeleton.pulseMinOpacity] and the equivalents on
  /// `DabblerProgressBar` and `DabblerSpinner`); the shared thing is the
  /// curve, which is the design source's, not any one component's.
  ///
  /// Skeleton, ProgressBar and Spinner resolved this same curve three times
  /// over — deliberately, so that two components in one layer would not depend
  /// on each other. Promoting it to the token layer is what resolves that
  /// properly: they now share the source's keyframe, not each other.
  ///
  /// Exposed so tests can check the curve's endpoints and midpoint rather than
  /// pumping frames and reading opacities back out of the tree.
  static double pulseOpacityAt(double t, {required double minOpacity}) {
    final double cycle = t % 1.0;
    // 0 → .5 travels down to the minimum, .5 → 1 returns.
    final double leg = cycle < 0.5 ? cycle * 2 : (1 - cycle) * 2;
    final double eased = Curves.easeInOut.transform(leg);
    return 1 + (minOpacity - 1) * eased;
  }
}
