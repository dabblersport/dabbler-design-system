import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// What a speaker's corner badge shows in a [DabblerSpeakerGrid].
enum DabblerSpeakerBadge {
  /// No badge.
  none,

  /// The bold `microphone-2` icon on the brand fill — an active speaker.
  speaking,

  /// A plus on the accent fill — someone you can invite.
  invite,
}

/// One participant of a [DabblerSpeakerGrid].
@immutable
class DabblerSpeaker {
  /// A speaker cell.
  const DabblerSpeaker({
    required this.name,
    this.seed,
    this.badge = DabblerSpeakerBadge.none,
  });

  /// The name under the avatar.
  final String name;

  /// The avatar seed; defaults to [name].
  final String? seed;

  /// The corner badge.
  final DabblerSpeakerBadge badge;
}

/// SpeakerGrid — the room's speakers in a three-column grid: a 64px avatar with
/// an optional corner badge and a name under each.
///
/// Ported from the live design project's `components/rooms/SpeakerGrid.jsx`
/// (Figma node `8:51`, design system 1.2.0): 96px columns, 88px rows, a 16px
/// gap, avatars 64, badges 24 with a 2px ring, names `caption-1` at weight 600.
/// The source hard-codes six cells in a `320 x 192` frame; this widget takes
/// any number of [speakers] and adds rows as needed.
///
/// The `7px`/`11px` badge texts in the source (Inter) are never the visible
/// content — each cell's badge child is the icon or a `+`; the `+` is drawn here
/// in `caption-2` weight 700, and the Inter family is not applied (the cxo
/// ruling refuses a family override).
class DabblerSpeakerGrid extends StatelessWidget {
  /// A speaker grid.
  const DabblerSpeakerGrid({super.key, required this.speakers});

  /// The cells, row-major.
  final List<DabblerSpeaker> speakers;

  /// Columns — `gridTemplateColumns: '96px 96px 96px'`.
  static const int columns = 3;

  /// Cell width — `width: 96`.
  static const double cellWidth = 96;

  /// Row height — `gridTemplateRows: '88px 88px'`.
  static const double rowHeight = 88;

  /// Gap between cells — `gap: '16px 16px'`.
  static const double gap = DabblerSpacing.space4 + 4;

  /// The avatar — `width: 64`.
  static const double avatarSide = 64;

  /// The badge — `width: 24`.
  static const double badgeSide = 24;

  /// The badge's offset from the avatar's start and top — `left: 42, top: 42`.
  static const double badgeOffset = 42;

  /// The badge ring — `2px solid var(--neutral-100)`.
  static const double badgeRing = 2;

  /// The gap between avatar and name — `gap: 6`.
  static const double nameGap = DabblerSpacing.space2;

  /// The fill of [badge].
  static Color badgeFillFor(DabblerColors colors, DabblerSpeakerBadge badge) =>
      switch (badge) {
        DabblerSpeakerBadge.none => const Color.fromARGB(0, 0, 0, 0),
        DabblerSpeakerBadge.speaking => colors.brandPrimary,
        DabblerSpeakerBadge.invite => DabblerPalette.activeP600,
      };

  @override
  Widget build(BuildContext context) {
    final int rows = (speakers.length + columns - 1) ~/ columns;
    final double height =
        rows == 0 ? 0 : rows * rowHeight + (rows - 1) * gap;
    return SizedBox(
      width: columns * cellWidth + (columns - 1) * gap,
      height: height,
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < speakers.length; i++)
            PositionedDirectional(
              start: (i % columns) * (cellWidth + gap),
              top: (i ~/ columns) * (rowHeight + gap),
              width: cellWidth,
              height: rowHeight,
              child: _Cell(speaker: speakers[i]),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.speaker});

  final DabblerSpeaker speaker;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return Semantics(
      label: speaker.badge == DabblerSpeakerBadge.speaking
          ? '${speaker.name}, speaking'
          : speaker.name,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: DabblerSpeakerGrid.avatarSide,
            height: DabblerSpeakerGrid.avatarSide,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  width: DabblerSpeakerGrid.avatarSide,
                  height: DabblerSpeakerGrid.avatarSide,
                  child: DabblerAvatar(
                    seed: speaker.seed ?? speaker.name,
                    size: DabblerAvatarSize.lg,
                  ),
                ),
                if (speaker.badge != DabblerSpeakerBadge.none)
                  PositionedDirectional(
                    start: DabblerSpeakerGrid.badgeOffset,
                    top: DabblerSpeakerGrid.badgeOffset,
                    child: Container(
                      width: DabblerSpeakerGrid.badgeSide,
                      height: DabblerSpeakerGrid.badgeSide,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DabblerSpeakerGrid.badgeFillFor(
                          colors,
                          speaker.badge,
                        ),
                        border: Border.all(
                          color: colors.bgPrimary,
                          width: DabblerSpeakerGrid.badgeRing,
                        ),
                      ),
                      child: speaker.badge == DabblerSpeakerBadge.speaking
                          ? DabblerIcon(
                              'microphone-2',
                              weight: DabblerIconWeight.bold,
                              size: 12,
                              color: DabblerPalette.paper,
                            )
                          : Text(
                              '+',
                              style: DabblerType.caption2
                                  .resolveForDirection(direction)
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: DabblerPalette.paper,
                                  ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DabblerSpeakerGrid.nameGap),
          Text(
            speaker.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DabblerType.caption1
                .resolveForDirection(direction)
                .copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
