/// Gallery entry for [DabblerImage] (KAN-410 item b).
///
/// The gallery ships no photo and calls no third-party host: every specimen
/// uses a null or unreachable URL, so what shows is deterministic — the
/// placeholder, the error state, the scrim with an overlay and the radii.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_geometry.dart';
import 'image.dart';

/// The image's specimens.
const List<GalleryEntry> imageGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'image',
    page: 'components/image',
    group: GalleryPurpose.contentContainers,
    title: 'Image — network photo frame',
    description:
        'A token-radius frame: the sunken fill while loading or with no URL, '
        'an error glyph and label when the request fails, an optional scrim '
        'with a badge over it, and the cover and thumbnail radii.',
    builder: _image,
  ),
];

const String _broken = 'https://invalid.example/cover.png';

Widget _frame(Widget child) => SizedBox(width: 320, child: child);

Widget _image(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'no URL — placeholder (cover, 210 high, xl radius)',
      child: _frame(const DabblerImage(height: 210)),
    ),
    GallerySpecimen(
      label: 'unreachable URL — error glyph and label (16:9)',
      child: _frame(
        const DabblerImage(
          url: _broken,
          aspectRatio: 16 / 9,
          errorLabel: 'Image unavailable',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'scrim with a sport badge over it',
      child: _frame(
        const DabblerImage(
          height: 210,
          scrim: true,
          overlay: DabblerBadge(label: 'Padel'),
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'thumbnail — 64 square, lg radius',
      child: DabblerImage(width: 64, height: 64, radius: DabblerRadius.lgAll),
    ),
  ],
);
