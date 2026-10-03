/// Gallery entries for [DabblerSortControl] and [DabblerSheetList]
/// (Alpha DS gaps 5, item 11).
///
/// Both mirror `Listings.dc.html`: the sort chip group of the filter sheet
/// (`:291-299`) and the location sheet's search-over-list (`:313-345`).
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../forms/search_field.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'menu.dart';
import 'sheet.dart';
import 'sheet_list.dart';
import 'sort_control.dart';

/// SortControl and SheetList specimens.
const List<GalleryEntry> sortControlGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'sort-control',
    page: 'components/sort-control',
    group: GalleryPurpose.selectionAndInput,
    title: 'SortControl — reorder a view-all list',
    description:
        'The compact chip that opens a sheet of options, and the inline '
        'segmented chips.',
    builder: _sorts,
  ),
  GalleryEntry(
    id: 'sheet-list',
    page: 'components/sheet-list',
    group: GalleryPurpose.presentation,
    title: 'SheetList — a bounded list inside a sheet (trigger)',
    description: 'A searchable list of thirty places, and the empty state.',
    builder: _sheetLists,
  ),
];

const List<DabblerSortOption<String>> _options = <DabblerSortOption<String>>[
  DabblerSortOption<String>(value: 'near', label: 'Nearest'),
  DabblerSortOption<String>(value: 'soon', label: 'Starting soonest'),
  DabblerSortOption<String>(value: 'price', label: 'Lowest price'),
];

Widget _sorts(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'sheet',
      child: _SortDemo(variant: DabblerSortControlVariant.sheet),
    ),
    GallerySpecimen(
      label: 'segmented',
      child: _SortDemo(variant: DabblerSortControlVariant.segmented),
    ),
  ],
);

class _SortDemo extends StatefulWidget {
  const _SortDemo({required this.variant});

  final DabblerSortControlVariant variant;

  @override
  State<_SortDemo> createState() => _SortDemoState();
}

class _SortDemoState extends State<_SortDemo> {
  String _sort = 'near';

  @override
  Widget build(BuildContext context) => DabblerSortControl<String>(
    label: 'Sort by',
    options: _options,
    value: _sort,
    variant: widget.variant,
    onChanged: (String v) => setState(() => _sort = v),
  );
}

Widget _sheetLists(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'searchable list',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open list sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Change location',
            detent: DabblerSheetDetent.content,
            builder: (_) => DabblerSheetList(
              header: const DabblerSearchField(
                placeholder: 'Search venues and areas',
              ),
              itemCount: 30,
              itemBuilder: (_, int i) =>
                  DabblerMenuItem(label: 'Place ${i + 1}'),
            ),
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'empty',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open empty sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Change location',
            detent: DabblerSheetDetent.content,
            builder: (_) => DabblerSheetList(
              itemCount: 0,
              itemBuilder: (_, int i) => const SizedBox.shrink(),
              emptyText: 'Nothing matches that. Try another name.',
            ),
          ),
        ),
      ),
    ),
  ],
);
