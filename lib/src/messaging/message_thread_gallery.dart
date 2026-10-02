/// Gallery entries for [DabblerMessage], [DabblerMessageThread] and the
/// messaging foundations.
///
/// Every value is an injected view-model; nothing is sent anywhere. The image
/// attachment is a caller-supplied slot (a sunken fill), as the package ships
/// no art.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_type.dart';
import 'message.dart';
import 'message_thread.dart';
import 'messaging_foundations.dart';
import 'messaging_parts.dart';

/// Message, MessageThread and messaging-foundations specimens.
const List<GalleryEntry> messagingThreadGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'message',
    page: 'components/message',
    group: GalleryPurpose.contentContainers,
    title: 'Message — one bubble, every case',
    description:
        'Incoming and outgoing, each group position, reply, image, shared '
        'object, selected, read-only and every delivery state.',
    builder: _messages,
  ),
  GalleryEntry(
    id: 'message-thread',
    page: 'components/message-thread',
    group: GalleryPurpose.contentContainers,
    title: 'MessageThread — the conversation timeline',
    description:
        'A direct and a group thread with derived grouping, dates, unread, '
        'system, notice and typing rows.',
    builder: _threads,
  ),
  GalleryEntry(
    id: 'messaging-foundations',
    page: 'components/messaging-foundations',
    group: GalleryPurpose.contentContainers,
    title: 'Messaging foundations — rhythm and semantic maps',
    description:
        'The spacing rhythm, kind glyphs, activity statuses, delivery '
        'states and the reaction set.',
    builder: _foundations,
  ),
];

void _noop() {}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot();

  @override
  Widget build(BuildContext context) {
    final DabblerColors c = DabblerColors.of(context);
    return ColoredBox(
      color: c.surfaceSunken,
      child: Center(
        child: DabblerIcon('gallery', size: 24, color: c.textTertiary),
      ),
    );
  }
}

const DabblerMessageAttachment _image = DabblerMessageAttachment.image(
  child: _ImageSlot(),
);

const DabblerMessageAttachment _game = DabblerMessageAttachment.object(
  DabblerSharedObjectCard(
    title: 'Thursday 5-a-side',
    sport: DabblerSport.football,
    status: DabblerActivityStatus.confirmed,
    meta: <DabblerSharedMeta>[
      DabblerSharedMeta(icon: 'clock', text: 'Thu 19:00'),
      DabblerSharedMeta(icon: 'location', text: 'Al Wasl Park'),
    ],
  ),
);

Widget _w(Widget child) => SizedBox(width: 360, child: child);

