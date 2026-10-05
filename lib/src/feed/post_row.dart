import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../interaction/expanded_hit_area.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_home_frame.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';
import 'post_detail.dart';

/// One run of a [DabblerPostRow]'s body text. A [link] run (a `#hashtag` or an
/// `@mention`) is drawn in the brand colour; the run's own tap is not exposed —
/// the row's [DabblerPostRow.onTap] is the navigation seam.
@immutable
class DabblerPostSegment {
  /// A run of body text.
  const DabblerPostSegment(this.text, {this.link = false});

  /// The run's text.
  final String text;

  /// Whether the run is a hashtag or mention, drawn in `brandPrimary`.
  final bool link;
}

/// PostRow — one post in the Home Feed list: avatar, author line, time and
/// place, body, sport pill and the like / vibe / reply / share / more actions.
///
/// Transcribed from the Claude Design file `Home Feed.dc.html` (DesignSync,
/// fetched 2026-10-03 and truncated at the tool's 256 KiB cap — the markup is
/// complete; the script ends mid-array, see "Not readable" below). The row is
/// the markup at lines 285-338 of that file. Design values are quoted against
/// the file's line numbers.
///
/// | Design (`Home Feed.dc.html`) | Dart |
/// | --- | --- |
/// | `:286` row `gap:12px; padding:15px 0; border-bottom 1px --faint` | `space4`, `space5`, `bgTertiary` at `borderDefault` width ([divider]) |
/// | `:288` avatar `size="sm"` 36px | [DabblerAvatar] `sm`, seeded by [seed] or [name] |
/// | `:290` column `gap:6px` | `space2` |
/// | `:292` name 15/20 `--ink` ellipsis | `subheadline`, `textPrimary`, one line |
/// | `:293` 3px dot `--subtle`; role 12/16 `--muted` | 3px dot `textTertiary`; `caption1`, `textSecondary` |
/// | `:295` distance pill 2/8, 11/13, `--color-status-info-*` | [DabblerBadge] `status: info`, `paddingInline: space3` (see deviations) |
/// | `:299-305` meta row `gap:5px`, 13px icons `--subtle`, 12/16 `--muted` | `space2`, icon 13 `textTertiary`, `caption1` `textSecondary`; second icon inset `space1` (design 4) |
/// | `:307` body 15/20 `--ink-soft`, `margin:3px 0 0` | `subheadline`, `textSecondary`, `space1` |
/// | `:309-313` sport pill 5/11/5/9, `gap:5px`, 12/16, `--ink-soft`, 1px `--outline-card` | `caption1`, `textSecondary`, `borderDefault`, pill radius, 6 / 12 / 6 / 9 padding |
/// | `:316` actions `gap:18px`, icons 20, counts 12/16 `gap:6px` | [DabblerFeedAction], `space6` rhythm, 20, `caption1`, `space2` |
/// | `:325-326` `more-circle` pushed to the end (`margin-left:auto`) | `Spacer`, mirrors under RTL |
///
/// ## Deviations (recorded, not silent)
///
/// * **Emoji.** The design's `sportEmoji` (`:311`) is not reproduced — the
///   system is Iconsax and tokens only. [sportLeading] is a `Widget` slot for
///   a sport glyph; omitted by default.
/// * **Body colour.** `--ink-soft` resolves to `textSecondary`
///   (`D-003(a)`); `--muted` text resolves to `textSecondary` as well, as in
///   the conversation row. `--subtle` is only used for icons and the dot
///   (`textTertiary`).
/// * **Distance pill.** The design is a 2/8-padded, border-less 11/13 pill;
///   [DabblerBadge] is 4/10, bold, and draws a status hairline. Horizontal
///   padding is `space3` (9, the nearest step to 8).
/// * **Spacing steps.** 5px gaps and the 5/11 pill padding take the nearest
///   steps of the base-3 ramp (6, 12).
/// * **45px targets.** Each action is a [DabblerFeedAction] with a 45px hit
///   box, so the action row is 45 high instead of the design's 20. The
///   design's 6px top margin is dropped (12.5px of box inset replaces it) and
///   the block-end padding is 3 instead of 15; the 18px inter-action gap
///   becomes the 45px boxes' own inset, so icon-only actions sit about 25px
///   apart instead of 18.
/// * **Avatar link and sport pill link** (`:288`, `:309`, which navigate to
///   Profiles / Results) are not exposed: neither reaches 45px without
///   changing the layout. The consumer navigates from [onTap].
/// * **Active colours.** The like / vibe active inks (`p.likeColor`,
///   `p.vibeFg`, `:318`, `:322`) are computed in the truncated script. They
///   are inferred: liked is the `error` status colour (a heart, as in the
///   design's Favourites page), vibed is `brandPrimary`; inactive is
///   `textSecondary`.
/// * **Segments.** `p.parts` (`:307`) is script data that is not readable; it
///   is modelled as [DabblerPostSegment]s, link runs in `brandPrimary`.
///
/// ## Not readable
///
/// `roleLabel`, `p.likeColor`, `p.vibeFg`, `p.parts`, `p.dist`'s computation
/// and `p.open` live in the script that the 256 KiB cap cut off.
///
/// RTL: every inset is directional; the avatar leads, the more action trails
/// and the type resolves to the Arabic metrics. Counts and distances are
/// rewritten to Western digits.
///
/// Accessibility: with [onTap] the row is one button; each action is its own
/// button named from its label and count. The icons are decoration.
class DabblerPostRow extends StatelessWidget {
  /// A post row.
  const DabblerPostRow({
    super.key,
    required this.name,
    this.seed,
    this.roleLabel,
    this.distance,
    required this.time,
    required this.place,
    this.body = '',
    this.segments,
    this.sportLabel,
    this.sportLeading,
    this.showActions = true,
    this.likes = 0,
    this.replies = 0,
    this.liked = false,
    this.vibed = false,
    this.onTap,
    this.onLike,
    this.onVibe,
    this.onComment,
    this.onShare,
    this.onMore,
    this.imageUrl,
    this.onAuthorTap,
    this.authorLabel,
    this.media,
    this.onRepost,
    this.reposts,
    this.reposted = false,
    this.reactions,
    this.kindBadge,
    this.views,
    this.detail,
    this.divider = true,
    this.likeLabel = 'Like',
    this.vibeLabel = 'Vibe',
    this.commentLabel = 'Reply',
    this.shareLabel = 'Share',
    this.moreLabel = 'More options',
    this.repostLabel = 'Repost',
    this.viewsLabel = 'Views',
    this.metrics = DabblerFeedMetrics.touch,
  });

