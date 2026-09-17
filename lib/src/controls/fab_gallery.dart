/// Gallery entries for [DabblerFab] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'fab.dart';

/// Fab's specimens.
const List<GalleryEntry> fabGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Fab — tones',
    description: 'Every DabblerFabTone. The FAB carries the system\'s one '
        'documented shadow exception.',
    builder: _tones,
  ),
];

Widget _tones(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerFabTone tone in DabblerFabTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerFab(
          tone: tone,
          semanticLabel: 'Create game',
          onPressed: _noop,
          child: const DabblerIcon('add'),
        ),
      ),
  ],
);

void _noop() {}
