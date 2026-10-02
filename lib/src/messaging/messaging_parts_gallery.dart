/// Gallery entries for the shared messaging parts: [DabblerMessageReplyReference],
/// [DabblerReactionGroup], [DabblerReactionPicker], [DabblerSharedObjectCard]
/// and [DabblerConversationNotice].
///
/// Every specimen is fixed: callbacks are no-ops and nothing is sent anywhere.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'messaging_foundations.dart';
import 'messaging_parts.dart';

/// The messaging parts' specimens.
const List<GalleryEntry> messagingPartsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'message-reply-reference',
    page: 'components/message-reply-reference',
    group: GalleryPurpose.contentContainers,
    title: 'MessageReplyReference — the quoted message',
    description:
        'In an incoming bubble, in an outgoing bubble, above the composer '
        'with cancel, and quoting an attachment.',
    builder: _replies,
  ),
  GalleryEntry(
    id: 'reaction-group',
    page: 'components/reaction-group',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ReactionGroup — the tallies under a message',
    description: 'Mine and not mine, single and double-digit counts, and add.',
    builder: _reactionGroups,
  ),
  GalleryEntry(
    id: 'reaction-picker',
    page: 'components/reaction-picker',
    group: GalleryPurpose.selectionAndInput,
    title: 'ReactionPicker — choose a reaction',
    description: 'Nothing chosen, then two reactions already applied.',
    builder: _pickers,
  ),
  GalleryEntry(
    id: 'shared-object-card',
    page: 'components/shared-object-card',
    group: GalleryPurpose.contentContainers,
    title: 'SharedObjectCard — a game, venue or player in a thread',
    description:
        'A game with status, meta, footnote and call to action; a venue with '
        'its photo slot and chips; a player with chips.',
    builder: _sharedCards,
  ),
  GalleryEntry(
    id: 'conversation-notice',
    page: 'components/conversation-notice',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ConversationNotice — an important update in a thread',
    description:
        'Info, success, warning, error and its critical alias, with an action, '
        'a dismiss and a timestamp.',
    builder: _notices,
  ),
];

void _noop() {}
void _noopKey(String _) {}

const double _w = 320;

Widget _replies(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      const GallerySpecimen(
        label: 'message — in an incoming bubble',
        child: SizedBox(
          width: _w,
          child: DabblerMessageReplyReference(
            sender: 'Omar',
            content: 'Is the 7pm slot still free on court 2?',
          ),
        ),
      ),
      GallerySpecimen(
        label: 'onBrand — in an outgoing bubble',
        child: SizedBox(
          width: _w,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.brandPrimary,
              borderRadius: DabblerRadius.lgAll,
            ),
            child: const Padding(
              padding: EdgeInsets.all(DabblerSpacing.space4),
              child: DabblerMessageReplyReference(
                sender: 'Lina',
                content: 'Bring the spare bibs, we are short two.',
                variant: DabblerReplyVariant.onBrand,
              ),
            ),
          ),
        ),
      ),
      const GallerySpecimen(
        label: 'composer — with cancel',
        child: SizedBox(
          width: _w,
          child: DabblerMessageReplyReference(
            sender: 'Omar',
            content:
                'Running late, 10 minutes. Start without me and I will '
                'join the second half.',
            variant: DabblerReplyVariant.composer,
            onCancel: _noop,
          ),
        ),
      ),
      const GallerySpecimen(
        label: 'attachment label',
        child: SizedBox(
          width: _w,
          child: DabblerMessageReplyReference(
            sender: 'Lina',
            attachmentLabel: 'Photo',
          ),
        ),
      ),
    ],
  );
}

Widget _reactionGroups(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'mine and not mine',
      child: DabblerReactionGroup(
        reactions: <DabblerMessageReaction>[
          DabblerMessageReaction(key: 'in', count: 3, mine: true),
          DabblerMessageReaction(key: 'late', count: 1),
          DabblerMessageReaction(key: 'heart', count: 12),
        ],
        onToggle: _noopKey,
      ),
    ),
    GallerySpecimen(
      label: 'with add',
      child: DabblerReactionGroup(
        reactions: <DabblerMessageReaction>[
          DabblerMessageReaction(key: 'star', count: 2),
        ],
        onToggle: _noopKey,
        onAdd: _noop,
      ),
    ),
    GallerySpecimen(
      label: 'add only',
      child: DabblerReactionGroup(onAdd: _noop),
    ),
  ],
);

Widget _pickers(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'nothing chosen',
      child: DabblerReactionPicker(onPick: _noopKey),
    ),
    GallerySpecimen(
      label: 'active — in and heart',
      child: DabblerReactionPicker(
        onPick: _noopKey,
        active: <String>['in', 'heart'],
      ),
    ),
  ],
);

Widget _sharedCards(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'game — status, meta, footnote, call to action',
      child: SizedBox(
        width: 268,
        child: DabblerSharedObjectCard(
          title: 'Friday 5-a-side',
          subtitle: 'Hosted by Omar',
          sport: DabblerSport.football,
          status: DabblerActivityStatus.confirmed,
          meta: <DabblerSharedMeta>[
            DabblerSharedMeta(icon: 'calendar', text: 'Fri 12 Oct · 19:00'),
            DabblerSharedMeta(icon: 'location', text: 'Al Nahda Court 2'),
          ],
          footnote: '8 of 10 spots taken',
          cta: 'View game',
          onPress: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'venue — photo slot and chips',
      child: SizedBox(
        width: 268,
        child: DabblerSharedObjectCard(
          kind: DabblerSharedKind.venue,
          title: 'Al Nahda Sports Hub',
          subtitle: 'Padel · Football',
          chips: <String>['Indoor', 'Parking'],
          meta: <DabblerSharedMeta>[
            DabblerSharedMeta(icon: 'location', text: '2.4 km away'),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'player — chips and call to action',
      child: SizedBox(
        width: 268,
        child: DabblerSharedObjectCard(
          kind: DabblerSharedKind.player,
          title: 'Lina Haddad',
          subtitle: 'Midfielder',
          chips: <String>['Football', 'Padel'],
          cta: 'View profile',
          onPress: _noop,
        ),
      ),
    ),
  ],
);

Widget _notices(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'info — with timestamp',
      child: SizedBox(
        width: _w,
        child: DabblerConversationNotice(
          title: 'Kickoff moved',
          description: 'The game now starts at 19:30.',
          timestamp: '18:02',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'success',
      child: SizedBox(
        width: _w,
        child: DabblerConversationNotice(
          tone: DabblerNoticeTone.success,
          title: 'Court booked',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'warning — with action',
      child: SizedBox(
        width: _w,
        child: DabblerConversationNotice(
          tone: DabblerNoticeTone.warning,
          title: 'Payment required',
          description: 'Pay your share before 18:00 to keep your spot.',
          actionLabel: 'Pay now',
          onAction: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'error — with dismiss',
      child: SizedBox(
        width: _w,
        child: DabblerConversationNotice(
          tone: DabblerNoticeTone.error,
          title: 'Venue changed',
          description: 'Court 2 is closed; the game moved to court 4.',
          onDismiss: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'critical — the error alias',
      child: SizedBox(
        width: _w,
        child: DabblerConversationNotice(
          tone: DabblerNoticeTone.critical,
          title: 'Game cancelled',
          timestamp: 'Yesterday',
        ),
      ),
    ),
  ],
);
