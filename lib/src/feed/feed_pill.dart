import 'package:flutter/widgets.dart';

import '../interaction/expanded_hit_area.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_hue_tone.dart';
import '../tokens/dabbler_type.dart';

/// FeedPill — the post row's outlined pill: the sport tag (`Home Feed.dc.html`
/// sport pill, `p.sportEmoji` + `p.sport`), the place and vibe tags, and the
/// vibe chips under a post (KAN-963).
///
/// Extracted from [DabblerPostRow]'s private pill, so every pill on a post is
/// one widget with one set of metrics:
///
/// | | drawn ([DabblerFeedMetrics.drawn]) | touch (default) |
/// | --- | --- | --- |
/// | height | at least `DabblerHomeFrame.sportPillHeight` (32), content centred | content |
/// | padding (start, block, end) | `space3`, `sportPillPaddingBlock`, `sportPillPaddingEnd`, each plus the 1px border | `space3`, `space2`, `space4` |
/// | leading gap | `sportPillGap` | `space2` |
/// | label | `caption1` (12/16), one line, ellipsis | same |
/// | border | 1px `borderDefault`, pill radius | same |
///
/// ## Emoji
///
/// [emoji] is drawn at `subheadline` (15/20) before the label, as the design's
/// `p.sportEmoji` (`<span style="font-size:15px;line-height:20px">`).
/// **Documented exception to the no-emoji rule**, granted by the CEO on
/// 2026-11-16 (KAN-963: "same size and shape as the sport chip, coloured, plus
/// the emoji from the DB for each vibe"), for this pill only. The emoji is
/// data (the sport table's or `public.vibes.emoji`); none is named here.
/// Decorative: the label carries the accessible name. [leading] (a glyph
/// widget) is drawn instead when [emoji] is null.
///
/// ## Tint and selected
///
/// [tint] is a colour that comes from data (a vibe's `color_hex`, parsed with
/// [DabblerHueTone.parseHex]). The pill takes the [DabblerHueTone] of its hue:
///
/// | | fill | border | label |
/// | --- | --- | --- | --- |
/// | tinted | `surface` | `edge` | `deep` |
/// | tinted, [selected] | `edge` | `deep` | `deep` |
/// | neutral (no or achromatic tint) | none | `borderDefault` | `textSecondary` |
/// | neutral, [selected] | brand at 12% over `surfaceCard` | `brandPrimary` | `textPrimary` |
///
/// **Pastels only** (CEO 2026-11-16, KAN-963: "not good for solid colour,
/// should be pastels only"): no state is a solid fill. The tone is built from
/// the input's hue alone at fixed OKLCH lightness and chroma, so an input that
/// is already pastel draws the same pastel. Selected ("mine") is the slightly
/// deeper pastel `edge` (L 0.882) with the hue's `deep` (L 0.42) border and
/// label, readable on both pastels; the neutral pill selects to the same rule
/// in the brand hue ([DabblerHueTone.ramp]). The border is always drawn and
/// keeps its width, so selecting never changes the pill's size.
///
/// ## Tap
///
/// With [onTap] the pill is a button, hit from at least
/// [DabblerSizing.touchTargetMin] square around it (hit-test only, see
/// [DabblerExpandedHitArea]); without it the pill takes no taps.
class DabblerFeedPill extends StatelessWidget {
  /// A pill.
  const DabblerFeedPill({
    super.key,
    required this.label,
    this.emoji,
    this.leading,
    this.tint,
    this.selected = false,
    this.onTap,
    this.semanticLabel,
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// The text, already localised ("Football", "Inspired 3").
  final String label;

  /// An emoji before the label, drawn at 15/20; wins over [leading].
  final String? emoji;

  /// A glyph widget before the label when there is no [emoji].
  final Widget? leading;

  /// The data colour the pill is tinted with; null draws the neutral pill.
  final Color? tint;

  /// Whether this is the viewer's own (the stronger, filled state).
  final bool selected;

  /// Taps; null makes the pill inert.
  final VoidCallback? onTap;

  /// The accessible name; defaults to [label].
  final String? semanticLabel;

  /// [DabblerFeedMetrics.drawn] lays the pill out as the Home Feed frame.
  final DabblerFeedMetrics metrics;

  /// The brand as a pastel tone, for a neutral pill's selected state.
  static DabblerHueTone _brandTone(DabblerColors colors) => DabblerHueTone.ramp(
    base: colors.brandPrimary,
    deep: colors.brandPrimary,
    card: colors.surfaceCard,
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final bool drawn = metrics == DabblerFeedMetrics.drawn;
    final DabblerHueTone? tone = tint == null
        ? null
        : DabblerHueTone.fromColor(tint!);

    final Color? fill = tone != null
        ? (selected ? tone.edge : tone.surface)
        : (selected ? _brandTone(colors).surface : null);
    final Color border = tone != null
        ? (selected ? tone.deep : tone.edge)
        : (selected ? colors.brandPrimary : colors.borderDefault);
    final Color ink = tone != null
        ? tone.deep
        : (selected ? colors.textPrimary : colors.textSecondary);

    final Widget? lead = emoji != null
        ? ExcludeSemantics(
            child: Text(
              emoji!,
              style: DabblerType.subheadline.resolveForDirection(dir),
            ),
          )
        : leading;

    final Widget content = Padding(
      padding: drawn
          ? const EdgeInsetsDirectional.fromSTEB(
              DabblerSpacing.space3 + DabblerSizing.borderDefault,
              DabblerHomeFrame.sportPillPaddingBlock +
                  DabblerSizing.borderDefault,
              DabblerHomeFrame.sportPillPaddingEnd +
                  DabblerSizing.borderDefault,
              DabblerHomeFrame.sportPillPaddingBlock +
                  DabblerSizing.borderDefault,
            )
          : const EdgeInsetsDirectional.fromSTEB(
              DabblerSpacing.space3,
              DabblerSpacing.space2,
              DabblerSpacing.space4,
              DabblerSpacing.space2,
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (lead != null) ...<Widget>[
            // The neutral pill leaves a glyph's own colour alone (as the sport
            // tag always drew it); a tinted or selected one inks it.
            if (tone == null && !selected)
              lead
            else
              IconTheme.merge(
                data: IconThemeData(color: ink),
                child: lead,
              ),
            SizedBox(
              width: drawn
                  ? DabblerHomeFrame.sportPillGap
                  : DabblerSpacing.space2,
            ),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DabblerType.caption1
                  .resolveForDirection(dir)
                  .copyWith(color: ink),
            ),
          ),
        ],
      ),
    );

    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(color: border, width: DabblerSizing.borderDefault),
      ),
      // At the drawing's 32 the pill centres its content in a minimum-height
      // box, so a 12px glyph in place of the emoji keeps the pill's height.
      child: drawn
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DabblerHomeFrame.sportPillHeight,
              ),
              child: Center(widthFactor: 1, child: content),
            )
          : content,
    );

    if (onTap == null) return pill;
    return DabblerExpandedHitArea(
      minimum: const Size(
        DabblerSizing.touchTargetMin,
        DabblerSizing.touchTargetMin,
      ),
      child: Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: pill,
        ),
      ),
    );
  }
}
