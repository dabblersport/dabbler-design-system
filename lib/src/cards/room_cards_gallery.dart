/// Gallery entries for the room-and-poll cards: [DabblerCardPoll],
/// [DabblerCardRoom] and [DabblerCardActiveRoom].
///
/// The compositions mirror the live design project's `cards.card.html`
/// (Poll, Room, Active-Room) with injected text and seeds.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card_active_room.dart';
import 'card_poll.dart';
import 'card_room.dart';

/// The room-card specimens.
const List<GalleryEntry> roomCardsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'card-poll',
    page: 'components/card-poll',
    group: GalleryPurpose.contentContainers,
    title: 'CardPoll — a poll result',
    description: 'Two options, the vote count, and the end-poll link.',
    builder: _poll,
  ),
  GalleryEntry(
    id: 'card-room',
    page: 'components/card-room',
    group: GalleryPurpose.contentContainers,
    title: 'CardRoom — a room',
    description: 'A room name and topic with a participant stack.',
    builder: _room,
  ),
  GalleryEntry(
    id: 'card-active-room',
    page: 'components/card-active-room',
    group: GalleryPurpose.contentContainers,
    title: 'CardActiveRoom — a live room',
    description: 'The speaker, the mute pill and the join pill.',
    builder: _active,
  ),
];

Widget _poll(BuildContext context) => const GallerySpecimen(
  label: 'two options',
  child: SizedBox(
    width: 360,
    child: DabblerCardPoll(
      question: 'Which color scheme?',
      options: <DabblerPollOption>[
        DabblerPollOption(fraction: 0.65, percentLabel: '65%'),
        DabblerPollOption(fraction: 0.35, percentLabel: '35%'),
      ],
      votesLabel: '42 votes',
    ),
  ),
);

Widget _room(BuildContext context) => const GallerySpecimen(
  label: 'with four avatars and +42',
  child: SizedBox(
    width: 360,
    child: DabblerCardRoom(
      name: 'Design Studio',
      topic: 'Product critique — Dabbler v2 new flows',
      avatarSeeds: <String>[
        'Alen Rahman',
        'Bushra Riaz',
        'Carlos Alvarez',
        'Dana Halabi',
      ],
      overflowLabel: '+42',
    ),
  ),
);

Widget _active(BuildContext context) => GallerySpecimen(
  label: 'unmute and join',
  child: SizedBox(
    width: 360,
    child: DabblerCardActiveRoom(
      name: 'Design Sync',
      topic: 'Weekly design critique',
      speakerSeed: 'Mina Iskander',
      onMute: () {},
      onJoin: () {},
    ),
  ),
);
