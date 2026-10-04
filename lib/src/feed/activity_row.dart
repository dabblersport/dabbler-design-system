import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart' show DabblerAvatar, DabblerAvatarGroup;
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../interaction/expanded_hit_area.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// The leading tile of a system activity (a venue, a notice): a 40px rounded
/// tile holding one bold brand-coloured glyph.
///
/// `Home Feed.dc.html:353-357` — `40x40`, `--radius-lg`, `--surface-card`
/// fill, 1px `--outline-card`, `--color-brand-primary` glyph at 20, bold.
/// Pass it as [DabblerActivityRow.leading]; a person is a [DabblerAvatar]
/// (`size: sm`) and a group a [DabblerAvatarGroup], both from the barrel.
class DabblerActivitySystemTile extends StatelessWidget {
  /// A tile drawing the kebab-case Iconsax [icon].
  const DabblerActivitySystemTile(
    this.icon, {
    super.key,
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// The kebab-case Iconsax name.
  final String icon;

  /// [DabblerFeedMetrics.drawn] draws the tile at the frame's measured 42
  /// ([DabblerHomeFrame.activityTile]: 40 plus the hairline).
  final DabblerFeedMetrics metrics;

  /// The tile's side — `width:40px;height:40px`.
  static const double size = 40;

  /// The glyph's side — `size="20"`.
  static const double glyphSize = 20;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return ExcludeSemantics(
      child: Container(
        width: metrics == DabblerFeedMetrics.drawn
            ? DabblerHomeFrame.activityTile
            : size,
        height: metrics == DabblerFeedMetrics.drawn
            ? DabblerHomeFrame.activityTile
            : size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: DabblerRadius.lgAll,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
        ),
        child: DabblerIcon(
          icon,
          size: glyphSize,
          weight: DabblerIconWeight.bold,
          color: colors.brandPrimary,
        ),
      ),
    );
  }
}

/// A group heading in the Active tab: a label and a hairline running to the end
/// (`Home Feed.dc.html:343-346`).
///
/// | Design | Dart |
/// | --- | --- |
/// | `padding:18px 0 9px`, `gap:9px` | `space6` top, `space3` bottom and gap |
/// | label 12/16 `--muted`, `labelColor` | `caption1`; `textSecondary`, or `success.strong` when [live] |
/// | `flex:1;height:1px;background:--faint` | `bgTertiary`, 1px |
///
/// `g.labelColor` is computed in the truncated script; the live tint is
/// inferred (the first group, "Happening now", is the live one).
class DabblerActivityGroupHeader extends StatelessWidget {
  /// A heading reading [label].
  const DabblerActivityGroupHeader(
    this.label, {
    super.key,
    this.live = false,
    this.count,
    this.dense = false,
  });

  /// The heading text.
  final String label;

  /// Whether the group is the live one (tints the label with the success ink).
  final bool live;

  /// The group's size, drawn between the label and the hairline — `3 items`
  /// (`Notifications.dc.html:111`, 11/14 semibold `--subtle`). Null omits it.
  final String? count;

