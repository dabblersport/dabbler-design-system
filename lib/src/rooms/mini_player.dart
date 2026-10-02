import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The colour role of a [DabblerMiniPlayerAction] glyph.
enum DabblerMiniPlayerTone {
  /// `--pink-600` in the source's heart.
  accent,

  /// `--neutral-700`, the muted ink.
  muted,

  /// `--purple-600`, the brand colour.
  brand,
}

/// One trailing glyph of a [DabblerMiniPlayer].
@immutable
class DabblerMiniPlayerAction {
  /// A glyph button.
  const DabblerMiniPlayerAction({
    required this.icon,
    required this.label,
    this.weight = DabblerIconWeight.linear,
    this.tone = DabblerMiniPlayerTone.muted,
    this.onTap,
  });

  /// The Iconsax name.
  final String icon;

  /// The accessible name.
  final String label;

  /// Linear or bold.
  final DabblerIconWeight weight;

  /// The glyph colour role.
  final DabblerMiniPlayerTone tone;

  /// Called when pressed; null leaves it decorative.
  final VoidCallback? onTap;
}

/// MiniPlayer — the collapsed room player: two speaker avatars, one caption
/// line and a row of trailing glyph actions.
///
/// Ported from the live design project's `components/rooms/MiniPlayer.jsx`
/// (Figma node `8:49`, design system 1.2.0). It owns no audio and no room
/// state; everything is injected.
///
/// ## Type, per the cxo ruling
///
/// The only text is the caption: `caption-1` 12/16 with a weight 600 override
/// (the source is 12/18/600; the leading snaps to the ramp). The three `18/28`
/// spans in the source at weight 400 are **icon slots** — `JSX` renders a heart
/// icon, an up-arrow glyph and a message icon in them — so they are drawn as
/// icons here, not sized from a text style.
class DabblerMiniPlayer extends StatelessWidget {
  /// A mini player.
  const DabblerMiniPlayer({
    super.key,
    required this.caption,
    this.avatarSeeds = const <String>[],
    this.actions = const <DabblerMiniPlayerAction>[],
  });

  /// The caption, e.g. `Design room · 134 listening`.
  final String caption;

  /// The speaker avatars, leading, overlapped.
  final List<String> avatarSeeds;

  /// The trailing glyph actions.
  final List<DabblerMiniPlayerAction> actions;

  /// Corner radius — `borderRadius: 16`.
  static const double radius = DabblerRadius.card;

  /// Avatar diameter — `width: 28`.
  static const double avatarSide = 28;

  /// How far each avatar steps from the last — the source overlaps by 6.
  static const double avatarStep = 22;

  /// The action glyph size — `size={18}`.
  static const double glyphSize = DabblerSizing.iconSm;

  /// The caption's weight — `fontWeight: 600`.
  static const FontWeight captionWeight = FontWeight.w600;

  /// The glyph colour of [tone].
  static Color toneColor(DabblerColors colors, DabblerMiniPlayerTone tone) =>
      switch (tone) {
        DabblerMiniPlayerTone.accent => colors.accent,
        DabblerMiniPlayerTone.muted => colors.textSecondary,
        DabblerMiniPlayerTone.brand => colors.brandPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final double stackWidth = avatarSeeds.isEmpty
        ? 0
        : avatarSide + (avatarSeeds.length - 1) * avatarStep;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.all(Radius.circular(radius)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space4,
          horizontal: DabblerSpacing.space4 + 4,
        ),
        child: Row(
          children: <Widget>[
            if (avatarSeeds.isNotEmpty) ...<Widget>[
              SizedBox(
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
                            size: DabblerAvatarSize.xs,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: DabblerSpacing.space4),
            ],
            Expanded(
              child: Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(
                      fontWeight: captionWeight,
                      color: colors.textPrimary,
                    ),
              ),
            ),
            for (final DabblerMiniPlayerAction a in actions) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space4),
              _ActionButton(action: a),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.action});

  final DabblerMiniPlayerAction action;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerMiniPlayerAction a = widget.action;
    final Widget glyph = DabblerIcon(
      a.icon,
      weight: a.weight,
      size: DabblerMiniPlayer.glyphSize,
      color: DabblerMiniPlayer.toneColor(colors, a.tone),
    );
    if (a.onTap == null) {
      return Semantics(label: a.label, image: true, child: glyph);
    }
    return Semantics(
      button: true,
      label: a.label,
      onTap: a.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                a.onTap!();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: a.onTap,
            onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: SizedBox(
              width: DabblerSizing.touchTargetMin,
              height: DabblerSizing.touchTargetMin,
              child: Center(
                child: DabblerFocusRing.visible(
                  visible: _focused,
                  borderRadius: DabblerRadius.smAll,
                  child: DabblerPressScale(pressed: _pressed, child: glyph),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
