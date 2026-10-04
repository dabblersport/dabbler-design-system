/// Gallery entry for [DabblerCardEventResult].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card_event_result.dart';

/// CardEventResult specimens.
const List<GalleryEntry> cardEventResultGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'card-event-result',
    page: 'components/card-event-result',
    group: GalleryPurpose.contentContainers,
    title: 'CardEventResult — a game or meet-up in a search result',
    description: 'A game with a Join action, and a meet-up with none.',
    builder: _specimens,
  ),
];

Widget _specimens(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'game with action',
      child: SizedBox(
        width: 340,
        child: DabblerCardEventResult(
          month: 'Aug',
          day: '18',
          kind: 'Game',
          kindIcon: 'game',
          time: 'Today · 8:00 PM',
          title: 'Dabbler Football Night',
          query: 'dabbler',
          place: 'Al Maryah Island',
          meta: '0/10 spots',
          actionLabel: 'Join',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'meet-up, no action',
      child: SizedBox(
        width: 340,
        child: DabblerCardEventResult(
          month: 'Aug',
          day: '20',
          kind: 'Meet-up',
          kindIcon: 'calendar',
          time: 'Thu · 7:30 PM',
          title: 'Dabbler Community Meetup',
          query: 'dabbler',
          place: 'Nad Al Sheba',
        ),
      ),
    ),
  ],
);
