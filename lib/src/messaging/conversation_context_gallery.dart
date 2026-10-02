/// Gallery entries for [DabblerConversationContext].
///
/// Collapsed, a live toggle, expanded with every row, cancelled, completed
/// and an Arabic right-to-left header. Nothing is fetched or sent.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'conversation_context.dart';
import 'messaging_foundations.dart';

/// ConversationContext's specimens.
const List<GalleryEntry> conversationContextGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'conversation-context',
    page: 'components/conversation-context',
    group: GalleryPurpose.contentContainers,
    title: 'ConversationContext — the activity header of a game chat',
    description:
        'Collapsed, live toggle, expanded, cancelled, completed and Arabic.',
    builder: _contexts,
  ),
];

void _noop() {}

const List<DabblerConversationContextAction> _actions =
    <DabblerConversationContextAction>[
      DabblerConversationContextAction(
        label: 'View game',
        onPress: _noop,
        icon: 'game',
      ),
      DabblerConversationContextAction(label: 'Invite', onPress: _noop),
    ];

DabblerConversationContext _expanded({
  bool collapsed = false,
  VoidCallback? onToggle,
}) => DabblerConversationContext(
  sport: DabblerSport.football,
  title: 'Friday 5-a-side',
  when: 'Fri 8:00 PM',
  venue: 'Al Wasl Sports Club',
  status: DabblerActivityStatus.confirmed,
  collapsed: collapsed,
  onToggle: onToggle ?? _noop,
  mapLabel: '2.4 km away',
  mapActionLabel: 'Directions',
  onMapAction: _noop,
  participants: '8 of 10 going',
  spots: '2 spots left',
  people: const <String>['amal', 'omar', 'sara'],
  overflow: 5,
  organizerLabel: 'Organised by',
  organizer: 'Omar',
  actions: _actions,
);

Widget _contexts(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'collapsed',
      child: SizedBox(
        width: 360,
        child: DabblerConversationContext(
          title: 'Friday 5-a-side',
          when: 'Fri 8:00 PM',
          venue: 'Al Wasl Sports Club',
          onToggle: _noop,
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'live — tap to expand',
      child: SizedBox(width: 360, child: _LiveContext()),
    ),
    GallerySpecimen(
      label: 'expanded',
      child: SizedBox(width: 360, child: _expanded()),
    ),
    const GallerySpecimen(
      label: 'cancelled — struck title, error tile',
      child: SizedBox(
        width: 360,
        child: DabblerConversationContext(
          sport: DabblerSport.padel,
          title: 'Padel doubles',
          when: 'Sat 6:00 PM',
          venue: 'Padel Pro',
          status: DabblerActivityStatus.cancelled,
          onToggle: _noop,
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'completed — muted tile',
      child: SizedBox(
        width: 360,
        child: DabblerConversationContext(
          title: 'Sunday league',
          when: 'Sun 5:00 PM',
          venue: 'Zabeel Park',
          status: DabblerActivityStatus.completed,
          onToggle: _noop,
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'Arabic, right to left',
      child: SizedBox(
        width: 360,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerConversationContext(
            title: 'مباراة الجمعة',
            when: 'الجمعة 8:00 م',
            venue: 'نادي الوصل',
            status: DabblerActivityStatus.soon,
            statusLabel: 'تبدأ قريبًا',
            onToggle: _noop,
          ),
        ),
      ),
    ),
  ],
);

class _LiveContext extends StatefulWidget {
  const _LiveContext();

  @override
  State<_LiveContext> createState() => _LiveContextState();
}

class _LiveContextState extends State<_LiveContext> {
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) => _expanded(
    collapsed: _collapsed,
    onToggle: () => setState(() => _collapsed = !_collapsed),
  );
}
