import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'detail_page.dart';

/// The decorative tile a [DabblerDetailHeader] can be painted in instead of a
/// section theme — the meetup frame's amber band (`Details.dc.html:218`,
/// `background: var(--tile-amber-surface)`).
enum DabblerDetailHeaderTile {
  /// `--tile-amber-surface`.
  amber,

  /// `--tile-info-surface`.
  info,

  /// `--tile-accent-surface`.
  accent,
}

/// DetailHeader — the coloured band that opens a detail screen: a row of round
/// buttons, a wrap of caption pills, the title, and a place line.
///
/// Drawn from the game-details hero, `Details.dc.html:46-77`: a full-width
/// `--sport-p-600` band padded `18 18 24` under the status bar, a back button
/// on the inline start with favourite and share on the inline end (40px
/// translucent circles), 15 below them a column of 9 — a wrap of translucent pills
/// (`rgba(255,255,255,0.2)`, 11/15 bold, 4/10), the 34/40 display title, and a
/// place row (location glyph, a 13/18 600 place, a 3px dot, a 13/18 distance in
/// 78% on-colour).
///
/// ```dart
/// DabblerDetailHeader(
///   leading: DabblerOnColorIconButton(
///     icon: 'arrow-circle-left',
///     mirrorInRtl: true,
///     semanticLabel: 'Back',
///     onPressed: back,
///   ),
///   actions: <Widget>[ ... ],
///   chips: const <String>['Upcoming', 'Football'],
///   title: 'Tuesday 5-a-side',
///   place: 'Dubai Sports City',
/// )
/// ```
///
/// ## The band's colour
///
/// [theme] chooses which section theme the band is painted in — the design
/// uses the sport theme's brand (`--sport-p-600`) for a game. The **whole
/// band's subtree** is re-themed to it, so a [DabblerOnColorIconButton] or a
/// `DabblerText` with the on-brand tone placed in [leading] or [actions] takes
/// that theme's on-colour with no colour argument.
///
/// ## Slots
///
/// * [leading] / [actions] — the buttons, built by the caller (normally
///   [DabblerOnColorIconButton]).
/// * [chips] — plain strings; the band draws them as translucent pills.
/// * [title], [place], [meta] — text. [meta] is the dimmer second fact after
///   the dot ("2.1 km away").
///
/// ## Safe area
///
/// The band pads the status-bar inset itself so it can bleed under it; pair it
/// with a page whose top bar is empty ([DabblerDetailPage] does).
///
/// ## Type
///
/// Title — `largeTitle` (34/40, display). Place — `footnote` (13/18) at weight
/// 600. Meta — `footnote` regular. Pills — `caption2` (11/15) bold.
///
/// ## RTL
///
/// The band is a column of rows, so the buttons, pills and place line all
/// start at the inline start; the glyph in the place row sits before the text
/// in either direction.
class DabblerDetailHeader extends StatelessWidget {
  /// A detail header.
  const DabblerDetailHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.chips = const <String>[],
    this.place,
    this.meta,
    this.extra,
    this.theme = DabblerTheme.sport,
    this.tile,
  });

  /// The title, in the display face. Up to two lines.
  final String title;

  /// The inline-start button — back.
  final Widget? leading;

  /// The inline-end buttons — favourite, share.
  final List<Widget> actions;

  /// The translucent pills above the title.
  final List<String> chips;

  /// The place line's main text, with a location glyph before it.
  final String? place;

  /// The dimmer fact after the place, after a dot.
  final String? meta;

  /// A third fact after [meta], in the full ink and weight 600 — the meetup
  /// frame's `Today 6:00 AM` (`Details.dc.html:236`).
  final String? extra;

  /// The section theme the band is painted in. Defaults to
  /// [DabblerTheme.sport]. Ignored when [tile] is set.
  final DabblerTheme theme;

  /// Paints the band in a decorative tile instead of [theme]: the page's own
  /// ink sits on it, the pills are the ink at [tileWashAlpha], and the place
  /// row is the ink at [tileMetaAlpha]. Pair its buttons with
  /// [DabblerOnColorIconButton.onTile]. Null keeps the themed band.
  final DabblerDetailHeaderTile? tile;

  /// The pills' wash over the ink on a tile band — `rgba(20,20,20,0.1)`
  /// (`Details.dc.html:233`).
  static const double tileWashAlpha = 0.1;

  /// The place row's ink alpha on a tile band — `rgba(20,20,20,0.7)`
  /// (`Details.dc.html:233`).
  static const double tileMetaAlpha = 0.7;

  /// The separator dot's alpha on a tile band — `rgba(20,20,20,0.4)`.
  static const double tileDotAlpha = 0.4;

  /// The translucent pills' fill alpha over the on-colour — `0.2`.
  static const double chipAlpha = 0.2;

  /// The meta text's alpha over the on-colour — `0.78`.
  static const double metaAlpha = 0.78;

  /// The dot between place and meta — `3`.
  static const double dotSize = DabblerSpacing.space1;

  @override
  Widget build(BuildContext context) {
    final DabblerColors outer = DabblerColors.of(context);
    final DabblerColors band = tile != null
        ? outer
        : DabblerColors.resolve(theme: theme, brightness: outer.brightness);
    final DabblerToneColor? tileTone = switch (tile) {
      DabblerDetailHeaderTile.amber => DabblerColors.tileAmber,
      DabblerDetailHeaderTile.info => DabblerColors.tileInfo,
      DabblerDetailHeaderTile.accent => DabblerColors.tileAccent,
      null => null,
    };
    final double wash = tileTone == null ? chipAlpha : tileWashAlpha;
    final double metaA = tileTone == null ? metaAlpha : tileMetaAlpha;
    final double dotA = tileTone == null ? 0.5 : tileDotAlpha;
    final TextDirection direction = Directionality.of(context);
    final double top = MediaQuery.paddingOf(context).top;
    final Color on = tileTone == null ? band.onBrand : band.textPrimary;

    final Widget buttons = Row(
      children: <Widget>[
        ?leading,
        const Spacer(),
        for (int i = 0; i < actions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: DabblerSpacing.space3),
          actions[i],
        ],
      ],
    );

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buttons,
        const SizedBox(height: DabblerSpacing.space5),
        if (chips.isNotEmpty) ...<Widget>[
          Wrap(
            spacing: DabblerSpacing.space2,
            runSpacing: DabblerSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final String c in chips)
                DabblerSurface(
                  fill: on.withValues(alpha: wash),
                  borderColor: on.withValues(alpha: 0),
                  borderWidth: 0,
                  radius: DabblerRadius.pill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DabblerSpacing.space3 + 1,
                    vertical: DabblerSpacing.space1 + 1,
                  ),
                  child: Text(
                    c,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.caption2
                        .resolveForDirection(direction)
                        .copyWith(color: on, fontWeight: DabblerType.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DabblerSpacing.space3),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: DabblerType.largeTitle
              .resolveForDirection(direction)
              .copyWith(color: on),
        ),
        if (place != null || meta != null || extra != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space3),
          Row(
            children: <Widget>[
              if (place != null) ...<Widget>[
                ExcludeSemantics(
                  child: DabblerIcon(
                    'location',
                    size: DabblerSizing.iconXs + 2,
                    color: on.withValues(alpha: metaA),
                  ),
                ),
                const SizedBox(width: DabblerSpacing.space1 + 2),
                Flexible(
                  child: Text(
                    place!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.footnote
                        .resolveForDirection(direction)
                        .copyWith(color: on, fontWeight: DabblerType.semibold),
                  ),
                ),
              ],
              if (place != null && meta != null) ...<Widget>[
                const SizedBox(width: DabblerSpacing.space2),
                SizedBox.square(
                  dimension: dotSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on.withValues(alpha: dotA),
                    ),
                  ),
                ),
                const SizedBox(width: DabblerSpacing.space2),
              ],
              if (meta != null)
                Flexible(
                  child: Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.footnote
                        .resolveForDirection(direction)
                        .copyWith(color: on.withValues(alpha: metaA)),
                  ),
                ),
              if (extra != null) ...<Widget>[
                if (place != null || meta != null) ...<Widget>[
                  const SizedBox(width: DabblerSpacing.space2),
                  SizedBox.square(
                    dimension: dotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: on.withValues(alpha: dotA),
                      ),
                    ),
                  ),
                  const SizedBox(width: DabblerSpacing.space2),
                ],
                Flexible(
                  child: Text(
                    extra!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.footnote
                        .resolveForDirection(direction)
                        .copyWith(color: on, fontWeight: DabblerType.semibold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );

    return Theme(
      data: ThemeData(
        brightness: outer.brightness,
        extensions: <DabblerColors>[band],
      ),
      child: ColoredBox(
        color: tileTone?.surface ?? band.brandPrimary,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            DabblerSpacing.space6,
            top + DabblerSpacing.space6,
            DabblerSpacing.space6,
            DabblerSpacing.space8,
          ),
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DabblerDetailPage.maxContentWidth,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
