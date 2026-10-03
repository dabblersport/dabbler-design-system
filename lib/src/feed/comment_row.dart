import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';

/// CommentRow — one reply under a post: avatar, author line with a relative
/// time, body, an optional attached image or GIF, and the like / reply text
/// actions; nests by [depth] (KAN-412 gaps 5 item 9).
///
/// Transcribed from the Claude Design file `Post.dc.html` (alpha-plan design
/// set). The top-level reply is the markup at lines 285-300; a nested reply
/// ("kid") is lines 306-317. Design values are quoted against those lines.
///
/// | Design (`Post.dc.html`) | Dart |
/// | --- | --- |
/// | `:285` row `gap:12px; padding:15px 0; border-bottom 1px --faint` | `space4`, `space5`, `bgTertiary` at `borderDefault` ([divider]) |
/// | `:286` avatar `size="sm"` 36px; kid `:308` `size="xs"` 30px, `gap:9px` | [DabblerAvatar] `sm`; at [depth] > 0 `xs` (28) and `space3` |
/// | `:287` column `gap:4px`; kid `gap:3px` | `space1` (3) for both |
/// | `:289` name 14/19 600 `--ink` ellipsis; kid 13/18 | `subheadline` / `footnote`, [DabblerType.semibold], `textPrimary` |
/// | `:290-292` handle, 3px dot `--subtle`, time 12/16 `--muted` | `caption1` `textSecondary`; dot `textTertiary` |
/// | `:293` `more-circle` 18 pushed to the end | [onMore], a 45px target, `Spacer` (mirrors in RTL) |
/// | `:297` body 15/21 `--ink-soft`; kid 14/20 | `subheadline` / `footnote`, `textSecondary` |
/// | `:305-307` actions `gap:18px; margin-top:2px`, heart 18 + count 12/16 600 | [DabblerFeedAction] 18; `caption1` semibold text actions |
/// | `:306` `Reply` 12/16 600 `--muted` | [replyLabel] text button, `textSecondary` |
/// | `:308` kids toggle 12/16 600 `--color-brand-primary` | [repliesLabel] text button, `brandPrimary` |
/// | `:311` kids `margin-top:12px` inside the parent column | [depth] indent of [indentStep] (36 + 12) per level |
///
/// ## Deviations (recorded, not silent)
///
/// * **Spacing steps.** 4px and 2px gaps take `space1` (3); the kid avatar is
///   the 28px `xs` size, not 30 (the avatar has no 30px step).
/// * **Type.** 14/19 has no style; the top-level name and body take
///   `subheadline` (15/20), the kid's 13/18 and 14/20 take `footnote` (13).
/// * **45px targets.** The heart, Reply, the replies toggle and more are each
///   at least 45px square, so the action row is 45 high instead of 16.
/// * **Attachment.** The design draws no media in a reply; [attachment] is a
///   slot under the body, clipped to [DabblerRadius.lgAll], sized by the
///   caller (a [DabblerImage] for a photo or GIF).
/// * **Joined chip** (`:298-303`) is content, not structure: pass it in
///   [attachment] or above the row.
///
/// RTL: every inset is directional — the avatar leads, more trails and the
/// [depth] indent grows from the start edge. Counts are Western digits.
///
/// Accessibility: with [onTap] the row is one button; [onLongPress] is
/// exposed as the long-press semantics action (the context menu seam) with or
/// without a tap. Each action is its own button named by its label.
class DabblerCommentRow extends StatelessWidget {
  /// A reply row.
  const DabblerCommentRow({
    super.key,
    required this.name,
    this.seed,
    this.imageUrl,
    this.handle,
    required this.time,
    this.timeSlot,
    this.body = '',
    this.bodySpan,
    this.attachment,
    this.attachments,
    this.likes = 0,
    this.showLike = true,
    this.liked = false,
    this.depth = 0,
    this.divider,
    this.onTap,
    this.onLongPress,
    this.onLike,
    this.onReply,
    this.onViewReplies,
    this.onMore,
    this.onAuthorTap,
    this.likeLabel = 'Like',
    this.replyLabel = 'Reply',
    this.repliesLabel,
    this.moreLabel = 'More options',
  }) : assert(depth >= 0, 'depth must not be negative');

