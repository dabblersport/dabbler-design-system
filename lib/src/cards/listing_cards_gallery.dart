/// Gallery entries for the Listings additions (Alpha DS gaps 6, items 1 and
/// 7): the event cards' player-progress / price / join slots, the new
/// [DabblerCardVenue], and [DabblerStatTile]'s icon slot, scale-to-fit value
/// and [DabblerStatGrid]'s row height.
///
/// Mirrors `Listings.dc.html:242-259` (game card), `:750-820` (venue card)
/// and `Details.dc.html:93-110` (100px stat grid with icons).
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../controls/chip.dart';
import '../feedback/progress_bar.dart';
import '../foundations/icon.dart';
import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card_event_large.dart';
import 'card_event_listing.dart';
import 'card_event_medium.dart';
import 'card_venue.dart';
import 'stat_tile.dart';

/// Listing specimens.
const List<GalleryEntry> listingCardsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'card-event/listing',
    page: 'components/card-event',
    group: GalleryPurpose.contentContainers,
    title: 'Card — event, with players, price and Join',
    description:
        'Large with all three listing slots, a joining (loading) button, '
        'and Medium full with a disabled Join.',
    builder: _events,
  ),
  GalleryEntry(
    id: 'card-venue',
    page: 'components/card-venue',
    group: GalleryPurpose.contentContainers,
    title: 'CardVenue — a venue in a listing',
    description:
        'With a cover, rating and sport tags, favourite and a price row; '
        'and without a cover.',
    builder: _venues,
  ),
  GalleryEntry(
    id: 'stat-tile/icon-fit',
    page: 'components/stat-tile',
    group: GalleryPurpose.contentContainers,
    title: 'StatTile — icon, scale-to-fit value, 100px rows',
    description:
        'A StatGrid at the Details row height with icon tiles, and a '
        'long value scaled down instead of clipped.',
    builder: _stats,
  ),
];

const double _width = 340;

Widget _events(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'large — players, price, Join',
      child: SizedBox(
        width: _width,
        child: DabblerCardEventLarge(
          title: 'Sunday five-a-side at Al Barsha Pond Park',
          sport: DabblerSport.football,
          dateTime: 'Sun 21 Sep · 18:00',
          location: 'Al Barsha Pond Park',
          onTap: () {},
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
        ),
      ),
    ),
    GallerySpecimen(
      label: 'large — joining (loading)',
      child: SizedBox(
        width: _width,
        child: DabblerCardEventLarge(
          title: 'Padel doubles, mixed level',
          sport: DabblerSport.padel,
          progress: const DabblerCardEventPlayers(
            label: '6 of 10 players in',
            joined: 6,
            capacity: 10,
            note: '4 spots left',
            tone: DabblerProgressBarTone.info,
          ),
          price: const DabblerCardEventPrice(price: 'Free', free: true),
          action: DabblerCardEventListing.joinButton(
            label: 'Join game',
            onPressed: () {},
            loading: true,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'medium — full, Join disabled',
      child: SizedBox(
        width: _width,
        child: DabblerCardEventMedium(
          title: 'Saturday 7-a-side',
          sport: DabblerSport.football,
          dateTime: 'Sat 27 Sep · 09:00',
          progress: const DabblerCardEventPlayers(
            label: '14 of 14 players in',
            joined: 14,
            capacity: 14,
            note: 'Full',
            tone: DabblerProgressBarTone.error,
          ),
          price: const DabblerCardEventPrice(price: 'AED 65'),
          action: DabblerCardEventListing.joinButton(
            label: 'Join game',
            disabled: true,
          ),
        ),
      ),
    ),
  ],
);

Widget _venues(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'with a cover',
      child: SizedBox(
        width: _width,
        child: _venue(
          cover: const DabblerIcon('gallery', size: 30),
          name: 'Elite Football Arena',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'no cover',
      child: SizedBox(
        width: _width,
        child: _venue(name: 'Lane Eight Aquatics'),
      ),
    ),
  ],
);

Widget _venue({Widget? cover, required String name}) => DabblerCardVenue(
  name: name,
  cover: cover == null ? null : Center(child: cover),
  area: 'Dubai Silicon Oasis',
  distance: '4 km',
  tags: <Widget>[
    DabblerCardVenue.rating(rating: '4.8', reviews: '(126)'),
    const DabblerChip(label: 'Football'),
    const DabblerChip(label: 'Padel'),
  ],
  favourite: DabblerButton.icon(
    icon: 'heart',
    semanticLabel: 'Save venue',
    onPressed: () {},
  ),
  price: 'AED 120 / hour',
  priceCaption: 'Starting from',
  trailing: DabblerButton(label: 'View venue', onPressed: () {}),
  onTap: () {},
);

Widget _stats(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'StatGrid at 100px rows, with icons',
      child: SizedBox(
        width: _width,
        child: DabblerStatGrid(
          rowExtent: DabblerStatGrid.detailsRowHeight,
          children: <DabblerStatTile>[
            DabblerStatTile(
              icon: DabblerIcon('calendar'),
              value: '214',
              label: 'Games run',
              span: 3,
            ),
            DabblerStatTile(
              icon: DabblerIcon('star'),
              value: '4.8',
              label: 'Rating from players',
              span: 3,
              tone: DabblerStatTileTone.amber,
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'long value — fitValue scales down (left) vs clips (right)',
      child: SizedBox(
        width: _width,
        child: DabblerStatGrid(
          children: <DabblerStatTile>[
            DabblerStatTile(
              value: '12,480',
              label: 'Minutes played',
              fitValue: true,
              span: 2,
            ),
            DabblerStatTile(value: '12,480', label: 'Minutes played', span: 2),
          ],
        ),
      ),
    ),
  ],
);
