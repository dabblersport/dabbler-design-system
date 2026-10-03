import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

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

enum _RingStyle { ticks, arc }

/// Ring — a gauge drawn as a ring, with an optional centre.
///
/// Two forms, one widget, both painted with a [CustomPainter] and **no SVG and
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
///
/// ```dart
/// DabblerRing.ticks(fraction: 0.4, diameter: 54, child: Text('3'));
/// DabblerRing.arc(fraction: 0.72, child: Text('72%'));
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
/// ## Accessibility
///
/// The ring announces its value as a rounded percentage (`'65%'`), overridable
/// with `semanticValue` — a countdown will usually want `'3 days left'` — and
/// is named by `semanticLabel`. The painted ticks themselves are never
/// separate semantic nodes. The centre [child] keeps its own semantics.
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
       strokeWidth = tickWidth;

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
       tickLength = 0;

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
