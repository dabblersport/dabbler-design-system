// =============================================================================
// Dabbler — Card / Surface component
// -----------------------------------------------------------------------------
// A flat, token-driven card. Separation comes from the tinted-neutral ladder
// (bgPrimary → surfaceCard → bgTertiary) plus hairline borders — NEVER a shadow.
// Elevation is 0 and any M3 surface tint is suppressed, so nested surfaces read
// as distinct layers purely via tint + border, in every theme.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_spacing.dart';

/// Card treatments. `interactive` is tappable with a tonal press; `selected`
/// (or the `selected` flag) is the choice-card treatment.
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

  bool get _isSelected =>
      selected || variant == DabblerCardVariant.selected;
  bool get _tappable => onTap != null;

  @override
  State<DabblerCard> createState() => _DabblerCardState();
}

class _DabblerCardState extends State<DabblerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final padding = widget.padding ??
        const EdgeInsets.all(DabblerSpacing.cardPadding); // 18

    final baseBg = _baseBackground(d);
    final bg = (_pressed && widget._tappable) ? _pressedBackground(d, baseBg) : baseBg;
    final side = _borderSide(d);

    Widget content = Padding(padding: padding, child: widget.child);

    // Interactive cards respect the min tap target.
    if (widget._tappable) {
      content = ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: DabblerSizing.touchTargetMin),
        child: content,
      );
    }

    return Material(
      color: bg,
      // ignore: avoid_redundant_argument_values  (explicit: the flat-elevation rule)
      elevation: 0, // flat — no shadow, ever
      surfaceTintColor: Colors.transparent, // suppress M3 tonal tint
      shape: RoundedRectangleBorder(
        borderRadius: DabblerRadius.lgRadius, // 12
        side: side,
      ),
      clipBehavior: Clip.antiAlias, // clip the ripple to the card radius
      child: widget._tappable
          ? InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (h) => setState(() => _pressed = h),
              child: content,
            )
          : content,
    );
  }

  Color _baseBackground(DabblerColors d) {
    if (widget._isSelected) {
      // Subtle tint toward brand for choice cards.
      return Color.lerp(d.surfaceCard, d.brandPrimary, 0.08)!;
    }
    return switch (widget.variant) {
      DabblerCardVariant.filled => d.bgTertiary,
      DabblerCardVariant.outlined => Colors.transparent,
      _ => d.surfaceCard,
    };
  }

  /// Tonal press: shift one step along the neutral ladder toward bgTertiary
  /// (never a shadow or scale).
  Color _pressedBackground(DabblerColors d, Color baseBg) {
    // If we're already at bgTertiary (filled), step slightly further so the
    // press still reads; otherwise move toward bgTertiary.
    if (baseBg == d.bgTertiary) {
      return Color.lerp(d.bgTertiary, d.borderDefault, 0.5)!;
    }
    return Color.lerp(baseBg, d.bgTertiary, 0.7)!;
  }

  BorderSide _borderSide(DabblerColors d) {
    if (widget._isSelected) {
      return BorderSide(color: d.brandPrimary, width: DabblerSizing.borderDefault + 1); // 2px
    }
    return switch (widget.variant) {
      DabblerCardVariant.filled =>
        BorderSide.none,
      DabblerCardVariant.outlined =>
        // ignore: avoid_redundant_argument_values  (token-driven, not a literal)
        BorderSide(color: d.borderDefault, width: DabblerSizing.borderDefault), // 1px
      _ => BorderSide(color: d.borderDefault, width: DabblerSizing.borderHairline), // 0.5px
    };
  }
}