  /// The author's name.
  final String name;

  /// The avatar seed; falls back to [name].
  final String? seed;

  /// The author's photo; the seed portrait stands in.
  final String? imageUrl;

  /// The author's handle (`@moatazmustapha`), drawn after the name at the top
  /// level only, as in the design.
  final String? handle;

  /// The reply's age, already formatted (`2h`).
  final String time;

  /// Replaces the [time] text when set — a live-updating relative time, say.
  final Widget? timeSlot;

  /// The body as plain text; ignored when [bodySpan] is given.
  final String body;

  /// The body as rich runs (an `@mention` in the brand colour, as in the
  /// design's kid rows, `:314`). Styled on top of the row's body style.
  final InlineSpan? bodySpan;

  /// An attached image or GIF under the body, clipped to the large corner.
  final Widget? attachment;

  /// Several attachments under the body (DS gaps 6, item 14), laid out in a
  /// [Wrap] that runs from the start edge with [DabblerSpacing.space2]
  /// between items and between runs, each clipped to the large corner like
  /// [attachment]. When both are given, [attachment] comes first. Sized by
  /// the caller. **Design frame missing:** `Post.dc.html` draws no media in
  /// a reply; the 6px gap is the system's `iconGap` step, the tightest that
  /// still separates two thumbnails' hairlines.
  final List<Widget>? attachments;

  /// The like count.
  final int likes;

  /// Whether the like action is drawn. Default true; a thread whose comments
  /// carry no like data passes false so no inert heart shows.
  final bool showLike;

  /// Whether the viewer liked the reply (bold, error-coloured heart).
  final bool liked;

  /// Nesting level: 0 is a top-level reply; each level indents by
  /// [indentStep] and uses the smaller avatar and type.
  final int depth;

  /// Whether the block-end hairline is drawn. Null draws it at depth 0 only.
  final bool? divider;

  /// Opens the reply. Null leaves the row inert to taps.
  final VoidCallback? onTap;

  /// Called on long press — open the reply's context menu from here.
  final VoidCallback? onLongPress;

  /// Toggles the like. Null hides nothing; the heart is drawn inert.
  final VoidCallback? onLike;

  /// Starts a reply to this reply. Null hides the Reply action.
  final VoidCallback? onReply;

  /// Shows or hides the nested replies; drawn only with [repliesLabel].
  final VoidCallback? onViewReplies;

  /// Opens the reply's options; null hides the more target.
  final VoidCallback? onMore;

  /// Opens the author's profile from the avatar and the name.
  final VoidCallback? onAuthorTap;

  /// Accessible name of the like action.
  final String likeLabel;

  /// The Reply text action, already localised.
  final String replyLabel;

  /// The nested-replies toggle (`3 replies`, `Hide replies`), localised; null
  /// hides it.
  final String? repliesLabel;

  /// Accessible name of the more action.
  final String moreLabel;

  /// Per-level indent — the parent avatar ([DabblerAvatarSize.sm], 36) plus its gap (12), so a nested
  /// reply lines up with its parent's text column (`:311`).
  static const double indentStep = 36 + DabblerSpacing.space4;

  /// Action glyph side — `size="18"` (`:305`).
  static const double actionGlyphSize = DabblerSizing.iconSm;

  /// Separator dot — `3px` (`:291`).
  static const double dotSize = 3;

  Widget _textAction(
    String label,
    Color ink,
    VoidCallback onTap,
    TextStyle style,
  ) {
    return DabblerFeedTappable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      borderRadius: DabblerRadius.smAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: DabblerSizing.touchTargetMin,
          minHeight: DabblerSizing.touchTargetMin,
        ),
        child: Center(
          widthFactor: 1,
          child: Text(label, maxLines: 1, style: style.copyWith(color: ink)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final bool nested = depth > 0;
    final TextStyle caption = t(
      DabblerType.caption1,
    ).copyWith(color: colors.textSecondary);
    final TextStyle actionStyle = caption.copyWith(
      fontWeight: DabblerType.semibold,
    );
    final DabblerTypeStyle textRole = nested
        ? DabblerType.footnote
        : DabblerType.subheadline;

    final Widget dot = ExcludeSemantics(
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.textTertiary,
        ),
      ),
    );

