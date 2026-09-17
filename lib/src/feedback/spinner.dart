import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';

/// The three sizes [DabblerSpinner] comes in, transcribed from the design
/// source `components/feedback/Spinner.d.ts` (*"Sizes: sm 18px · md 24px ·
/// lg 30px"*) and `Spinner.jsx`'s `SIZES` map.
///
/// Size is explicit and never fluid — `Spinner.prompt.md`, *"Responsive
/// behaviour"*. Each value coincides exactly with the matching icon size in
/// [DabblerSizing], which is why the diameters are read from there rather than
/// restated: a spinner standing in for an icon must occupy the icon's box.
enum DabblerSpinnerSize {
  /// 18px — rows, chips, and `Button`'s `loading` state (DS-400).
  sm,

  /// 24px — the default. Buttons and cards.
  md,

  /// 30px — a section-level load.
  lg;

  /// The diameter in logical pixels.
  ///
  /// `SIZES = { sm: 18, md: 24, lg: 30 }` in `Spinner.jsx`, which is
  /// [DabblerSizing.iconSm], [DabblerSizing.iconMd] and [DabblerSizing.iconLg].
  double get diameter => switch (this) {
        DabblerSpinnerSize.sm => DabblerSizing.iconSm,
        DabblerSpinnerSize.md => DabblerSizing.iconMd,
        DabblerSpinnerSize.lg => DabblerSizing.iconLg,
      };
}

/// Where [DabblerSpinner] takes its indicator colour from.
///
/// Transcribed from `Spinner.jsx`'s `TONE_COLORS`.
enum DabblerSpinnerTone {
  /// `var(--color-brand-primary)` — [DabblerColors.brandPrimary]. The default,
  /// so the spinner re-tints with the active section theme at no cost to the
  /// caller.
  brand,

  /// `currentColor`. Takes the colour of the enclosing
  /// [DefaultTextStyle]/[IconTheme], which is how it sits inside a tinted
  /// button or row without being told what colour that button is.
  inherit,

  /// `var(--color-on-brand)` — [DabblerColors.onBrand]. For a solid brand fill.
  onBrand,
}

/// Spinner — the system's only indeterminate loading indicator.
///
/// Transcribed from the design source `components/feedback/Spinner.jsx`,
/// `Spinner.d.ts` and `Spinner.prompt.md`. Every loader in the product resolves
/// to this widget: buttons, panels, `LoadMore`, pull-to-refresh.
///
/// ## The ring
///
/// A **2px stroke ring** ([strokeWidth]) drawn inside the size's box: a full
/// track circle at [trackOpacity] of the indicator colour, and a solid
/// indicator arc spanning [arcFraction] of the circumference with a round cap.
/// The whole ring rotates once every [rotationPeriod], **linearly** — no
/// easing, because an indeterminate loader that accelerates implies progress it
/// does not have.
///
/// No shadow, no gradient, no tinted circle behind it. `Spinner.prompt.md`,
/// *"Composition rules"*: the ring is the whole component.
///
/// ## Reduced motion
///
/// Read the same way `DabblerSkeleton` reads it —
/// [MediaQueryData.disableAnimations]. The **behaviour differs**, and
/// deliberately: the source replaces `.dbl-spin` with `dbl-pulse` under
/// `prefers-reduced-motion: reduce` rather than switching it off
/// (`foundations/overlay.jsx:34-41`), and `Spinner.prompt.md` is explicit —
/// *"the rotation becomes an opacity pulse (1 → 0.55, 1.2s) — never a static
/// frame"*. A skeleton that stops still reads as "content not here yet"; a
/// spinner that stops still reads as "hung". So this widget keeps animating
/// when animations are disabled, and a caller who wants nothing moving at all
/// passes `animate: false`.
///
/// ## Accessibility
///
/// Wrapped in [Semantics] as a live region with [label] (default `"Loading"`),
/// matching the source's `role="status"` + `aria-live="polite"`. Pass [label]
/// whenever the spinner is the only content of its container — *"Joining
/// game"* tells the user more than *"Loading"* does.
///
/// ## RTL
///
/// Direction-neutral. Rotation direction carries no meaning and is **not**
/// mirrored (`Spinner.prompt.md`, *"RTL behaviour"*), so nothing here consults
/// [Directionality].
///
/// ```dart
/// const DabblerSpinner();
/// const DabblerSpinner(size: DabblerSpinnerSize.sm, tone: DabblerSpinnerTone.inherit);
/// const DabblerSpinner(size: DabblerSpinnerSize.lg, label: 'Loading games');
/// ```
class DabblerSpinner extends StatefulWidget {
  /// Creates an indeterminate loading indicator.
  const DabblerSpinner({
    super.key,
    this.size = DabblerSpinnerSize.md,
    this.tone = DabblerSpinnerTone.brand,
    this.label,
    this.animate = true,
  });

  /// The diameter. Default [DabblerSpinnerSize.md] (24px), per `Spinner.jsx`'s
  /// `size = 'md'`.
  final DabblerSpinnerSize size;

