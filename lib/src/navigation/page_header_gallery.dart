/// Gallery entry for [DabblerPageHeader] (Alpha fidelity rebuild, KAN-426).
///
/// Mirrors the Listings header, `Listings.dc.html:60-100`.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'page_header.dart';

/// PageHeader specimens.
const List<GalleryEntry> pageHeaderGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'page-header',
    page: 'components/page-header',
    group: GalleryPurpose.navigation,
    title: 'PageHeader — a listing screen heading',
    description:
        'Title, tappable location row, and icon actions with a count badge.',
    builder: _headers,
  ),
];

const double _width = 360;

Widget _headers(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'location and two actions, filter count 3',
      child: SizedBox(
        width: _width,
        child: DabblerPageHeader(
          title: 'Games',
          locationLabel: 'Sheikha Fatima Bint Mubarak Street',
          onLocationPressed: () {},
          safeArea: false,
          actions: <DabblerPageHeaderAction>[
            DabblerPageHeaderAction(
              icon: 'search-normal',
              semanticLabel: 'Search',
              onPressed: () {},
            ),
            DabblerPageHeaderAction(
              icon: 'filter',
              semanticLabel: 'Filters',
              onPressed: () {},
              count: 3,
            ),
          ],
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'title only',
      child: SizedBox(
        width: _width,
        child: DabblerPageHeader(title: 'Venues', safeArea: false),
      ),
    ),
  ],
);
