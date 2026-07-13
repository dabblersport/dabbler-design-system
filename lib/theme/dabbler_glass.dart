// =============================================================================
// Dabbler — Liquid Glass primitive (BUTTONS-ONLY scope)
// Source of truth: .claude/skills/dabbler-liquid-glass/SKILL.md
// -----------------------------------------------------------------------------
// THE LAYERING LAW: glass is reserved for the floating navigation/control layer.
// Content (cards, lists, tiles, form fields) stays OPAQUE. If it scrolls, it's
// opaque; if it floats, it's glass.
//
// THE RECIPE — always all three ingredients:
//   1 · backdrop blur
//   2 · SATURATION BOOST (ImageFilter.compose + ColorFilter.matrix) — skipping
//       this is the #1 reason hand-rolled glass looks like frosted plastic
//   3 · tinted overlay + a top-lit gradient hairline (the refraction lip)
//
// This file deliberately contains only what buttons need. Nav-chrome surfaces
// (app bar, tab bar, search field) will extend it later.
// =============================================================================

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'dabbler_colors.dart';
import 'dabbler_spacing.dart';

/// App-level glass switch (a manual Reduce Transparency override). The platform
/// signal (`MediaQuery.highContrast`) is honoured independently by [DabblerGlass].
abstract final class DabblerGlassConfig {
  DabblerGlassConfig._();
  static bool enabled = true;
}

/// Luminance-preserving saturation matrix (public so tests can verify the boost
/// keeps luminance: every row sums to 1).
List<double> saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final sr = (1 - s) * lr, sg = (1 - s) * lg, sb = (1 - s) * lb;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// A lighter tint of the active brand (the gradient stroke's mid-stop and the
/// active overlay). Derived, never hardcoded, so Sport/Bright re-tint correctly.
Color dabblerBrandLight(DabblerColors d) =>
    Color.lerp(d.brandPrimary, Colors.white, 0.5)!;

/// The two-part shadow stacks from the skill: a brand-coloured cast + a white
/// lip. All colours derive from the ACTIVE theme's brandPrimary.
abstract final class DabblerGlassShadows {
  DabblerGlassShadows._();

  static List<BoxShadow> _pair(
    DabblerColors d, {
    required double castAlpha,
    required double castBlur,
    required double castY,
    required double lipAlpha,
    required double lipBlur,
    required double lipY,
  }) =>
      [
        BoxShadow(
          color: d.brandPrimary.withValues(alpha: castAlpha),
          blurRadius: castBlur,
          offset: Offset(0, castY),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: lipAlpha),
          blurRadius: lipBlur,
          offset: Offset(0, lipY),
        ),
      ];

  /// Small floating controls (glass buttons, chips).
  static List<BoxShadow> raised(DabblerColors d) => _pair(d,
      castAlpha: 0.14, castBlur: 18, castY: 6,
      lipAlpha: 0.85, lipBlur: 2, lipY: 1);

  /// Large floating chrome (nav bar, sheets) — reserved for the later phase.
  static List<BoxShadow> float(DabblerColors d) => _pair(d,
      castAlpha: 0.15, castBlur: 32, castY: 14,
      lipAlpha: 0.90, lipBlur: 3, lipY: 1);

  /// Recessed controls (search field) — reserved for the later phase.
  static List<BoxShadow> inset(DabblerColors d) => _pair(d,
      castAlpha: 0.20, castBlur: 12, castY: 4,
      lipAlpha: 0.90, lipBlur: 2, lipY: -1);

  /// Selected / engaged control.
  static List<BoxShadow> active(DabblerColors d) => _pair(d,
      castAlpha: 0.40, castBlur: 20, castY: 8,
      lipAlpha: 0.80, lipBlur: 2, lipY: 1);

  /// Pressed feedback: pull the cast in tighter and deepen it slightly.
  static List<BoxShadow> deepen(List<BoxShadow> shadows) => [
        for (final s in shadows)
          s.copyWith(
            color: s.color.withValues(
                alpha: (s.color.a * (s.offset.dy > 0 ? 1.3 : 1.0)).clamp(0, 1)),
            blurRadius: s.blurRadius * 0.75,
            offset: Offset(s.offset.dx, s.offset.dy * 0.6),
          ),
      ];
}

