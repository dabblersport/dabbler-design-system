import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_auto_direction.dart';
import 'messaging_foundations.dart';
import 'message_receipts.dart';
import 'messaging_parts.dart';

part 'message_models.dart';
part 'message_bubble_body.dart';
part 'message_meta.dart';

/// Message — the canonical message.
///
/// Ported from the live design project's `components/messaging/Message.jsx` and
/// `Message.d.ts` (design system 1.2.0). One component covers incoming and
/// outgoing, direct and group, text, reply, image and shared-object content and
/// every delivery state. Geometry, grouping radii and vertical rhythm are owned
/// here; no screen sets its own. Every axis is logical, so the layout mirrors
/// in Arabic with no RTL prop.
///
/// Radius encodes grouping: free corners stay [DabblerRadius.xl], the corner on
/// the sender's own side tightens to [DabblerRadius.sm] where a message
/// continues a group, and the block-end own corner is always the tail.
///
/// Delivery metadata is outgoing-only (messaging §11, KAN-580). In `direct`
/// context every state shows as a glyph, and the newest outgoing message also
/// spells the word ([showDeliveryLabel]). In `group` context sending, retrying
/// and failed behave as in direct; once the server has the message the glyph is
/// replaced by one compact [receipt] count ("Seen by 4 of 9") that opens the
/// Message info drawer through [onReceipts]. Incoming messages never show
/// either.
///
/// A [fresh] message fades in over `--motion-slow`; a sending or retrying
/// bubble dims to [sendingOpacity] over `--motion-base`. Both hold still under
/// reduced motion.
///
/// Source: live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
/// (Dabbler Design System), files `components/messaging/Message.jsx` and
/// `Message.prompt.md`, read via DesignSync get_file on 2026-10-02 and
/// transcribed to a local mirror by the coordinator.
///
/// | Source | Dart |
/// |---|---|
/// | bubble `padding: 9px 12px` (`bubbleBlock`/`bubbleInline`) | [DabblerMessagingSpacing.bubbleBlock] / [DabblerMessagingSpacing.bubbleInline] |
/// | bare attachment `padding: var(--space-1)`, transparent, no border | `EdgeInsets.all(3)`, no fill, no border |
/// | column `maxWidth: '76%'` of the row / `288` bare | [maxWidthFraction] of the full row width / [bareMaxWidth] |
/// | `--radius-xl` free corners, `--radius-sm` own block-end tail, own block-start `sm` when not leading | [radiusFor] (logical corners) |
/// | avatar column `28px`, gap `--space-2` | [DabblerMessagingSpacing.avatarGutter] / [DabblerMessagingSpacing.avatarGap] |
/// | column `gap: --space-1` (sender, bubble, reactions, meta) | 3px before each following child |
/// | bubble `gap: --space-2` (reply, attachment, content) | [DabblerMessagingSpacing.replyGap] |
/// | image slot 232x156, `--radius-lg`; shared object 268 wide | [imageSize], [DabblerRadius.lgAll]; [objectWidth] |
/// | `opacity: 0.7` while sending, `--motion-base` | [sendingOpacity], `AnimatedOpacity` over [DabblerMotion.base] |
/// | `outline: 2px solid brand`, offset 2 | [selectedOutline] at [selectedOutlineOffset], painted outside layout |
/// | `scale(--press-scale)` while held, only with `onPress` and not readOnly | [DabblerMessagingTap] |
/// | meta `t-caption-1`, `--muted`, failure `--color-status-error-strong` | `DabblerType.caption1`, `textSecondary` (D-003(a)), `error.strong` |
/// | delivery glyph size 14, tone per `DELIVERY` | [deliveryGlyph], [DabblerDeliveryState.colorFor] |
/// | Retry button, weight 700, `--touch-target-min` | [retryKey] target, 45 min height |
///
/// Deviation: the source's Retry button pulls itself into the metadata line
/// with negative margins (`marginInline: -9px`, `marginBlock: -(45-16)/2`), so
/// its 45px target overlaps neighbours without growing the line. Flutter has
/// no negative margin and cannot hit-test outside a box's layout, so the
/// visual inline position is kept (3px gap, no inline padding) and the line
/// grows to the 45px target height when Retry shows.
class DabblerMessage extends StatelessWidget {
  /// A message.
  const DabblerMessage({
    super.key,
    this.direction = DabblerMessageDirection.incoming,
    this.context = DabblerMessageContext.direct,
    this.groupPosition = DabblerGroupPosition.single,
    this.sender,
    this.avatarSeed,
    this.content,
    this.attachment,
    this.reply,
    this.timestamp,
    this.edited = false,
    this.editedLabel = 'edited',
    this.deliveryState,
    this.receipt,
    this.onReceipts,
    this.showDeliveryLabel = false,
    this.deliveryLabel,
    this.lang = 'en',
    this.fresh = false,
    this.reactions = const <DabblerMessageReaction>[],
    this.state = DabblerMessageState.normal,
    this.showSender,
    this.showAvatar,
    this.onPress,
    this.onReact,
    this.onRetry,
    this.retryLabel,
  });

