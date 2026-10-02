import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// Messaging foundations — not a component.
///
/// Ported from the live design project's `components/messaging/messaging.jsx`
/// (design system 1.2.0): the conversation spacing rhythm, the four semantic
/// maps every messaging component reads (kind glyph, activity status, delivery
/// state, reactions) and the shared press behaviour. The source also injects a
/// stylesheet for a keyframe, a scrollbar rule and two line clamps; Flutter
/// needs none of that — the typing dots animate in their own widget, scrollbars
/// are not drawn and clamps are `maxLines`.
abstract final class DabblerMessagingSpacing {
  const DabblerMessagingSpacing._();

  /// `timelineInline` — 12, the timeline's gutters.
  static const double timelineInline = DabblerSpacing.space4;

  /// `timelineBlock` — 12, the timeline's top and bottom.
  static const double timelineBlock = DabblerSpacing.space4;

  /// `groupGap` — 12, between sender groups.
  static const double groupGap = DabblerSpacing.space4;

  /// `messageGap` — 3, inside one sender group.
  static const double messageGap = DabblerSpacing.space1;

  /// `avatarGap` — 6, avatar to bubble.
  static const double avatarGap = DabblerSpacing.space2;

  /// `avatarGutter` — 28, the avatar column an `xs` avatar occupies.
  static const double avatarGutter = 28;

  /// `senderGap` — 3, sender name to content.
  static const double senderGap = DabblerSpacing.space1;

  /// `replyGap` — 6, reply reference to content.
  static const double replyGap = DabblerSpacing.space2;

  /// `metaGap` — 3, content to metadata.
  static const double metaGap = DabblerSpacing.space1;

  /// `reactionGap` — 0, the reaction row's 45px target already spaces it.
  static const double reactionGap = 0;

  /// `systemBlock` — 3, system message padding.
  static const double systemBlock = DabblerSpacing.space1;

  /// `bubbleInline` — 12, the bubble's inline padding.
  static const double bubbleInline = DabblerSpacing.space4;

  /// `bubbleBlock` — 9, the bubble's block padding.
  static const double bubbleBlock = DabblerSpacing.space3;
}

/// What a conversation is — `KIND_GLYPH` in the source.
enum DabblerConversationKind {
  /// One person; no kind glyph.
  player(null),

  /// A squad — the `people` glyph.
  squad('people'),

  /// A huddle — the `global` glyph.
  huddle('global'),

  /// A game — the sport glyph instead of an Iconsax name.
  game(null);

  const DabblerConversationKind(this.glyph);

  /// The Iconsax glyph on the avatar's kind tile, or null.
  final String? glyph;
}

/// Activity status shown on a shared game and a conversation context —
/// `GAME_STATUS` in the source. `open`, `full` and `completed` are labels, not
/// severities, so they take the neutral tint; only three statuses earn colour.
enum DabblerActivityStatus {
  /// `Open`, neutral.
  open('Open', null),

  /// `Full`, neutral.
  full('Full', null),

  /// `Confirmed`, success.
  confirmed('Confirmed', DabblerStatusTone.success),

  /// `Starting soon`, warning.
  soon('Starting soon', DabblerStatusTone.warning),

  /// `In progress`, success.
  live('In progress', DabblerStatusTone.success),

  /// `Completed`, neutral.
  completed('Completed', null),

  /// `Cancelled`, error.
  cancelled('Cancelled', DabblerStatusTone.error);

  const DabblerActivityStatus(this.label, this.tone);

  /// The default English label.
  final String label;

  /// The semantic tone, or null for the neutral tint.
  final DabblerStatusTone? tone;
}

/// Delivery metadata — `DELIVERY` in the source. Never a dominant treatment.
enum DabblerDeliveryState {
  /// In flight.
  sending('clock', DabblerIconWeight.linear),

  /// Handed to the server.
  sent('tick-circle', DabblerIconWeight.linear),

  /// Reached the recipient.
  delivered('tick-circle', DabblerIconWeight.bold),

  /// Seen.
  read('tick-circle', DabblerIconWeight.bold),

  /// Not sent.
  failed('danger', DabblerIconWeight.bold);

  const DabblerDeliveryState(this.icon, this.weight);

