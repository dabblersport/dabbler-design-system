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

/// The design's own ticket specimens, content and all.
///
/// The four tickets on `components/cards/cards.card.html` are reproduced
/// literally — same references, dates, organisers, titles, prices, status tones
/// and **action counts** — because the fidelity pass is judged by putting this
/// gallery beside that page, and a specimen carrying invented content
/// ("EGP 120", "Friday five-a-side") cannot be compared to it.
///
/// `brand` is the fifth header the design describes but does not draw; it is
/// shown last, on the first specimen's content, so the set is complete.
const List<_TicketSpec> _ticketSpecs = <_TicketSpec>[
  _TicketSpec(
    header: DabblerTicketHeader.indigo,
    code: 'GBD99763JS',
    date: '24/09/2024',
    organiser: 'Reform Padel Club',
    title: 'Tuesday Padel Doubles',
    status: 'Upcoming',
    tone: DabblerTicketStatusTone.upcoming,
    price: 'AED 45',
    actions: <String>['Register', 'Done'],
  ),
  _TicketSpec(
    header: DabblerTicketHeader.amber,
    code: 'GBD997275JP',
    date: '29/08/2024',
    organiser: 'Zayed Sports City',
    title: 'Saturday 7-a-side',
    status: 'Past',
    tone: DabblerTicketStatusTone.past,
    price: 'AED 35',
    actions: <String>['View Detail'],
  ),
  _TicketSpec(
    header: DabblerTicketHeader.mint,
    code: 'GBD99118TR',
    date: '10/04/2024',
    organiser: 'Dubai Padel League',
    title: 'Ramadan Padel Cup',
    status: 'Success',
    tone: DabblerTicketStatusTone.success,
    price: 'AED 120',
    actions: <String>['View Detail'],
  ),
  _TicketSpec(
    header: DabblerTicketHeader.pink,
    code: 'GBD99420MK',
    date: '10/08/2024',
    organiser: 'Trendsetters Collective',
    title: 'Urban Chic Showcase',
    status: 'Expired',
    tone: DabblerTicketStatusTone.expired,
    price: 'AED 95',
    actions: <String>['View Detail'],
  ),
  _TicketSpec(
    header: DabblerTicketHeader.brand,
    code: 'GBD99763JS',
    date: '24/09/2024',
    organiser: 'Reform Padel Club',
    title: 'Tuesday Padel Doubles',
    status: 'Upcoming',
    tone: DabblerTicketStatusTone.upcoming,
    price: 'AED 45',
    actions: <String>['Register', 'Done'],
  ),
];

/// One row of [_ticketSpecs].
@immutable
class _TicketSpec {
  const _TicketSpec({
    required this.header,
    required this.code,
    required this.date,
    required this.organiser,
    required this.title,
    required this.status,
    required this.tone,
    required this.price,
    required this.actions,
  });

  final DabblerTicketHeader header;
  final String code;
  final String date;
  final String organiser;
  final String title;
  final String status;
  final DabblerTicketStatusTone tone;
  final String price;
  final List<String> actions;
}

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
      // The design's own pricing pair: the trial pill straddling the top edge
      // on both tiles, the per-year figure with its per-month equivalent
      // beneath it, and the billing note under that.
      children: <Widget>[
        GallerySpecimen(
          label: 'pricing, selected',
          child: DabblerCardPricing(
            plan: 'yearly',
            price: r'$59.99/yr',
            priceNote: r'($5.00/mo)',
            billingNote: 'billed annually',
            trialLabel: '7d free trial',
            selected: true,
            width: 186,
          ),
        ),
        GallerySpecimen(
          label: 'pricing, unselected',
          child: DabblerCardPricing(
            plan: 'monthly',
            price: r'$5.99/mo',
            billingNote: 'billed monthly',
            trialLabel: '7d free trial',
            width: 186,
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final _TicketSpec spec in _ticketSpecs)
          GallerySpecimen(
            label: 'ticket, ${spec.header.name}',
            child: DabblerCardTicket(
              header: spec.header,
              code: spec.code,
              date: spec.date,
              organiser: spec.organiser,
              title: spec.title,
              status: spec.status,
              statusTone: spec.tone,
              price: spec.price,
              width: 400,
              actions: <DabblerTicketAction>[
                for (final String label in spec.actions)
                  DabblerTicketAction(label: label),
              ],
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
