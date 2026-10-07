/// Gallery entries for [DabblerListingPage] and [DabblerTopFill]
/// (Listings design, 2026-10-08).
library;

import 'package:flutter/widgets.dart';

import '../controls/filter_rail.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../navigation/page_header.dart';
import '../tokens/dabbler_colors.dart';
import 'listing_page.dart';
import 'top_fill.dart';
import 'tabs.dart';

/// ListingPage and TopFill specimens.
const List<GalleryEntry> listingPageGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'listing-page',
    page: 'components/listing-page',
    group: GalleryPurpose.navigation,
    title: 'ListingPage — the collapsing listing header',
    description:
        'A tinted header band (title row, sport tabs, applied filters) '
        'over a scrolling list; the band folds as the list scrolls.',
    builder: _listing,
  ),
  GalleryEntry(
    id: 'top-fill',
    page: 'components/top-fill',
    group: GalleryPurpose.navigation,
    title: 'TopFill — the band under the status bar',
    description: 'A colour painted across the top safe-area inset.',
    builder: _topFill,
  ),
];

const double _width = 360;
const double _height = 420;

Widget _listing(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'tint band, three filters applied',
      child: SizedBox(
        width: _width,
        height: _height,
        child: Builder(
          builder: (BuildContext context) => DabblerListingPage(
            header: const DabblerPageHeader(
              title: 'Games',
              safeArea: false,
              contentPadding: DabblerPageHeader.listingPadding,
            ),
            tabs: const <DabblerTabItem>[
              DabblerTabItem(id: 'all', label: 'All sports'),
              DabblerTabItem(id: 'football', label: 'Football'),
              DabblerTabItem(id: 'padel', label: 'Padel'),
            ],
            filters: <DabblerFilterRailItem>[
              DabblerFilterRailItem(label: 'Within 5 km', onRemove: () {}),
              DabblerFilterRailItem(label: 'Today', onRemove: () {}),
            ],
            clearAllLabel: 'Clear all',
            onClearAll: () {},
            pages: <Widget>[for (int i = 0; i < 3; i++) const _Rows()],
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'accent band, no filters',
      child: SizedBox(
        width: _width,
        height: _height,
        child: Builder(
          builder: (BuildContext context) => DabblerListingPage(
            head: DabblerListingHead.accent,
            header: const DabblerPageHeader(
              title: 'Meetups',
              safeArea: false,
              contentPadding: DabblerPageHeader.listingPadding,
            ),
            tabs: const <DabblerTabItem>[
              DabblerTabItem(id: 'all', label: 'All'),
              DabblerTabItem(id: 'running', label: 'Running'),
            ],
            filters: const <DabblerFilterRailItem>[],
            clearAllLabel: 'Clear all',
            onClearAll: () {},
            pages: <Widget>[for (int i = 0; i < 2; i++) const _Rows()],
          ),
        ),
      ),
    ),
  ],
);

class _Rows extends StatelessWidget {
  const _Rows();

  @override
  Widget build(BuildContext context) =>
      ListView(children: const <Widget>[SizedBox(height: 600)]);
}

Widget _topFill(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'a 44 inset filled with the band colour',
      child: SizedBox(
        width: _width,
        height: 120,
        child: MediaQuery(
          data: MediaQueryData.fromView(
            View.of(context),
          ).copyWith(padding: const EdgeInsets.only(top: 44)),
          child: DabblerTopFill(
            color: DabblerColors.tileAccent.surface,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  ],
);