  /// Ownership.
  final DabblerMessageDirection direction;

  /// Conversation context. (Named `context` as in the source; inside `build`
  /// the [BuildContext] parameter is `buildContext`.)
  final DabblerMessageContext context;

  /// Position within a same-sender run.
  final DabblerGroupPosition groupPosition;

  /// The sender's name.
  final String? sender;

  /// The avatar seed; defaults to [sender].
  final String? avatarSeed;

  /// The text. Optional when an [attachment] is present.
  final String? content;

  /// An image or shared object.
  final DabblerMessageAttachment? attachment;

  /// A quoted message.
  final DabblerReplySpec? reply;

  /// The timestamp text.
  final String? timestamp;

  /// Whether the message was edited.
  final bool edited;

  /// The `edited` text.
  final String editedLabel;

  /// Delivery metadata.
  final DabblerDeliveryState? deliveryState;

  /// Group receipt tally. Used for an outgoing group message once it is no
  /// longer in flight; ignored in direct context and for incoming messages.
  final DabblerReceipt? receipt;

  /// Opens the Message info drawer. The receipt count is a 45px button when
  /// this is set and plain text when it is null.
  final VoidCallback? onReceipts;

  /// Spells the delivery word beside the glyph (the newest outgoing message in
  /// a direct chat). A failed message always spells it.
  final bool showDeliveryLabel;

  /// Overrides the delivery word, for a language beyond `en` and `ar`.
  final String? deliveryLabel;

  /// `en` or `ar`, for the default delivery and receipt words.
  final String lang;

  /// A message that has just arrived: it fades in over `--motion-slow`.
  final bool fresh;

  /// Reaction tallies.
  final List<DabblerMessageReaction> reactions;

  /// Normal, selected or read-only.
  final DabblerMessageState state;

  /// Overrides the automatic sender-name rule.
  final bool? showSender;

  /// Overrides the automatic avatar rule.
  final bool? showAvatar;

  /// The long-press / tap target for the message action sheet.
  final VoidCallback? onPress;

  /// Called with a reaction key.
  final ValueChanged<String>? onReact;

  /// Shown as a Retry action when [deliveryState] is `failed`.
  final VoidCallback? onRetry;

  /// The retry text; defaults to the [lang] word.
  final String? retryLabel;

  /// The share of the row a bubble may take — `maxWidth: '76%'`.
  static const double maxWidthFraction = 0.76;

  /// The width cap of a bare attachment — `maxWidth: 288`.
  static const double bareMaxWidth = 288;

  /// An image attachment's size — `width: 232, height: 156`.
  static const Size imageSize = Size(232, 156);

  /// A shared object's width — `width: 268`.
  static const double objectWidth = 268;

  /// The selected outline — `2px`.
  static const double selectedOutline = 2;

  /// The selected outline's offset — `var(--focus-ring-offset, 2px)`.
  static const double selectedOutlineOffset = 2;

  /// Identifies the selected outline's box (for tests and tooling).
  static const Key selectedOutlineKey = ValueKey<String>('message-selected');

  /// Identifies the retry target.
  static const Key retryKey = ValueKey<String>('message-retry');

  /// Identifies the group receipt count.
  static const Key receiptsKey = ValueKey<String>('message-receipts');

  static BorderRadiusDirectional _grow(BorderRadiusDirectional r, double by) {
    Radius g(Radius x) => Radius.circular(x.x + by);
    return BorderRadiusDirectional.only(
      topStart: g(r.topStart),
      topEnd: g(r.topEnd),
      bottomStart: g(r.bottomStart),
      bottomEnd: g(r.bottomEnd),
    );
  }

  /// The delivery glyph — `size={14}`.
  static const double deliveryGlyph = 14;

  /// Opacity while sending — `opacity: 0.7`.
  static const double sendingOpacity = 0.7;

  /// Whether the group lead rule applies at [position].
  static bool leads(DabblerGroupPosition position) =>
      position == DabblerGroupPosition.single ||
      position == DabblerGroupPosition.first;

  /// Whether the metadata rule applies at [position].
  static bool trails(DabblerGroupPosition position) =>
      position == DabblerGroupPosition.single ||
      position == DabblerGroupPosition.last;

  /// The bubble's grouped corner radii.
  static BorderRadiusDirectional radiusFor({
    required bool outgoing,
    required DabblerGroupPosition position,
  }) {
    const Radius xl = Radius.circular(DabblerRadius.xl);
    const Radius sm = Radius.circular(DabblerRadius.sm);
    final bool tight = !leads(position);
    return outgoing
        ? BorderRadiusDirectional.only(
            topStart: xl,
            bottomStart: xl,
            topEnd: tight ? sm : xl,
            bottomEnd: sm,
          )
        : BorderRadiusDirectional.only(
            topEnd: xl,
            bottomEnd: xl,
            topStart: tight ? sm : xl,
            bottomStart: sm,
          );
  }

