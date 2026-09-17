/// Gallery entries for [DabblerIconTile] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'icon_tile.dart';

/// IconTile's specimens.
const List<GalleryEntry> iconTileGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'IconTile — tones and weights',
    description: 'Every DabblerIconTileTone, plus the bold-weight named form.',
    builder: _tiles,
  ),
];

Widget _tiles(BuildContext context) => GalleryStack(
  children: <Widget>[
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
    const GallerySpecimen(
      label: 'bold weight, tappable',
      child: DabblerIconTile.named(
        'ticket-2',
        weight: DabblerIconWeight.bold,
        semanticLabel: 'Tickets',
      ),
    ),
  ],
);
