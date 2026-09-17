/// Gallery entries for [DabblerSkeleton] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'skeleton.dart';

/// Skeleton's specimens.
const List<GalleryEntry> skeletonGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Skeleton — variants',
    description: 'Text, rect, circle and card. Decorative: the whole widget '
        'is wrapped in ExcludeSemantics.',
    builder: _skeletons,
  ),
];

Widget _skeletons(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(label: 'text', child: DabblerSkeleton.text()),
    GallerySpecimen(
      label: 'rect',
      child: DabblerSkeleton.rect(width: 160, height: 24),
    ),
    GallerySpecimen(label: 'circle', child: DabblerSkeleton.circle(width: 48)),
    GallerySpecimen(label: 'card', child: DabblerSkeleton.card()),
  ],
);
