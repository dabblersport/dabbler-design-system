import 'package:flutter/widgets.dart';

/// A one-line figure that **scales down to fit** its width instead of being
/// clipped, never below [minScale] of its size — the value line of a
/// [DabblerStatTile] with `fitValue: true` (Alpha DS gaps 6, item 7).
///
/// Behaves like a `FittedBox(fit: BoxFit.scaleDown)` with a floor: the text is
/// measured at [style]; when it is wider than the room it is given, the font
/// size is multiplied by `room / width`, clamped to [minScale]. A figure that
/// still does not fit at the floor ellipsises rather than clipping mid-glyph,
/// so a value never shrinks into illegibility and never silently loses digits.
///
/// Scaling the font size (rather than painting a transform) keeps the line
/// box, the baseline and the accessible text identical to an unscaled value,
/// and respects the platform text scaler: the measurement uses the ambient
/// [MediaQuery.textScalerOf].
class DabblerStatTileValue extends StatelessWidget {
  /// A scale-to-fit line showing [text] at [style].
  const DabblerStatTileValue(
    this.text, {
    super.key,
    required this.style,
    this.minScale = defaultMinScale,
  }) : assert(minScale > 0 && minScale <= 1);

  /// The figure.
  final String text;

  /// The full-size style. Must carry a font size.
  final TextStyle style;

  /// The smallest fraction of [style]'s size the figure may shrink to.
  final double minScale;

  /// The default floor — **0.6**: a 26px small-tile value bottoms out at
  /// 15.6, about the body size, and a 46px hero value at 27.6. Below that
  /// the figure stops reading as the tile's headline.
  static const double defaultMinScale = 0.6;

  /// The scale [text] needs at [style] to fit [maxWidth], clamped to
  /// `[minScale, 1]`.
  static double scaleFor({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextDirection direction,
    TextScaler textScaler = TextScaler.noScaling,
    double minScale = defaultMinScale,
  }) {
    if (!maxWidth.isFinite) return 1;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    if (width <= maxWidth || width == 0) return 1;
    return (maxWidth / width).clamp(minScale, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double scale = scaleFor(
          text: text,
          style: style,
          maxWidth: box.maxWidth,
          direction: direction,
          textScaler: scaler,
          minScale: minScale,
        );
        final double size = style.fontSize ?? 14;
        return Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: scale == 1 ? style : style.copyWith(fontSize: size * scale),
        );
      },
    );
  }
}
