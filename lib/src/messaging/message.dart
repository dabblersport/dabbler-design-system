import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'messaging_foundations.dart';
import 'messaging_parts.dart';

/// Ownership of a [DabblerMessage]. Outgoing fills with brand and aligns to the
/// inline end.
enum DabblerMessageDirection {
  /// From someone else.
  incoming,

  /// From the viewer.
  outgoing,
}

/// The conversation context. `group` adds the avatar gutter and sender name.
enum DabblerMessageContext {
  /// One other person.
  direct,

  /// Several people.
  group,
}

/// Position within a same-sender run. Set by `DabblerMessageThread`.
enum DabblerGroupPosition {
  /// Alone.
  single,

  /// The run's first.
  first,

  /// Inside a run.
  middle,

  /// The run's last.
  last,
}

/// A message's interaction state.
enum DabblerMessageState {
  /// Normal.
  normal,

  /// Draws the brand outline.
  selected,

  /// Disables interaction.
  readOnly,
}

/// The quoted message of a reply.
@immutable
class DabblerReplySpec {
  /// A reply spec.
  const DabblerReplySpec({this.sender = '', this.content, this.attachmentLabel});

  /// Who wrote the quoted message.
  final String sender;

  /// The quoted text.
  final String? content;

  /// Set instead of [content] when the quoted message was an attachment.
  final String? attachmentLabel;
}

/// What a message carries besides text.
@immutable
class DabblerMessageAttachment {
  /// An image, supplied by the caller and drawn 232x156 with a 12px corner.
  const DabblerMessageAttachment.image({required this.child})
      : isImage = true;

  /// A shared game, venue or player.
  const DabblerMessageAttachment.object(DabblerSharedObjectCard card)
      : child = card,
        isImage = false;

  /// The attachment's widget.
  final Widget child;

  /// Whether this is an image.
  final bool isImage;
}

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
/// Delivery metadata is outgoing-only, and in `group` context only `sending`
/// and `failed` surface.
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
    this.reactions = const <DabblerMessageReaction>[],
    this.state = DabblerMessageState.normal,
    this.showSender,
    this.showAvatar,
    this.onPress,
    this.onReact,
    this.onRetry,
    this.retryLabel = 'Retry',
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

  /// The retry text.
  final String retryLabel;

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
    final bool failed = deliveryState == DabblerDeliveryState.failed;
    final bool selected = state == DabblerMessageState.selected;
    final bool readOnly = state == DabblerMessageState.readOnly;
    final bool bare = attachment != null && (content == null || content!.isEmpty);
    final bool interactive = onPress != null && !readOnly;
    final Color ink = out ? colors.onBrand : colors.textPrimary;

    final Widget bubbleBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (reply != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: (attachment != null || (content?.isNotEmpty ?? false))
                  ? DabblerMessagingSpacing.replyGap
                  : 0,
            ),
            child: DabblerMessageReplyReference(
              sender: reply!.sender,
              content: reply!.content,
              attachmentLabel: reply!.attachmentLabel,
              variant: out
                  ? DabblerReplyVariant.onBrand
                  : DabblerReplyVariant.message,
            ),
          ),
        if (attachment != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: (content?.isNotEmpty ?? false)
                  ? DabblerMessagingSpacing.replyGap
                  : 0,
            ),
            child: attachment!.isImage
                ? ClipRRect(
                    borderRadius: DabblerRadius.lgAll,
                    child: SizedBox(
                      width: imageSize.width,
                      height: imageSize.height,
                      child: attachment!.child,
                    ),
                  )
                : SizedBox(width: objectWidth, child: attachment!.child),
          ),
        if (content != null && content!.isNotEmpty)
          Text(
            content!,
            style: DabblerType.subheadline
                .resolveForDirection(dir)
                .copyWith(color: ink),
          ),
      ],
    );

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
      bubble = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radiusFor(outgoing: out, position: groupPosition),
          border: Border.all(color: colors.brandPrimary, width: selectedOutline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DabblerSpacing.space1 - 1),
          child: bubble,
        ),
      );
    }
    if (deliveryState == DabblerDeliveryState.sending) {
      bubble = Opacity(opacity: sendingOpacity, child: bubble);
    }
    if (interactive) {
      bubble = DabblerMessagingTap(
        onTap: onPress,
        label: content,
        ringRadius: radiusFor(outgoing: out, position: groupPosition)
            .resolve(dir),
        child: bubble,
      );
    }

    final DabblerDeliveryState? d = deliveryState;
    final bool showDelivery = out &&
        d != null &&
        (context == DabblerMessageContext.direct ||
            d == DabblerDeliveryState.sending ||
            failed);
    final bool withMeta = trails(groupPosition) &&
        (timestamp != null || showDelivery || edited);
    final Color metaColor = failed ? colors.error.strong : colors.textSecondary;
    final TextStyle caption1 =
        DabblerType.caption1.resolveForDirection(dir);

    final Widget column = Column(
      crossAxisAlignment:
          out ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (withSender && sender != null)
          Padding(
            padding: const EdgeInsets.only(
              left: DabblerSpacing.space1,
              right: DabblerSpacing.space1,
            ),
            child: Text(
              sender!,
              style: caption1.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
        bubble,
        if (reactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DabblerSpacing.space1),
            child: DabblerReactionGroup(
              reactions: reactions,
              onToggle: onReact,
            ),
          ),
        if (withMeta)
          Padding(
            padding: const EdgeInsets.only(
              left: DabblerSpacing.space1,
              right: DabblerSpacing.space1,
              top: DabblerMessagingSpacing.metaGap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (timestamp != null)
                  Text(timestamp!, style: caption1.copyWith(color: metaColor)),
                if (edited) ...<Widget>[
                  const SizedBox(width: DabblerSpacing.space1),
                  Text('· $editedLabel',
                      style: caption1.copyWith(color: metaColor)),
                ],
                if (showDelivery) ...<Widget>[
                  const SizedBox(width: DabblerSpacing.space1),
                  Semantics(
                    label: d.name,
                    image: true,
                    child: DabblerIcon(
                      d.icon,
                      weight: d.weight,
                      size: deliveryGlyph,
                      color: d.colorFor(colors),
                    ),
                  ),
                ],
                if (failed && onRetry != null)
                  DabblerMessagingTap(
                    onTap: onRetry,
                    label: retryLabel,
                    scale: false,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: DabblerSizing.touchTargetMin,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DabblerSpacing.space3,
                        ),
                        child: Center(
                          child: Text(
                            retryLabel,
                            style: caption1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.error.strong,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext c, BoxConstraints box) {
        final double avail = box.maxWidth.isFinite ? box.maxWidth : 400;
        final double gutter = (!out && group)
            ? DabblerMessagingSpacing.avatarGutter +
                DabblerMessagingSpacing.avatarGap
            : 0;
        final double maxW = bare
            ? bareMaxWidth
            : (avail - gutter) * maxWidthFraction;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              out ? MainAxisAlignment.end : MainAxisAlignment.start,
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
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: column,
            ),
          ],
        );
      },
    );
  }
}
