import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// NewsCard — one story in the Home Feed's News tab: a media block with a
/// sport pill over it, the like / comment / view figures and age, then the
/// title and a two-line excerpt.
///
/// Transcribed from the Claude Design file `Home Feed.dc.html` (DesignSync,
/// fetched 2026-10-03 and truncated at the tool's 256 KiB cap — the markup is
/// complete; the script ends mid-array). The card is the markup at lines
/// 407-436 of that file; the NEWS sample data is at `:2620-2634`.
///
/// | Design (`Home Feed.dc.html`) | Dart |
/// | --- | --- |
/// | `:408` card `gap:9px; padding-bottom:21px; margin-bottom:18px; border-bottom 1px --faint` | `space3`, `space7`, `space6`, `bgTertiary` at `borderDefault` width |
/// | `:409` media `height:210px; radius --radius-xl; overflow hidden; bg --surface-sunken` | [mediaHeight] 210, `DabblerRadius.xl` (18), `surfaceSunken` |
/// | `:410` `<image-slot>` | [media] — a `Widget` slot, no image dependency |
/// | `:411` pill `top:12 left:12`, 4/10, brand fill, `--color-on-brand`, 11/13 | [DabblerBadge] default tone (4/10), `PositionedDirectional` `space4` |
/// | `:415` action row `gap:15px` | `space5` before the view figure |
/// | `:416-418` heart 18, count 12/16 `gap:6px`, active `likeColor` | [DabblerFeedAction] `iconSize` 18 (`iconSm`), `caption1`, `space2` |
/// | `:424` `eye` figure, not interactive | [DabblerFeedAction] with no tap |
/// | `:429` time `margin-left:auto` 12/16 `--muted` | trailing, `caption1`, `textSecondary`, mirrors in RTL |
/// | `:432` title 17/22 weight 600 `--ink` | `headline` (17/22/600), `textPrimary` |
/// | `:433` excerpt 15/20 `--muted`, `clamp-2` | `subheadline`, `textSecondary`, two lines, ellipsis |
/// | `:432-433` text column `gap:5px` | `space2` |
///
/// ## Deviations (recorded, not silent)
///
/// * **Media** is a slot: the caller supplies the image (or nothing — the
///   sunken surface shows). The design's placeholder hint is not reproduced.
/// * **Pill.** [DabblerBadge] is bold; the design's pill is regular weight.
///   Its ink is `surfaceCard` where the design names `--color-on-brand`
///   (identical in the light themes).
/// * **Excerpt** `--muted` resolves to `textSecondary` (`D-003(a)`).
/// * **45px targets.** Like and comment are 45px hit boxes, so the action row
///   is 45 high instead of 18; the 9px gaps either side of it are dropped (the
///   box inset, 13.5px, replaces them) and the 15px inter-action gap becomes
///   the boxes' own inset.
/// * **Active like** (`n.likeColor`, `:416`) is computed in the truncated
///   script: inferred as the `error` status colour with a bold heart.
///
/// ## Not readable
///
/// `n.likeColor`, `n.likeType`, `n.open`, `n.slotId` and the story feed's
/// filtering (`followed`) live in the truncated script.
///
/// RTL: the pill sits at the start corner, the time trails, and type resolves
/// to the Arabic metrics; counts and the age are rewritten to Western digits.
///
/// Accessibility: with [onTap] the card is one button composed from title,
/// excerpt and age; like and comment are their own buttons; the views figure is
/// announced as `viewsLabel, count`.
class DabblerNewsCard extends StatelessWidget {
  /// A news card.
  const DabblerNewsCard({
    super.key,
    this.media,
    this.sportLabel,
    required this.title,
    this.excerpt,
    required this.time,
    this.likes = 0,
    this.comments = 0,
    this.views,
    this.liked = false,
    this.onTap,
    this.onLike,
    this.onComment,
    this.divider = true,
    this.likeLabel = 'Like',
    this.commentLabel = 'Comments',
    this.viewsLabel = 'Views',
  });

  /// The media block's content (an image, usually). Null leaves the sunken
  /// surface.
  final Widget? media;

  /// The sport pill over the media; omitted when null.
  final String? sportLabel;

  /// The story's title.
  final String title;

  /// The excerpt, clamped to two lines.
  final String? excerpt;

  /// The story's age, already formatted (`3h ago`).
  final String time;

  /// The like count.
  final int likes;

  /// The comment count.
  final int comments;

  /// The view count; the figure is omitted when null.
  final int? views;

  /// Whether the viewer has liked the story.
  final bool liked;

  /// Opens the story. Null leaves the card inert.
  final VoidCallback? onTap;

  /// Toggles the like.
  final VoidCallback? onLike;

  /// Opens the comments.
  final VoidCallback? onComment;

  /// Whether the hairline block-end divider is drawn.
  final bool divider;

  /// Accessible name of the like action.
  final String likeLabel;

  /// Accessible name of the comment action.
  final String commentLabel;

  /// Accessible name of the views figure.
  final String viewsLabel;

  /// Media height — `height:210px` (`:409`).
  static const double mediaHeight = 210;

  /// Action glyph side — `size="18"` (`:416`), `iconSm`.
  static const double actionGlyphSize = DabblerSizing.iconSm;

  /// Block-end padding — `padding-bottom:21px` (`:408`), `space7`.
  static const double paddingBottom = DabblerSpacing.space7;

  /// Block-end margin — `margin-bottom:18px` (`:408`), `space6`.
  static const double marginBottom = DabblerSpacing.space6;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);

    final Widget mediaBlock = ClipRRect(
      borderRadius: DabblerRadius.xlAll,
      child: SizedBox(
        height: mediaHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: colors.surfaceSunken),
            ?media,
            if (sportLabel != null)
              PositionedDirectional(
                top: DabblerSpacing.space4,
                start: DabblerSpacing.space4,
                child: IgnorePointer(child: DabblerBadge(label: sportLabel!)),
              ),
          ],
        ),
      ),
    );

    final Widget actions = Row(
      children: <Widget>[
        DabblerFeedAction(
          icon: 'heart',
          count: likes,
          iconSize: actionGlyphSize,
          weight: liked ? DabblerIconWeight.bold : DabblerIconWeight.linear,
          color: liked ? colors.error.base : null,
          onTap: onLike,
          semanticLabel: likeLabel,
        ),
        DabblerFeedAction(
          icon: 'message-text',
          count: comments,
          iconSize: actionGlyphSize,
          onTap: onComment,
          semanticLabel: commentLabel,
        ),
        if (views != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space5),
          DabblerFeedAction(
            icon: 'eye',
            count: views,
            iconSize: actionGlyphSize,
            semanticLabel: viewsLabel,
          ),
        ],
        const Spacer(),
        Text(
          DabblerType.toWesternDigits(time),
          maxLines: 1,
          style: t(DabblerType.caption1).copyWith(color: colors.textSecondary),
        ),
      ],
    );

    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: t(DabblerType.headline).copyWith(color: colors.textPrimary),
          ),
        ),
        if (excerpt != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space2),
          Text(
            excerpt!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t(
              DabblerType.subheadline,
            ).copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );

    final Widget card = DecoratedBox(
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
          bottom: divider ? paddingBottom : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[mediaBlock, actions, text],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: marginBottom),
      child: DabblerFeedTappable(onTap: onTap, child: card),
    );
  }
}