  /// [DabblerFeedMetrics.drawn] lays the row out as the Home Feed frame
  /// measures it (`home-design-measure.md` section 7a): a 2/8 type pill, 5
  /// gaps in the meta row (the pin 4 further in), the sport pill 32 high, and
  /// a 20 high action row — glyphs and counts only, 18 apart — under 12 of
  /// air, with 15 below it. Each action keeps its 45px target as a
  /// hit-test-only area. The default keeps the 45px action boxes in layout.
  final DabblerFeedMetrics metrics;

  bool get _drawn => metrics == DabblerFeedMetrics.drawn;

  /// The author's name.
  final String name;

  /// The avatar seed; falls back to [name].
  final String? seed;

  /// The author's photo. Drawn by [DabblerAvatar] in the same circle; the seed
  /// portrait stands in while it loads, when it is empty and when it fails.
  final String? imageUrl;

  /// Called when the author's avatar or name is tapped — open the author's
  /// profile from here. Null makes both inert. The avatar's tap target is
  /// 36px wide (the design's own link target), taller below it.
  final VoidCallback? onAuthorTap;

  /// The accessible name of the author target; falls back to [name].
  final String? authorLabel;

  /// The post's media (a photo, a carousel), drawn under the body in a rounded
  /// box clipped to the card radius. The caller sizes it (an aspect ratio or a
  /// fixed height); the row adds no image dependency.
  final Widget? media;

