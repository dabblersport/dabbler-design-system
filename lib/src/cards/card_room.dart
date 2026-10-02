import 'package:flutter/widgets.dart';

import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// CardRoom — a room as a card: the room name, its topic, and a stack of
/// participant avatars ending in a `+N` count.
///
/// Ported from the live design project's `components/cards/CardRoom.jsx` (Figma
/// node `8:33`, design system 1.2.0). Text and avatar seeds are injected.
///
/// | Source | Here | Why |
/// |---|---|---|
/// | `417.5` frame width | flexible width | a Figma frame measurement |
/// | name `11 / 16.5 / 500` | `caption-2` 11/13 at weight 500 | leading snaps to the ramp |
/// | topic `15 / 20.6 / 700` | `subheadline` 15/20 at weight 700 | weight override; leading snaps to the ramp |
/// | `+42` chip `10 / 15 / 700` | `caption-2` 11/13 at weight 700 | the source size is below the ramp floor; cxo ruled it to 11 |
/// | per-avatar pastel backdrops | none | the avatar paints its own artwork; the backdrops were Figma placeholders |
class DabblerCardRoom extends StatelessWidget {
  /// A room card.
  const DabblerCardRoom({
    super.key,
    required this.name,
    required this.topic,
    this.avatarSeeds = const <String>[],
    this.overflowLabel,
    this.onTap,
  });

  /// The room name, the small line above the topic.
  final String name;

  /// The room topic, the bold line.
  final String topic;

  /// Participant seeds, in stack order.
  final List<String> avatarSeeds;

  /// The `+N` text of the trailing chip; null draws no chip.
  final String? overflowLabel;

  /// Makes the card tappable.
  final VoidCallback? onTap;

  /// The avatar diameter — `width: 36`.
  static const double avatarSide = 36;

  /// How far each avatar steps from the last — `left: 28`.
  static const double avatarStep = 28;

  /// The ring around the chip — `2px solid var(--neutral-100)`.
  static const double chipRing = 2;

  /// Padding on every edge — `padding: 16`.
  static const double padding = DabblerSpacing.space4 + 4;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final int count = avatarSeeds.length + (overflowLabel == null ? 0 : 1);
    final double stackWidth = count == 0
        ? 0
        : avatarSide + (count - 1) * avatarStep;

    final Widget stack = SizedBox(
      width: stackWidth,
      height: avatarSide,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int i = 0; i < avatarSeeds.length; i++)
            PositionedDirectional(
              start: i * avatarStep,
              child: SizedBox(
                width: avatarSide,
                height: avatarSide,
                child: DabblerAvatar(
                  seed: avatarSeeds[i],
                  size: DabblerAvatarSize.sm,
                ),
              ),
            ),
          if (overflowLabel != null)
            PositionedDirectional(
              start: avatarSeeds.length * avatarStep,
              child: Container(
                width: avatarSide,
                height: avatarSide,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brandPrimary.withValues(alpha: 0.12),
                  border: Border.all(color: colors.bgPrimary, width: chipRing),
                ),
                child: Text(
                  overflowLabel!,
                  maxLines: 1,
                  style: DabblerType.caption2
                      .resolveForDirection(direction)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.brandPrimary,
                      ),
                ),
              ),
            ),
        ],
      ),
    );

    final Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.cardAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.caption2
                        .resolveForDirection(direction)
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: DabblerSpacing.space1 - 1),
                  Text(
                    topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DabblerType.subheadline
                        .resolveForDirection(direction)
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
            if (count > 0) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space4),
              stack,
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return body;
    return Semantics(
      button: true,
      label: '$name, $topic',
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: MouseRegion(cursor: SystemMouseCursors.click, child: body),
        ),
      ),
    );
  }
}
