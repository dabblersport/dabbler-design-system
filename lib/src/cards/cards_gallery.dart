/// Gallery entries for the card family (KAN-259 AC2).
///
/// One colocated file for the family rather than one per variant: they share a
/// single source specimen sheet and read as a set, and splitting them would
/// put seven near-identical files in the same directory without making any of
/// them independently editable in practice.
library;

import 'package:flutter/widgets.dart';

import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card.dart';
import 'card_event_large.dart';
import 'card_event_medium.dart';
import 'card_event_small.dart';
import 'card_house.dart';
import 'card_pricing_default.dart';
import 'card_ticket.dart';
import 'empty_state.dart';

/// The card family's specimens.
const List<GalleryEntry> cardsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Card — variants',
    description: 'The base card in every DabblerCardVariant.',
    builder: _cards,
  ),
  GalleryEntry(
    title: 'Card — event, large / medium / small',
    description: 'The three event densities.',
    builder: _events,
  ),
  GalleryEntry(
    title: 'Card — house, pricing, ticket',
    description: 'The venue card, both pricing states, and the ticket with '
        'its header tones and status tones.',
    builder: _others,
  ),
  GalleryEntry(
    title: 'EmptyState — inline and page',
    description: 'Both sizes, with and without an action.',
    builder: _emptyStates,
  ),
];

Widget _cards(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerCardVariant variant in DabblerCardVariant.values)
      GallerySpecimen(
        label: variant.name,
        child: DabblerCard(
          variant: variant,
          width: 200,
          child: const Text('Card body'),
        ),
      ),
  ],
);

Widget _events(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'large',
      child: DabblerCardEventLarge(
        title: 'Friday five-a-side',
        sport: DabblerSport.football,
        location: 'Zamalek Sporting Club',
      ),
    ),
    GallerySpecimen(
      label: 'medium',
      child: DabblerCardEventMedium(
        title: 'Padel doubles',
        sport: DabblerSport.padel,
        location: 'New Cairo',
      ),
    ),
    GallerySpecimen(
      label: 'small',
      child: DabblerCardEventSmall(
        title: 'Morning run',
        sport: DabblerSport.running,
        location: 'Corniche',
      ),
    ),
  ],
);

Widget _others(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'house',
      child: DabblerCardHouse(
        name: 'Wadi Degla',
        meta: 'Maadi · 6 courts',
        actionLabel: 'Book',
      ),
    ),
    const GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'pricing, unselected',
          child: DabblerCardPricing(plan: 'Monthly', price: 'EGP 250'),
        ),
        GallerySpecimen(
          label: 'pricing, selected',
          child: DabblerCardPricing(
            plan: 'Yearly',
            price: 'EGP 2,400',
            priceNote: '/year',
            trialLabel: '7-day trial',
            selected: true,
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final DabblerTicketHeader header in DabblerTicketHeader.values)
          GallerySpecimen(
            label: 'ticket, ${header.name}',
            child: DabblerCardTicket(
              header: header,
              code: 'DBL-40192',
              title: 'Friday five-a-side',
              organiser: 'Zamalek SC',
              price: 'EGP 120',
              status: 'Upcoming',
            ),
          ),
      ],
    ),
  ],
);

Widget _emptyStates(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'inline',
      child: DabblerEmptyState(
        icon: 'calendar',
        title: 'No games yet',
        text: 'Games you join show up here.',
      ),
    ),
    GallerySpecimen(
      label: 'page',
      child: DabblerEmptyState(
        icon: 'search-normal',
        title: 'Nothing matched',
        text: 'Try widening your filters.',
        size: DabblerEmptyStateSize.page,
      ),
    ),
  ],
);