  /// Shows the repost action when set; called on tap. The caller decides
  /// whether this post can be reposted.
  final VoidCallback? onRepost;

  /// The repost count beside the action; none is drawn when null.
  final int? reposts;

  /// Whether the viewer has reposted: draws the glyph bold and in the brand
  /// colour.
  final bool reposted;

  /// A summary of reactions drawn under the actions (usually a `Wrap` of
  /// `DabblerChip`s). Null draws nothing.
  final Widget? reactions;

  /// A kind or origin badge (a `DabblerBadge`) drawn at the end of the author
  /// line. Null draws nothing.
  final Widget? kindBadge;

  /// The view count, with an eye glyph after the actions. Null hides it; the
  /// caller decides who sees it (the post's author, usually).
  final int? views;

  /// Open-post extras — full timestamp, edited marker and visibility — drawn
  /// as a [DabblerPostDetailLine] above the actions. Null (the default) leaves
  /// the feed row exactly as it was.
  final DabblerPostDetail? detail;

  /// The author's role, already localised (the design's `roleLabel`).
  final String? roleLabel;

  /// The distance pill, already formatted (`1.1 km`).
  final String? distance;

  /// The post's age, already formatted (`2h`).
  final String time;

  /// Where the post was made.
  final String place;

  /// The body as plain text; ignored when [segments] is given.
  final String body;

  /// The body as runs, with hashtag / mention runs marked as links.
  final List<DabblerPostSegment>? segments;

  /// The sport pill's text; the pill is omitted when null.
  final String? sportLabel;

  /// Whether the action row (like, vibe, reply, share, more) is drawn. Off for
  /// the result lists of `Results.dc.html`, which end on the sport pill.
  final bool showActions;

  /// An optional leading glyph for the sport pill (a widget slot, never emoji).
  final Widget? sportLeading;

  /// The like count.
  final int likes;

  /// The reply count.
  final int replies;

  /// Whether the viewer has liked the post (bold error-coloured heart).
  final bool liked;

  /// Whether the viewer has vibed the post (bold brand-coloured glyph).
  final bool vibed;

  /// Opens the post. Null leaves the row inert.
  final VoidCallback? onTap;

  /// Toggles the like.
  final VoidCallback? onLike;

  /// Opens the vibe picker.
  final VoidCallback? onVibe;

  /// Opens the replies.
  final VoidCallback? onComment;

  /// Shares the post.
  final VoidCallback? onShare;

  /// Opens the post's options.
  final VoidCallback? onMore;

  /// Whether the hairline block-end divider is drawn.
  final bool divider;

  /// Accessible name of the like action.
  final String likeLabel;

  /// Accessible name of the vibe action.
  final String vibeLabel;

  /// Accessible name of the reply action.
  final String commentLabel;

  /// Accessible name of the share action.
  final String shareLabel;

  /// Accessible name of the more action.
  final String moreLabel;

  /// Accessible name of the repost action.
  final String repostLabel;

  /// Accessible name of the view count.
  final String viewsLabel;

  /// Meta-row glyph side — `size="13"` (`:300`).
  static const double metaGlyphSize = 13;

  /// Separator dot — `width:3px;height:3px` (`:293`).
  static const double dotSize = 3;

  /// Block padding — `padding:15px 0` (`:286`), `space5`.
  static const double paddingBlock = DabblerSpacing.space5;

  /// Avatar-to-column gap — `gap:12px` (`:286`), `space4`.
  static const double avatarGap = DabblerSpacing.space4;

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

  Widget _metaGlyph(String name, DabblerColors colors) => ExcludeSemantics(
    child: DabblerIcon(name, size: metaGlyphSize, color: colors.textTertiary),
  );

