/// Gallery entry for [DabblerCardUpcoming] (Alpha fidelity rebuild, KAN-426).
///
/// Mirrors the Listings Upcoming rail, `Listings.dc.html:139-170`.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card_upcoming.dart';

/// CardUpcoming specimens.
const List<GalleryEntry> cardUpcomingGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'card-upcoming',
    page: 'components/card-upcoming',
    group: GalleryPurpose.contentContainers,
    title: 'CardUpcoming — a game you are in, counting down',
    description: 'The tinted tile with a countdown ring, in the three tones.',
    builder: _tiles,
  ),
];

Widget _tiles(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'amber',
      child: SizedBox(
        width: 300,
        child: DabblerCardUpcoming(
          title: 'Tuesday 5-a-side',
          fraction: 0.4,
          countdownValue: '3',
          countdownUnit: 'hours',
          when: 'Sep 2 · 7:30 PM · 60 min',
          place: 'Dubai Sports City',
          distance: '3.1 km',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'info',
      child: SizedBox(
        width: 300,
        child: DabblerCardUpcoming(
          tone: DabblerCardUpcomingTone.info,
          title: 'Half court pickup',
          fraction: 0.1,
          countdownValue: '2',
          countdownUnit: 'days',
          when: 'Sep 3 · 6:00 PM · 90 min',
          place: 'Zayed Sports City',
        ),
      ),
    ),
  ],
);