/// The canonical Liquid Glass surface (from the skill), plus the minimum extras
/// buttons need: an optional [tint]/[overlay]/[strokeColor] for the ACTIVE
/// treatment, and an optional outer [shadows] stack (painted outside the clip).
class DabblerGlass extends StatelessWidget {
  const DabblerGlass({
    super.key,
    required this.child,
    this.blur = 28,
    this.borderRadius,
    this.tintOpacity, // null → derive from brightness (0.45 light / 0.12 dark)
    this.tint, // colour override (active: brandPrimary @ 85%)
    this.overlay, // top-lit sheen over the tint (active treatment)
    this.strokeColor, // solid stroke override (active: white @ 70%)
    this.shadows,
  });

  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final double? tintOpacity;
  final Color? tint;
  final Gradient? overlay;
  final Color? strokeColor;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(DabblerRadius.lg);

    // Reduce Transparency → opaque fallback. Non-negotiable.
    if (MediaQuery.maybeOf(context)?.highContrast == true ||
        !DabblerGlassConfig.enabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tint != null
              ? Color.alphaBlend(tint!, d.surfaceCard)
              : d.surfaceCard,
          borderRadius: radius,
          border: Border.all(
              color: d.borderDefault,
              // ignore: avoid_redundant_argument_values  (token-driven, not a literal)
              width: DabblerSizing.borderDefault),
        ),
        child: child,
      );
    }

    final fill =
        tint ?? Colors.white.withValues(alpha: tintOpacity ?? (dark ? 0.12 : 0.45));

    Widget overlayed = DecoratedBox(
      // 3 · tinted overlay
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      // 3 · refraction highlight stroke (top-lit lip)
      child: CustomPaint(
        painter: _GlassBorderPainter(
          radius: radius,
          brand: d.brandPrimary,
          brandLight: dabblerBrandLight(d),
          dark: dark,
          solidColor: strokeColor,
        ),
        child: child,
      ),
    );
    if (overlay != null) {
      overlayed = DecoratedBox(
        decoration: BoxDecoration(gradient: overlay, borderRadius: radius),
        child: overlayed,
      );
    }

    Widget glass = RepaintBoundary(
      // isolate the expensive layer
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            // 2 · saturation boost — the ingredient everyone forgets
            outer: ColorFilter.matrix(saturationMatrix(dark ? 1.4 : 1.8)),
            // 1 · the blur
            inner: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          ),
          child: overlayed,
        ),
      ),
    );

    if (shadows != null) {
      // Shadows live OUTSIDE the clip so the cast isn't cut off.
      glass = DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: glass,
      );
    }
    return glass;
  }
}

/// 1px top-lit gradient hairline:
///   0% white · 40% brand-light @33% · 70% brand @25% · 100% white @90%.
/// White stops drop to ~40% in dark so the lip doesn't glow. [solidColor]
/// overrides the gradient (the active control's white @70% stroke).
class _GlassBorderPainter extends CustomPainter {
  _GlassBorderPainter({
    required this.radius,
    required this.brand,
    required this.brandLight,
    required this.dark,
    this.solidColor,
  });

  final BorderRadius radius;
  final Color brand;
  final Color brandLight;
  final bool dark;
  final Color? solidColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius
        .toRRect(rect)
        .deflate(DabblerSizing.borderDefault / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DabblerSizing.borderDefault;

    if (solidColor != null) {
      paint.color = solidColor!;
    } else {
      double w(double a) => dark ? a * 0.4 : a;
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.4, 0.7, 1.0],
        colors: [
          Colors.white.withValues(alpha: w(1.0)),
          brandLight.withValues(alpha: 0.33),
          brand.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: w(0.9)),
        ],
      ).createShader(rect);
    }
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassBorderPainter old) =>
      old.brand != brand ||
      old.dark != dark ||
      old.radius != radius ||
      old.solidColor != solidColor;
}
