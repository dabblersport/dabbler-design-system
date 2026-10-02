/// Gallery entries for the five messaging atoms in `messaging_atoms.dart`:
/// [DabblerDateSeparator], [DabblerUnreadDivider], [DabblerSystemMessage],
/// [DabblerTypingIndicator] and [DabblerConversationAvatar].
///
/// Variants follow the live `*.prompt.md` files of the Claude Design project
/// 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System). Every value
/// is injected; nothing here reads a backend.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'messaging_atoms.dart';
import 'messaging_foundations.dart';

/// The messaging atoms' specimens, one entry per unit.
const List<GalleryEntry> messagingAtomsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'date-separator',
    page: 'components/date-separator',
    group: GalleryPurpose.structure,
    title: 'DateSeparator — the day boundary',
    description: 'A sunken pill with a pre-formatted day label.',
    builder: _dateSeparators,
  ),
  GalleryEntry(
    id: 'unread-divider',
    page: 'components/unread-divider',
    group: GalleryPurpose.structure,
    title: 'UnreadDivider — the new-messages boundary',
    description: 'A brand-coloured labelled rule, short and long labels.',
    builder: _unreadDividers,
  ),
  GalleryEntry(
    id: 'system-message',
    page: 'components/system-message',
    group: GalleryPurpose.statusAndFeedback,
    title: 'SystemMessage — product-generated activity',
    description:
        'Neutral and positive tones, with and without a glyph and a '
        'timestamp.',
    builder: _systemMessages,
  ),
  GalleryEntry(
    id: 'typing-indicator',
    page: 'components/typing-indicator',
    group: GalleryPurpose.statusAndFeedback,
    title: 'TypingIndicator — someone is typing',
    description:
        'One, two and three-plus names, no names, a label override and the '
        'dots-only form.',
    builder: _typingIndicators,
  ),
  GalleryEntry(
    id: 'conversation-avatar',
    page: 'components/conversation-avatar',
    group: GalleryPurpose.identityAndStatus,
    title: 'ConversationAvatar — a conversation identity',
    description:
        'Player, squad, huddle and game kinds at 48 and 36, and the online '
        'dot.',
    builder: _conversationAvatars,
  ),
];

Widget _dateSeparators(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'today',
      child: SizedBox(width: 320, child: DabblerDateSeparator(label: 'Today')),
    ),
    GallerySpecimen(
      label: 'a full date',
      child: SizedBox(
        width: 320,
        child: DabblerDateSeparator(label: 'Saturday, 14 September'),
      ),
    ),
  ],
);

Widget _unreadDividers(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default',
      child: SizedBox(
        width: 320,
        child: DabblerUnreadDivider(label: 'New messages'),
      ),
    ),
    GallerySpecimen(
      label: 'with a count',
      child: SizedBox(
        width: 320,
        child: DabblerUnreadDivider(label: '12 unread messages'),
      ),
    ),
  ],
);

Widget _systemMessages(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'neutral',
      child: SizedBox(
        width: 320,
        child: DabblerSystemMessage(text: 'Mina left the game'),
      ),
    ),
    GallerySpecimen(
      label: 'neutral — glyph and timestamp',
      child: SizedBox(
        width: 320,
        child: DabblerSystemMessage(
          icon: 'people',
          text: 'Omar invited Sara',
          timestamp: '18:42',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'positive — glyph and timestamp',
      child: SizedBox(
        width: 320,
        child: DabblerSystemMessage(
          icon: 'tick-circle',
          text: 'Booking confirmed',
          timestamp: '18:45',
          tone: DabblerSystemMessageTone.positive,
        ),
      ),
    ),
  ],
);

Widget _typingIndicators(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'one name',
      child: DabblerTypingIndicator(names: <String>['Mina']),
    ),
    GallerySpecimen(
      label: 'two names',
      child: DabblerTypingIndicator(names: <String>['Mina', 'Omar']),
    ),
    GallerySpecimen(
      label: 'three or more',
      child: DabblerTypingIndicator(names: <String>['Mina', 'Omar', 'Sara']),
    ),
    GallerySpecimen(label: 'no names', child: DabblerTypingIndicator()),
    GallerySpecimen(
      label: 'label override',
      child: DabblerTypingIndicator(label: 'Coach is drafting the lineup'),
    ),
    GallerySpecimen(
      label: 'dots only',
      child: DabblerTypingIndicator(dotsOnly: true),
    ),
  ],
);

Widget _conversationAvatars(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: '48 — player, player online, squad, huddle, game',
      child: GalleryWrap(
        children: <Widget>[
          DabblerConversationAvatar(seed: 'mina'),
          DabblerConversationAvatar(seed: 'omar', online: true),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.squad,
            seed: 'squad',
          ),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.huddle,
            seed: 'huddle',
          ),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.game,
            sport: DabblerSport.padel,
            seed: 'game',
          ),
        ],
      ),
    ),
    GallerySpecimen(
      label: '36 — header size',
      child: GalleryWrap(
        children: <Widget>[
          DabblerConversationAvatar(seed: 'mina', size: 36, online: true),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.squad,
            seed: 'squad',
            size: 36,
          ),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.huddle,
            seed: 'huddle',
            size: 36,
          ),
          DabblerConversationAvatar(
            kind: DabblerConversationKind.game,
            seed: 'game',
            size: 36,
          ),
        ],
      ),
    ),
  ],
);
