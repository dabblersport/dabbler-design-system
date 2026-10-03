import 'package:flutter/widgets.dart';

import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// How a [DabblerTabsVariant.segmented] strip treats labels that do not fit
/// their equal share of the track — DS gaps 6 (item 8).
///
/// Ignored by the underline variant, which already has `scrollable`.
enum DabblerTabsLabelFit {
  /// The previous behaviour, and the default: each label ellipsises inside
  /// its equal-width segment.
  ellipsis,

  /// Never truncate. The labels first scale down together — every segment at
  /// the same size — from [DabblerType.subheadline] to no smaller than
  /// [DabblerType.footnote] (15 → 13 in Latin, 14.1 → 12.1 in Arabic). If
  /// they still do not fit at that floor, the segments drop their equal
  /// widths and the track scrolls horizontally, with the active segment kept
  /// in view. Both directions; under RTL the scroll starts at the right.
  fit,
}

/// The resolved layout of a [DabblerTabsLabelFit.fit] strip.
@immutable
class DabblerTabsFitResult {
  /// Creates a result.
  const DabblerTabsFitResult({required this.scale, required this.scroll});

  /// The factor applied to the label's font size (1 = no change).
  final double scale;

  /// Whether the strip scrolls, with segments at their natural width.
  final bool scroll;
}

/// Works out [DabblerTabsLabelFit.fit] for [labels] in a track of [width].
///
/// Pure apart from text measurement: the widest label at the active weight
/// ([DabblerType.medium]) is measured with [textScaler]; each segment's share
/// is the track's inner width (less [DabblerSpacing.space1] padding at both
/// ends and between segments) over the label count, and a segment needs the
/// label plus [DabblerSpacing.space5] of padding on both sides. Leading icons
/// and badges are not measured — a segmented strip with those should keep
/// [DabblerTabsLabelFit.ellipsis] or be checked by eye.
DabblerTabsFitResult dabblerTabsFit({
  required List<String> labels,
  required double width,
  required TextDirection direction,
  required TextScaler textScaler,
}) {
  if (labels.isEmpty || !width.isFinite) {
    return const DabblerTabsFitResult(scale: 1, scroll: false);
  }
  final TextStyle base = DabblerType.subheadline
      .resolveForDirection(direction)
      .copyWith(fontWeight: DabblerType.medium);
  final double floor =
      DabblerType.footnote.resolveForDirection(direction).fontSize! /
      base.fontSize!;
  double widest = 0;
  for (final String label in labels) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: label, style: base),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    if (painter.width > widest) {
      widest = painter.width;
    }
    painter.dispose();
  }
  final int n = labels.length;
  final double inner =
      width - 2 * DabblerSpacing.space1 - (n - 1) * DabblerSpacing.space1;
  final double room = inner / n - 2 * DabblerSpacing.space5;
  if (widest <= 0 || widest <= room) {
    return const DabblerTabsFitResult(scale: 1, scroll: false);
  }
  // A one-pixel margin against glyph-advance rounding at the smaller size.
  final double scale = (room - 1) / widest;
  if (scale >= floor) {
    return DabblerTabsFitResult(scale: scale, scroll: false);
  }
  return DabblerTabsFitResult(scale: floor, scroll: true);
}
