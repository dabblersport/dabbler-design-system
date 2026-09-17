/// Gallery entries for the foundations — [DabblerIcon], [DabblerSportIcon] and
/// [DabblerSportBackground] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'icon.dart';
import 'sport_background.dart';
import 'sport_icon.dart';
import 'sports.dart';

/// The foundations' specimens.
const List<GalleryEntry> foundationsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Icon — the app vocabulary',
    description: 'Every name in DabblerIconRegistry.vocabulary, linear, at '
        'the three documented sizes for the first few.',
    builder: _icons,
  ),
  GalleryEntry(
    title: 'SportIcon — every sport',
    description: 'DabblerSport.values in both weights.',
    builder: _sportIcons,
  ),
  GalleryEntry(
    title: 'SportBackground — every variant',
    description: 'The artwork behind a sport-themed surface.',
    builder: _sportBackgrounds,
  ),
];

Widget _icons(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final double size in <double>[
          DabblerSizing.iconSm,
          DabblerSizing.iconMd,
          DabblerSizing.iconLg,
        ])
          GallerySpecimen(
            label: '${size.toInt()}',
            child: DabblerIcon('calendar', size: size),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final String name in DabblerIconRegistry.vocabulary)
          GallerySpecimen(label: name, child: DabblerIcon(name)),
      ],
    ),
  ],
);

Widget _sportIcons(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerSport sport in DabblerSport.values)
      GallerySpecimen(
        label: sport.name,
        child: DabblerSportIcon(sport, size: DabblerSizing.iconLg),
      ),
  ],
);

Widget _sportBackgrounds(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerSportBackgroundVariant variant
        in DabblerSportBackgroundVariant.values)
      GallerySpecimen(
        label: variant.name,
        child: SizedBox(
          width: 160,
          height: 100,
          child: DabblerSportBackground(
            DabblerSport.football,
            variant: variant,
          ),
        ),
      ),
  ],
);