Widget _messages(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerGroupPosition p in DabblerGroupPosition.values)
      GallerySpecimen(
        label: 'incoming group · ${p.name}',
        child: _w(
          DabblerMessage(
            context: DabblerMessageContext.group,
            groupPosition: p,
            sender: 'Layla',
            content: 'Pitch 3 tonight.',
            timestamp: '17:10',
          ),
        ),
      ),
    for (final DabblerGroupPosition p in DabblerGroupPosition.values)
      GallerySpecimen(
        label: 'outgoing · ${p.name}',
        child: _w(
          DabblerMessage(
            direction: DabblerMessageDirection.outgoing,
            groupPosition: p,
            content: 'I can take two.',
            timestamp: '17:11',
            deliveryState: DabblerDeliveryState.read,
          ),
        ),
      ),
    for (final DabblerDeliveryState d in DabblerDeliveryState.values)
      GallerySpecimen(
        label: 'delivery · ${d.name}',
        child: _w(
          DabblerMessage(
            direction: DabblerMessageDirection.outgoing,
            content: 'On my way',
            timestamp: '17:12',
            deliveryState: d,
            onRetry: d == DabblerDeliveryState.failed ? _noop : null,
          ),
        ),
      ),
    GallerySpecimen(
      label: 'reply, reactions, edited',
      child: _w(
        const DabblerMessage(
          context: DabblerMessageContext.group,
          sender: 'Omar',
          reply: DabblerReplySpec(sender: 'You', content: 'I can take two.'),
          content: 'Perfect, I am in for one of those seats.',
          timestamp: '17:12',
          edited: true,
          reactions: <DabblerMessageReaction>[
            DabblerMessageReaction(key: 'in', count: 3, mine: true),
            DabblerMessageReaction(key: 'late', count: 1),
          ],
          onReact: _noopKey,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'image attachment (bare)',
      child: _w(
        const DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          attachment: _image,
          timestamp: '17:13',
          deliveryState: DabblerDeliveryState.delivered,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'shared game',
      child: _w(
        const DabblerMessage(
          attachment: _game,
          content: 'Spots left on this one.',
          timestamp: '17:14',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'selected and read-only',
      child: _w(
        const Column(
          children: <Widget>[
            DabblerMessage(
              content: 'Selected',
              state: DabblerMessageState.selected,
              onPress: _noop,
            ),
            SizedBox(height: 12),
            DabblerMessage(
              content: 'Read-only: not pressable',
              state: DabblerMessageState.readOnly,
              onPress: _noop,
            ),
          ],
        ),
      ),
    ),
  ],
);

void _noopKey(String _) {}

/// A group thread exercising every row kind; shared with tests.
const List<DabblerThreadItem> messagingSampleGroupThread = <DabblerThreadItem>[
  DabblerThreadDate('Yesterday'),
  DabblerThreadSystem(text: 'Layla joined the game', icon: 'user-add'),
  DabblerThreadMessage(id: '1', sender: 'Layla', content: 'Who has a ball?'),
  DabblerThreadMessage(
    id: '2',
    sender: 'Layla',
    content: 'Mine is flat.',
    timestamp: '18:02',
  ),
  DabblerThreadMessage(
    id: '3',
    direction: DabblerMessageDirection.outgoing,
    sender: 'You',
    content: 'I will bring one.',
    timestamp: '18:03',
    deliveryState: DabblerDeliveryState.sent,
  ),
  DabblerThreadDate('Today'),
  DabblerThreadUnread('2 unread'),
  DabblerThreadNotice(
    tone: DabblerNoticeTone.warning,
    title: 'Kick-off moved to 19:30',
  ),
  DabblerThreadMessage(
    id: '4',
    sender: 'Omar',
    reply: DabblerReplySpec(sender: 'You', content: 'I will bring one.'),
    content: 'Legend.',
    timestamp: '09:40',
    reactions: <DabblerMessageReaction>[
      DabblerMessageReaction(key: 'like', count: 2, mine: true),
    ],
  ),
  DabblerThreadMessage(
    id: '5',
    direction: DabblerMessageDirection.outgoing,
    sender: 'You',
    attachment: _image,
  ),
  DabblerThreadMessage(
    id: '6',
    direction: DabblerMessageDirection.outgoing,
    sender: 'You',
    content: 'Pitch photo',
    timestamp: '09:41',
    deliveryState: DabblerDeliveryState.failed,
    onRetry: _noop,
  ),
  DabblerThreadTyping(names: <String>['Layla'], label: 'Layla is typing'),
];

const List<DabblerThreadItem> _direct = <DabblerThreadItem>[
  DabblerThreadDate('Today'),
  DabblerThreadMessage(sender: 'Sara', content: 'Still on for padel?'),
  DabblerThreadMessage(sender: 'Sara', attachment: _game, timestamp: '08:15'),
  DabblerThreadMessage(
    direction: DabblerMessageDirection.outgoing,
    sender: 'You',
    content: 'Yes, see you there.',
    timestamp: '08:16',
    deliveryState: DabblerDeliveryState.read,
  ),
  DabblerThreadMessage(
    direction: DabblerMessageDirection.outgoing,
    sender: 'You',
    content: 'Bringing balls.',
    timestamp: '08:17',
    deliveryState: DabblerDeliveryState.sending,
  ),
];

Widget _threads(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'group',
      child: SizedBox(
        width: 380,
        height: 900,
        child: DabblerMessageThread(
          context: DabblerMessageContext.group,
          items: messagingSampleGroupThread,
          selectedId: '4',
          onMessagePress: (_) {},
          onReact: (_, _) {},
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'direct',
      child: SizedBox(
        width: 380,
        height: 560,
        child: DabblerMessageThread(items: _direct),
      ),
    ),
  ],
);

Widget _foundations(BuildContext context) {
  final DabblerColors c = DabblerColors.of(context);
  final TextStyle t = DabblerType.footnote
      .resolveForDirection(Directionality.of(context))
      .copyWith(color: c.textPrimary);
  Widget line(Widget lead, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: <Widget>[
        SizedBox(width: 30, child: lead),
        Expanded(child: Text(text, style: t)),
      ],
    ),
  );
  const Map<String, double> rhythm = <String, double>{
    'timelineInline': DabblerMessagingSpacing.timelineInline,
    'timelineBlock': DabblerMessagingSpacing.timelineBlock,
    'groupGap': DabblerMessagingSpacing.groupGap,
    'messageGap': DabblerMessagingSpacing.messageGap,
    'avatarGap': DabblerMessagingSpacing.avatarGap,
    'avatarGutter': DabblerMessagingSpacing.avatarGutter,
    'senderGap': DabblerMessagingSpacing.senderGap,
    'replyGap': DabblerMessagingSpacing.replyGap,
    'metaGap': DabblerMessagingSpacing.metaGap,
    'reactionGap': DabblerMessagingSpacing.reactionGap,
    'systemBlock': DabblerMessagingSpacing.systemBlock,
    'bubbleInline': DabblerMessagingSpacing.bubbleInline,
    'bubbleBlock': DabblerMessagingSpacing.bubbleBlock,
  };
  return GalleryStack(
    children: <Widget>[
      GallerySpecimen(
        label: 'rhythm',
        child: _w(
          Column(
            children: <Widget>[
              for (final MapEntry<String, double> e in rhythm.entries)
                line(
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: e.value,
                      height: 9,
                      child: ColoredBox(color: c.brandPrimary),
                    ),
                  ),
                  '${e.key} · ${e.value.toStringAsFixed(0)}',
                ),
            ],
          ),
        ),
      ),
      GallerySpecimen(
        label: 'kind glyphs',
        child: _w(
          Column(
            children: <Widget>[
              for (final DabblerConversationKind k
                  in DabblerConversationKind.values)
                line(
                  k.glyph == null
                      ? const SizedBox.shrink()
                      : DabblerIcon(k.glyph!, size: 18, color: c.textPrimary),
                  '${k.name} · ${k.glyph ?? (k == DabblerConversationKind.game ? 'sport icon' : 'none')}',
                ),
            ],
          ),
        ),
      ),
      GallerySpecimen(
        label: 'activity status',
        child: _w(
          Column(
            children: <Widget>[
              for (final DabblerActivityStatus s
                  in DabblerActivityStatus.values)
                line(
                  const SizedBox.shrink(),
                  '${s.name} · ${s.label} · ${s.tone?.name ?? 'neutral'}',
                ),
            ],
          ),
        ),
      ),
      GallerySpecimen(
        label: 'delivery',
        child: _w(
          Column(
            children: <Widget>[
              for (final DabblerDeliveryState d in DabblerDeliveryState.values)
                line(
                  DabblerIcon(
                    d.icon,
                    weight: d.weight,
                    size: 18,
                    color: d.colorFor(c),
                  ),
                  '${d.name} · ${d.icon} · ${d.weight.name}',
                ),
            ],
          ),
        ),
      ),
      GallerySpecimen(
        label: 'reactions',
        child: _w(
          Column(
            children: <Widget>[
              for (final DabblerReactionDef r in DabblerReactions.all)
                line(
                  DabblerIcon(r.icon, size: 18, color: c.textPrimary),
                  '${r.key} · ${r.label}',
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
