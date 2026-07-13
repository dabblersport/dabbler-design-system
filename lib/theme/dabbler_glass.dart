// =============================================================================
// Dabbler — Liquid Glass foundation
// Source of truth: dabbler.pen · frame "Search Screen" (node gJe6e)
// -----------------------------------------------------------------------------
// This SUPERSEDES the flat-elevation rule. Surfaces are translucent glass:
//   • fill        — white @ 45% (light) / ~12% (dark) over a backdrop blur
//   • border      — a 1px top-to-bottom gradient hairline (white → brand-light →
//                   brand → white) that re-tints from the ACTIVE theme
//   • shadow      — a two-part set: a coloured cast (brandPrimary-derived) plus
//                   a 1px white "lip" highlight
// Nothing here hardcodes the violet — every colour derives from context.dabbler.
//
// PERFORMANCE
//   BackdropFilter is expensive. [DabblerGlassSurface] therefore:
//   • never nests blurs — a surface inside another glass surface skips its own
//     BackdropFilter automatically (translucent fill + border still apply);
//   • wraps itself in a RepaintBoundary;
//   • honours [DabblerGlass.enabled] and the platform accessibility flags
//     (high-contrast / disable-animations) by degrading to a solid tinted
//     surface + border with no blur.
// =============================================================================

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'dabbler_colors.dart';
import 'dabbler_spacing.dart';

/// Liquid-glass tokens. Static values mirror the .pen design; colour-bearing
/// members are methods over [DabblerColors] so they re-tint per theme.
abstract final class DabblerGlass {
  DabblerGlass._();

  // --- app-level reduce-transparency switch -----------------------------------

  /// App-level reduce-transparency setting. When false, every glass surface
  /// renders as a solid tinted surface + border (no BackdropFilter).
  static bool enabled = true;

  /// Effective glass state for [context]: the app switch AND the platform
  /// accessibility signals (high contrast / disable animations) must allow it.
  static bool resolve(BuildContext context) {
    if (!enabled) return false;
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return true;
    return !mq.highContrast && !mq.disableAnimations;
  }

  // --- surface -----------------------------------------------------------------

  /// Backdrop blur sigmas per surface scale (from the .pen effects).
  static const double blurCard = 28; // cards / lists
  static const double blurField = 22; // search field, icon containers
  static const double blurSmall = 18; // chips, circular arrow buttons
  static const double blurSelected = 16; // selected / active chips

  /// Glass fill: white 45% in light, ~12% in dark.
  static const Color fillLight = Color(0x73FFFFFF);
  static const Color fillDark = Color(0x1FFFFFFF);

  static Color fill(Brightness b) =>
      b == Brightness.dark ? fillDark : fillLight;

  /// A lighter tint of the active brand — the "brand-light" used by the border
  /// mid-stop, overlays, and background orbs (≈ #C18FFF in the Main theme).
  static Color brandLight(DabblerColors d) =>
      Color.lerp(d.brandPrimary, Colors.white, 0.5)!;

  // --- gradient border -----------------------------------------------------------

