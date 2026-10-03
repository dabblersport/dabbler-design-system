/// Part of the `sheet.dart` library — how a sheet chooses its height
/// (KAN-412 W1 gap 8).
///
/// A `part` for the reason the rest of the library is (KAN-265): the sizing
/// helper reads [DabblerSheet.maxHeightFraction] and is used by the private
/// state, and `sheet.dart` is near the 500-line rule.
///
/// The imports are the library's — a part file declares none of its own.
part of 'sheet.dart';

/// How a [DabblerSheet] chooses its height.
enum DabblerSheetDetent {
  /// The panel is a fixed fraction of the viewport — [DabblerSheet.detents],
  /// snapping between them on drag. Today's behaviour and the default.
  fractions,

  /// The panel is as tall as its content (title, body and footer), capped at
  /// [DabblerSheet.contentMaxFraction] of the viewport, and the body scrolls
  /// beyond the cap. [DabblerSheet.detents] and [DabblerSheet.snapTo] are
  /// ignored. Dragging the handle down past the dismiss threshold still
  /// closes it; a shorter drag springs back.
  ///
  /// The design draws its sheets this way — `max-height: 80%` / `78%` of the
  /// phone frame, no fixed height (`Listings.dc.html`, the filter and sort
  /// sheets) — so a short list gives a short sheet and a long one stops at
  /// the cap and scrolls.
  content,
}

/// The tallest a content-sized sheet may be: [fraction] of [viewportHeight],
/// never above [DabblerSheet.maxHeightFraction]. The fraction is clamped to
/// `(0, maxHeightFraction]`.
double dabblerSheetContentMaxHeight(double viewportHeight, double fraction) =>
    viewportHeight *
    math.min(
      fraction <= 0 ? DabblerSheet.defaultContentMaxFraction : fraction,
      DabblerSheet.maxHeightFraction,
    );
