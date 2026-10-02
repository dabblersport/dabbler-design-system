import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'message.dart';
import 'messaging_atoms.dart';
import 'messaging_foundations.dart';
import 'messaging_parts.dart';

/// One row of a [DabblerMessageThread] — the five kinds the source's `items`
/// array carries (`kind` of `date`, `unread`, `system`, `notice`, `typing`, or
/// none for a message).
@immutable
sealed class DabblerThreadItem {
  const DabblerThreadItem();
}

/// A message row.
@immutable
class DabblerThreadMessage extends DabblerThreadItem {
  /// A message row; the thread derives its group position.
  const DabblerThreadMessage({
    this.id,
    this.direction = DabblerMessageDirection.incoming,
    this.sender,
    this.avatarSeed,
    this.content,
    this.attachment,
    this.reply,
    this.timestamp,
    this.edited = false,
    this.deliveryState,
    this.reactions = const <DabblerMessageReaction>[],
    this.state = DabblerMessageState.normal,
  });

  /// A stable id, compared with the thread's `selectedId`.
  final String? id;

  /// Ownership.
  final DabblerMessageDirection direction;

  /// The sender.
  final String? sender;

  /// The avatar seed.
  final String? avatarSeed;

  /// The text.
  final String? content;

  /// An attachment.
  final DabblerMessageAttachment? attachment;

  /// A quoted message.
  final DabblerReplySpec? reply;

  /// The timestamp.
  final String? timestamp;

  /// Whether edited.
  final bool edited;

  /// Delivery metadata.
  final DabblerDeliveryState? deliveryState;

  /// Reactions.
  final List<DabblerMessageReaction> reactions;

  /// The row's own state.
  final DabblerMessageState state;
}

/// A day boundary row.
@immutable
class DabblerThreadDate extends DabblerThreadItem {
  /// A day row.
  const DabblerThreadDate(this.label);

  /// The day text.
  final String label;
}

/// The unread boundary row; the `unread` anchor scrolls to it.
@immutable
class DabblerThreadUnread extends DabblerThreadItem {
  /// An unread row.
  const DabblerThreadUnread(this.label);

  /// The label.
  final String label;
}

/// A system activity row.
@immutable
class DabblerThreadSystem extends DabblerThreadItem {
  /// A system row.
  const DabblerThreadSystem({
    required this.text,
    this.icon,
    this.timestamp,
    this.positive = false,
  });

  /// The text.
  final String text;

  /// The glyph.
  final String? icon;

  /// The timestamp.
  final String? timestamp;

  /// The success tone.
  final bool positive;
}

/// A notice row.
@immutable
class DabblerThreadNotice extends DabblerThreadItem {
  /// A notice row.
  const DabblerThreadNotice({
    this.tone = DabblerNoticeTone.info,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.timestamp,
  });

  /// The tone.
  final DabblerNoticeTone tone;

  /// The title.
  final String? title;

  /// The body.
  final String? description;

  /// The action label.
  final String? actionLabel;

  /// The action.
  final VoidCallback? onAction;

  /// The caption.
  final String? timestamp;
}

/// A typing row: three dots in a bubble, with an optional label.
@immutable
class DabblerThreadTyping extends DabblerThreadItem {
  /// A typing row.
  const DabblerThreadTyping({this.names = const <String>[], this.label});

  /// Who is typing.
  final List<String> names;

  /// The label beside the bubble.
  final String? label;
}

/// Where a [DabblerMessageThread] rests after it lays out.
enum DabblerThreadAnchor {
  /// The newest message.
  bottom,

  /// The unread divider.
  unread,
}

/// MessageThread — the conversation timeline.
///
/// Ported from `components/messaging/MessageThread.jsx`. A flat [items] list;
/// the thread derives each message's [DabblerGroupPosition], owns the rhythm
/// (12 between groups, 3 inside one) and the scroll anchoring. A pinned
/// [header] (the source's `children`) scrolls with the content.
class DabblerMessageThread extends StatefulWidget {
  /// A thread.
  const DabblerMessageThread({
    super.key,
    this.items = const <DabblerThreadItem>[],
    this.context = DabblerMessageContext.direct,
    this.anchor = DabblerThreadAnchor.bottom,
    this.header,
    this.onMessagePress,
    this.selectedId,
    this.onReact,
  });

  /// The rows.
  final List<DabblerThreadItem> items;

  /// The conversation context.
  final DabblerMessageContext context;

  /// Where the thread rests.
  final DabblerThreadAnchor anchor;

  /// A pinned widget above the rows (the game context strip).
  final Widget? header;

  /// Called with the pressed message.
  final ValueChanged<DabblerThreadMessage>? onMessagePress;

  /// The id of the selected message.
  final String? selectedId;

  /// Called with the message and the reaction key.
  final void Function(DabblerThreadMessage message, String key)? onReact;

