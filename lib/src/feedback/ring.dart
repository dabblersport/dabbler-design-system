import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import 'spinner.dart';

/// Which neutral role paints the part of a [DabblerRing] that is not filled.
///
/// The design uses both, in different screens, so the choice is a parameter and
/// not a guess: the Wallet (`Payment v2`) `ring(fraction,total,big,small)`
/// helper paints unfilled ticks `var(--outline-card)`, while the Listings
/// `gauge()` helper and the Sport Profile completion ring paint theirs
/// `var(--faint)`.
enum DabblerRingTrack {
  /// `--faint` — [DabblerColors.bgTertiary]. The default of [DabblerRing.arc].
  faint,

  /// `--outline-card` — [DabblerColors.borderDefault]. The default of
  /// [DabblerRing.ticks].
  outline,
}

enum _RingStyle { ticks, arc, progress }

/// The indicator colour of a [DabblerRing.progress] ring — `ProgressRing`'s
/// `tone`: `brand`, `inherit` (`currentColor`), `on-brand`, or any status
/// tone, which paints that status's **base**.
enum DabblerRingTone {
  /// [DabblerColors.brandPrimary]. The default.
  brand,

  /// `currentColor` — the enclosing [IconTheme], then [DefaultTextStyle], as
  /// [DabblerSpinnerTone.inherit] resolves it.
  inherit,

  /// [DabblerColors.onBrand], for a ring on a brand fill.
  onBrand,

  /// [DabblerStatusColor.base] of `success`.
  success,

  /// [DabblerStatusColor.base] of `warning`.
  warning,

  /// [DabblerStatusColor.base] of `error`.
  error,

  /// [DabblerStatusColor.base] of `info`.
  info,
}

/// Ring — a gauge drawn as a ring, with an optional centre.
///
/// Three forms, one widget, both painted with a [CustomPainter] and **no SVG and
/// no image** (the design system forbids inline SVG; the source screens draw
/// the same thing with CSS-rotated divs and an inline `<svg>`):
///
/// * [DabblerRing.ticks] — the **countdown tick ring**. `count` radial ticks
///   (24 or 32 in the design), the first `round(fraction * count)` of them
///   [DabblerColors.brandPrimary], the rest the [track] role. Wallet and
///   Listings countdown rings, with a big number and a small unit in the
///   centre.
/// * [DabblerRing.arc] — the **completion ring**. A full track circle in the
///   [track] role and a round-capped [DabblerColors.brandPrimary] arc of
///   `fraction` of the circle on top (Sport Profile's `r=20 stroke=5` SVG
///   circle with a `stroke-dasharray` of the circumference).
/// * [DabblerRing.progress] — the design source's **`ProgressRing`**
///   (`components/feedback/ProgressRing.jsx`, *"the one new primitive"* of
///   `status-feedback.card.html`): the [DabblerSpinner]'s geometry — a
///   [DabblerSpinner.strokeWidth] (2px) ring whose track is the indicator
///   colour at [DabblerSpinner.trackOpacity] (25%) — carrying a **value**.
///   With no value it *is* the spinner: a [DabblerSpinner.arcFraction] arc
///   turning every [DabblerSpinner.rotationPeriod], pulsing under reduced
///   motion. It is a form of this widget rather than a sibling class because
///   it is a ring gauge with a centre slot and a 0–1 value, which is exactly
///   what this widget already is; only the paint differs.
///
/// ```dart
/// DabblerRing.ticks(fraction: 0.4, diameter: 54, child: Text('3'));
/// DabblerRing.arc(fraction: 0.72, child: Text('72%'));
/// DabblerRing.progress(value: 0.35);              // determinate
/// DabblerRing.progress(semanticLabel: 'Syncing'); // indeterminate, spins
/// ```
///
/// ## Values
///
/// [fraction] is `0–1`, clamped (`NaN` paints as 0), never a percentage — the
/// same contract as `DabblerProgressBar`. Both forms start at **twelve
/// o'clock and run clockwise**.
///
/// ## Geometry → tokens
///
/// | Design | Here |
/// |---|---|
/// | tick `2px` wide | [tickWidth] `2` — a named constant, **off the grid** (see below) |
/// | tick `6–9px` long | `tickLength` — default `DabblerSpacing.space2` (6); the Wallet large ring's 9 is `space3` |
/// | tick `7px` long (Listings) | `space2` (6) — nearest token, 1px short |
/// | tick circle radius `22–34` | derived: `diameter / 2` is the outer end of the ticks |
/// | arc `r=20`, stroke `5` | [arcDefaultDiameter] `space11` (48) and [arcDefaultStrokeWidth] `space2` (6) — 5 sits between `space1` 3 and `space2` 6, nearer 6 |
///
/// The 2px tick width has no token (`borderDefault` is 1, `space1` is 3). It
/// is kept as the design's own number rather than rounded to 3, because at
/// 24 ticks on a 52px ring a 3px tick closes the gap between ticks to 2px and
/// the ring stops reading as ticks.
///
/// ## RTL
///
/// **The ring does not mirror by default.** The design drives both forms with
/// `transform: rotate(…deg)` and `stroke-dasharray`, neither of which flips
/// under `dir="rtl"`; and a ring is a clock face, which reads clockwise in
/// every locale. Set `mirrorInRtl` to opt a specific use into
/// counter-clockwise fill under [TextDirection.rtl] — the contract is tested
/// both ways. The centre [child] lays out in the ambient direction as normal.
///
/// The progress form **never** mirrors and has no `mirrorInRtl`: the card is
/// explicit that *"the arc runs clockwise in both directions — progress
/// direction is not mirrored"*.
///
/// ## Accessibility
///
/// The ring announces its value as a rounded percentage (`'65%'`), overridable
/// with `semanticValue` — a countdown will usually want `'3 days left'` — and
/// is named by `semanticLabel`. The painted ticks themselves are never
/// separate semantic nodes. The centre [child] keeps its own semantics.
///
/// The progress form follows `ProgressRing`'s own contract instead:
/// `role="progressbar"` with the value exposed when determinate
/// ([SemanticsRole.progressBar], `0`–`100`, the rounded percentage), and
/// `role="status"` when not — announced as the spinner announces itself, a
/// polite live region named by `semanticLabel` (default
/// [DabblerSpinner.defaultLabel]).
class DabblerRing extends StatelessWidget {
  /// The countdown tick ring: [count] radial ticks whose outer ends lie on a
  /// circle of [diameter].
  const DabblerRing.ticks({
    super.key,
    required this.fraction,
    required this.diameter,
    this.count = 24,
    this.tickLength = DabblerSpacing.space2,
    this.track = DabblerRingTrack.outline,
    this.mirrorInRtl = false,
    this.semanticLabel,
    this.semanticValue,
    this.child,
  }) : assert(count > 0, 'a tick ring needs at least one tick'),
       assert(diameter > 0, 'diameter must be positive'),
       _style = _RingStyle.ticks,
       strokeWidth = tickWidth,
       indeterminate = false,
       tone = DabblerRingTone.brand;

