/// Gallery entries for [DabblerMiniPlayer] and [DabblerSpeakerGrid] — the live
/// design project's `rooms.card.html`, with injected text and seeds.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'mini_player.dart';
import 'speaker_grid.dart';

/// The rooms specimens.
const List<GalleryEntry> roomsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'mini-player',
    page: 'components/mini-player',
    group: GalleryPurpose.contentContainers,
    title: 'MiniPlayer — the collapsed room player',
    description: 'Two avatars, a caption and three glyph actions.',
    builder: _miniPlayer,
  ),
  GalleryEntry(
    id: 'speaker-grid',
    page: 'components/speaker-grid',
    group: GalleryPurpose.contentContainers,
    title: 'SpeakerGrid — the room speakers',
    description: 'Six cells in three columns, with speaking and invite badges.',
    builder: _speakerGrid,
  ),
];

Widget _miniPlayer(BuildContext context) => GallerySpecimen(
  label: 'caption with actions',
  child: SizedBox(
    width: 384,
    child: DabblerMiniPlayer(
      caption: 'Design room · 134 listening',
      avatarSeeds: const <String>['Alen Rahman', 'Mariam Al Suwaidi'],
      actions: <DabblerMiniPlayerAction>[
        DabblerMiniPlayerAction(
          icon: 'heart',
          label: 'Like',
          weight: DabblerIconWeight.bold,
          tone: DabblerMiniPlayerTone.accent,
          onTap: () {},
        ),
        DabblerMiniPlayerAction(
          icon: 'arrow-up-2',
          label: 'Share',
          onTap: () {},
        ),
        DabblerMiniPlayerAction(
          icon: 'sms',
          label: 'Chat',
          tone: DabblerMiniPlayerTone.brand,
          onTap: () {},
        ),
      ],
    ),
  ),
);

Widget _speakerGrid(BuildContext context) => const GallerySpecimen(
  label: 'six speakers',
  child: DabblerSpeakerGrid(
    speakers: <DabblerSpeaker>[
      DabblerSpeaker(
        name: 'Alen',
        seed: 'Alen Rahman',
        badge: DabblerSpeakerBadge.speaking,
      ),
      DabblerSpeaker(
        name: 'Maya',
        seed: 'Mariam Al Suwaidi',
        badge: DabblerSpeakerBadge.speaking,
      ),
      DabblerSpeaker(name: 'Sara', seed: 'Salem Al Marri'),
      DabblerSpeaker(
        name: 'Josh',
        seed: 'Jomana Fikri',
        badge: DabblerSpeakerBadge.invite,
      ),
      DabblerSpeaker(
        name: 'Nina',
        seed: 'Nizar Toufic',
        badge: DabblerSpeakerBadge.speaking,
      ),
      DabblerSpeaker(name: 'Drew', seed: 'Dara Rostami'),
    ],
  ),
);