  @override
  Widget build(BuildContext buildContext) {
    final DabblerColors colors = DabblerColors.of(buildContext);
    final TextDirection dir = Directionality.of(buildContext);
    final bool out = direction == DabblerMessageDirection.outgoing;
    final bool group = context == DabblerMessageContext.group;
    final bool lead = leads(groupPosition);
    final bool withAvatar = showAvatar ?? (!out && group && lead);
    final bool withSender = showSender ?? (!out && group && lead);
    final bool selected = state == DabblerMessageState.selected;
    final bool readOnly = state == DabblerMessageState.readOnly;
    final bool bare =
        attachment != null && (content == null || content!.isEmpty);
    final bool interactive = onPress != null && !readOnly;
    final Color ink = out ? colors.onBrand : colors.textPrimary;

    final Widget bubbleBody = _bubbleBody(dir, ink, out);

    Widget bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: bare
            ? null
            : out
            ? colors.brandPrimary
            : colors.surfaceCard,
        borderRadius: radiusFor(outgoing: out, position: groupPosition),
        border: (out || bare)
            ? null
            : Border.all(
                color: colors.borderDefault,
                width: DabblerSizing.borderDefault,
              ),
      ),
      child: Padding(
        padding: bare
            ? const EdgeInsets.all(DabblerSpacing.space1)
            : const EdgeInsets.symmetric(
                vertical: DabblerMessagingSpacing.bubbleBlock,
                horizontal: DabblerMessagingSpacing.bubbleInline,
              ),
        child: bubbleBody,
      ),
    );
    if (selected) {
      // CSS `outline` takes no layout space: draw the 2px ring outside the
      // bubble at the 2px offset, its corners grown by the same outset.
      const double outset = selectedOutlineOffset + selectedOutline;
      bubble = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          bubble,
          Positioned(
            left: -outset,
            top: -outset,
            right: -outset,
            bottom: -outset,
            child: IgnorePointer(
              child: DecoratedBox(
                key: selectedOutlineKey,
                decoration: BoxDecoration(
                  borderRadius: _grow(
                    radiusFor(outgoing: out, position: groupPosition),
                    outset,
                  ),
                  border: Border.all(
                    color: colors.brandPrimary,
                    width: selectedOutline,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    bubble = AnimatedOpacity(
      opacity: (deliveryState?.inFlight ?? false) ? sendingOpacity : 1,
      duration: DabblerMotion.reduceMotion(buildContext)
          ? Duration.zero
          : DabblerMotion.base,
      curve: DabblerMotion.easeOut,
      child: bubble,
    );
    if (interactive) {
      bubble = DabblerMessagingTap(
        onTap: onPress,
        label: content,
        ringRadius: radiusFor(
          outgoing: out,
          position: groupPosition,
        ).resolve(dir),
        child: bubble,
      );
    }

    final Widget? meta = _meta(buildContext, colors, dir);

    final Widget column = Column(
      crossAxisAlignment: out
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (withSender && sender != null)
          Padding(
            padding: const EdgeInsets.only(
              left: DabblerSpacing.space1,
              right: DabblerSpacing.space1,
              bottom: DabblerMessagingSpacing.senderGap,
            ),
            child: Text(
              sender!,
              style: DabblerType.caption1
                  .resolveForDirection(dir)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
            ),
          ),
        bubble,
        if (reactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: DabblerSpacing.space1,
              right: DabblerSpacing.space1,
              top: DabblerMessagingSpacing.metaGap,
            ),
            child: DabblerReactionGroup(
              reactions: reactions,
              onToggle: onReact,
            ),
          ),
        ?meta,
      ],
    );

    final Widget row = LayoutBuilder(
      builder: (BuildContext c, BoxConstraints box) {
        final double avail = box.maxWidth.isFinite ? box.maxWidth : 400;
        // `maxWidth: '76%'` on a flex item resolves against the row's full
        // width, avatar gutter included.
        final double maxW = bare ? bareMaxWidth : avail * maxWidthFraction;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: out
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            if (!out && group) ...<Widget>[
              SizedBox(
                width: DabblerMessagingSpacing.avatarGutter,
                child: withAvatar
                    ? DabblerAvatar(
                        seed: avatarSeed ?? sender,
                        size: DabblerAvatarSize.xs,
                      )
                    : null,
              ),
              const SizedBox(width: DabblerMessagingSpacing.avatarGap),
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: column,
              ),
            ),
          ],
        );
      },
    );
    if (!fresh || DabblerMotion.reduceMotion(buildContext)) return row;
    // `dbl-fade-in` over `--motion-slow` under `--ease-out`: opacity only, so
    // the arriving row takes exactly the box a typing row held.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
      builder: (BuildContext _, double v, Widget? child) =>
          Opacity(opacity: v, child: child),
      child: row,
    );
  }
}
