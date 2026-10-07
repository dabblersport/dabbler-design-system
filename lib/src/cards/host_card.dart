import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../surfaces/avatar.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// HostCard — who runs a meetup: the host's avatar, a role caption over the
/// name, and an optional pill action at the end.
///
/// Drawn from the meetup details host block, `Details.dc.html:277-284`: a
/// `--tile-accent-surface` panel, radius `lg`, padding 15, gap 12; an `md`
/// avatar, the role (11/15, 60% ink) over the name (15/20, 600), and a
/// page-coloured pill (13/17, 600; 8/14) — `Follow`.
///
/// ```dart
/// DabblerHostCard(
///   seed: 'Dubai Running Club',
///   caption: 'Community host',
///   name: 'Dubai Running Club',
///   actionLabel: 'Follow',
///   onAction: follow,
/// )
/// ```
///
/// ## States
///
/// A card without [actionLabel] is the host alone. [onAction] null with an
/// [actionLabel] draws the pill inert (a follow already in flight).
///
/// ## RTL
///
/// Avatar first at the inline start, the action at the inline end.
///
/// ## Accessibility
///
/// The text is read as one block; the pill is its own named button.
class DabblerHostCard extends StatelessWidget {
  /// A host card.
  const DabblerHostCard({
    super.key,
    required this.name,
    this.seed,
    this.imageUrl,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  /// The host's name.
  final String name;

  /// The avatar's seed; falls back to [name].
  final String? seed;

  /// The host's photo, when there is one.
  final String? imageUrl;

  /// The role line above the name — `Community host`.
  final String? caption;

  /// The pill's words — `Follow`. Null draws no pill.
  final String? actionLabel;

  /// Runs the pill.
  final VoidCallback? onAction;

  /// The caption's ink alpha over the ink — `rgba(20,20,20,0.6)`.
  static const double captionAlpha = 0.6;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return DabblerSurface(
      fill: colors.tileAccentTone.surface,
      borderWidth: 0,
      radius: DabblerRadius.lg,
      padding: const EdgeInsets.all(DabblerSpacing.space5),
      child: Row(
        spacing: DabblerSpacing.space4,
        children: <Widget>[
          DabblerAvatar(seed: seed ?? name, imageUrl: imageUrl),
          Expanded(
            child: Semantics(
              container: true,
              label: <String>[?caption, name].join(', '),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (caption != null)
                      Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DabblerType.caption2
                            .resolveForDirection(direction)
                            .copyWith(
                              color: colors.brightness == Brightness.dark
                                  ? colors.tileSubInk
                                  : colors.textPrimary.withValues(
                                      alpha: captionAlpha,
                                    ),
                            ),
                      ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DabblerType.subheadline
                          .resolveForDirection(direction)
                          .copyWith(
                            color: colors.textPrimary,
                            fontWeight: DabblerType.semibold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (actionLabel != null)
            DabblerFeedTappable(
              onTap: onAction,
              semanticLabel: actionLabel,
              excludeChildSemantics: true,
              borderRadius: DabblerRadius.pillAll,
              child: DabblerSurface(
                fill: colors.bgPrimary,
                borderWidth: 0,
                radius: DabblerRadius.pill,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: DabblerSpacing.space4 + 2,
                  vertical: DabblerSpacing.space3 - 1,
                ),
                child: Text(
                  actionLabel!,
                  maxLines: 1,
                  style: DabblerType.footnote
                      .resolveForDirection(direction)
                      .copyWith(
                        color: colors.textPrimary,
                        fontWeight: DabblerType.semibold,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