  /// The completion ring: a track circle and a round-capped brand arc.
  ///
  /// [diameter] is the outer diameter including the stroke, and defaults to
  /// [arcDefaultDiameter].
  const DabblerRing.arc({
    super.key,
    required this.fraction,
    this.diameter = arcDefaultDiameter,
    this.strokeWidth = arcDefaultStrokeWidth,
    this.track = DabblerRingTrack.faint,
    this.mirrorInRtl = false,
    this.semanticLabel,
    this.semanticValue,
    this.child,
  }) : assert(diameter > 0, 'diameter must be positive'),
       assert(strokeWidth > 0, 'strokeWidth must be positive'),
       _style = _RingStyle.arc,
       count = 0,
       tickLength = 0,
       indeterminate = false,
       tone = DabblerRingTone.brand;

  /// The progress ring — `ProgressRing` (`status-feedback.card.html`).
  ///
  /// [value] is a fraction 0–1, or null for an indeterminate ring that spins.
  /// [diameter] is explicit, like the spinner's size, never fluid: the card
  /// draws it at [DabblerSizing.iconMd] (24), [DabblerSizing.iconXl] (36) and
  /// — on the Action Area — [DabblerSizing.actionAreaRing] (32). [tone] is
  /// `ProgressRing`'s: `brand`, `inherit` (`currentColor`), `onBrand` for a
  /// ring on a brand fill, or a status tone's `base`.
  const DabblerRing.progress({
    super.key,
    double? value,
    this.diameter = DabblerSizing.iconMd,
    this.tone = DabblerRingTone.brand,
    this.semanticLabel,
    this.child,
  }) : assert(diameter > 0, 'diameter must be positive'),
       _style = _RingStyle.progress,
       fraction = value ?? 0,
       indeterminate = value == null,
       strokeWidth = DabblerSpinner.strokeWidth,
       count = 0,
       tickLength = 0,
       track = DabblerRingTrack.faint,
       mirrorInRtl = false,
       semanticValue = null;

  /// Progress as a fraction from 0 to 1, clamped.
  final double fraction;

  /// The outer diameter of the ring.
  final double diameter;

  /// How many ticks the circle carries. Ticks form only.
  final int count;

  /// How long each tick is. Ticks form only.
  final double tickLength;

