/// Gallery entries for [DabblerDivider] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'divider.dart';

/// Divider's specimens.
const List<GalleryEntry> dividerGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Divider — horizontal, labelled, vertical',
    description: 'Hairline by default; strong for a section break.',
    builder: _dividers,
  ),
];

Widget _dividers(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(label: 'default', child: DabblerDivider()),
    GallerySpecimen(label: 'strong', child: DabblerDivider(strong: true)),
    GallerySpecimen(
      label: 'inset',
      child: DabblerDivider(inset: DabblerSpacing.space8),
    ),
    GallerySpecimen(label: 'labelled', child: DabblerDivider(label: 'or')),
    GallerySpecimen(
      label: 'vertical',
      child: SizedBox(height: 48, child: DabblerDivider.vertical()),
    ),
  ],
);
