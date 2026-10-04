/// Gallery entries for [DabblerProgressStages].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'progress_stages.dart';

/// ProgressStages specimens.
const List<GalleryEntry> progressStagesGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'progress-stages',
    page: 'components/progress-stages',
    group: GalleryPurpose.statusAndFeedback,
    title: 'ProgressStages — the steps of a setup',
    description: 'Done, running and pending; then a failed stage.',
    builder: _stages,
  ),
];

const double _width = 300;

Widget _stages(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'running',
      child: SizedBox(
        width: _width,
        child: DabblerProgressStages(
          stages: <DabblerProgressStage>[
            DabblerProgressStage(
              label: 'Creating your profile',
              status: DabblerStageStatus.done,
            ),
            DabblerProgressStage(
              label: 'Setting up your sports',
              status: DabblerStageStatus.active,
            ),
            DabblerProgressStage(label: 'Getting your feed ready'),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'failed',
      child: SizedBox(
        width: _width,
        child: DabblerProgressStages(
          stages: <DabblerProgressStage>[
            DabblerProgressStage(
              label: 'Creating your profile',
              status: DabblerStageStatus.done,
            ),
            DabblerProgressStage(
              label: 'Setting up your sports',
              status: DabblerStageStatus.failed,
            ),
            DabblerProgressStage(label: 'Getting your feed ready'),
          ],
        ),
      ),
    ),
  ],
);
