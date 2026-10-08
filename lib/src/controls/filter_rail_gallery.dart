/// Gallery entry for [DabblerFilterRail] and [DabblerFilterGroup]
/// (Alpha fidelity rebuild, KAN-426). Mirrors `Listings.dc.html:101-111` and
/// `:291-299`.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'chip.dart';
import 'filter_rail.dart';

/// FilterRail and FilterGroup specimens.
const List<GalleryEntry> filterRailGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'filter-rail',
    page: 'components/filter-rail',
    group: GalleryPurpose.selectionAndInput,
    title: 'FilterRail — the applied filters, removable',
    description: 'Removable chips and Clear all; and a labelled option group.',
    builder: _rails,
  ),
];

Widget _rails(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'rail',
      child: SizedBox(
        width: 360,
        child: DabblerFilterRail(
          items: <DabblerFilterRailItem>[
            DabblerFilterRailItem(label: 'Within 5 km', onRemove: () {}),
            DabblerFilterRailItem(label: 'Today', onRemove: () {}),
            DabblerFilterRailItem(label: 'Nearest', onRemove: () {}),
          ],
          clearAllLabel: 'Clear all',
          onClearAll: () {},
        ),
      ),
    ),
    GallerySpecimen(
      label: 'rail, tappable as a whole (opens the filter sheet)',
      child: SizedBox(
        width: 360,
        child: DabblerFilterRail(
          items: <DabblerFilterRailItem>[
            DabblerFilterRailItem(label: 'Within 5 km', onRemove: () {}),
            DabblerFilterRailItem(label: 'Nearest', onRemove: () {}),
          ],
          clearAllLabel: 'Clear all',
          onClearAll: () {},
          onTap: () {},
          tapSemanticLabel: 'Filters',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'group',
      child: SizedBox(
        width: 360,
        child: DabblerFilterGroup(
          label: 'Date',
          children: <Widget>[
            DabblerChip(label: 'Today', selected: true, onTap: () {}),
            DabblerChip(label: 'Tomorrow', onTap: () {}),
            DabblerChip(label: 'This week', onTap: () {}),
          ],
        ),
      ),
    ),
  ],
);