  /// Where the indicator colour comes from. Default [DabblerSpinnerTone.brand],
  /// per `Spinner.jsx`'s `tone = 'brand'`.
  final DabblerSpinnerTone tone;

  /// The accessible label announced by the live region. Defaults to
  /// [defaultLabel].
  final String? label;

  /// Whether to animate at all.
  ///
  /// `false` renders a still ring and is **not** what reduced motion does — see
  /// the class doc. There is no `animate` prop in the source; it exists here
  /// because a Flutter widget test and a golden both need a frame that does not
  /// move, and because `Button` may need to park the indicator while it is
  /// off-screen.
  final bool animate;

  /// `aria-label={label || 'Loading'}` in `Spinner.jsx`.
  static const String defaultLabel = 'Loading';

  /// The ring's stroke — `const stroke = 2` in `Spinner.jsx`.
  ///
  /// Expressed as twice [DabblerSizing.borderDefault] rather than a bare `2`:
  /// this is the one width in the system that is deliberately double a hairline
  /// border, so that the ring reads as a control and not as an outline.
  static const double strokeWidth = DabblerSizing.borderDefault * 2;

  /// The track's opacity against the indicator colour — `opacity="0.25"` on the
  /// first `<circle>` in `Spinner.jsx`.
  static const double trackOpacity = 0.25;

  /// The share of the circumference the indicator arc covers —
  /// `strokeDasharray={2πr * 0.28 …}` in `Spinner.jsx`, and *"brand indicator
  /// arc at 28% of the circumference"* in `Spinner.prompt.md`.
  static const double arcFraction = 0.28;

  /// One full turn — `.dbl-spin{animation:dbl-spin 800ms linear infinite}`
  /// (`foundations/overlay.jsx:30`).
  static const Duration rotationPeriod = Duration(milliseconds: 800);

  /// The reduced-motion pulse period —
  /// `.dbl-pulse{animation:dbl-pulse 1.2s ease-in-out infinite}`
  /// (`foundations/overlay.jsx:31`), which `.dbl-spin` adopts under
  /// `prefers-reduced-motion: reduce`.
  static const Duration pulsePeriod = Duration(milliseconds: 1200);

  /// The floor of that pulse — `@keyframes dbl-pulse{…50%{opacity:.55}}`.
  static const double pulseMinOpacity = 0.55;

  @override
  State<DabblerSpinner> createState() => _DabblerSpinnerState();
}

class _DabblerSpinnerState extends State<DabblerSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sets the controller to the period the current mode calls for and runs it,
  /// or parks it. Called from [build] because reduced motion arrives through
  /// the [MediaQuery] and can change under us.
  void _sync({required bool running, required Duration period}) {
    if (_controller.duration != period) {
      _controller.duration = period;
      if (_controller.isAnimating) _controller.repeat();
    }
    if (running) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  /// The indicator colour for [DabblerSpinner.tone].
  Color _indicator(BuildContext context) => switch (widget.tone) {
        DabblerSpinnerTone.brand => DabblerColors.of(context).brandPrimary,
        DabblerSpinnerTone.onBrand => DabblerColors.of(context).onBrand,
        // `currentColor`. IconTheme first — a spinner standing in for an icon
        // should match that icon — then the ambient text colour.
        DabblerSpinnerTone.inherit => IconTheme.of(context).color ??
            DefaultTextStyle.of(context).style.color ??
            DabblerColors.of(context).textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _sync(
      running: widget.animate,
      period: reduceMotion
          ? DabblerSpinner.pulsePeriod
          : DabblerSpinner.rotationPeriod,
    );

    final double diameter = widget.size.diameter;
    final Color indicator = _indicator(context);

    Widget ring = SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _RingPainter(
          color: indicator,
          strokeWidth: DabblerSpinner.strokeWidth,
          trackOpacity: DabblerSpinner.trackOpacity,
          arcFraction: DabblerSpinner.arcFraction,
        ),
      ),
    );

    if (widget.animate) {
      ring = AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => reduceMotion
            // The source's substitution: the ring holds still and breathes.
            ? Opacity(
                opacity: DabblerMotion.pulseOpacityAt(
                  _controller.value,
                  minOpacity: DabblerSpinner.pulseMinOpacity,
                ),
                child: child,
              )
            : Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: child,
              ),
        child: ring,
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.label ?? DabblerSpinner.defaultLabel,
      child: ExcludeSemantics(child: ring),
    );
  }
}


/// Paints the track circle and the indicator arc, both inset by half the stroke
/// so the ring sits entirely inside the size's box — the source's
/// `r = (px - stroke) / 2`.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.trackOpacity,
    required this.arcFraction,
  });

  final Color color;
  final double strokeWidth;
  final double trackOpacity;
  final double arcFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: color.a * trackOpacity);
    canvas.drawCircle(rect.center, radius, track);

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    // Twelve o'clock, clockwise — `strokeDasharray` starts at the SVG's 3
    // o'clock, but the ring turns continuously, so only the sweep is visible.
    canvas.drawArc(rect, -math.pi / 2, arcFraction * 2 * math.pi, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.trackOpacity != trackOpacity ||
      old.arcFraction != arcFraction;
}
