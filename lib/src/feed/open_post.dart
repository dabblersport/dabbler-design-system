import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';
import 'post_row.dart' show DabblerPostSegment;

/// OpenPost — the post a detail screen is about: author header with the
/// Follow pill, the body at reading size, the sport and place pills, the
/// timestamp / views / audience line and the like / vibe / reply / share row.
///
/// Transcribed from `Post.dc.html` (alpha-plan design set) lines 58-126, the
/// block above the replies in all three frames.
///
/// | Design (`Post.dc.html`) | Dart |
/// | --- | --- |
/// | `:58` block `gap:12px; padding:18px 18px 15px; border-bottom 1px --faint` | `space4`; `space6` / `space5`; `bgTertiary` hairline |
/// | `:60` avatar `sm`; name 16/21 600; role 12/16 600 `--muted`; `Dab` pill 2/8 11/14 brand | [DabblerAvatar] `sm`; `callout`; `caption1`; [badgeLabel] pill |
/// | `:71` handle 13/18 `--muted` | [handle], `footnote` `textSecondary` |
/// | `:74` Follow 33px high, 0/15, pill, 1px brand, 13/18 600 | [followLabel], brand hairline pill; filled brand when [following] |
/// | `:78` body 17/26 `--ink` | [segments], `body`; link runs `brandPrimary` |
/// | `:80-92` sport pill brand fill, place pill card + hairline, 6/12/6/10, 12/16 600 | [sportLabel] + [sportIcon]; [placeLabel] with a brand `location` glyph |
/// | `:94-103` time, dot, date, dot, eye + views; audience `global` + `EN` at the end | [timeLabel], [dateLabel], [viewsLabel]; [audienceIcon] + [audienceLabel] |
/// | `:105-123` actions `gap:18; padding-top:12; border-top 1px --faint`, icons 22, counts 13/18 600; share at the end | [DabblerFeedAction]s at 22; `share` pushed to the end |
///
/// ## Deviations (recorded, not silent)
///
/// * **Targets.** Each action keeps the 45px touch box, so the row is taller
///   than the design's 22px and the 18px gap is the boxes' own inset.
/// * **Pill padding.** 5px steps take the 6 / 12 steps of the base-3 ramp.
/// * **Type.** 17/26 body takes `body`; 16/21 name takes `callout`.
/// * **Vibe glyph.** A chosen vibe's emoji (`:114`) is not reproduced; the
///   `add-square` glyph turns bold and brand when [vibed].
///
/// RTL: the avatar leads, Follow and the audience trail, share sits at the
/// inline end; digits are Western.
class DabblerOpenPost extends StatelessWidget {
  /// An open post.
  const DabblerOpenPost({
    super.key,
    required this.name,
    this.seed,
    this.imageUrl,
    this.roleLabel,
    this.badgeLabel,
    this.handle,
    this.onAuthorTap,
    this.followLabel,
    this.following = false,
    this.onFollow,
    this.segments = const <DabblerPostSegment>[],
    this.media,
    this.sportLabel,
    this.sportIcon = 'game',
    this.placeLabel,
    this.chips,
    this.timeLabel,
    this.dateLabel,
    this.viewsLabel,
    this.audienceIcon = 'global',
    this.audienceLabel,
    this.likes = 0,
    this.vibes = 0,
    this.replies = 0,
    this.liked = false,
    this.vibed = false,
    this.onLike,
    this.onVibe,
    this.onComment,
    this.onShare,
    this.likeSemanticLabel = 'Like',
    this.vibeSemanticLabel = 'Vibe',
    this.commentSemanticLabel = 'Reply',
    this.shareSemanticLabel = 'Share',
  });

  /// The author's name.
  final String name;

  /// Avatar seed; falls back to [name].
  final String? seed;

  /// The author's photo.
  final String? imageUrl;

  /// The author's role (`Player`).
  final String? roleLabel;

  /// A short brand pill after the role (`Dab`).
  final String? badgeLabel;

  /// The handle under the name (`@moatazmustapha`).
  final String? handle;

  /// Opens the author's profile.
  final VoidCallback? onAuthorTap;

  /// The Follow pill's text; null hides the pill.
  final String? followLabel;

  /// Whether the viewer follows the author (filled pill).
  final bool following;

  /// Toggles the follow; null draws the pill inert.
  final VoidCallback? onFollow;

  /// The body as runs.
  final List<DabblerPostSegment> segments;

  /// Media under the body, clipped to the large corner.
  final Widget? media;