  /// The Iconsax glyph.
  final String icon;

  /// Linear or bold.
  final DabblerIconWeight weight;

  /// The glyph colour. Source tones and the roles they resolve to:
  ///
  /// | `DELIVERY` tone | Role | Light value |
  /// |---|---|---|
  /// | `--muted` (sending, sent) | [DabblerColors.textTertiary] | `#8C8C8C` |
  /// | `--ink-soft` (delivered) | [DabblerColors.textSecondary] | `#404040` |
  /// | `--color-brand-primary` (read) | [DabblerColors.brandPrimary] | theme |
  /// | `--color-status-error-strong` (failed) | error `strong` | theme |
  ///
  /// The glyph is an icon, not text, so `--muted` takes the tertiary role
  /// (D-003(a): `--muted` is the light tertiary value, legitimate for icons),
  /// and `--ink-soft` takes the secondary role, which resolves to exactly
  /// `--ink-soft` in light and follows dark mode (the earlier port used the
  /// light-only `DabblerPalette.inkSoft` literal). This keeps the source's
  /// sent/delivered contrast: same glyph family, lighter tone until delivered.
  Color colorFor(DabblerColors colors) => switch (this) {
    sending || sent => colors.textTertiary,
    delivered => colors.textSecondary,
    read => colors.brandPrimary,
    failed => colors.error.strong,
  };
}

/// One coordination reaction — `REACTIONS` in the source. Iconsax glyphs, not
/// emoji: the system's content rule is no emoji, ever.
@immutable
class DabblerReactionDef {
  /// A reaction definition.
  const DabblerReactionDef(this.key, this.icon, this.label);

  /// The stable key reported to callers.
  final String key;

  /// The Iconsax glyph.
  final String icon;

  /// The accessible name.
  final String label;
}

/// The reaction set.
abstract final class DabblerReactions {
  const DabblerReactions._();

  /// The six reactions, in the source's order.
  static const List<DabblerReactionDef> all = <DabblerReactionDef>[
    DabblerReactionDef('in', 'tick-circle', "I'm in"),
    DabblerReactionDef('late', 'clock', 'Running late'),
    DabblerReactionDef('out', 'close-circle', "Can't make it"),
    DabblerReactionDef('like', 'like-1', 'Nice'),
    DabblerReactionDef('heart', 'heart', 'Love it'),
    DabblerReactionDef('star', 'star', 'Standout'),
  ];

  /// The definition for [key]. The source's `REACTION_BY_KEY[key]` yields
  /// `undefined` for an unknown key; this port falls back to the first
  /// definition instead so a caller can never render an empty pill.
  static DabblerReactionDef byKey(String key) => all.firstWhere(
    (DabblerReactionDef r) => r.key == key,
    orElse: () => all.first,
  );
}

/// Press, focus ring and keyboard activation around a tappable child — the
/// shared interaction every messaging control uses (`usePress` in the source,
/// plus the system's focus ring and press scale).
class DabblerMessagingTap extends StatefulWidget {
  /// Wraps [child]. A null [onTap] makes the child inert and unfocusable.
  const DabblerMessagingTap({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
    this.selected,
    this.ringRadius = DabblerRadius.smAll,
    this.scale = true,
  });

  /// Called on tap, Enter and Space.
  final VoidCallback? onTap;

  /// The control's visual.
  final Widget child;

  /// The accessible name.
  final String? label;

  /// Pressed/selected semantics for toggles.
  final bool? selected;

  /// The focus ring's corner radius.
  final BorderRadius ringRadius;

  /// Whether the press scale applies.
  final bool scale;

  @override
  State<DabblerMessagingTap> createState() => _DabblerMessagingTapState();
}

class _DabblerMessagingTapState extends State<DabblerMessagingTap> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return Semantics(label: widget.label, child: widget.child);
    }
    Widget visual = DabblerFocusRing.visible(
      visible: _focused,
      borderRadius: widget.ringRadius,
      child: widget.child,
    );
    if (widget.scale) {
      visual = DabblerPressScale(pressed: _pressed, child: visual);
    }
    return Semantics(
      button: true,
      toggled: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onTap!();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: visual,
          ),
        ),
      ),
    );
  }
}
