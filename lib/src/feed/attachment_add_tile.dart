import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// AttachmentAddTile — the dashed "Add" tile that sits before a reply's
/// attachment previews: a glyph over a short word.
///
/// Transcribed from `Post.dc.html` (alpha-plan design set) line 541: 56 wide,
/// 95 high, `--radius-lg`, 1px dashed `--outline-card`, `gallery` 20 over
/// `Add` 11/14 600, all `--muted`; and, with [dashed] false, the 64 x 128
/// solid add tile of the Create post media rail (`Home Feed.dc.html:523`).
///
/// ## Deviations
///
/// * **Type.** 11/14 has no style; the word takes `caption1`.
/// * **Size.** 56 x 95 become [width] x [height] (56 x 96), the 45px floor
///   being met on both sides.
///
/// RTL: symmetrical. Accessibility: one button named [label].
class DabblerAttachmentAddTile extends StatelessWidget {
  /// An add tile.
  const DabblerAttachmentAddTile({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    this.label,
    this.icon = 'gallery',
    this.dashed = true,
    this.tileWidth = width,
    this.tileHeight = height,
  });

  /// The button's accessible name.
  final String semanticLabel;

  /// The word under the glyph; null draws the glyph alone.
  final String? label;

  /// Dashed hairline (`Post.dc.html:541`); false draws the solid card tile of
  /// `Home Feed.dc.html:523` (card fill, 1px hairline, `add` 22).
  final bool dashed;

  /// Tile width — 56 dashed, 64 solid in the designs.
  final double tileWidth;

  /// Tile height — 96 dashed, 128 solid in the designs.
  final double tileHeight;

  /// Adds an attachment; null draws the tile inert.
  final VoidCallback? onTap;

  /// The glyph.
  final String icon;

  /// Tile width.
  static const double width = 56;

  /// Tile height.
  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.lgAll,
      child: CustomPaint(
        painter: dashed ? _DashedBorder(colors.borderDefault) : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dashed ? null : colors.surfaceCard,
            borderRadius: DabblerRadius.lgAll,
            border: dashed
                ? null
                : Border.all(
                    color: colors.borderDefault,
                    width: DabblerSizing.borderDefault,
                  ),
          ),
          child: SizedBox(
            width: tileWidth,
            height: tileHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DabblerIcon(
                  icon,
                  size: label == null ? 22 : 20,
                  color: colors.textSecondary,
                ),
                if (label != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space1),
                  Text(
                    label!,
                    maxLines: 1,
                    style: DabblerType.caption1
                        .resolveForDirection(dir)
                        .copyWith(
                          color: colors.textSecondary,
                          fontWeight: DabblerType.semibold,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = DabblerSizing.borderDefault;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(DabblerRadius.lg),
        ),
      );
    for (final metric in path.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        canvas.drawPath(metric.extractPath(at, at + 4), paint);
        at += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
