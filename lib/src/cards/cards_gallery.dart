/// Gallery entries for the card family (KAN-259 AC2).
///
/// One colocated file for the family rather than one per variant: they share a
/// single source specimen sheet and read as a set, and splitting them would
/// put seven near-identical files in the same directory without making any of
/// them independently editable in practice.
///
/// ## What `cards.card.html` draws, and what this package has (KAN-288)
///
/// The fidelity pass is judged by putting this gallery beside
/// `components/cards/cards.card.html`. That page draws **six groups**; this
/// package covers two of them in full and none of the other four. The audit is
/// written here rather than in a ticket comment because the absence is a
/// property of this directory, and a reader who cannot see it will assume the
/// gallery is the whole card family.
///
/// | Drawn on `cards.card.html` | Here |
/// |---|---|
/// | `Card` × 5 shells | **built** — every [DabblerCardVariant], drawn at the specimen's own 150 |
/// | `CardEventSmall/Medium/Large` | **built**, and deliberately *not* the drawn node: the bundle's `8:36`/`8:37`/`8:38` exports are mis-labelled settings rows, so `DECISIONS.md` **D-006** rules the geometry instead. See `DabblerCardEventGeometry`. Comparing them to that page is comparing to the wrong drawing |
/// | `CardHouse` | **built** — with three recorded, test-pinned deviations, listed below |
/// | `CardPricingDefault/Selected` | **built** — one widget, two states, per D-019 |
/// | `CardTicket` | **built in full** — five header colours, eleven status tones, N actions; all five headers and both action counts are specimened below |
/// | `CardRoom`, `CardActiveRoom`, `CardPoll` | **absent** |
/// | `StatTile`, `StatGrid` | **absent** |
/// | `PanelCard`, `ChecklistPanel`, `MemberListPanel` | **absent** |
/// | `MutualsCard` | **absent** |
/// | `Rating` | **not drawn on this page at all**, and absent here |
///
/// The nine absent components are each a whole component with its own source,
/// prompt and states — four of them (`PanelCard` and its two bodies,
/// `StatTile`/`StatGrid`) carry interaction contracts of their own. They are
/// **reported as follow-ups needing separate sizing**, not started here.
///
/// ### CardHouse's three open deltas, deliberately not closed in KAN-288
///
/// All three are drawn one way and built another *on purpose*, each with a
/// written reason and an existing test asserting the deviation
/// (`test/cards/card_house_test.dart:192-251`). Closing them is a design
/// decision plus a test change outside `lib/src/cards/`, so they are reported:
///
/// * join pill `height: 41` → [DabblerSizing.touchTargetMin] (45), on the
///   accessibility floor. **`CardTicket` made the opposite call** for its own
///   40px action pill — transcribe the drawn height, report the conflict — so
///   the package currently answers the same question two ways;
/// * join pill label `14 / 21 / 600` → `.t-label`, which is **17/22 Medium**:
///   three points larger than the drawing, the most visible of the three;
/// * `line-height: 22.5` / `19.5` on the name and meta → the ramp's 20 / 18.
///   `DabblerCardPricing` transcribes exactly these two drawn leadings; this
///   card does not.
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
    id: 'card/variants',
    page: 'components/card',
    group: GalleryPurpose.contentContainers,
    title: 'Card — variants',
    description: 'The base card in every DabblerCardVariant.',
    builder: _cards,
  ),
  GalleryEntry(
    id: 'card-event/densities',
    page: 'components/card-event',
    group: GalleryPurpose.contentContainers,
    title: 'Card — event, large / medium / small',
    description: 'The three event densities.',
    builder: _events,
  ),
  GalleryEntry(
    id: 'card-house/composed',
    page: 'components/card-house',
    group: GalleryPurpose.contentContainers,
    title: 'Card — house, pricing, ticket',
    description: 'The venue card, both pricing states, and the ticket with '
        'its header tones and status tones.',
    builder: _others,
  ),
  GalleryEntry(
    id: 'empty-state',
    page: 'components/empty-state',
    group: GalleryPurpose.statusAndFeedback,
    title: 'EmptyState — inline and page',
    description: 'Both sizes, with and without an action.',
    builder: _emptyStates,
  ),
];

/// The shell row of `components/cards/cards.card.html:48-52`.
///
/// `width: 150` and a body reading the variant's own name are the drawn
/// specimen's, not this gallery's invention: the five shells are compared to
/// that row side by side, and a 200-wide shell carrying "Card body" cannot be.
Widget _cards(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerCardVariant variant in DabblerCardVariant.values)
      GallerySpecimen(
        label: variant.name,
        child: DabblerCard(
          variant: variant,
          width: 150,
          child: Text(variant.name),
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
    // The design's own house specimen, content and all — `CardHouse.jsx`'s
    // `text1`/`text2`/`text3` defaults, which are what
    // `components/cards/cards.card.html` draws in its "Kit compositions" row.
    // Invented content ("Wadi Degla", "Maadi · 6 courts", "Book") cannot be put
    // beside that page, which is how this ticket is judged. Same reasoning as
    // [_ticketSpecs] below.
    const GallerySpecimen(
      label: 'house',
      child: DabblerCardHouse(
        name: 'Dabbler Design House',
        meta: '25–50 rooms / week',
        actionLabel: 'join house',
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
