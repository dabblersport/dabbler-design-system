/// Gallery entries for [DabblerIconTile] (KAN-259 AC2).
///
/// The first row mirrors the design specimen
/// `components/surfaces/surfaces.card.html`: *"Default tint · overridden tint ·
/// with a SportIcon"* — `game`, `location`, `notification-bing` on the accent
/// tint, and a `padel` [DabblerSportIcon]. The previous entry drew `calendar`
/// four times, which showed the tones but not the thing the specimen is about:
/// that the slot takes **any** 24px glyph, including a sport glyph.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sport_icon.dart';
import '../foundations/sports.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'icon_tile.dart';

/// IconTile's specimens.
const List<GalleryEntry> iconTileGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'icon-tile',
    page: 'components/icon-tile',
    group: GalleryPurpose.contentContainers,
    title: 'IconTile — the 45×45 tinted glyph container',
    description: 'Default tint · overridden tint · with a SportIcon, then '
        'every DabblerIconTileTone and the bold-weight form.',
    builder: _tiles,
  ),
];

Widget _tiles(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'game — default tint',
          child: DabblerIconTile.named('game', semanticLabel: 'Games'),
        ),
        GallerySpecimen(
          label: 'location — default tint',
          child: DabblerIconTile.named('location', semanticLabel: 'Location'),
        ),
        GallerySpecimen(
          // `color="var(--color-accent)"` in the specimen; this system reaches
          // the accent tint through the tone rather than a raw colour.
          label: 'notification-bing — accent',
          child: DabblerIconTile.named(
            'notification-bing',
            tone: DabblerIconTileTone.accent,
            semanticLabel: 'Notifications',
          ),
        ),
        GallerySpecimen(
          label: 'a SportIcon in the slot',
          child: DabblerIconTile(
            DabblerSportIcon(DabblerSport.padel, size: DabblerSizing.iconMd),
            semanticLabel: 'Padel',
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final DabblerIconTileTone tone in DabblerIconTileTone.values)
          GallerySpecimen(
            label: tone.name,
            child: DabblerIconTile.named(
              'calendar',
              tone: tone,
              semanticLabel: 'Calendar',
            ),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'bold weight, tappable',
          child: DabblerIconTile.named(
            'ticket-2',
            weight: DabblerIconWeight.bold,
            semanticLabel: 'Tickets',
          ),
        ),
      ],
    ),
  ],
);
