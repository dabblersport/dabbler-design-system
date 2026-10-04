import 'package:flutter/widgets.dart';

import '../cards/card.dart';
import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'feed_atoms.dart';
import 'post_detail.dart';

/// RepostRow — a repost in the feed: the reposter's header ("Karim reposted"),
/// an optional quote, and the original post embedded in a card.
///
/// **Source.** The design files carry no repost markup: `Profiles.dc.html:528`
/// names a `Reposts` feed tab and `:531` its empty state, and nothing draws a
/// repost row. The structure is therefore taken from the app's shipped
/// `HomeRepostRow` (`home_post_row.dart`, the repost branch of the Home Feed),
/// rebuilt here from system parts so the app can drop its local copy:
///
/// | App (`HomeRepostRow`) | Dart |
/// | --- | --- |
/// | block padding `space5` | [DabblerPostRow.paddingBlock] (`space5`) |
/// | reposter avatar, then `space3` | [DabblerAvatar] `sm`, `space4` (the post row's own avatar gap) |
/// | name, subheadline semibold `textPrimary` | `subheadline` `semibold`, `textPrimary`, one line |
/// | 13px `refresh` glyph in `brandPrimary`, caption `textSecondary` | same, `caption1` |
/// | quote, subheadline `textPrimary`, 4 lines | `subheadline`, `textPrimary`, [quoteMaxLines] |
/// | original in `DabblerCard(padding: zero)`, `space3` above | [DabblerCard] with zero padding, `space3` above |
/// | unavailable note, footnote `textSecondary`, `space4` inset | [unavailableLabel], same |
/// | `DabblerPostDetailLine` under the card | [detail] |
///
/// [original] is a slot: pass a `DabblerPostRow(divider: false)` for the
/// embedded post, so its author, body, media and actions are the feed row's
/// own. When it is null the card shows [unavailableLabel] instead (a deleted or
/// hidden original). [actions] is an optional row under the card for actions
/// on the repost itself.
///
/// **Deviation.** The reposter avatar is the post row's `sm` (36) rather than
/// the app's default `md` (48), so a repost and a post line up in one feed.
///
/// RTL: every inset is directional; the avatar leads and the glyph precedes
/// the reposted line in reading order. The type resolves to the Arabic
/// metrics.
///
/// Accessibility: the reposter avatar and name are one target named
/// [authorLabel] (falling back to [name]) when [onAuthorTap] is set; the
/// reposted line is plain text; the embedded post keeps its own semantics.
class DabblerRepostRow extends StatelessWidget {
  /// A repost row.
  const DabblerRepostRow({
    super.key,
    required this.name,
    required this.repostedLabel,
    this.seed,
    this.imageUrl,
    this.onAuthorTap,
    this.authorLabel,
    this.badge,
    this.quote,
    this.original,
    this.unavailableLabel,
    this.actions,
    this.detail,
    this.divider = true,
  });

  /// The reposter's name.
  final String name;

  /// The reposted line, already localised and formatted
  /// (`Reposted · 2h`).
  final String repostedLabel;

  /// The avatar seed; falls back to [name].
  final String? seed;

  /// The reposter's photo.
  final String? imageUrl;

  /// Opens the reposter's profile. Null makes the avatar and name inert.
  final VoidCallback? onAuthorTap;

  /// The accessible name of the reposter target; falls back to [name].
  final String? authorLabel;

  /// A badge after the name (a persona `DabblerBadge`). Null draws nothing.
  final Widget? badge;

  /// The reposter's quote. Null or blank draws nothing.
  final String? quote;

  /// The embedded original post — usually a `DabblerPostRow(divider: false)`.
  final Widget? original;

  /// Shown inside the card when [original] is null.
  final String? unavailableLabel;

  /// Actions on the repost itself, drawn under the card. Null draws nothing.
  final Widget? actions;

  /// The open-post detail line, drawn under the card.
  final DabblerPostDetail? detail;

  /// Whether the hairline block-end divider is drawn.
  final bool divider;

  /// The quote's line cap.
  static const int quoteMaxLines = 4;

  /// The reposted glyph side.
  static const double glyphSize = 13;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    TextStyle t(DabblerTypeStyle s) => s.resolveForDirection(dir);
    final String label = authorLabel ?? name;

    final Widget header = Row(
      children: <Widget>[
        Flexible(
          child: DabblerFeedTappable(
            onTap: onAuthorTap,
            semanticLabel: label,
            excludeChildSemantics: true,
            child: Text(
              name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: t(DabblerType.subheadline).copyWith(
                color: colors.textPrimary,
                fontWeight: DabblerType.semibold,
              ),
            ),
          ),
        ),
        if (badge != null) ...<Widget>[
          const SizedBox(width: DabblerSpacing.space2),
          badge!,
        ],
      ],
    );

    final Widget reposted = Row(
      children: <Widget>[
        ExcludeSemantics(
          child: DabblerIcon(
            'refresh',
            size: glyphSize,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(width: DabblerSpacing.space1),
        Flexible(
          child: Text(
            DabblerType.toWesternDigits(repostedLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t(
              DabblerType.caption1,
            ).copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );

    final String? q = quote?.trim();
    final Widget card = DabblerCard(
      padding: EdgeInsets.zero,
      child:
          original ??
          Padding(
            padding: const EdgeInsets.all(DabblerSpacing.space4),
            child: Text(
              unavailableLabel ?? '',
              style: t(
                DabblerType.footnote,
              ).copyWith(color: colors.textSecondary),
            ),
          ),
    );

    return DecoratedBox(
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
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: DabblerSpacing.space5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DabblerFeedTappable(
              onTap: onAuthorTap,
              semanticLabel: label,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  header,
                  const SizedBox(height: DabblerSpacing.space1),
                  reposted,
                  if (q != null && q.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: DabblerSpacing.space2,
                      ),
                      child: Text(
                        q,
                        maxLines: quoteMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: t(
                          DabblerType.subheadline,
                        ).copyWith(color: colors.textPrimary),
                      ),
                    ),
                  const SizedBox(height: DabblerSpacing.space3),
                  card,
                  if (detail != null) DabblerPostDetailLine(detail: detail!),
                  ?actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