  /// The sport pill's body: at the drawing's 32 it centres its content in a
  /// minimum-height box, so a 12px glyph in place of the frame's emoji keeps
  /// the pill's height.
  Widget _sportBox(Widget content) => _drawn
      ? ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DabblerHomeFrame.sportPillHeight,
          ),
          child: Center(widthFactor: 1, child: content),
        )
      : content;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final TextStyle caption = t(
      DabblerType.caption1,
    ).copyWith(color: colors.textSecondary);
    final TextStyle bodyStyle = t(
      DabblerType.subheadline,
    ).copyWith(color: colors.textSecondary);

    final Widget nameText = Text(
      name,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: t(DabblerType.subheadline).copyWith(color: colors.textPrimary),
    );
    final Widget header = Row(
      children: <Widget>[
        Flexible(
          child: DabblerFeedTappable(
            onTap: onAuthorTap,
            semanticLabel: authorLabel ?? name,
            excludeChildSemantics: true,
            child: nameText,
          ),
        ),
        if (roleLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          _dot(colors),
          const SizedBox(width: DabblerSpacing.space2),
          Text(roleLabel!, maxLines: 1, style: caption),
        ],
        if (distance != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          DabblerBadge(
            label: DabblerType.toWesternDigits(distance!),
            status: colors.info,
            paddingInline: _drawn
                ? DabblerHomeFrame.postBadgePaddingInline
                : DabblerSpacing.space3,
            paddingBlock: _drawn
                ? DabblerHomeFrame.postBadgePaddingBlock
                : null,
            metrics: metrics,
          ),
        ],
        if (kindBadge != null) ...<Widget>[
          const Spacer(),
          const SizedBox(width: DabblerSpacing.space2),
          kindBadge!,
        ],
      ],
    );

    final Widget meta = Row(
      children: <Widget>[
        _metaGlyph('global', colors),
        SizedBox(
          width: _drawn ? DabblerHomeFrame.postMetaGap : DabblerSpacing.space2,
        ),
        Text(DabblerType.toWesternDigits(time), maxLines: 1, style: caption),
        if (_drawn)
          const SizedBox(
            width:
                DabblerHomeFrame.postMetaGap +
                DabblerHomeFrame.postMetaPinInset,
          )
        else ...<Widget>[
          const SizedBox(width: DabblerSpacing.space1),
          const SizedBox(width: DabblerSpacing.space1),
        ],
        _metaGlyph('location', colors),
        SizedBox(
          width: _drawn ? DabblerHomeFrame.postMetaGap : DabblerSpacing.space2,
        ),
        Flexible(
          child: Text(
            place,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: caption,
          ),
        ),
      ],
    );

    final Widget bodyText = Text.rich(
      TextSpan(
        children: segments == null
            ? <InlineSpan>[TextSpan(text: body)]
            : <InlineSpan>[
                for (final DabblerPostSegment s in segments!)
                  TextSpan(
                    text: s.text,
                    style: s.link
                        ? TextStyle(color: colors.brandPrimary)
                        : null,
                  ),
              ],
      ),
      style: bodyStyle,
    );

    final Widget? sport = sportLabel == null
        ? null
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: DabblerRadius.pillAll,
                border: Border.all(
                  color: colors.borderDefault,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: _sportBox(
                Padding(
                  padding: _drawn
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
                      if (sportLeading != null) ...<Widget>[
                        sportLeading!,
                        SizedBox(
                          width: _drawn
                              ? DabblerHomeFrame.sportPillGap
                              : DabblerSpacing.space2,
                        ),
                      ],
                      Text(sportLabel!, maxLines: 1, style: caption),
                    ],
                  ),
                ),
              ),
            ),
          );

    final Widget actions = Row(
      spacing: _drawn ? DabblerSpacing.space6 : 0,
      children: <Widget>[
        DabblerFeedAction(
          metrics: metrics,
          icon: 'heart',
          count: likes,
          weight: liked ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          color: liked ? colors.error.base : null,
          onTap: onLike,
          semanticLabel: likeLabel,
        ),
        DabblerFeedAction(
          metrics: metrics,
          icon: 'add-square',
          weight: vibed ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          color: vibed ? colors.brandPrimary : null,
          onTap: onVibe,
          semanticLabel: vibeLabel,
        ),
        DabblerFeedAction(
          metrics: metrics,
          icon: 'message-text',
          count: replies,
          onTap: onComment,
          semanticLabel: commentLabel,
        ),
        if (onRepost != null)
          DabblerFeedAction(
            metrics: metrics,
            icon: 'refresh',
            count: reposts,
            weight: reposted
                ? DabblerIconWeight.bold
                : DabblerIconWeight.linear,
            color: reposted ? colors.brandPrimary : null,
            onTap: onRepost,
            semanticLabel: repostLabel,
          ),
        // An inert share is not drawn once the row also carries a repost
        // action: the five actions plus more no longer fit a 360 row at the
        // 45px touch floor.
        if (onShare != null || onRepost == null)
          DabblerFeedAction(
            metrics: metrics,
            icon: 'share',
            onTap: onShare,
            semanticLabel: shareLabel,
          ),
        if (views != null)
          DabblerFeedAction(
            metrics: metrics,
            icon: 'eye',
            count: views,
            semanticLabel: viewsLabel,
          ),
        const Spacer(),
        DabblerFeedAction(
          metrics: metrics,
          icon: 'more-circle',
          onTap: onMore,
          semanticLabel: moreLabel,
        ),
      ],
    );

    final Widget content = DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: colors.bgTertiary,
                  width: DabblerSizing.borderDefault,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: paddingBlock,
          // Drawn: the 15 of padding (plus the hairline the frame's content-
          // box row counts in its own height) closes the content column
          // instead, so the action row's hit area has the room it needs.
          bottom: _drawn ? 0 : DabblerSpacing.space1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DabblerFeedTappable(
              onTap: onAuthorTap,
              semanticLabel: authorLabel ?? name,
              excludeChildSemantics: true,
              borderRadius: DabblerRadius.pillAll,
              child: DabblerAvatar(
                seed: seed ?? name,
                imageUrl: imageUrl,
                size: DabblerAvatarSize.sm,
              ),
            ),
            const SizedBox(width: avatarGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  header,
                  const SizedBox(height: DabblerSpacing.space2),
                  meta,
                  const SizedBox(height: DabblerSpacing.space2),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: DabblerSpacing.space1,
                    ),
                    child: bodyText,
                  ),
                  if (media != null) ...<Widget>[
                    const SizedBox(height: DabblerSpacing.space3),
                    ClipRRect(borderRadius: DabblerRadius.lgAll, child: media),
                  ],
                  if (sport != null) ...<Widget>[
                    const SizedBox(height: DabblerSpacing.space3),
                    sport,
                  ],
                  if (detail != null) DabblerPostDetailLine(detail: detail!),
                  // 6 of gap plus the action row's own 6 margin.
                  if (showActions && _drawn)
                    const SizedBox(height: DabblerSpacing.space4),
                  if (showActions)
                    // Drawn: the row lays out at 20 and the 45 target is a
                    // hit-test-only band over it, vertical slop included (a
                    // parent that is only 20 high would clip it).
                    _drawn
                        ? DabblerExpandedHitArea(
                            minimum: const Size(
                              0,
                              DabblerSizing.touchTargetMin,
                            ),
                            child: actions,
                          )
                        : actions,
                  if (reactions != null) ...<Widget>[
                    const SizedBox(height: DabblerSpacing.space2),
                    reactions!,
                  ],
                  if (_drawn)
                    SizedBox(
                      height:
                          paddingBlock +
                          (divider ? DabblerSizing.borderDefault : 0),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return DabblerFeedTappable(onTap: onTap, child: content);
  }
}
