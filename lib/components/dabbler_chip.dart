// =============================================================================
// Dabbler — Chip + Icon Tile (Liquid Glass)
// -----------------------------------------------------------------------------
// DabblerChip: a pill glass chip — translucent glass with the gradient hairline
// by default; the brand-filled "selected" treatment (top-lit sheen + white
// stroke + selected shadow) when active. Label colour on the selected fill is
// ALWAYS onBrand — dark in Bright/Sport, never a hardcoded white.
//
// DabblerIconTile: the tinted square icon container from the design — brand @
// 10% fill, brand-light stroke, radius lg, inset glass shadows.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_glass.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';

/// A glass filter/tag chip. `selected` switches to the brand-filled treatment.
class DabblerChip extends StatelessWidget {
  const DabblerChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final enabled = onTap != null;
    final fg = selected ? d.onBrand : d.textPrimary;

    Widget chip = DabblerGlassSurface(
      borderRadius: DabblerRadius.pillRadius,
      blur: selected ? DabblerGlass.blurSelected : DabblerGlass.blurSmall,
      fill: selected ? DabblerGlass.selectedFill(d) : null,
      overlay: selected ? DabblerGlass.selectedOverlay(d) : null,
      borderColor: selected ? DabblerGlass.selectedStroke() : null,
      shadows: selected
          ? DabblerGlass.selectedShadows(d, b)
          : DabblerGlass.raisedShadows(d, b),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space5, // 15 (pen 14)
        vertical: DabblerSpacing.space3, // 9 (pen 8)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon,
                size: DabblerSizing.iconSm,
                color: selected ? d.onBrand : d.brandPrimary),
            const SizedBox(width: DabblerSpacing.iconGap),
          ],
          Text(
            label,
            style: DabblerType.emphasized(DabblerType.subheadline)
                .copyWith(color: fg),
          ),
        ],
      ),
    );

    if (!enabled) return chip;

    // Keep the visual chip compact but guarantee a >= 45px tap area.
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: DabblerSizing.touchTargetMin),
            child: Center(widthFactor: 1, child: chip),
          ),
        ),
      ),
    );
  }
}

/// The 45×45 tinted icon container (design: "Icon Bg"). Fill and stroke derive
/// from the active brand; the icon renders in brandPrimary at iconMd.
class DabblerIconTile extends StatelessWidget {
  const DabblerIconTile({super.key, required this.icon, this.color});

  final IconData icon;

  /// Optional tint override (defaults to the theme's brandPrimary).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final b = Theme.of(context).brightness;
    final tint = color ?? d.brandPrimary;

    return DabblerGlassSurface(
      width: DabblerSizing.touchTargetMin, // 45 (pen 44, snapped to base-3)
      height: DabblerSizing.touchTargetMin,
      borderRadius: DabblerRadius.lgRadius, // 12
      blur: DabblerGlass.blurField,
      fill: tint.withValues(alpha: 0.10),
      borderColor: Color.lerp(tint, Colors.white, 0.5)!.withValues(alpha: 0.4),
      shadows: DabblerGlass.insetShadows(d, b),
      alignment: Alignment.center,
      child: Icon(icon, size: DabblerSizing.iconMd, color: tint),
    );
  }
}
