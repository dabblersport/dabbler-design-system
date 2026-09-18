/// Gallery entries for [DabblerSheet] (KAN-259 AC2).
///
/// A sheet is a route, for the same reason the dialog's entries are triggers:
/// the detents, the drag and the scrim only exist on the real route.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'sheet.dart';

/// Sheet's specimens.
const List<GalleryEntry> sheetGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'sheet/detents',
    page: 'components/sheet',
    group: GalleryPurpose.presentation,
    title: 'Sheet — detents and footer (trigger)',
    description: 'A half-height sheet, and a two-detent sheet with a footer.',
    builder: _sheets,
  ),
];

Widget _sheets(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'single detent',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Filters',
            builder: _body,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'two detents, with a footer',
      child: Builder(
        builder: (BuildContext context) => DabblerButton(
          label: 'Open tall sheet',
          onPressed: () => showDabblerSheet<void>(
            context: context,
            title: 'Pick a sport',
            detents: <double>[0.4, 0.9],
            builder: _body,
            footerBuilder: (BuildContext context) => DabblerButton(
              label: 'Apply',
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _body(BuildContext context) => const Padding(
  padding: EdgeInsets.all(DabblerSpacing.space6),
  child: Text('Sheet content.'),
);
