/// Gallery entries for [DabblerSearchField] and [DabblerHighlightedText]
/// (KAN-412 items 2 and 3).
///
/// Both mirror `Search.dc.html`: the field is the results-page header
/// (`:162-173`) and the highlighted rows are the result lists
/// (`:205, 282, 505`).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'highlighted_text.dart';
import 'search_field.dart';

/// SearchField and HighlightedText specimens.
const List<GalleryEntry> searchGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'search-field',
    page: 'components/search-field',
    group: GalleryPurpose.selectionAndInput,
    title: 'SearchField — with an inline clear button',
    description:
        'Empty (no clear), holding a query (clear at the inline '
        'end), and disabled.',
    builder: _searchFields,
  ),
  GalleryEntry(
    id: 'highlighted-text',
    page: 'components/highlighted-text',
    group: GalleryPurpose.selectionAndInput,
    title: 'HighlightedText — the matched part of a result',
    description:
        'A title row, a body row with two matches, Arabic, and a '
        'Latin match inside an Arabic sentence.',
    builder: _highlights,
  ),
];

const double _width = 260;

Widget _searchFields(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'empty — no clear button',
      child: SizedBox(
        width: _width,
        child: DabblerSearchField(placeholder: 'Search people, games, posts'),
      ),
    ),
    GallerySpecimen(
      label: 'loading — spinner in place of clear',
      child: SizedBox(
        width: _width,
        child: DabblerSearchField(
          placeholder: 'Search people, games, posts',
          initialValue: 'dabbler',
          loading: true,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'with a query — clear at the inline end',
      child: SizedBox(
        width: _width,
        child: DabblerSearchField(
          placeholder: 'Search people, games, posts',
          initialValue: 'dabbler',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'disabled',
      child: SizedBox(
        width: _width,
        child: DabblerSearchField(
          placeholder: 'Search people, games, posts',
          initialValue: 'dabbler',
          enabled: false,
        ),
      ),
    ),
  ],
);

Widget _highlights(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'title row — semibold, one line',
      child: SizedBox(
        width: _width,
        child: DabblerHighlightedText(
          text: 'The Dabbler player',
          query: 'dabbler',
          fontWeight: DabblerHighlightedText.matchWeight,
          maxLines: 1,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'body row — two matches, wraps',
      child: SizedBox(
        width: _width,
        child: DabblerHighlightedText(
          text:
              'Photos from the Dabbler community meetup — every Dabbler '
              'welcome',
          query: 'dabbler',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic',
      child: SizedBox(
        width: _width,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerHighlightedText(
            text: 'لاعب دابلر يبحث عن مباراة',
            query: 'دابلر',
            maxLines: 1,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Latin match inside Arabic',
      child: SizedBox(
        width: _width,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerHighlightedText(
            text: 'تطبيق Dabbler لحجز الملاعب',
            query: 'dabbler',
            maxLines: 1,
          ),
        ),
      ),
    ),
  ],
);
