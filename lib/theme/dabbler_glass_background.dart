// =============================================================================
// Dabbler — Glass background
// -----------------------------------------------------------------------------
// Glass needs a rich backdrop to read as glass — over a flat background it
// looks broken (skill: ACCESSIBILITY). This paints a light tint of the ACTIVE
// theme's primary plus four radial brand/accent orbs. Sport renders green orbs,
// Bright orange — nothing hardcodes the violet.
// =============================================================================

import 'package:flutter/material.dart';

import 'dabbler_colors.dart';
import 'dabbler_glass.dart';

class DabblerGlassBackground extends StatelessWidget {
  const DabblerGlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final light = dabblerBrandLight(d);

    final base = dark
        ? Color.lerp(d.brandPrimary, Colors.black, 0.86)!
        : Color.lerp(d.brandPrimary, Colors.white, 0.92)!;

    // Orbs run at ×0.4 opacity in dark: light-brand themes (Simple, whose dark
    // brandPrimary is near-white) otherwise wash the backdrop out and drop
    // secondary text on glass below WCAG AA — see glass_buttons_test.dart.
    double a(double v) => dark ? v * 0.4 : v;

    Widget orb({
      required Alignment center,
      required Color color,
      required double alpha,
      required double radius,
      required double stop,
    }) {
      return Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: center,
                radius: radius,
                stops: [0.0, stop],
                colors: [
                  color.withValues(alpha: a(alpha)),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(child: ColoredBox(color: base)),
        orb(
          center: const Alignment(0.7, -0.9),
          color: light, alpha: 0.33, radius: 0.9, stop: 0.8,
        ),
        orb(
          center: const Alignment(-0.8, -0.3),
          color: d.brandPrimary, alpha: 0.19, radius: 0.8, stop: 0.75,
        ),
        orb(
          center: const Alignment(0.8, 0.5),
          color: d.accent, alpha: 0.18, radius: 0.8, stop: 0.7,
        ),
        orb(
          center: const Alignment(-0.4, 1.0),
          color: light, alpha: 0.20, radius: 1.0, stop: 0.7,
        ),
        child,
      ],
    );
  }
}
