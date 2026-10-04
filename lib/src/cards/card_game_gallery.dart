/// Gallery entry for [DabblerCardGame] (Alpha fidelity rebuild, KAN-426).
///
/// Mirrors the Listings game card, `Listings.dc.html:207-262`.
library;

import 'package:flutter/widgets.dart';

import '../feedback/progress_bar.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import 'card_event_listing.dart';
import 'card_game.dart';

/// CardGame specimens.
const List<GalleryEntry> cardGameGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'card-game',
    page: 'components/card-game',
    group: GalleryPurpose.contentContainers,
    title: 'CardGame — a game in a listing',
    description:
        'Title, tags, day and time, place, player progress, price and join.',
    builder: _games,
  ),
];

const double _width = 360;

Widget _games(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'full',
      child: SizedBox(
        width: _width,
        child: DabblerCardGame(
          title: 'Tuesday 5-a-side',
          verified: true,
          tags: const <Widget>[
            DabblerBadge(label: 'Football'),
            DabblerBadge(label: 'Intermediate'),
          ],
          dayLabel: 'Today',
          timeLabel: '7:30 PM',
          meta: const <String>['Dubai Sports City', '2.1 km', '90 min'],
          progress: const DabblerCardEventPlayers(
            label: '9 of 10 players in',
            joined: 9,
            capacity: 10,
            note: '1 spot left · almost full',
            tone: DabblerProgressBarTone.warning,
          ),
          price: const DabblerCardEventPrice(
            price: 'AED 40',
            note: 'per player',
          ),
          action: DabblerCardEventListing.joinButton(
            label: 'Join game',
            onPressed: () {},
          ),
          onTap: () {},
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'title and time only',
      child: SizedBox(
        width: _width,
        child: DabblerCardGame(
          title: 'Half court pickup',
          timeLabel: '6:00 PM',
        ),
      ),
    ),
  ],
);
