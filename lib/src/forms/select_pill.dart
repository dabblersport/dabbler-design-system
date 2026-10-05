import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// SelectPill — a status-tinted pill that opens a choice: a bold glyph, the
/// current value and a trailing `arrow-circle-down`.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 489-497, the post type and audience pills of the Create post sheet:
/// `padding:7px 12px`, `gap:6px`, pill, status `surface` fill and `strong`
/// ink, 13/18 400, glyph 15 bold, trailing 14.
///
/// ## Deviations
///
/// * **Padding.** 7px becomes `space2` (6); the touch box is the 45px floor.
/// * **Type.** 13/18 is `footnote`.
///
/// RTL: the glyph leads and the arrow trails, mirrored by the row.
/// Accessibility: one button named [semanticLabel] or [label].
class DabblerSelectPill extends StatelessWidget {
  /// A select pill.
  const DabblerSelectPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.tone,
    this.trailingIcon = 'arrow-circle-down',
    this.semanticLabel,
    this.brandInk = false,
  });

  /// The current value.
  final String label;

  /// The leading glyph; null draws none.
  final String? icon;

  /// The status tint: `colors.info`, `colors.success`, … Null draws the
  /// neutral pill of `Home Feed.dc.html:566` — card fill, 1px hairline,
  /// `textSecondary` ink.
  final DabblerStatusColor? tone;

  /// The trailing glyph (`arrow-circle-down`; `arrow-circle-right` for a
  /// value that opens a detail).
  final String trailingIcon;

  /// Opens the choice.
  final VoidCallback? onTap;

  /// The accessible name; falls back to [label].
  final String? semanticLabel;

  /// Draws the neutral pill's value and arrow in the brand ink — the Create
  /// meet-up Advanced rows (`Home Feed.dc.html:1213-1263`: card fill, card
  /// hairline, `color: var(--color-brand-primary)`). Ignored with a [tone].
  final bool brandInk;

  /// Leading glyph side — `size="15"`.
  static const double glyphSize = 15;

  /// Trailing arrow side — `size="14"`.
  static const double arrowSize = 14;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final Color ink =
        tone?.strong ?? (brandInk ? colors.brandPrimary : colors.textSecondary);
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: semanticLabel ?? label,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.pillAll,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone?.surface ?? colors.surfaceCard,
          borderRadius: DabblerRadius.pillAll,
          border: tone == null
              ? Border.all(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DabblerSpacing.space4,
            vertical: DabblerSpacing.space3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                DabblerIcon(
                  icon!,
                  size: glyphSize,
                  weight: DabblerIconWeight.bold,
                  color: ink,
                ),
                const SizedBox(width: DabblerSpacing.space2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: DabblerType.footnote
                      .resolveForDirection(dir)
                      .copyWith(color: ink),
                ),
              ),
              const SizedBox(width: DabblerSpacing.space2),
              DabblerIcon(trailingIcon, size: arrowSize, color: ink),
            ],
          ),
        ),
      ),
    );
  }
}
