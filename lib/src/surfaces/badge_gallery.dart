/// Gallery entries for [DabblerBadge] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'badge.dart';

/// Badge's specimens.
const List<GalleryEntry> badgeGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Badge — tones',
    description: 'Every DabblerBadgeTone.',
    builder: _tones,
  ),
];

Widget _tones(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerBadgeTone tone in DabblerBadgeTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerBadge(label: 'Upcoming', tone: tone),
      ),
  ],
);
