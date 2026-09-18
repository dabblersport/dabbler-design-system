/// Gallery entries for [DabblerSurface] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'surface.dart';

/// Surface's specimens.
const List<GalleryEntry> surfaceGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'surface/variants',
    page: 'components/surface',
    group: GalleryPurpose.contentContainers,
    title: 'Surface — variants',
    description: 'Every DabblerSurfaceVariant. Flat throughout: no shadow, '
        'no gradient, no blur.',
    builder: _variants,
  ),
];

Widget _variants(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerSurfaceVariant variant in DabblerSurfaceVariant.values)
      GallerySpecimen(
        label: variant.name,
        child: DabblerSurface(
          variant: variant,
          width: 120,
          height: 72,
          center: true,
          padding: const EdgeInsets.all(DabblerSpacing.space4),
          child: Text(variant.name),
        ),
      ),
  ],
);
