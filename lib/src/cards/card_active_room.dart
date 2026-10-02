import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// CardActiveRoom — a live room: its name and topic, an `unmute` pill, the
/// current speaker with a speaking badge, and a `join` pill.
///
/// Ported from the live design project's `components/cards/CardActiveRoom.jsx`
/// (Figma node `8:32`, design system 1.2.0). It composes only [DabblerAvatar]
/// and [DabblerIcon]; it owns no audio or room state — every label and callback
/// is injected.
///
/// | Source | Here | Why |
/// |---|---|---|
/// | `417.5` frame width | flexible width | a Figma frame measurement |
/// | name/topic `13 / 19.5 / 600, 700` | `footnote` 13/18 at weights 600 and 700 | leading snaps to the ramp |
/// | pill labels `12 / 18` | `caption-1` 12/16 | leading snaps to the ramp |
/// | badge glyph `7px` Inter | a 12px bold mic icon only | the source's `7px` text is never rendered (its child is the icon); the Inter face is not shipped and the cxo ruling refuses a family override |
/// | `●` glyph in Inter | a brand-coloured dot drawn as a shape | same reason |
class DabblerCardActiveRoom extends StatelessWidget {
  /// An active-room card.
  const DabblerCardActiveRoom({
    super.key,
    required this.name,
    required this.topic,
    required this.speakerSeed,
    this.muteLabel = 'unmute',
    this.speakingLabel = 'speaking now',
    this.joinLabel = 'join',
    this.onMute,
    this.onJoin,
  });

  /// The room name.
  final String name;

  /// The room topic.
  final String topic;

  /// The current speaker's avatar seed.
  final String speakerSeed;

  /// The mute pill text.
  final String muteLabel;

  /// The speaking caption.
  final String speakingLabel;

  /// The join pill text.
  final String joinLabel;

  /// Called when the mute pill is pressed.
  final VoidCallback? onMute;

  /// Called when the join pill is pressed.
  final VoidCallback? onJoin;

  /// Padding on every edge — `padding: 16`.
  static const double padding = DabblerSpacing.space4 + 4;

  /// The speaker avatar — `width: 36`.
  static const double avatarSide = 36;

  /// The speaking badge — `width: 16`.
  static const double badgeSide = 16;

  /// The badge's ring — `2px solid var(--neutral-100)`.
  static const double badgeRing = 2;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextStyle footnote = DabblerType.footnote.resolveForDirection(
      direction,
    );
    final TextStyle caption1 = DabblerType.caption1.resolveForDirection(
      direction,
    );

    Widget pill({
      required Widget child,
      required Color fill,
      required EdgeInsetsGeometry padding,
      Color? border,
      VoidCallback? onTap,
      required String label,
    }) {
      final Widget p = DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: DabblerRadius.pillAll,
          border: border == null
              ? null
              : Border.all(color: border, width: DabblerSizing.borderDefault),
        ),
        child: Padding(padding: padding, child: child),
      );
      if (onTap == null) return p;
      return Semantics(
        button: true,
        label: label,
        onTap: onTap,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: MouseRegion(cursor: SystemMouseCursors.click, child: p),
          ),
        ),
      );
    }

    final Widget top = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: footnote.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DabblerSpacing.space4),
        pill(
          fill: colors.surfaceCard,
          border: colors.borderDefault,
          padding: const EdgeInsets.symmetric(
            vertical: DabblerSpacing.space2,
            horizontal: DabblerSpacing.space4,
          ),
          onTap: onMute,
          label: muteLabel,
          child: Text(
            muteLabel,
            style: caption1.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );

    final Widget speaker = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: avatarSide + 4,
          height: avatarSide + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              SizedBox(
                width: avatarSide,
                height: avatarSide,
                child: DabblerAvatar(
                  seed: speakerSeed,
                  size: DabblerAvatarSize.sm,
                ),
              ),
              PositionedDirectional(
                start: 22,
                top: 22,
                child: Container(
                  width: badgeSide,
                  height: badgeSide,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.brandPrimary,
                    border: Border.all(
                      color: colors.bgPrimary,
                      width: badgeRing,
                    ),
                  ),
                  child: DabblerIcon(
                    'microphone-2',
                    weight: DabblerIconWeight.bold,
                    size: 12,
                    color: colors.onBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DabblerSpacing.space2 + 2),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.brandPrimary,
          ),
          child: const SizedBox(width: 8, height: 8),
        ),
        const SizedBox(width: 4),
        Text(
          speakingLabel,
          style: caption1.copyWith(color: colors.textSecondary),
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.cardAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            top,
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: DabblerSpacing.space4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  speaker,
                  pill(
                    fill: colors.brandPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: DabblerSpacing.space2 + 2,
                      horizontal: DabblerSpacing.space4 + 8,
                    ),
                    onTap: onJoin,
                    label: joinLabel,
                    child: Text(
                      joinLabel,
                      style: footnote.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onBrand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
