/// Gallery entries for [DabblerSpinner] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'spinner.dart';

/// Spinner's specimens.
const List<GalleryEntry> spinnerGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'spinner',
    page: 'components/spinner',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Spinner — sizes and tones',
    description: 'Every size and tone. The label is what assistive technology '
        'announces.',
    builder: _spinners,
  ),
];

Widget _spinners(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerSpinnerSize size in DabblerSpinnerSize.values)
          GallerySpecimen(
            label: size.name,
            child: DabblerSpinner(size: size),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final DabblerSpinnerTone tone in DabblerSpinnerTone.values)
          GallerySpecimen(
            label: tone.name,
            child: DabblerSpinner(tone: tone),
          ),
      ],
    ),
    const GallerySpecimen(
      label: 'with label',
      child: DabblerSpinner(label: 'Loading games'),
    ),
  ],
);
