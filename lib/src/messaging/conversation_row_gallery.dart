/// Gallery entries for [DabblerConversationRow].
///
/// The four kinds, read and unread, muted, typing, a capped count, a status
/// badge with a kind label, and an Arabic row under right-to-left. Taps go
/// nowhere.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import 'conversation_row.dart';
import 'messaging_foundations.dart';

/// ConversationRow's specimens.
const List<GalleryEntry> conversationRowGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'conversation-row',
    page: 'components/conversation-row',
    group: GalleryPurpose.identityAndStatus,
    title: 'ConversationRow — one conversation in the inbox',
    description:
        'Player, squad, huddle and game rows; unread, muted, typing, a capped '
        'count, a status badge, and an Arabic row in RTL.',
    builder: _rows,
  ),
];

void _noop() {}

Widget _row(Widget child) => SizedBox(width: 360, child: child);

Widget _rows(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'player — unread, online',
      child: _row(
        const DabblerConversationRow(
          title: 'Layla Haddad',
          preview: 'See you at the court!',
          timestamp: '17:02',
          unread: 2,
          online: true,
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'squad — read, sender prefix',
      child: _row(
        const DabblerConversationRow(
          kind: DabblerConversationKind.squad,
          title: 'Sunday Strikers',
          sender: 'Omar',
          preview: 'Who is bringing the bibs?',
          timestamp: 'Mon',
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'huddle — muted, 120 unread caps at 99+',
      child: _row(
        const DabblerConversationRow(
          kind: DabblerConversationKind.huddle,
          title: 'Padel regulars',
          sender: 'Sara',
          preview: 'Courts 3 and 4 are free tonight',
          timestamp: '09:41',
          unread: 120,
          muted: true,
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'game — typing, status badge, kind label',
      child: _row(
        const DabblerConversationRow(
          kind: DabblerConversationKind.game,
          sport: DabblerSport.football,
          title: 'Thursday 5-a-side',
          sender: 'Omar',
          typing: true,
          timestamp: '17:02',
          unread: 3,
          state: DabblerConversationState(
            label: 'Confirmed',
            status: DabblerStatusTone.success,
            icon: 'tick-circle',
          ),
          kindLabel: 'Game chat',
          onTap: _noop,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic, right-to-left',
      child: _row(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerConversationRow(
            kind: DabblerConversationKind.squad,
            title: 'فريق الأحد',
            sender: 'عمر',
            preview: 'من سيحضر القمصان؟',
            timestamp: '١٧:٠٢',
            unread: 4,
            divider: false,
            onTap: _noop,
          ),
        ),
      ),
    ),
  ],
);
