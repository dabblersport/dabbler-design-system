import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_type.dart';

/// ActionRow — one action in a sheet: a leading glyph, the action's name and a
/// one-line note under it, on a sunken tile.
///
/// Transcribed from `Home Feed.dc.html` `:450-461` (the "Post options" sheet):
/// `display:flex; gap:12px; padding:14px 15px; border-radius:--radius-lg;
/// background:--surface-sunken`, a 20px glyph, the label 15/20 and the note
/// 12/16 `--muted`. A destructive row draws glyph and label in the error ink.
///
/// | Design | Dart |
/// | --- | --- |
/// | tile `--surface-sunken`, radius lg | [DabblerSurface] filled `surfaceSunken`, `lg` |
/// | padding 14 / 15 | `space4` block, `space5` inline (nearest steps) |
/// | glyph 20, gap 12 | [glyphSize], `space4` |
/// | label `--ink`, or `--color-status-error-strong` | `subheadline`, `textPrimary` / `error.strong` |
/// | note 12/16 `--muted` | `caption1`, `textSecondary` |
///
/// RTL: the glyph leads and the text follows it; insets are directional.
///
/// Accessibility: the whole tile is one button named by [label] and [note].
class DabblerActionRow extends StatelessWidget {
  /// An action row.
  const DabblerActionRow({
    super.key,
    required this.icon,
    required this.label,
    this.note,
    this.destructive = false,
    this.onTap,
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// [DabblerFeedMetrics.drawn] draws the row as the Home Feed's post-options
  /// sheet does (`home-design-measure.md` section 9a): 14 above and below, a 1
  /// gap between label and note and no hairline — a flat sunken fill — so a row
  /// with a note is 65 high. Default [DabblerFeedMetrics.touch] is unchanged.
  final DabblerFeedMetrics metrics;

  /// The kebab-case Iconsax name.
  final String icon;

  /// The action's name.
  final String label;

  /// A line under the name; none is drawn when null.
  final String? note;

  /// Draws glyph and label in the error ink.
  final bool destructive;

  /// Runs the action. Null leaves the row inert.
  final VoidCallback? onTap;

  /// The glyph's side — `size="20"` (`:453`).
  static const double glyphSize = 20;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final Color ink = destructive ? colors.error.strong : colors.textPrimary;
    final bool drawn = metrics == DabblerFeedMetrics.drawn;
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: note == null ? label : '$label. $note',
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.lgAll,
      child: DabblerSurface(
        fill: colors.surfaceSunken,
        radius: DabblerRadius.lg,
        borderWidth: drawn ? 0 : null,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: DabblerSpacing.space5,
          vertical: drawn
              ? DabblerHomeFrame.actionRowPaddingBlock
              : DabblerSpacing.space4,
        ),
        child: Row(
          children: <Widget>[
            DabblerIcon(icon, size: glyphSize, color: ink),
            const SizedBox(width: DabblerSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: t(DabblerType.subheadline).copyWith(color: ink),
                  ),
                  if (note != null && drawn)
                    const SizedBox(height: DabblerHomeFrame.actionRowTextGap),
                  if (note != null)
                    Text(
                      note!,
                      style: t(
                        DabblerType.caption1,
                      ).copyWith(color: colors.textSecondary),
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