  /// The 1px hairline gradient, top → bottom. White stops soften in dark mode
  /// (×0.4) so the lip doesn't glow against deep surfaces.
  static Gradient borderGradient(DabblerColors d, Brightness b) {
    final dark = b == Brightness.dark;
    double w(double a) => dark ? a * 0.4 : a;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.4, 0.7, 1.0],
      colors: [
        Colors.white.withValues(alpha: w(1.0)),
        brandLight(d).withValues(alpha: 0.33),
        d.brandPrimary.withValues(alpha: 0.25),
        Colors.white.withValues(alpha: w(0.9)),
      ],
    );
  }

  // --- shadows (two-part: coloured cast + white lip) ---------------------------

  static List<BoxShadow> _pair(
    DabblerColors d,
    Brightness b, {
    required double castAlpha,
    required double castBlur,
    required Offset castOffset,
    required double lipAlpha,
    required double lipBlur,
    required Offset lipOffset,
    Color? base,
  }) {
    final dark = b == Brightness.dark;
    return [
      BoxShadow(
        color: (base ?? d.brandPrimary).withValues(alpha: castAlpha),
        blurRadius: castBlur,
        offset: castOffset,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: dark ? lipAlpha * 0.4 : lipAlpha),
        blurRadius: lipBlur,
        offset: lipOffset,
      ),
    ];
  }

  /// Cards / list containers.
  static List<BoxShadow> cardShadows(DabblerColors d, Brightness b) => _pair(
        d, b,
        castAlpha: 0.15, castBlur: 32, castOffset: const Offset(0, 14),
        lipAlpha: 0.90, lipBlur: 3, lipOffset: const Offset(0, 1),
      );

  /// Small raised elements: chips, circular arrow buttons.
  static List<BoxShadow> raisedShadows(DabblerColors d, Brightness b) => _pair(
        d, b,
        castAlpha: 0.14, castBlur: 18, castOffset: const Offset(0, 6),
        lipAlpha: 0.85, lipBlur: 2, lipOffset: const Offset(0, 1),
      );

  /// Recessed surfaces: the search field, icon containers (lip sits ABOVE).
  static List<BoxShadow> insetShadows(DabblerColors d, Brightness b) => _pair(
        d, b,
        castAlpha: 0.20, castBlur: 12, castOffset: const Offset(0, 4),
        lipAlpha: 0.90, lipBlur: 2, lipOffset: const Offset(0, -1),
      );

  /// Selected / active chips and the primary (filled) button. Pass [base] to
  /// cast from another semantic colour (e.g. error for destructive buttons).
  static List<BoxShadow> selectedShadows(DabblerColors d, Brightness b,
          {Color? base}) =>
      _pair(
        d, b,
        castAlpha: 0.40, castBlur: 20, castOffset: const Offset(0, 8),
        lipAlpha: 0.80, lipBlur: 2, lipOffset: const Offset(0, 1),
        base: base,
      );

  /// Pressed feedback: pull the cast in tighter and deepen it slightly.
  static List<BoxShadow> deepen(List<BoxShadow> shadows) => [
        for (final s in shadows)
          s.copyWith(
            color: s.color.withValues(
                alpha: (s.color.a * (s.offset.dy >= 0 ? 1.3 : 1.0)).clamp(0, 1)),
            blurRadius: s.blurRadius * 0.75,
            offset: Offset(s.offset.dx, s.offset.dy * 0.6),
          ),
      ];

  // --- selected / active (brand-filled) treatment -------------------------------

  /// Base fill of a selected chip / primary button: brand @ 85%. Pass [base]
  /// to reuse the treatment on another semantic colour (e.g. error).
  static Color selectedFill(DabblerColors d, {Color? base}) =>
      (base ?? d.brandPrimary).withValues(alpha: 0.85);

  /// Top-lit sheen over the selected fill: brand-light 50% → transparent by mid.
  static Gradient selectedOverlay(DabblerColors d) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.5],
        colors: [
          brandLight(d).withValues(alpha: 0.5),
          brandLight(d).withValues(alpha: 0.0),
        ],
      );

  /// Selected stroke: white @ 70%, 1px.
  static Color selectedStroke() => Colors.white.withValues(alpha: 0.7);

  // --- icon container (tinted tile) ---------------------------------------------

  static Color iconTileFill(DabblerColors d) =>
      d.brandPrimary.withValues(alpha: 0.10);
  static Color iconTileStroke(DabblerColors d) =>
      brandLight(d).withValues(alpha: 0.40);

  /// Divider inside glass list containers: brand @ 10% hairline.
  static Color divider(DabblerColors d) =>
      d.brandPrimary.withValues(alpha: 0.10);

  // --- disabled-glass fallback ---------------------------------------------------

  /// Opaque stand-in for the glass fill when transparency is reduced.
  static Color solidFill(DabblerColors d, Brightness b) =>
      Color.alphaBlend(fill(b), d.bgSecondary);

  // --- background ----------------------------------------------------------------

  /// Base wash behind everything (Main light ≈ #F4F0FB).
  static Color backgroundBase(DabblerColors d, Brightness b) =>
      b == Brightness.dark
          ? Color.lerp(d.brandPrimary, Colors.black, 0.86)!
          : Color.lerp(d.brandPrimary, Colors.white, 0.92)!;
}

// =============================================================================
// Nesting marker — a glass surface inside another glass surface must not add a
// second BackdropFilter.
// =============================================================================

