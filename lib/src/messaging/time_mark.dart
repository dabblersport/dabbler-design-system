/// TimeMark — a tinted tile with a caller-supplied date / time label and an
/// optional countdown line, in the context card's tile style.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/icon_tile.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The tint of a [DabblerTimeMark].
enum DabblerTimeMarkTone {
  /// The brand colour.
  brand,

  /// A neutral secondary ink.
  neutral,

  /// Success.
  success,

  /// Warning.
  warning,

  /// Error.
  error,
}

/// A 36 dp tinted [DabblerIconTile] beside a date / time [label] and, when
/// given and not empty, a [countdown] caption under it.
///
/// Both strings are the caller's: the design system formats no date and writes
/// no "in 2 hours". The label and countdown wrap rather than clip, so the mark
/// grows at a 200 percent text scale, and the row mirrors in RTL.
///
/// This is new: the conversation context header's tile is a sport icon and is
/// unchanged.
class DabblerTimeMark extends StatelessWidget {
  /// A mark showing [label].
  const DabblerTimeMark({
    super.key,
    required this.label,
    this.countdown,
    this.tone = DabblerTimeMarkTone.brand,
    this.icon = 'calendar-1',
  });

  /// The date / time text, already formatted by the caller.
  final String label;

  /// An optional second line (a countdown), already worded by the caller.
  final String? countdown;

  /// The tile's tint.
  final DabblerTimeMarkTone tone;

  /// The Iconsax glyph in the tile.
  final String icon;

  Color _tint(DabblerColors c) => switch (tone) {
    DabblerTimeMarkTone.brand => c.brandPrimary,
    DabblerTimeMarkTone.neutral => c.textSecondary,
    DabblerTimeMarkTone.success => c.status(DabblerStatusTone.success).base,
    DabblerTimeMarkTone.warning => c.status(DabblerStatusTone.warning).base,
    DabblerTimeMarkTone.error => c.status(DabblerStatusTone.error).base,
  };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final Color tint = _tint(colors);
    final String? extra = (countdown == null || countdown!.isEmpty)
        ? null
        : countdown;
    return Semantics(
      container: true,
      label: extra == null ? label : '$label, $extra',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DabblerIconTile.tinted(
              DabblerIcon(icon, size: DabblerSizing.iconSm, color: tint),
              color: tint,
              size: DabblerSpacing.space10,
            ),
            const SizedBox(width: DabblerSpacing.space3),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: DabblerType.footnote
                        .resolveForDirection(dir)
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                  ),
                  if (extra != null)
                    Text(
                      extra,
                      style: DabblerType.caption1
                          .resolveForDirection(dir)
                          .copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
