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

  /// `--action-area-hold: 260ms` — how long the Action Area's collapsed
  /// circle shows before it expands, and again before it returns to idle
  /// (`status-feedback.card.html` — *Action Area · Geometry and tokens*).
  ///
  /// One of the **two structural tokens** the Action Area adds (the other is
  /// `DabblerSizing.actionAreaSize`); the card is explicit that it adds no
  /// colours. It is a **hold**, i.e. timing rather than animation, so reduced
  /// motion does not zero it: the collapsed circle is still shown for this
  /// long, only the size transitions around it are dropped.
  static const Duration actionAreaHold = Duration(milliseconds: 260);

  // --- App roles (zero-literal pass) ---------------------------------------
  //
  // Everything below is an **app role**, not a design-source transcription:
  // `tokens/spacing.css` declares only [fast]/[base]/[slow] and [easeOut].
  // Each entry names what the consuming app uses a duration for, so the app
  // writes a name and never `Duration(...)`. Values are the app's own measured
  // timings (dabbler-code `lib/`, 2026-10-03), with near misses folded onto one
  // role per purpose; each fold is named in the entry's dartdoc.
  //
  // Visual roles honour reduced motion through [durationOf]; the non-visual
  // groups (toast lifetime, auto-advance, debounce, timeout, polling, delay)
  // are timing, not animation, and must NOT be zeroed.

  /// App role: an in-place content swap — `AnimatedSwitcher` /
  /// `AnimatedContainer` changing state, 300ms. The app's 350ms switcher
  /// folds here.
  static const Duration contentSwap = Duration(milliseconds: 300);

  /// App role: programmatic scroll, page or indicator travel — `animateTo`,
  /// `animateToPage`, a carousel indicator growing, 400ms.
  static const Duration scrollTo = Duration(milliseconds: 400);

  /// App role: a dragged surface springing back to rest — mapped onto [slow]
  /// (200ms). The app's 220ms carousel snap-back folds here.
  static const Duration snapBack = slow;

  /// App role: the default page-route transition (fade / shared axis), 300ms.
  /// The app's 320ms route folds here.
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// App role: a directional (slide) page-route transition, 350ms.
  static const Duration pageTransitionSlide = Duration(milliseconds: 350);

  /// App role: a modal / bottom-sheet page route rising, 400ms.
  static const Duration pageTransitionModal = Duration(milliseconds: 400);

  /// App role: a large hero or cover cross-fade (landing carousel), 500ms.
  /// The app's 550ms game-detail header folds here.
  static const Duration heroCrossfade = Duration(milliseconds: 500);

  /// App role: a whole screen's staggered entrance controller, 800ms.
  static const Duration screenEntrance = Duration(milliseconds: 800);

  /// App role: one cycle of a looping ambient animation, 1200ms.
  static const Duration ambientLoop = Duration(milliseconds: 1200);

  /// App role: a one-word acknowledgement toast lifetime ("Copied"), 1s.
  static const Duration toastBrief = Duration(seconds: 1);

  /// App role: the default toast / snackbar lifetime, 2s.
  static const Duration toastShort = Duration(seconds: 2);

  /// App role: a toast carrying a sentence or an action, 3s.
  static const Duration toastLong = Duration(seconds: 3);

  /// App role: an in-content gallery paging itself (venue photos), 3s.
  static const Duration autoAdvance = Duration(seconds: 3);

  /// App role: a full-screen hero paging itself (landing), 5s.
  static const Duration autoAdvanceHero = Duration(seconds: 5);

  /// App role (non-visual): search-as-you-type debounce, 350ms. The app's
  /// 300ms and 400ms search debounces fold here.
  static const Duration debounceSearch = Duration(milliseconds: 350);

  /// App role (non-visual): debounce before a remote validity check
  /// (username availability), 500ms.
  static const Duration debounceValidation = Duration(milliseconds: 500);

  /// App role (non-visual): debounce before fetching suggestions, 800ms.
  static const Duration debounceSuggestion = Duration(milliseconds: 800);

  /// App role (non-visual): a quick request the UI waits on (feed page,
  /// location fix), 5s. The app's 6s GPS timeout folds here.
  static const Duration timeoutShort = Duration(seconds: 5);

  /// App role (non-visual): a network request's ceiling, 10s. The app's 8s
  /// onboarding timeout folds here.
  static const Duration timeoutNetwork = Duration(seconds: 10);

  /// App role (non-visual): background polling interval, 30s.
  static const Duration pollInterval = Duration(seconds: 30);

  /// App role (non-visual): yield a frame / let a tick settle, 100ms. The
  /// app's 50ms and 150ms waits fold here.
  static const Duration delayFrame = Duration(milliseconds: 100);

  /// App role (non-visual): wait for a route or keyboard to settle before
  /// acting, 300ms. The app's 200ms and 250ms waits fold here.
  static const Duration delaySettle = Duration(milliseconds: 300);

  /// App role (non-visual): first retry back-off, 500ms.
  static const Duration delayRetry = Duration(milliseconds: 500);

  /// App role (non-visual): second retry back-off, 1s.
  static const Duration delayRetryLong = Duration(seconds: 1);

  /// App role (non-visual): last retry back-off, 2s.
  static const Duration delayRetryMax = Duration(seconds: 2);

  /// App role: emphasised deceleration, an element arriving — the app's
  /// `Curves.easeOutCubic`. Only [easeOut] is the design source's curve.
  static const Curve emphasizedDecelerate = Curves.easeOutCubic;

  /// App role: emphasised acceleration, an element leaving — the app's
  /// `Curves.easeInCubic`.
  static const Curve emphasizedAccelerate = Curves.easeInCubic;

  /// App role: symmetric travel between two resting states (a scroll) — the
  /// app's `Curves.easeInOut`.
  static const Curve standardInOut = Curves.easeInOut;

  /// [duration] for an **animation**, honouring reduced motion:
  /// [Duration.zero] when the platform asks for reduced motion, else
  /// [duration]. For visual roles only — never a toast lifetime, debounce,
  /// timeout, poll or delay.
  static Duration durationOf(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;

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
