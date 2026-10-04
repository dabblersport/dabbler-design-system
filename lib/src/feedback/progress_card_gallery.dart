/// Gallery entries for [DabblerProgressCard] (Alpha fidelity, KAN-426).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'progress_card.dart';

/// ProgressCard's specimens.
const List<GalleryEntry> progressCardGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'progress-card',
    page: 'components/progress-card',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ProgressCard — one stage of a multi-stage goal',
    description:
        'Active, settled and completed stages, and the card in Arabic.',
    builder: _cards,
  ),
];

Widget _cards(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'active',
      child: DabblerProgressCard(
        label: 'Week 1',
        caption: '3/7 days',
        value: 3 / 7,
        active: true,
      ),
    ),
    GallerySpecimen(
      label: 'completed, settled',
      child: DabblerProgressCard(
        label: 'Week 1',
        caption: '7/7 days',
        value: 1,
        completed: true,
      ),
    ),
    GallerySpecimen(
      label: 'Arabic',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerProgressCard(
          label: 'الأسبوع ١',
          caption: '٣/٧ أيام',
          value: 3 / 7,
          active: true,
        ),
      ),
    ),
  ],
);