  /// The stroke of the arc (configurable), or of a tick ([tickWidth]).
  final double strokeWidth;

  /// Which neutral role paints the unfilled part.
  final DabblerRingTrack track;

  /// Whether the fill runs counter-clockwise under [TextDirection.rtl].
  /// Defaults to false — see *RTL* on the class.
  final bool mirrorInRtl;

  /// The ring's accessible name.
  final String? semanticLabel;

  /// Overrides the announced value (default: the rounded percentage).
  final String? semanticValue;

  /// Centred inside the ring — typically a big number over a small unit.
  final Widget? child;

  /// Whether a [DabblerRing.progress] ring has no value and spins. Always
  /// false for the other two forms.
  final bool indeterminate;

  /// The indicator colour of a [DabblerRing.progress] ring. Ignored by the
  /// other two forms, which are always [DabblerColors.brandPrimary].
  final DabblerRingTone tone;

  final _RingStyle _style;

  /// The design's tick width — `width: 2px`. Not a token; see the class doc.
  static const double tickWidth = 2;

  /// Default outer diameter of the arc form — [DabblerSpacing.space11], the
  /// nearest token to the design's `r=20` + stroke (45).
  static const double arcDefaultDiameter = DabblerSpacing.space11;

  /// Default stroke of the arc form — [DabblerSpacing.space2].
  static const double arcDefaultStrokeWidth = DabblerSpacing.space2;

  /// The fraction clamped into `0–1`; `NaN` is 0.
  static double clampFraction(double value) =>
      value.isNaN ? 0 : value.clamp(0.0, 1.0);

  /// The number of filled ticks for [fraction] of [count] — the design's
  /// `Math.round(frac * total)`.
  static int filledTicks(double fraction, int count) =>
      (clampFraction(fraction) * count).round();

  @override
  Widget build(BuildContext context) {
    if (_style == _RingStyle.progress) {
      return _ProgressRing(
        fraction: clampFraction(fraction),
        indeterminate: indeterminate,
        diameter: diameter,
        tone: tone,
        semanticLabel: semanticLabel,
        child: child,
      );
    }
    final DabblerColors colors = DabblerColors.of(context);
    final double f = clampFraction(fraction);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double sign = (mirrorInRtl && rtl) ? -1 : 1;

    final Widget paint = CustomPaint(
      painter: _RingPainter(
        isTicks: _style == _RingStyle.ticks,
        fraction: f,
        count: count,
        tickLength: tickLength,
        strokeWidth: strokeWidth,
        fill: colors.brandPrimary,
        trackColor: track == DabblerRingTrack.faint
            ? colors.bgTertiary
            : colors.borderDefault,
        direction: sign,
      ),
    );

    final Widget ring = SizedBox.square(
      dimension: diameter,
      child: child == null
          ? paint
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                paint,
                Center(child: child),
              ],
            ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      value: semanticValue ?? '${(f * 100).round()}%',
      child: ring,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.isTicks,
    required this.fraction,
    required this.count,
    required this.tickLength,
    required this.strokeWidth,
    required this.fill,
    required this.trackColor,
    required this.direction,
  });

  final bool isTicks;
  final double fraction;
  final int count;
  final double tickLength;
  final double strokeWidth;
  final Color fill;
  final Color trackColor;

  /// `1` clockwise, `-1` counter-clockwise.
  final double direction;

  static const double _top = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    if (isTicks) {
      _paintTicks(canvas, center, size.shortestSide / 2);
    } else {
      _paintArc(canvas, center, (size.shortestSide - strokeWidth) / 2);
    }
  }

  void _paintTicks(Canvas canvas, Offset center, double outer) {
    final double inset = strokeWidth / 2;
    final double r1 = outer - inset;
    final double r0 = outer - tickLength + inset;
    if (r1 <= 0 || r0 <= 0 || r1 <= r0) return;
    final int filled = DabblerRing.filledTicks(fraction, count);
    final Paint on = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fill;
    final Paint off = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    for (int i = 0; i < count; i++) {
      final double a = _top + direction * (i / count) * 2 * math.pi;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * r0,
        center + dir * r1,
        i < filled ? on : off,
      );
    }
  }

  void _paintArc(Canvas canvas, Offset center, double radius) {
    if (radius <= 0) return;
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);
    // Round caps would draw a dot at 0; the design's dasharray draws nothing.
    if (fraction <= 0) return;
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _top,
      direction * fraction * 2 * math.pi,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.isTicks != isTicks ||
      old.fraction != fraction ||
      old.count != count ||
      old.tickLength != tickLength ||
      old.strokeWidth != strokeWidth ||
      old.fill != fill ||
      old.trackColor != trackColor ||
      old.direction != direction;
}