    final Widget header = Row(
      children: <Widget>[
        Flexible(
          child: DabblerFeedTappable(
            onTap: onAuthorTap,
            semanticLabel: name,
            excludeChildSemantics: true,
            child: Text(
              name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: t(textRole).copyWith(
                color: colors.textPrimary,
                fontWeight: DabblerType.semibold,
              ),
            ),
          ),
        ),
        if (handle != null && !nested) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          Flexible(
            child: Text(
              handle!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: caption,
            ),
          ),
        ],
        const SizedBox(width: DabblerSpacing.space2),
        dot,
        const SizedBox(width: DabblerSpacing.space2),
        timeSlot ??
            Text(
              DabblerType.toWesternDigits(time),
              maxLines: 1,
              style: caption,
            ),
        if (onMore != null) ...<Widget>[
          const Spacer(),
          DabblerFeedAction(
            icon: 'more-circle',
            iconSize: actionGlyphSize,
            onTap: onMore,
            semanticLabel: moreLabel,
          ),
        ],
      ],
    );

    final TextStyle bodyStyle = t(
      textRole,
    ).copyWith(color: colors.textSecondary);
    final Widget bodyText = Text.rich(
      bodySpan ?? TextSpan(text: body),
      style: bodyStyle,
    );

    final Widget actions = Row(
      children: <Widget>[
        if (showLike)
          DabblerFeedAction(
            icon: 'heart',
            count: likes,
            iconSize: actionGlyphSize,
            weight: liked ? DabblerIconWeight.bold : DabblerIconWeight.linear,
            color: liked ? colors.error.base : null,
            onTap: onLike,
            semanticLabel: likeLabel,
          ),
        if (onReply != null)
          _textAction(replyLabel, colors.textSecondary, onReply!, actionStyle),
        if (repliesLabel != null && onViewReplies != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          _textAction(
            repliesLabel!,
            colors.brandPrimary,
            onViewReplies!,
            actionStyle,
          ),
        ],
      ],
    );

    final List<Widget> media = <Widget>[?attachment, ...?attachments];
    final bool drawDivider = divider ?? !nested;
    final Widget content = DecoratedBox(
      decoration: BoxDecoration(
        border: drawDivider
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
          start: indentStep * depth,
          top: nested ? DabblerSpacing.space4 : DabblerSpacing.space5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DabblerFeedTappable(
              onTap: onAuthorTap,
              semanticLabel: name,
              excludeChildSemantics: true,
              borderRadius: DabblerRadius.pillAll,
              child: DabblerAvatar(
                seed: seed ?? name,
                imageUrl: imageUrl,
                size: nested ? DabblerAvatarSize.xs : DabblerAvatarSize.sm,
              ),
            ),
            SizedBox(
              width: nested ? DabblerSpacing.space3 : DabblerSpacing.space4,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  header,
                  const SizedBox(height: DabblerSpacing.space1),
                  bodyText,
                  if (media.isNotEmpty) ...<Widget>[
                    const SizedBox(height: DabblerSpacing.space3),
                    if (media.length == 1)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: ClipRRect(
                          borderRadius: DabblerRadius.lgAll,
                          child: media.single,
                        ),
                      )
                    else
                      Wrap(
                        spacing: DabblerSpacing.space2,
                        runSpacing: DabblerSpacing.space2,
                        children: <Widget>[
                          for (final Widget m in media)
                            ClipRRect(
                              borderRadius: DabblerRadius.lgAll,
                              child: m,
                            ),
                        ],
                      ),
                  ],
                  actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return DabblerFeedTappable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }
    if (onLongPress != null) {
      return Semantics(
        onLongPress: onLongPress,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: content,
        ),
      );
    }
    return content;
  }
}