  /// The sport pill's text; null hides it.
  final String? sportLabel;

  /// The sport pill's glyph.
  final String sportIcon;

  /// The place pill's text; null hides it.
  final String? placeLabel;

  /// Further pills drawn after the place pill (a vibe, an origin).
  final List<Widget>? chips;

  /// The time (`8:00 PM`).
  final String? timeLabel;

  /// The date (`Aug 16, 2026`).
  final String? dateLabel;

  /// The views text (`1,204 views`); null hides the eye.
  final String? viewsLabel;

  /// The audience glyph.
  final String audienceIcon;

  /// The audience text (`EN`).
  final String? audienceLabel;

  /// Like count.
  final int likes;

  /// Vibe count.
  final int vibes;

  /// Reply count.
  final int replies;

  /// Whether the viewer liked it.
  final bool liked;

  /// Whether the viewer vibed it.
  final bool vibed;

  /// Toggles the like.
  final VoidCallback? onLike;

  /// Opens the vibe picker.
  final VoidCallback? onVibe;

  /// Focuses the reply field.
  final VoidCallback? onComment;

  /// Shares the post; null hides the share glyph.
  final VoidCallback? onShare;

  /// Like action name.
  final String likeSemanticLabel;

  /// Vibe action name.
  final String vibeSemanticLabel;

  /// Reply action name.
  final String commentSemanticLabel;

  /// Share action name.
  final String shareSemanticLabel;

  /// Action glyph side — `size="22"` (`:108`).
  static const double actionGlyphSize = 22;

  /// Isolates a left-to-right token (handle, time, date) so a right-to-left
  /// paragraph does not reorder its `@` or its AM / PM.
  static String _ltr(String s) => '\u2066$s\u2069';

