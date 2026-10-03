/// Gallery entries for [DabblerHeroIcon] (Alpha DS gaps 5, item 10).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'hero_icon.dart';

/// HeroIcon specimens.
const List<GalleryEntry> heroIconGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'hero-icon',
    page: 'components/hero-icon',
    group: GalleryPurpose.identityAndStatus,
    title: 'HeroIcon — the large round glyph on a result screen',
    description: 'Brand, success, warning, error, info and neutral tones.',
    builder: _heroes,
  ),
];

Widget _heroes(BuildContext context) => const GalleryWrap(
  children: <Widget>[
    GallerySpecimen(label: 'brand', child: DabblerHeroIcon('cup')),
    GallerySpecimen(
      label: 'success',
      child: DabblerHeroIcon('tick-circle', tone: DabblerHeroIconTone.success),
    ),
    GallerySpecimen(
      label: 'warning',
      child: DabblerHeroIcon('warning-2', tone: DabblerHeroIconTone.warning),
    ),
    GallerySpecimen(
      label: 'error',
      child: DabblerHeroIcon('danger', tone: DabblerHeroIconTone.error),
    ),
    GallerySpecimen(
      label: 'info',
      child: DabblerHeroIcon('info-circle', tone: DabblerHeroIconTone.info),
    ),
    GallerySpecimen(
      label: 'neutral',
      child: DabblerHeroIcon(
        'search-normal',
        tone: DabblerHeroIconTone.neutral,
      ),
    ),
  ],
);
