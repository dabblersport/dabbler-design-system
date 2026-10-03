import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// The info button of the `DabblerInputRow.toggle` pattern — an
/// `info-circle` glyph at [DabblerSizing.iconSm] in
/// [DabblerColors.textTertiary] (a non-informational affordance glyph, the
/// D-027 carve-out the chevron also uses), inside a
/// [DabblerSizing.touchTargetMin] square hit target with its own button
/// semantics.
///
/// Settings draws its explainers as an `information` glyph at 16 in
/// `--subtle` (`Settings.dc.html:277-279`). **Deviation:** 16 is not an icon
/// step, so the glyph takes [DabblerSizing.iconSm] (18); the name is the
/// registry's `info-circle`.
class DabblerInputRowInfoButton extends StatelessWidget {
  /// Creates an info button.
  const DabblerInputRowInfoButton({
    super.key,
    required this.onPressed,
    this.semanticLabel = defaultSemanticLabel,
  });

  /// Called on tap.
  final VoidCallback onPressed;

  /// The accessible name.
  final String semanticLabel;

  /// The default accessible name.
  static const String defaultSemanticLabel = 'More info';

  /// The glyph.
  static const String iconName = 'info-circle';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: SizedBox.square(
              dimension: DabblerSizing.touchTargetMin,
              child: Center(
                child: DabblerIcon(
                  iconName,
                  size: DabblerSizing.iconSm,
                  color: DabblerColors.of(context).textTertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The single-line trailing chip strip of `DabblerInputRow.trailingChips`.
///
/// Chips never wrap: they sit in one [Row] inside a horizontal
/// [SingleChildScrollView], so a width too narrow for all of them clips and
/// scrolls instead of overflowing. Spaced by [DabblerSpacing.iconGap]. The
/// scroll view follows the ambient [Directionality], so under RTL the strip
/// starts at the right edge.
class DabblerInputRowChipStrip extends StatelessWidget {
  /// Creates a strip of [chips].
  const DabblerInputRowChipStrip({super.key, required this.chips});

  /// The chips, in reading order.
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < chips.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: DabblerSpacing.iconGap),
            chips[i],
          ],
        ],
      ),
    );
  }
}
