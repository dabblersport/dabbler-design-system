/// Gallery entries for the Meetups parts: [DabblerMeetupAttendees],
/// [DabblerCardUpcomingRail], [DabblerRsvpCta] and [DabblerHostCard]
/// (`Listings.dc.html` meetup frames, `Details.dc.html` meetup frame; KAN-429).
library;

import 'package:flutter/widgets.dart';

import '../controls/rsvp_cta.dart';
import '../feed/feed_atoms.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import 'card_event_listing.dart';
import 'card_game.dart';
import 'card_upcoming.dart';
import 'card_upcoming_rail.dart';
import 'host_card.dart';
import 'meetup_attendees.dart';

/// Meetups-part specimens.
const List<GalleryEntry> meetupPartsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'meetup-attendees',
    page: 'components/meetup-attendees',
    group: GalleryPurpose.contentContainers,
    title: 'MeetupAttendees — who is going and how many fit',
    description: 'Avatar stack, going count and capacity; open and full.',
    builder: _attendees,
  ),
  GalleryEntry(
    id: 'card-upcoming-rail',
    page: 'components/card-upcoming-rail',
    group: GalleryPurpose.contentContainers,
    title: 'CardUpcomingRail — the narrow upcoming tile',
    description: 'Date block, title, time, venue and a small countdown ring.',
    builder: _rail,
  ),
  GalleryEntry(
    id: 'rsvp-cta',
    page: 'components/rsvp-cta',
    group: GalleryPurpose.actions,
    title: 'RsvpCta — the call to action in every RSVP state',
    description:
        'Join, request, going, interested, pending, full and the inert '
        'closed, cancelled, started, not visible and not allowed.',
    builder: _cta,
  ),
  GalleryEntry(
    id: 'host-card',
    page: 'components/host-card',
    group: GalleryPurpose.contentContainers,
    title: 'HostCard — who runs the meetup',
    description:
        'Avatar, role and name on the accent tile, with a pill action.',
    builder: _host,
  ),
  GalleryEntry(
    id: 'card-game/meetup',
    page: 'components/card-game',
    group: GalleryPurpose.contentContainers,
    title: 'CardGame as a meetup — the Listings meetup card',
    description: 'Badges, attendees, price, an RSVP action and social counts.',
    builder: _meetupCard,
  ),
];

const double _width = 360;

Widget _attendees(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'open',
      child: DabblerMeetupAttendees(
        people: <String>[
          'Ahmed Farouk',
          'Lina Haddad',
          'Yousef Amer',
          'Nadia Saleh',
        ],
        goingLabel: '24 going',
        capacityLabel: 'Max 40',
      ),
    ),
    GallerySpecimen(
      label: 'full',
      child: DabblerMeetupAttendees(
        people: <String>['Mariam Zayed', 'Hessa Ali'],
        goingLabel: '25 going',
        capacityLabel: 'Full',
        full: true,
      ),
    ),
    GallerySpecimen(
      label: 'nobody yet',
      child: DabblerMeetupAttendees(
        goingLabel: '0 going',
        capacityLabel: 'Max 25',
      ),
    ),
  ],
);

Widget _rail(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'amber',
      child: DabblerCardUpcomingRail(
        month: 'SEP',
        day: '2',
        title: 'Sunrise run',
        time: '6:00 AM',
        place: 'Kite Beach',
        fraction: 0.4,
        countdownValue: '3',
        countdownUnit: 'hours',
      ),
    ),
    GallerySpecimen(
      label: 'info',
      child: DabblerCardUpcomingRail(
        tone: DabblerCardUpcomingTone.info,
        month: 'SEP',
        day: '3',
        title: 'يوغا الغروب',
        time: '6:45 PM',
        place: 'Al Barsha Pond Park',
        fraction: 0.15,
        countdownValue: '1',
        countdownUnit: 'day',
      ),
    ),
  ],
);

Widget _cta(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final (DabblerRsvpCtaState, String) s
        in <(DabblerRsvpCtaState, String)>[
          (DabblerRsvpCtaState.join, 'Join meetup'),
          (DabblerRsvpCtaState.request, 'Request to join'),
          (DabblerRsvpCtaState.going, 'You are going'),
          (DabblerRsvpCtaState.interested, 'Maybe going'),
          (DabblerRsvpCtaState.pending, 'Request sent'),
          (DabblerRsvpCtaState.full, "Full - you're interested"),
          (DabblerRsvpCtaState.closed, 'Registration closed'),
          (DabblerRsvpCtaState.cancelled, 'Cancelled'),
          (DabblerRsvpCtaState.started, 'Already started'),
          (DabblerRsvpCtaState.notVisible, 'Not available'),
          (DabblerRsvpCtaState.notAllowed, 'Switch to a Socialiser profile'),
        ])
      GallerySpecimen(
        label: s.$1.name,
        child: SizedBox(
          width: _width,
          child: DabblerRsvpCta(state: s.$1, label: s.$2, onPressed: () {}),
        ),
      ),
    GallerySpecimen(
      label: 'card size',
      child: SizedBox(
        width: _width,
        child: DabblerRsvpCta(
          state: DabblerRsvpCtaState.going,
          label: 'You are going',
          size: DabblerRsvpCtaSize.card,
          onPressed: () {},
        ),
      ),
    ),
  ],
);

Widget _host(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'with action',
      child: SizedBox(
        width: _width,
        child: DabblerHostCard(
          seed: 'Dubai Running Club',
          name: 'Dubai Running Club',
          caption: 'Community host',
          actionLabel: 'Follow',
          onAction: () {},
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'host only',
      child: SizedBox(
        width: _width,
        child: DabblerHostCard(name: 'Mariam Zayed', caption: 'Host'),
      ),
    ),
  ],
);

Widget _meetupCard(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'meetup',
      child: SizedBox(
        width: _width,
        child: DabblerCardGame(
          title: 'Sunrise run',
          tags: const <Widget>[
            DabblerBadge(label: 'Running'),
            DabblerBadge(label: 'Outdoor'),
            DabblerBadge(label: 'Beginner'),
          ],
          dayLabel: 'Today',
          timeLabel: '6:00 AM',
          meta: const <String>['Kite Beach', '3 km'],
          progress: const DabblerMeetupAttendees(
            people: <String>['Ahmed Farouk', 'Lina Haddad', 'Yousef Amer'],
            goingLabel: '24 going',
            capacityLabel: 'Max 40',
          ),
          price: const DabblerCardEventPrice(
            price: 'Free',
            note: 'no charge',
            free: true,
          ),
          action: DabblerRsvpCta(
            state: DabblerRsvpCtaState.join,
            label: 'Join meetup',
            size: DabblerRsvpCtaSize.card,
            onPressed: () {},
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerFeedAction(icon: 'heart', count: 9),
              DabblerFeedAction(icon: 'share', count: 4),
            ],
          ),
          onTap: () {},
        ),
      ),
    ),
  ],
);