  /// The group position of the message at [index].
  static DabblerGroupPosition groupPositionFor(
    List<DabblerThreadItem> items,
    int index,
  ) {
    final DabblerThreadItem it = items[index];
    if (it is! DabblerThreadMessage) return DabblerGroupPosition.single;
    bool same(DabblerThreadItem? o) =>
        o is DabblerThreadMessage &&
        o.direction == it.direction &&
        o.sender == it.sender;
    final bool prev = index > 0 && same(items[index - 1]);
    final bool next = index < items.length - 1 && same(items[index + 1]);
    if (prev && next) return DabblerGroupPosition.middle;
    if (prev) return DabblerGroupPosition.last;
    if (next) return DabblerGroupPosition.first;
    return DabblerGroupPosition.single;
  }

  @override
  State<DabblerMessageThread> createState() => _DabblerMessageThreadState();
}

class _DabblerMessageThreadState extends State<DabblerMessageThread> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _unreadKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _anchor();
  }

  @override
  void didUpdateWidget(DabblerMessageThread old) {
    super.didUpdateWidget(old);
    if (old.anchor != widget.anchor ||
        old.items.length != widget.items.length) {
      _anchor();
    }
  }

  void _anchor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final BuildContext? u = _unreadKey.currentContext;
      if (widget.anchor == DabblerThreadAnchor.unread && u != null) {
        Scrollable.ensureVisible(u, alignment: 0.1);
      } else {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Widget _row(BuildContext context, int i) {
    final DabblerThreadItem it = widget.items[i];
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    switch (it) {
      case DabblerThreadDate():
        return DabblerDateSeparator(label: it.label);
      case DabblerThreadUnread():
        return KeyedSubtree(
          key: _unreadKey,
          child: DabblerUnreadDivider(label: it.label),
        );
      case DabblerThreadSystem():
        return DabblerSystemMessage(
          text: it.text,
          icon: it.icon,
          timestamp: it.timestamp,
          positive: it.positive,
        );
      case DabblerThreadNotice():
        return DabblerConversationNotice(
          tone: it.tone,
          title: it.title,
          description: it.description,
          actionLabel: it.actionLabel,
          onAction: it.onAction,
          timestamp: it.timestamp,
        );
      case DabblerThreadTyping():
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            start: DabblerMessagingSpacing.avatarGutter +
                DabblerMessagingSpacing.avatarGap,
          ),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  border: Border.all(
                    color: colors.borderDefault,
                    width: DabblerSizing.borderDefault,
                  ),
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(DabblerRadius.xl),
                    topEnd: Radius.circular(DabblerRadius.xl),
                    bottomEnd: Radius.circular(DabblerRadius.xl),
                    bottomStart: Radius.circular(DabblerRadius.sm),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DabblerMessagingSpacing.bubbleBlock,
                    horizontal: DabblerMessagingSpacing.bubbleInline,
                  ),
                  child: DabblerTypingIndicator(names: it.names, dotsOnly: true),
                ),
              ),
              if (it.label != null) ...<Widget>[
                const SizedBox(width: DabblerMessagingSpacing.avatarGap),
                Text(
                  it.label!,
                  style: DabblerType.caption2
                      .resolveForDirection(dir)
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ],
          ),
        );
      case DabblerThreadMessage():
        final bool selected =
            widget.selectedId != null && widget.selectedId == it.id;
        return DabblerMessage(
          direction: it.direction,
          context: widget.context,
          groupPosition: DabblerMessageThread.groupPositionFor(widget.items, i),
          sender: it.sender,
          avatarSeed: it.avatarSeed,
          content: it.content,
          attachment: it.attachment,
          reply: it.reply,
          timestamp: it.timestamp,
          edited: it.edited,
          deliveryState: it.deliveryState,
          reactions: it.reactions,
          state: selected ? DabblerMessageState.selected : it.state,
          onPress: widget.onMessagePress == null
              ? null
              : () => widget.onMessagePress!(it),
          onReact: widget.onReact == null
              ? null
              : (String k) => widget.onReact!(it, k),
        );
    }
  }

  /// The gap above row [i]: 3 inside a same-sender run, else 12.
  double _gapAbove(int i) {
    if (i == 0 && widget.header == null) return 0;
    final DabblerThreadItem it = widget.items[i];
    if (it is DabblerThreadMessage) {
      final DabblerGroupPosition p =
          DabblerMessageThread.groupPositionFor(widget.items, i);
      if (!DabblerMessage.leads(p)) return DabblerMessagingSpacing.messageGap;
    }
    return DabblerMessagingSpacing.groupGap;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(
        horizontal: DabblerMessagingSpacing.timelineInline,
        vertical: DabblerMessagingSpacing.timelineBlock,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.header != null) widget.header!,
          for (int i = 0; i < widget.items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: _gapAbove(i)),
              child: _row(context, i),
            ),
        ],
      ),
    );
  }
}