  /// The tighter heading of `Notifications.dc.html:109` — `padding:9px 0 3px`
  /// instead of the Home Feed's `18px 0 9px`.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: dense ? DabblerSpacing.space3 : DabblerSpacing.space6,
        bottom: dense ? DabblerSpacing.space1 : DabblerSpacing.space3,
      ),
      child: Row(
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: DabblerType.caption1
                  .resolveForDirection(dir)
                  .copyWith(
                    color: live ? colors.success.strong : colors.textSecondary,
                  ),
            ),
          ),
          if (count != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space3),
            Text(
              count!,
              maxLines: 1,
              softWrap: false,
              style: DabblerType.caption1
                  .resolveForDirection(dir)
                  .copyWith(
                    color: colors.textTertiary,
                    fontSize: 11,
                    height: 14 / 11,
                  ),
            ),
          ],
          const SizedBox(width: DabblerSpacing.space3),
          Expanded(
            child: ExcludeSemantics(
              child: SizedBox(
                height: DabblerSizing.borderDefault,
                child: ColoredBox(color: colors.bgTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ActivityRow — one entry in the Home Feed's Active tab: who, what, where and
/// when, with an optional action pill and a Live or sport badge.
///
/// Transcribed from the Claude Design file `Home Feed.dc.html` (DesignSync,
/// fetched 2026-10-03 and truncated at the tool's 256 KiB cap — the markup is
/// complete; the script ends mid-array). The row is the markup at lines
/// 348-401 of that file; the ACTIVITY sample data is at `:2590-2613`.
///
/// | Design (`Home Feed.dc.html`) | Dart |
/// | --- | --- |
/// | `:348` card `gap:12px; padding:12px 12px; radius:24px; 1px --neutral-300; bg --neutral-50; margin-bottom:4px` | `space4`, `space4`, `DabblerRadius.xxl`, `borderDefault`, `surfaceGrey`, `space1` |
/// | `:351` person avatar `sm` 36px; `:354` group `sm max=3`; `:356` system tile 40px | [leading] ([DabblerAvatar], [DabblerAvatarGroup], [DabblerActivitySystemTile]) |
/// | `:361` text column `gap:3px` | `space1` |
/// | `:362-365` actor 15/20 `--ink`, verb 15/20 `--muted`, `gap:5px` | one `subheadline` run: `textPrimary` actor, `textSecondary` verb |
/// | `:368` subject 15/20 `--ink-soft` | `subheadline`, `textSecondary` |
/// | `:370-382` meta `gap:5px`, 13px `--subtle` icons, 12/16, 3px dots | wrap, `space2`, icon 13 `textTertiary`, `caption1`, 3px dot |
/// | `:384` action row `margin-top:9px; gap:9px` | `space3` of space around the 45px box |
/// | `:386` action pill `height:33; padding:0 15; 13/18; 1px border` | 33 high, `space5`, `footnote`, `borderDefault` |
/// | `:389` count 12/16 `--muted` | `caption1`, `textSecondary` |
/// | `:393` Live badge 3/9/3/7, `gap:5`, 11/13, 6px dot, `--color-status-success-*` | [DabblerBadge] `status: success` with a 6px dot |
/// | `:398` sport badge 3/10, 11/13, 1px `--outline-card`, `--ink-soft` | [DabblerBadge] neutral status |
///
/// ## Deviations (recorded, not silent)
///
/// * **Card fill and border.** `--neutral-50` and `--neutral-300` are not DS
///   tokens; the nearest roles are `surfaceGrey` (`#F5F5F5`) and
///   `borderDefault`. The design's own markup overrides the system card
///   (`surfaceCard` / `borderDefault`) with them (`:348`).
/// * **Action pill tones.** `a.actionBg/Fg/Border` (`:386`) are computed in the
///   truncated script; only `tone: 'filled' | 'outlined'` is readable
///   (`:2594-2611`). Filled is `brandPrimary` with `onBrand` ink; outlined is
///   unfilled with `textPrimary` ink and a `borderDefault` outline.
/// * **Badges.** [DabblerBadge] is 4/10 padded and bold; the design's are 3/9 and
///   regular. The Live badge takes `space3` (9) inline padding; the sport
///   badge's ink is `textPrimary` (the neutral status) where the design uses
///   `--ink-soft`.
/// * **45px action.** The 33px pill sits in a 45px hit box; the 9px top margin
///   becomes 3px plus the box's 6px inset, so the painted pill is where the
///   design puts it.
/// * **Spacing steps.** 5px gaps take 6.
///
/// ## Not readable
///
/// `a.actionBg`, `a.actionFg`, `a.actionBorder`, `g.labelColor`, `a.hasAction`
/// and `a.hasCount` live in the truncated script; the `cat` field of the
/// sample data (`Following`, `Venues`, `Games`) drives the tab's filter rail,
/// which is not part of this row.
///
/// RTL: the leading widget starts the row and the badges end it; the wrap
/// reflows. Times, distances and counts are rewritten to Western digits.
///
/// Accessibility: the row is one group named from its text; the action is its
/// own button; with [onTap] the row is also a button. Glyphs are decoration.
class DabblerActivityRow extends StatelessWidget {
  /// An activity row.
  const DabblerActivityRow({
    super.key,
    required this.leading,
    required this.actor,
    this.verb,
    this.subject,
    this.place,
    this.when,
    this.distance,
    this.actionLabel,
    this.actionFilled = false,
    this.onAction,
    this.count,
    this.live = false,
    this.liveLabel = 'Live',
    this.sportLabel,
    this.thumbnail,
    this.onTap,
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// [DabblerFeedMetrics.drawn] lays the card out as the frame measures it
  /// (`home-design-measure.md` section 7b): 5 gaps in the actor and meta
  /// lines, the meta line 2 lower, a 9 gap above a 35 high action pill that
  /// lays out at its own size (the 45 target is hit-test only), 3/10 sport
  /// badges and a 4 margin under the card.
  final DabblerFeedMetrics metrics;

  bool get _drawn => metrics == DabblerFeedMetrics.drawn;

  /// The leading widget: a [DabblerAvatar], [DabblerAvatarGroup] or
  /// [DabblerActivitySystemTile].
  final Widget leading;

  /// Who did it (`Aisha and 3 others`), in primary ink.
  final String actor;

  /// What they did (`are playing right now`), in secondary ink.
  final String? verb;

  /// What it was about.
  final String? subject;

  /// Where — the location glyph is drawn with it.
  final String? place;

  /// When, already formatted — the clock glyph is drawn with it.
  final String? when;

  /// How far, already formatted.
  final String? distance;

  /// The action pill's text; the pill is omitted when null.
  final String? actionLabel;

  /// Filled (brand) when true, outlined when false.
  final bool actionFilled;

  /// Runs the action.
  final VoidCallback? onAction;

  /// The count beside the action (`2 spots left`), already localised.
  final String? count;

  /// Whether the Live badge is drawn.
  final bool live;

  /// The Live badge's text.
  final String liveLabel;

  /// The sport badge's text; omitted when null.
  final String? sportLabel;

  /// An optional cover or thumbnail, drawn at the end of the row in a 40px
  /// rounded box (the media component, or any widget that fills its box).
  final Widget? thumbnail;

  /// Size of the [thumbnail] box.
  static const double thumbnailSide = 40;

  /// Opens the activity. Null leaves the row inert.
  final VoidCallback? onTap;

  /// Meta glyph side — `size="13"` (`:371`).
  static const double metaGlyphSize = 13;

  /// Separator dot — `width:3px;height:3px` (`:373`).
  static const double dotSize = 3;

  /// Action pill height — `height:33px` (`:386`).
  static const double actionHeight = 33;

  /// Live dot — `width:6px;height:6px` (`:394`).
  static const double liveDotSize = 6;

  /// Inset on all sides — `padding:12px` (`:348`), `space4`.
  static const double padding = DabblerSpacing.space4;

  Widget _dot(DabblerColors colors) => ExcludeSemantics(
    child: Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.textTertiary,
      ),
    ),
  );

  Widget _glyph(String name, DabblerColors colors) => ExcludeSemantics(
    child: DabblerIcon(name, size: metaGlyphSize, color: colors.textTertiary),
  );

  /// The action pill. Touch: a 45 box in layout. Drawn: the pill at its own
  /// size with the 45 as a hit-test-only area *around* its gesture.
  Widget _action(DabblerColors colors, TextStyle Function(DabblerTypeStyle) t) {
    final Widget pill = Container(
      height: _drawn ? DabblerHomeFrame.activityActionHeight : actionHeight,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal:
            DabblerSpacing.space5 + (_drawn ? DabblerSizing.borderDefault : 0),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: actionFilled ? colors.brandPrimary : null,
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(
          color: actionFilled ? colors.brandPrimary : colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Text(
        actionLabel!,
        maxLines: 1,
        style: t(
          DabblerType.footnote,
        ).copyWith(color: actionFilled ? colors.onBrand : colors.textPrimary),
      ),
    );
    final Widget tappable = DabblerFeedTappable(
      onTap: onAction,
      semanticLabel: actionLabel,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.pillAll,
      child: _drawn
          ? pill
          : ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DabblerSizing.touchTargetMin,
                minWidth: DabblerSizing.touchTargetMin,
              ),
              child: Center(widthFactor: 1, heightFactor: 1, child: pill),
            ),
    );
    return _drawn
        ? DabblerExpandedHitArea(
            minimum: const Size.square(DabblerSizing.touchTargetMin),
            child: tappable,
          )
        : tappable;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final TextStyle sub = t(DabblerType.subheadline);
    final TextStyle caption = t(
      DabblerType.caption1,
    ).copyWith(color: colors.textSecondary);

    final List<Widget> metaItems = <Widget>[
      if (place != null) ...<Widget>[
        _glyph('location', colors),
        Text(place!, style: caption),
      ],
      if (when != null) ...<Widget>[
        if (place != null) _dot(colors),
        _glyph('clock', colors),
        Text(DabblerType.toWesternDigits(when!), style: caption),
      ],
      if (distance != null) ...<Widget>[
        if (place != null || when != null) _dot(colors),
        Text(DabblerType.toWesternDigits(distance!), style: caption),
      ],
    ];

    final Widget? actionRow = (actionLabel == null && count == null)
        ? null
        : Wrap(
            spacing: DabblerSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (actionLabel != null) _action(colors, t),
              if (count != null)
                Text(DabblerType.toWesternDigits(count!), style: caption),
            ],
          );

    final Widget textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: actor,
                style: TextStyle(color: colors.textPrimary),
              ),
              if (verb != null)
                TextSpan(
                  text: ' $verb',
                  style: TextStyle(color: colors.textSecondary),
                ),
            ],
          ),
          style: sub,
        ),
        if (subject != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space1),
          Text(subject!, style: sub.copyWith(color: colors.textSecondary)),
        ],
        if (metaItems.isNotEmpty) ...<Widget>[
          SizedBox(
            height: _drawn
                ? DabblerSpacing.space1 + DabblerHomeFrame.activityMetaLift
                : DabblerSpacing.space1,
          ),
          Wrap(
            spacing: _drawn
                ? DabblerHomeFrame.activityGap
                : DabblerSpacing.space2,
            runSpacing: _drawn
                ? DabblerHomeFrame.activityGap
                : DabblerSpacing.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: metaItems,
          ),
        ],
        if (actionRow != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: _drawn ? DabblerSpacing.space3 : DabblerSpacing.space1,
            ),
            child: _drawn
                ? DabblerExpandedHitArea(
                    minimum: const Size(0, DabblerSizing.touchTargetMin),
                    child: actionRow,
                  )
                : actionRow,
          ),
      ],
    );

    final Widget card = Container(
      margin: EdgeInsetsDirectional.only(
        bottom: _drawn
            ? DabblerHomeFrame.activityMarginBottom
            : DabblerSpacing.space1,
      ),
      padding: const EdgeInsetsDirectional.all(padding),
      decoration: BoxDecoration(
        color: colors.surfaceGrey,
        borderRadius: DabblerRadius.xxlAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          leading,
          const SizedBox(width: DabblerSpacing.space4),
          Expanded(child: textColumn),
          if (live) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space4),
            DabblerBadge(
              label: liveLabel,
              status: colors.success,
              paddingInline: DabblerSpacing.space3,
              icon: Container(
                width: liveDotSize,
                height: liveDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.success.base,
                ),
              ),
            ),
          ],
          if (sportLabel != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space4),
            DabblerBadge(
              label: sportLabel!,
              status: DabblerBadge.neutralStatusOf(colors),
              metrics: metrics,
              // `padding:3px 10px` inside a hairline: 21 high in all.
              paddingBlock: _drawn ? DabblerSpacing.space1 : null,
            ),
          ],
          if (thumbnail != null) ...<Widget>[
            const SizedBox(width: DabblerSpacing.space4),
            ClipRRect(
              borderRadius: DabblerRadius.mdAll,
              child: SizedBox(
                width: thumbnailSide,
                height: thumbnailSide,
                child: ColoredBox(
                  color: colors.surfaceSunken,
                  child: thumbnail,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return DabblerFeedTappable(
      onTap: onTap,
      borderRadius: DabblerRadius.xxlAll,
      child: card,
    );
  }
}