class _GlassNesting extends InheritedWidget {
  const _GlassNesting({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlassNesting>() != null;

  @override
  bool updateShouldNotify(_GlassNesting oldWidget) => false;
}

// =============================================================================
// Gradient hairline border painter
// =============================================================================

class GlassBorderPainter extends CustomPainter {
  GlassBorderPainter({
    required this.radius,
    this.gradient,
    this.solidColor,
    this.strokeWidth = DabblerSizing.borderDefault,
  }) : assert(gradient != null || solidColor != null);

  final BorderRadius radius;
  final Gradient? gradient;
  final Color? solidColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    if (gradient != null) {
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = solidColor!;
    }
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.gradient != gradient ||
      oldDelegate.solidColor != solidColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

// =============================================================================
// Glass surface — the shared building block for cards, chips, fields, tiles
// =============================================================================

class DabblerGlassSurface extends StatelessWidget {
  const DabblerGlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.blur = DabblerGlass.blurCard,
    this.shadows,
    this.fill,
    this.overlay,
    this.borderGradient,
    this.borderColor,
    this.borderWidth = DabblerSizing.borderDefault,
    this.padding,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;

  /// Cast + lip shadows (from [DabblerGlass]); omitted = no shadow.
  final List<BoxShadow>? shadows;

  /// Surface fill; defaults to [DabblerGlass.fill] for the active brightness.
  final Color? fill;

  /// Optional gradient painted over the fill (the selected top-lit sheen).
  final Gradient? overlay;

  /// Hairline: a gradient (default: [DabblerGlass.borderGradient]) or a solid
  /// [borderColor] override (focus ring, error, selected white stroke).
  final Gradient? borderGradient;
  final Color? borderColor;
  final double borderWidth;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final glassOn = DabblerGlass.resolve(context);
    final nested = _GlassNesting.of(context);

    final effectiveFill = glassOn
        ? (fill ?? DabblerGlass.fill(b))
        : (fill != null && fill!.a >= 0.99
            ? fill! // already opaque (e.g. selected brand fill)
            : DabblerGlass.solidFill(d, b));

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (alignment != null) {
      content = Align(alignment: alignment!, child: content);
    }
    // Mark descendants so they skip their own BackdropFilter.
    content = _GlassNesting(child: content);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(color: effectiveFill),
      child: overlay == null
          ? content
          : DecoratedBox(
              decoration: BoxDecoration(gradient: overlay),
              child: content,
            ),
    );

    // One blur per surface, never nested, only when glass is on.
    if (glassOn && !nested) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      );
    }

    surface = ClipRRect(borderRadius: borderRadius, child: surface);

    surface = CustomPaint(
      foregroundPainter: GlassBorderPainter(
        radius: borderRadius,
        gradient: borderColor == null
            ? (borderGradient ?? DabblerGlass.borderGradient(d, b))
            : null,
        solidColor:
            borderColor ?? (glassOn ? null : d.borderStrong),
        strokeWidth: borderWidth,
      ),
      child: surface,
    );

    surface = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: surface,
    );

    return RepaintBoundary(child: surface);
  }
}

// =============================================================================
// Glass background — the rich backdrop the glass reads against
// =============================================================================

class DabblerGlassBackground extends StatelessWidget {
  const DabblerGlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final dark = b == Brightness.dark;
    final light = DabblerGlass.brandLight(d);
    // Orbs run at ×0.4 opacity in dark: light-brand themes (e.g. Simple, whose
    // dark brandPrimary is near-white) otherwise wash the backdrop out and drop
    // secondary text below WCAG AA — verified by glass_contrast_test.dart.
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
        Positioned.fill(
          child: ColoredBox(color: DabblerGlass.backgroundBase(d, b)),
        ),
        // Positions/sizes mirror the .pen radial fills (fractions of the frame).
        orb(
          center: const Alignment(0.7, -0.9), // (0.85, 0.05)
          color: light, alpha: 0.33, radius: 0.9, stop: 0.8,
        ),
        orb(
          center: const Alignment(-0.8, -0.3), // (0.10, 0.35)
          color: d.brandPrimary, alpha: 0.19, radius: 0.8, stop: 0.75,
        ),
        orb(
          center: const Alignment(0.8, 0.5), // (0.90, 0.75)
          color: d.accent, alpha: 0.18, radius: 0.8, stop: 0.7,
        ),
        orb(
          center: const Alignment(-0.4, 1.0), // (0.30, 1.00)
          color: light, alpha: 0.20, radius: 1.0, stop: 0.7,
        ),
        child,
      ],
    );
  }
}
