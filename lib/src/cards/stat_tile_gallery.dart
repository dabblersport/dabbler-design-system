/// Gallery entries for [DabblerStatTile] and [DabblerStatGrid].
///
/// The specimen mirrors the live design project's `cards.card.html` StatTile
/// group: every tone at the small size, the hero and wide footprints, an
/// interactive tile, and a six-column bento made with [DabblerStatGrid].
/// Line art is supplied by the caller in the product; the gallery draws none.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'stat_tile.dart';

/// StatTile's specimens.
const List<GalleryEntry> statTileGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'stat-tile',
    page: 'components/stat-tile',
    group: GalleryPurpose.contentContainers,
    title: 'StatTile — the bento stat tile',
    description:
        'Every tone at small, the hero and wide footprints, an '
        'interactive tile with a trailing chevron, and a StatGrid.',
    builder: _tiles,
  ),
];

Widget _tiles(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerStatTileTone tone in DabblerStatTileTone.values)
          GallerySpecimen(
            label: tone.name,
            child: SizedBox(
              width: 150,
              height: 78,
              child: DabblerStatTile(
                value: '214',
                label: 'Games run',
                sub: '4 years',
                tone: tone,
              ),
            ),
          ),
      ],
    ),
    GallerySpecimen(
      label: 'a StatGrid — hero, small, small, wide, interactive',
      child: SizedBox(
        width: 360,
        child: DabblerStatGrid(
          children: <DabblerStatTile>[
            const DabblerStatTile(
              size: DabblerStatTileSize.hero,
              tone: DabblerStatTileTone.brand,
              value: '214',
              label: 'Games run',
              sub: '4 years · 86 regulars',
            ),
            const DabblerStatTile(value: '4.8', label: 'Rating'),
            const DabblerStatTile(
              value: '12',
              label: 'Streak',
              tone: DabblerStatTileTone.amber,
            ),
            const DabblerStatTile(
              size: DabblerStatTileSize.wide,
              tone: DabblerStatTileTone.sunken,
              value: '98%',
              label: 'Show-up rate',
              sub: 'last 90 days',
            ),
            DabblerStatTile(
              value: '31',
              label: 'Squads',
              tone: DabblerStatTileTone.info,
              onTap: () {},
              trailing: const DabblerIcon(
                'arrow-right-3',
                size: 18,
                mirrorInRtl: true,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
);
