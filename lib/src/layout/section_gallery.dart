/// Gallery entries for [DabblerSection] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/surface.dart';
import 'section.dart';

/// Section's specimens.
const List<GalleryEntry> sectionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'section',
    page: 'components/section',
    group: GalleryPurpose.contentContainers,
    title: 'Section — title, subtitle and action',
    description: 'The standard grouping header a screen repeats down a page.',
    builder: _sections,
  ),
];

Widget _sections(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'title only',
      child: DabblerSection(
        title: 'Today',
        children: <Widget>[
          DabblerSurface.card(height: 56, center: true, child: Text('Game')),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'title, subtitle and action',
      child: DabblerSection(
        title: 'Near you',
        subtitle: 'Within 5 km',
        action: Text('See all'),
        children: <Widget>[
          DabblerSurface.card(height: 56, center: true, child: Text('Game')),
        ],
      ),
    ),
  ],
);
