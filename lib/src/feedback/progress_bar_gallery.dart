/// Gallery entries for [DabblerProgressBar] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'progress_bar.dart';

/// ProgressBar's specimens.
const List<GalleryEntry> progressBarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'progress-bar',
    page: 'components/progress-bar',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ProgressBar — tones, sizes, indeterminate',
    description: 'Determinate at 0.6 in every tone and size, then the '
        'indeterminate sweep.',
    builder: _bars,
  ),
];

Widget _bars(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerProgressBarTone tone in DabblerProgressBarTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerProgressBar(value: 0.6, tone: tone),
      ),
    for (final DabblerProgressBarSize size in DabblerProgressBarSize.values)
      GallerySpecimen(
        label: size.name,
        child: DabblerProgressBar(value: 0.35, size: size),
      ),
    const GallerySpecimen(
      label: 'with label and value',
      child: DabblerProgressBar(
        value: 0.8,
        label: 'Uploading',
        showValue: true,
      ),
    ),
    const GallerySpecimen(
      label: 'indeterminate',
      child: DabblerProgressBar.indeterminate(),
    ),
  ],
);
