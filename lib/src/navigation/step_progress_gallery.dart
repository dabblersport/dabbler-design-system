/// Gallery entries for [DabblerStepProgress] and [DabblerPageDots]
/// (Alpha DS gaps 5, item 10).
///
/// Both mirror `Auth and Onboarding.dc.html`: the step header
/// (`:333-339`) and the welcome carousel dots (`:77-81`).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'page_dots.dart';
import 'step_progress.dart';

/// StepProgress and PageDots specimens.
const List<GalleryEntry> stepProgressGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'step-progress',
    page: 'components/step-progress',
    group: GalleryPurpose.navigation,
    title: 'StepProgress — where a multi-step flow is',
    description: 'First, middle and last of five steps, with the step label.',
    builder: _steps,
  ),
  GalleryEntry(
    id: 'page-dots',
    page: 'components/page-dots',
    group: GalleryPurpose.navigation,
    title: 'PageDots — the position under a carousel',
    description: 'Static, and tappable (tap a dot to move).',
    builder: _dots,
  ),
];

const double _width = 280;

Widget _steps(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'step 1 of 5',
      child: SizedBox(
        width: _width,
        child: DabblerStepProgress(count: 5, current: 0, label: 'Step 1 of 5'),
      ),
    ),
    GallerySpecimen(
      label: 'step 3 of 5',
      child: SizedBox(
        width: _width,
        child: DabblerStepProgress(count: 5, current: 2, label: 'Step 3 of 5'),
      ),
    ),
    GallerySpecimen(
      label: 'segmentHeight 3, segmentGap 6 — the old grid-aligned look',
      child: SizedBox(
        width: _width,
        child: DabblerStepProgress(
          count: 5,
          current: 1,
          segmentHeight: DabblerSpacing.space1,
          segmentGap: DabblerSpacing.space2,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'step 5 of 5, no label',
      child: SizedBox(
        width: _width,
        child: DabblerStepProgress(count: 5, current: 4),
      ),
    ),
  ],
);

Widget _dots(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'static — page 2 of 4',
      child: DabblerPageDots(count: 4, index: 1),
    ),
    GallerySpecimen(label: 'tappable', child: _DotsDemo()),
    GallerySpecimen(
      label: 'compactHitArea — 6px tall, as the carousel frame draws it',
      child: _DotsDemo(compact: true),
    ),
  ],
);

class _DotsDemo extends StatefulWidget {
  const _DotsDemo({this.compact = false});

  final bool compact;

  @override
  State<_DotsDemo> createState() => _DotsDemoState();
}

class _DotsDemoState extends State<_DotsDemo> {
  int _page = 0;

  @override
  Widget build(BuildContext context) => DabblerPageDots(
    count: 4,
    index: _page,
    compactHitArea: widget.compact,
    onSelected: (int i) => setState(() => _page = i),
  );
}
