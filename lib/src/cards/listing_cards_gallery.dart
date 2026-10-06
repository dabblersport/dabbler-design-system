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
import '../controls/favourite_button.dart';
import '../feedback/progress_bar.dart';
import '../foundations/icon.dart';
import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card_event_large.dart';
import 'card_event_listing.dart';
import 'card_event_medium.dart';
import 'card_venue.dart';
import 'card_game.dart';
import 'empty_state.dart';
import 'meta_line.dart';
import '../feedback/listing_skeleton.dart';
import '../layout/tabs.dart';
import '../surfaces/listing_tag.dart';
import '../tokens/dabbler_geometry.dart';
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
    id: 'listing-tag',
    page: 'components/listing-tag',
    group: GalleryPurpose.identityAndStatus,
    title: 'ListingTag — the listing card pills',
    description:
        'Every tone of the 11/15 tag, the solid distance chip with its pin, '
        'and the outlined sport chip.',
    builder: _tags,
  ),
  GalleryEntry(
    id: 'meta-line',
    page: 'components/meta-line',
    group: GalleryPurpose.contentContainers,
    title: 'MetaLine — place, distance, duration',
    description:
        'The card size with the place emphasised, and the compact size of '
        'the upcoming card.',
    builder: _metaLines,
  ),
  GalleryEntry(
    id: 'listing-skeleton',
    page: 'components/listing-skeleton',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ListingSkeleton — game, meetup and venue placeholders',
    description: 'One placeholder per listing card, in its own shape.',
    builder: _skeletons,
  ),
  GalleryEntry(
    id: 'empty-state/listing',
    page: 'components/empty-state',
    group: GalleryPurpose.statusAndFeedback,
    title: 'EmptyState — listing size',
    description:
        'The 18-radius card with the 60 brand well, display title, copy '
        'and one action.',
    builder: _emptyListing,
  ),
  GalleryEntry(
    id: 'card-game/social',
    page: 'components/card-game',
    group: GalleryPurpose.contentContainers,
    title: 'CardGame — Join beside the social counts',
    description:
        'The action row: Join takes half of what the counts leave, as the '
        'frame lays it out.',
    builder: _gameSocial,
  ),
  GalleryEntry(
    id: 'tabs/listing',
    page: 'components/tabs',
    group: GalleryPurpose.navigation,
    title: 'Tabs — listing',
    description:
        'The listing rail: label-width tabs 21 apart, 600 active and 500 '
        'otherwise, 9 above a 2px underline.',
    builder: _listingTabs,
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
  tags: <Widget>[
    DabblerCardVenue.distanceTag(label: '4 km away'),
    DabblerCardVenue.rating(rating: '4.8', reviews: '(126)'),
    const DabblerListingTag(
      label: 'Top rated',
      tone: DabblerListingTagTone.warning,
    ),
  ],
  sports: const <Widget>[
    DabblerListingTag.outlined(label: 'Football'),
    DabblerListingTag.outlined(label: 'Padel'),
  ],
  facilities: <Widget>[
    DabblerCardVenue.facility(icon: 'car', label: 'Parking'),
    DabblerCardVenue.facility(icon: 'cup', label: 'Cafe'),
  ],
  favourite: DabblerFavouriteButton(
    selected: false,
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

Widget _tags(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'tones',
      child: Wrap(
        spacing: DabblerSpacing.space2,
        runSpacing: DabblerSpacing.space2,
        children: <Widget>[
          for (final DabblerListingTagTone t in DabblerListingTagTone.values)
            DabblerListingTag(label: t.name, tone: t),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'distance chip and outlined sport chips',
      child: Wrap(
        spacing: DabblerSpacing.space2,
        runSpacing: DabblerSpacing.space2,
        children: <Widget>[
          DabblerCardVenue.distanceTag(label: '4 km away'),
          const DabblerListingTag.outlined(label: 'Football'),
          const DabblerListingTag.outlined(label: 'Basketball'),
        ],
      ),
    ),
  ],
);

Widget _metaLines(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'card',
      child: SizedBox(
        width: _width,
        child: DabblerMetaLine(
          items: <String>['Dubai Sports City', '2.1 km', '90 min'],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'compact',
      child: SizedBox(
        width: _width,
        child: DabblerMetaLine(
          items: <String>['Kite Beach', '4.6 km'],
          size: DabblerMetaLineSize.compact,
        ),
      ),
    ),
  ],
);

Widget _skeletons(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerListingSkeletonKind k
        in DabblerListingSkeletonKind.values)
      GallerySpecimen(
        label: k.name,
        child: SizedBox(
          width: _width,
          child: DabblerListingSkeleton(kind: k),
        ),
      ),
  ],
);

Widget _emptyListing(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'listing',
      child: SizedBox(
        width: _width,
        child: DabblerEmptyState(
          icon: 'game',
          title: 'No games found nearby.',
          text:
              'Nothing within 5 km in the next 3 days. Widen the date or sport.',
          size: DabblerEmptyStateSize.listing,
          action: DabblerButton(label: 'Change filters', onPressed: () {}),
        ),
      ),
    ),
  ],
);

Widget _gameSocial(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'Join beside likes and shares',
      child: SizedBox(
        width: _width,
        child: DabblerCardGame(
          title: 'Tuesday 5-a-side',
          verified: true,
          tags: const <Widget>[
            DabblerListingTag(label: 'Football'),
            DabblerListingTag(
              label: 'Futsal 5s',
              tone: DabblerListingTagTone.brandTint,
            ),
          ],
          dayLabel: 'Today',
          timeLabel: '7:30 PM',
          meta: const <String>['Dubai Sports City', '2.1 km', '90 min'],
          price: const DabblerCardEventPrice(
            price: 'AED 40',
            note: 'per player',
          ),
          action: DabblerCardEventListing.joinButton(
            label: 'Join game',
            onPressed: () {},
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DabblerSpacing.space5,
            children: <Widget>[
              DabblerIcon('heart', size: DabblerSizing.iconRow),
              DabblerIcon('share', size: DabblerSizing.iconRow),
            ],
          ),
          onTap: () {},
        ),
      ),
    ),
  ],
);

Widget _listingTabs(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'listing',
      child: SizedBox(
        width: _width,
        child: DabblerTabs(
          variant: DabblerTabsVariant.listing,
          scrollable: true,
          value: 'all',
          onChanged: (_) {},
          items: const <DabblerTabItem>[
            DabblerTabItem(id: 'all', label: 'All sports'),
            DabblerTabItem(id: 'football', label: 'Football'),
            DabblerTabItem(id: 'padel', label: 'Padel'),
            DabblerTabItem(id: 'basketball', label: 'Basketball'),
          ],
        ),
      ),
    ),
  ],
);
