// =============================================================================
// Dabbler — Card / Surface component (Liquid Glass)
// -----------------------------------------------------------------------------
// A translucent glass card: blurred backdrop fill, a 1px gradient hairline, and
// the two-part glass shadow (coloured cast + white lip). Variants are glass
// DENSITIES now — `filled` is denser, `outlined` is lighter. All colour derives
// from the active theme via DabblerGlass; nothing hardcodes the violet.
//
// Public API is unchanged from the flat era.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_glass.dart';
import '../theme/dabbler_spacing.dart';

/// Card treatments. `interactive` is tappable with a density press; `selected`
/// (or the `selected` flag) is the brand-tinted choice-card treatment.
enum DabblerCardVariant { standard, interactive, outlined, filled, selected }

class DabblerCard extends StatefulWidget {
  const DabblerCard({
    super.key,
    required this.child,
    this.variant = DabblerCardVariant.standard,
    this.onTap,
    this.padding,
    this.selected = false,
  });

  final Widget child;
  final DabblerCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool selected;

  bool get _isSelected => selected || variant == DabblerCardVariant.selected;
  bool get _tappable => onTap != null;

  @override
  State<DabblerCard> createState() => _DabblerCardState();
}

class _DabblerCardState extends State<DabblerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final padding = widget.padding ??
        const EdgeInsets.all(DabblerSpacing.cardPadding); // 18

    Widget content = Padding(padding: padding, child: widget.child);

    if (widget._tappable) {
      content = ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: DabblerSizing.touchTargetMin),
        child: content,
      );
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          child: content,
        ),
      );
    }

    final shadows = DabblerGlass.cardShadows(d, b);

    return DabblerGlassSurface(
      borderRadius: DabblerRadius.xlRadius, // 18 (pen 16 → base-3 18)
      fill: _fill(d, b), // blur = the DabblerGlass.blurCard default

      borderColor: widget._isSelected
          ? d.brandPrimary.withValues(alpha: 0.7)
          : null, // null → the gradient hairline
      shadows: _pressed ? DabblerGlass.deepen(shadows) : shadows,
      child: content,
    );
  }

  /// Glass density per variant; pressing steps the density up (a tonal press,
  /// never a lift).
  Color _fill(DabblerColors d, Brightness b) {
    final dark = b == Brightness.dark;
    double bump(double v) => (_pressed ? v + 0.12 : v).clamp(0.0, 1.0);

    if (widget._isSelected) {
      // Choice cards: glass tinted toward the brand.
      return DabblerGlass.brandLight(d)
          .withValues(alpha: bump(dark ? 0.18 : 0.28));
    }
    return switch (widget.variant) {
      // Denser glass for nested / secondary surfaces (they skip their own blur
      // inside a glass parent, so the fill carries the separation).
      DabblerCardVariant.filled =>
        Colors.white.withValues(alpha: bump(dark ? 0.20 : 0.65)),
      // Lighter, quieter glass for low-emphasis grouping.
      DabblerCardVariant.outlined =>
        Colors.white.withValues(alpha: bump(dark ? 0.05 : 0.08)),
      _ => dark
          ? DabblerGlass.fillDark.withValues(
              alpha: bump(DabblerGlass.fillDark.a))
          : DabblerGlass.fillLight.withValues(
              alpha: bump(DabblerGlass.fillLight.a)),
    };
  }
}
