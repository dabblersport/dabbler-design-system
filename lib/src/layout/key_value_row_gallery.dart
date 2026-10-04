/// Gallery entries for [DabblerKeyValueRow] (Alpha fidelity, KAN-426).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import 'key_value_row.dart';

/// KeyValueRow's specimens.
const List<GalleryEntry> keyValueRowGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'key-value-row',
    page: 'components/key-value-row',
    group: GalleryPurpose.contentContainers,
    title: 'KeyValueRow — a read-only label and its value',
    description:
        'Inline and stacked, a long value wrapping, a badge in place of text, '
        'and the same row in Arabic.',
    builder: _rows,
  ),
];

Widget _rows(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'inline',
      child: DabblerKeyValueRow(
        label: 'Recipient',
        value: 'Al Ahly Sports Club',
      ),
    ),
    const GallerySpecimen(
      label: 'inline — long value wraps',
      child: DabblerKeyValueRow(
        label: 'Address',
        value: 'Plot 12, Marina Walk, Dubai Marina, United Arab Emirates',
      ),
    ),
    const GallerySpecimen(
      label: 'stacked',
      child: DabblerKeyValueRow(
        label: 'Description',
        value: 'Four covered courts with floodlights and a small café.',
        layout: DabblerKeyValueLayout.stacked,
      ),
    ),
    const GallerySpecimen(
      label: 'badge in place of text',
      child: DabblerKeyValueRow(
        label: 'Status',
        trailing: DabblerBadge(label: 'COMPLETED'),
      ),
    ),
    const GallerySpecimen(
      label: 'Arabic',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerKeyValueRow(
          label: 'العنوان',
          value: 'قطعة ١٢، ممشى المارينا، دبي مارينا، الإمارات العربية المتحدة',
        ),
      ),
    ),
  ],
);