/// The progress form's state: the rotation (or reduced-motion pulse) of an
/// indeterminate ring, and the value transition of a determinate one.
class _ProgressRing extends StatefulWidget {
  const _ProgressRing({
    required this.fraction,
    required this.indeterminate,
    required this.diameter,
    required this.tone,
    required this.semanticLabel,
    required this.child,
  });

  final double fraction;
  final bool indeterminate;
  final double diameter;
  final DabblerRingTone tone;
  final String? semanticLabel;
  final Widget? child;

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this);

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  /// Runs the spinner's rotation, its reduced-motion pulse, or nothing — the
  /// same periods [DabblerSpinner] runs, read from its constants.
  void _sync({required bool reduceMotion}) {
    if (!widget.indeterminate) {
      if (_spin.isAnimating) _spin.stop();
      return;
    }
    final Duration period = reduceMotion
        ? DabblerSpinner.pulsePeriod
        : DabblerSpinner.rotationPeriod;
    if (_spin.duration != period) {
      _spin.duration = period;
      if (_spin.isAnimating) _spin.repeat();
    }
    if (!_spin.isAnimating) _spin.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = DabblerMotion.reduceMotion(context);
    _sync(reduceMotion: reduceMotion);
    final DabblerColors colors = DabblerColors.of(context);
    final Color indicator = switch (widget.tone) {
      DabblerRingTone.brand => colors.brandPrimary,
      DabblerRingTone.onBrand => colors.onBrand,
      DabblerRingTone.success => colors.success.base,
      DabblerRingTone.warning => colors.warning.base,
      DabblerRingTone.error => colors.error.base,
      DabblerRingTone.info => colors.info.base,
      DabblerRingTone.inherit =>
        IconTheme.of(context).color ??
            DefaultTextStyle.of(context).style.color ??
            colors.textPrimary,
    };

    Widget paint(double fraction) => CustomPaint(
      painter: _ProgressRingPainter(
        color: indicator,
        fraction: widget.indeterminate ? DabblerSpinner.arcFraction : fraction,
      ),
    );

    Widget ring;
    if (widget.indeterminate) {
      ring = AnimatedBuilder(
        animation: _spin,
        builder: (BuildContext context, Widget? child) => reduceMotion
            // The spinner's substitution: hold still and breathe.
            ? Opacity(
                opacity: DabblerMotion.pulseOpacityAt(
                  _spin.value,
                  minOpacity: DabblerSpinner.pulseMinOpacity,
                ),
                child: child,
              )
            : Transform.rotate(angle: _spin.value * 2 * math.pi, child: child),
        child: paint(0),
      );
    } else {
      // A determinate value moves over `--motion-base`, as the progress bar's
      // width does; under reduced motion it snaps.
      ring = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: widget.fraction),
        duration: DabblerMotion.durationOf(context, DabblerMotion.base),
        curve: DabblerMotion.easeOut,
        builder: (BuildContext context, double f, Widget? _) => paint(f),
      );
    }

    final Widget sized = SizedBox.square(
      dimension: widget.diameter,
      child: widget.child == null
          ? ring
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ring,
                Center(child: widget.child),
              ],
            ),
    );

    if (widget.indeterminate) {
      // `role="status"` — announced the way DabblerSpinner announces itself.
      return Semantics(
        container: true,
        liveRegion: true,
        label: widget.semanticLabel ?? DabblerSpinner.defaultLabel,
        child: ExcludeSemantics(child: sized),
      );
    }
    return Semantics(
      container: true,
      role: SemanticsRole.progressBar,
      label: widget.semanticLabel,
      minValue: '0',
      maxValue: '100',
      value: '${(widget.fraction * 100).round()}%',
      child: ExcludeSemantics(child: sized),
    );
  }
}

/// Paints the progress ring: a full track at [DabblerSpinner.trackOpacity] of
/// [color], and a round-capped arc of [fraction] from twelve o'clock,
/// clockwise — inset by half the stroke so it stays inside its box, the
/// spinner's own `r = (px - stroke) / 2`. Never mirrored.
class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.color, required this.fraction});

  final Color color;
  final double fraction;

  static const double _top = -math.pi / 2;

  /// The sweep, in radians, the arc covers for [fraction] — always positive,
  /// i.e. clockwise, whatever the ambient direction. Exposed for the test.
  static double sweepFor(double fraction) => fraction * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = DabblerSpinner.strokeWidth;
    final double radius = (size.shortestSide - stroke) / 2;
    if (radius <= 0) return;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    canvas.drawCircle(
      rect.center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: color.a * DabblerSpinner.trackOpacity),
    );
    // A round cap would draw a dot at 0.
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      _top,
      sweepFor(fraction),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.color != color || old.fraction != fraction;
}
