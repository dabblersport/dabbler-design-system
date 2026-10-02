/// Gallery entries for [DabblerConversationHeader].
///
/// Default, online, typing, success and error subtitle tones, a game
/// conversation and a long title that ellipsizes. Nothing navigates anywhere.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'conversation_header.dart';
import 'messaging_foundations.dart';

/// ConversationHeader's specimens.
const List<GalleryEntry> conversationHeaderGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'conversation-header',
    page: 'components/conversation-header',
    group: GalleryPurpose.navigation,
    title: 'ConversationHeader — the top bar of a conversation',
    description:
        'Back, a tappable identity and overflow: default, online, typing, '
        'success and error subtitles, a game, and a long title.',
    builder: _headers,
  ),
];

void _noop() {}

Widget _h(String label, DabblerConversationHeader header) => GallerySpecimen(
  label: label,
  child: SizedBox(width: 360, child: header),
);

Widget _headers(BuildContext context) => GalleryStack(
  children: <Widget>[
    _h(
      'default',
      const DabblerConversationHeader(
        title: 'Layla Haddad',
        subtitle: 'Last seen 2h ago',
        onBack: _noop,
        onTitlePress: _noop,
        onOverflow: _noop,
      ),
    ),
    _h(
      'online — success subtitle',
      const DabblerConversationHeader(
        title: 'Layla Haddad',
        subtitle: 'Online',
        subtitleTone: DabblerConversationSubtitleTone.success,
        online: true,
        onBack: _noop,
        onTitlePress: _noop,
        onOverflow: _noop,
      ),
    ),
    _h(
      'typing replaces the subtitle',
      const DabblerConversationHeader(
        title: 'Thursday 5-a-side',
        kind: DabblerConversationKind.huddle,
        subtitle: '8 members',
        typing: <String>['Omar'],
        onBack: _noop,
        onTitlePress: _noop,
        onOverflow: _noop,
      ),
    ),
    _h(
      'error subtitle',
      const DabblerConversationHeader(
        title: 'Padel at Court 3',
        kind: DabblerConversationKind.game,
        sport: DabblerSport.padel,
        subtitle: 'Game cancelled',
        subtitleTone: DabblerConversationSubtitleTone.error,
        onBack: _noop,
        onTitlePress: _noop,
        onOverflow: _noop,
      ),
    ),
    _h(
      'long title — ellipsis',
      const DabblerConversationHeader(
        title: 'Sunday morning football league, west side pitches, all levels',
        kind: DabblerConversationKind.huddle,
        subtitle: '24 members, 3 online, next game Sunday 8am at the park',
        onBack: _noop,
        onTitlePress: _noop,
        onOverflow: _noop,
      ),
    ),
  ],
);