  Widget _dot(DabblerColors colors) => ExcludeSemantics(
    child: Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.textTertiary,
      ),
    ),
  );

  Widget _pill({
    required Widget child,
    required Color? fill,
    required Color? line,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      color: fill,
      borderRadius: DabblerRadius.pillAll,
      border: line == null
          ? null
          : Border.all(color: line, width: DabblerSizing.borderDefault),
    ),
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DabblerSpacing.space4,
        DabblerSpacing.space2,
        DabblerSpacing.space4,
        DabblerSpacing.space2,
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s, Color c, [FontWeight? w]) =>
        s.resolveForDirection(dir).copyWith(color: c, fontWeight: w);
    final TextStyle muted = t(DabblerType.footnote, colors.textSecondary);
    final TextStyle chipText = t(
      DabblerType.caption1,
      colors.textSecondary,
      DabblerType.semibold,
    );

    final Widget nameLine = Row(
      children: <Widget>[
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: t(
              DabblerType.callout,
              colors.textPrimary,
              DabblerType.semibold,
            ),
          ),
        ),
        if (roleLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          _dot(colors),
          const SizedBox(width: DabblerSpacing.space2),
          Text(
            roleLabel!,
            maxLines: 1,
            style: t(
              DabblerType.caption1,
              colors.textSecondary,
              DabblerType.semibold,
            ),
          ),
        ],
        if (badgeLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.brandPrimary,
              borderRadius: DabblerRadius.pillAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DabblerSpacing.space3,
                vertical: DabblerSpacing.space1,
              ),
              child: Text(
                badgeLabel!,
                maxLines: 1,
                style: t(
                  DabblerType.caption1,
                  colors.onBrand,
                  DabblerType.semibold,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final Widget header = Row(
      children: <Widget>[
        DabblerFeedTappable(
          onTap: onAuthorTap,
          semanticLabel: name,
          excludeChildSemantics: true,
          borderRadius: DabblerRadius.pillAll,
          child: DabblerAvatar(
            seed: seed ?? name,
            imageUrl: imageUrl,
            size: DabblerAvatarSize.sm,
          ),
        ),
        const SizedBox(width: DabblerSpacing.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              nameLine,
              if (handle != null)
                Text(
                  _ltr(handle!),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
            ],
          ),
        ),
        if (followLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space4),
          DabblerFeedTappable(
            onTap: onFollow,
            semanticLabel: followLabel,
            excludeChildSemantics: true,
            borderRadius: DabblerRadius.pillAll,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: following ? colors.brandPrimary : null,
                borderRadius: DabblerRadius.pillAll,
                border: Border.all(
                  color: colors.brandPrimary,
                  width: DabblerSizing.borderDefault,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DabblerSpacing.space5,
                  vertical: DabblerSpacing.space3,
                ),
                child: Text(
                  followLabel!,
                  maxLines: 1,
                  style: t(
                    DabblerType.footnote,
                    following ? colors.onBrand : colors.brandPrimary,
                    DabblerType.semibold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final Widget body = Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final DabblerPostSegment s in segments)
            TextSpan(
              text: s.text,
              style: s.link ? TextStyle(color: colors.brandPrimary) : null,
            ),
        ],
      ),
      style: t(DabblerType.body, colors.textPrimary),
    );

    final List<Widget> pills = <Widget>[
      if (sportLabel != null)
        _pill(
          fill: colors.brandPrimary,
          line: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerIcon(
                sportIcon,
                size: 14,
                weight: DabblerIconWeight.bold,
                color: colors.onBrand,
              ),
              const SizedBox(width: DabblerSpacing.space2),
              Text(
                sportLabel!,
                maxLines: 1,
                style: chipText.copyWith(color: colors.onBrand),
              ),
            ],
          ),
        ),
      if (placeLabel != null)
        _pill(
          fill: colors.surfaceCard,
          line: colors.borderDefault,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerIcon(
                'location',
                size: 14,
                weight: DabblerIconWeight.bold,
                color: colors.brandPrimary,
              ),
              const SizedBox(width: DabblerSpacing.space2),
              Flexible(
                child: Text(
                  placeLabel!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: chipText,
                ),
              ),
            ],
          ),
        ),
      ...?chips,
    ];

    final Widget when = Row(
      children: <Widget>[
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DabblerSpacing.space2,
            children: <Widget>[
              if (timeLabel != null)
                Text(
                  _ltr(DabblerType.toWesternDigits(timeLabel!)),
                  style: muted,
                ),
              if (timeLabel != null && dateLabel != null) _dot(colors),
              if (dateLabel != null)
                Text(
                  _ltr(DabblerType.toWesternDigits(dateLabel!)),
                  style: muted,
                ),
              if (viewsLabel != null) ...<Widget>[
                _dot(colors),
                DabblerIcon('eye', size: 14, color: colors.textTertiary),
                Text(DabblerType.toWesternDigits(viewsLabel!), style: muted),
              ],
            ],
          ),
        ),
        if (audienceLabel != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          DabblerIcon(audienceIcon, size: 14, color: colors.textSecondary),
          const SizedBox(width: DabblerSpacing.space2),
          Text(audienceLabel!, maxLines: 1, style: muted),
        ],
      ],
    );

    final Widget actions = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          DabblerFeedAction(
            icon: 'heart',
            iconSize: actionGlyphSize,
            count: likes,
            weight: liked ? DabblerIconWeight.bold : DabblerIconWeight.linear,
            color: liked ? colors.error.base : null,
            onTap: onLike,
            semanticLabel: likeSemanticLabel,
          ),
          DabblerFeedAction(
            icon: 'add-square',
            iconSize: actionGlyphSize,
            count: vibes,
            weight: vibed ? DabblerIconWeight.bold : DabblerIconWeight.linear,
            color: vibed ? colors.brandPrimary : null,
            onTap: onVibe,
            semanticLabel: vibeSemanticLabel,
          ),
          DabblerFeedAction(
            icon: 'message-text',
            iconSize: actionGlyphSize,
            count: replies,
            onTap: onComment,
            semanticLabel: commentSemanticLabel,
          ),
          const Spacer(),
          if (onShare != null)
            DabblerFeedAction(
              icon: 'share',
              iconSize: actionGlyphSize,
              onTap: onShare,
              semanticLabel: shareSemanticLabel,
            ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.bgTertiary,
            width: DabblerSizing.borderDefault,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DabblerSpacing.space6,
          DabblerSpacing.space6,
          DabblerSpacing.space6,
          DabblerSpacing.space5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            const SizedBox(height: DabblerSpacing.space4),
            body,
            if (media != null) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space4),
              ClipRRect(borderRadius: DabblerRadius.lgAll, child: media),
            ],
            if (pills.isNotEmpty) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space4),
              Wrap(
                spacing: DabblerSpacing.space2,
                runSpacing: DabblerSpacing.space2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: pills,
              ),
            ],
            if (timeLabel != null || audienceLabel != null) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space4),
              when,
            ],
            const SizedBox(height: DabblerSpacing.space4),
            actions,
          ],
        ),
      ),
    );
  }
}
