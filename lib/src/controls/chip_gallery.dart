/// Gallery entries for [DabblerChip] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_geometry.dart';
import 'chip.dart';

/// Chip's specimens.
const List<GalleryEntry> chipGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Chip — selection and leading icon',
    description: 'Unselected, selected, and with a leading icon name.',
    builder: _chips,
  ),
];

Widget _chips(BuildContext context) => const GalleryWrap(
  children: <Widget>[
    GallerySpecimen(label: 'default', child: DabblerChip(label: 'Football')),
    GallerySpecimen(
      label: 'selected',
      child: DabblerChip(label: 'Padel', selected: true),
    ),
    GallerySpecimen(
      label: 'leadingIcon',
      child: DabblerChip(
        label: 'Nearby',
        leadingIcon: DabblerIcon('location', size: DabblerSizing.iconSm),
      ),
    ),
  ],
);
