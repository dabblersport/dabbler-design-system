import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// A day's availability in a [DabblerCalendar] with `dayStatus` set (Alpha
/// DS gaps 6, item 10).
///
/// Each status maps onto an **existing** status tone — nothing new is
/// minted — and onto a **shape**, so colour is never the only cue (WCAG
/// 1.4.1):
///
/// | Status | Tone | Mark under the number | Number |
/// |---|---|---|---|
/// | [available] | success | filled dot | as usual |
/// | [limited] | warning | hollow ring | as usual |
/// | [full] | error | short bar | struck through |
/// | [none] | — | nothing | as usual |
///
/// The status also reaches assistive technology: a day with a status is
/// announced as "21, Limited" through [DabblerCalendarDayStatusStyle.labelFor].
///
/// **Design source:** no design frame draws per-day availability. The Details
/// screen embeds the plain `Calendar` (`Details.dc.html:580`) and the venue
/// "Check availability" sheet (`Details.dc.html:524, 753`) has no day-level
/// colouring. This mapping is derived from the system's status tokens, not
/// transcribed, and is recorded as such.
enum DabblerCalendarDayStatus {
  /// No availability information — the day renders exactly as without
  /// `dayStatus`.
  none,

  /// Open slots — success.
  available,

  /// Few slots left — warning.
  limited,

  /// No slots — error.
  full,
}

/// The geometry, colours and default labels for [DabblerCalendarDayStatus].
abstract final class DabblerCalendarDayStatusStyle {
  /// The mark's diameter — `--space-2` (6).
  static const double markSize = DabblerSpacing.space2;

  /// The full-day bar's width — `--space-4` (12), at [markStroke] tall.
  static const double barWidth = DabblerSpacing.space4;

  /// The ring's and the bar's stroke — `--space-1` (3) for the bar, the
  /// default border for the ring.
  static const double markStroke = DabblerSpacing.space1;

  /// The mark's inset from the pill's bottom edge — `--space-1` (3).
  static const double markInset = DabblerSpacing.space1;

  /// English defaults for the semantics suffix. Localise through
  /// `DabblerCalendar.dayStatusLabels`.
  static const Map<DabblerCalendarDayStatus, String> defaultLabels =
      <DabblerCalendarDayStatus, String>{
        DabblerCalendarDayStatus.available: 'Available',
        DabblerCalendarDayStatus.limited: 'Limited availability',
        DabblerCalendarDayStatus.full: 'Fully booked',
      };

  /// The status tone for [status]; null for [DabblerCalendarDayStatus.none].
  static DabblerStatusTone? toneFor(DabblerCalendarDayStatus status) =>
      switch (status) {
        DabblerCalendarDayStatus.none => null,
        DabblerCalendarDayStatus.available => DabblerStatusTone.success,
        DabblerCalendarDayStatus.limited => DabblerStatusTone.warning,
        DabblerCalendarDayStatus.full => DabblerStatusTone.error,
      };

  /// The mark's colour: the tone's `base` (the bare indicator role), or
  /// [DabblerColors.onBrand] on a selected day so the mark stays visible on
  /// the brand pill.
  static Color? colorFor(
    DabblerColors colors,
    DabblerCalendarDayStatus status, {
    bool selected = false,
  }) {
    final DabblerStatusTone? tone = toneFor(status);
    if (tone == null) return null;
    return selected ? colors.onBrand : colors.status(tone).base;
  }

  /// The semantics suffix for [status], from [labels] then [defaultLabels].
  static String? labelFor(
    DabblerCalendarDayStatus status, [
    Map<DabblerCalendarDayStatus, String>? labels,
  ]) {
    if (status == DabblerCalendarDayStatus.none) return null;
    return labels?[status] ?? defaultLabels[status];
  }
}

/// The small shape under a day number — see [DabblerCalendarDayStatus].
class DabblerCalendarDayStatusMark extends StatelessWidget {
  /// A mark for [status] in [color].
  const DabblerCalendarDayStatusMark({
    super.key,
    required this.status,
    required this.color,
  });

  /// Which shape to draw.
  final DabblerCalendarDayStatus status;

  /// The mark's colour.
  final Color color;

  @override
  Widget build(BuildContext context) => switch (status) {
    DabblerCalendarDayStatus.none => const SizedBox.shrink(),
    DabblerCalendarDayStatus.available => Container(
      width: DabblerCalendarDayStatusStyle.markSize,
      height: DabblerCalendarDayStatusStyle.markSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    DabblerCalendarDayStatus.limited => Container(
      width: DabblerCalendarDayStatusStyle.markSize,
      height: DabblerCalendarDayStatusStyle.markSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: DabblerSizing.borderDefault),
      ),
    ),
    DabblerCalendarDayStatus.full => Container(
      width: DabblerCalendarDayStatusStyle.barWidth,
      height: DabblerCalendarDayStatusStyle.markStroke,
      decoration: BoxDecoration(
        color: color,
        borderRadius: DabblerRadius.pillAll,
      ),
    ),
  };
}
