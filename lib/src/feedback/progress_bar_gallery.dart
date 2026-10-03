/// Gallery entries for [DabblerProgressBar] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'progress_bar.dart';

/// ProgressBar's specimens.
const List<GalleryEntry> progressBarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'progress-bar',
    page: 'components/progress-bar',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ProgressBar — tones, sizes, indeterminate',
    description:
        'Determinate at 0.6 in every tone and size, then the '
        'indeterminate sweep.',
    builder: _bars,
  ),
  GalleryEntry(
    id: 'progress-bar/on-brand',
    page: 'components/progress-bar',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ProgressBar — on a brand fill',
    description:
        'tone: onBrand — onBrand fill on an onBrand 22% track, for a '
        'bar inside a brand-filled card (DSG-NEW-002).',
    builder: _onBrand,
  ),
];

Widget _onBrand(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GallerySpecimen(
    label: 'onBrand on brandPrimary',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: DabblerRadius.xlAll,
      ),
      child: const Padding(
        padding: EdgeInsets.all(DabblerSpacing.space5),
        child: DabblerProgressBar(
          value: 0.7,
          tone: DabblerProgressBarTone.onBrand,
          label: 'Waitlist',
          showValue: true,
        ),
      ),
    ),
  );
}

Widget _bars(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerProgressBarTone tone in DabblerProgressBarTone.values)
      // onBrand is invisible on the page; it has its own specimen.
      if (tone != DabblerProgressBarTone.onBrand)
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
