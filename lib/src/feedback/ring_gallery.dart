/// Gallery entries for [DabblerRing].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'ring.dart';

/// Ring's specimens.
const List<GalleryEntry> ringGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'ring',
    page: 'components/ring',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Ring — tick countdown and completion arc',
    description:
        'The 24- and 32-tick countdown rings with a centre, in both '
        'track roles, then the completion arc at four fractions.',
    builder: _rings,
  ),
];

Widget _centre(BuildContext context, String big, String small) {
  final DabblerColors colors = DabblerColors.of(context);
  final TextDirection direction = Directionality.of(context);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        big,
        style: DabblerType.headline
            .resolveForDirection(direction)
            .copyWith(color: colors.textPrimary),
      ),
      Text(
        small,
        style: DabblerType.caption2
            .resolveForDirection(direction)
            .copyWith(color: colors.textTertiary),
      ),
    ],
  );
}

Widget _rings(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'ticks 24 · 0.4 · outline',
          child: DabblerRing.ticks(
            fraction: 0.4,
            diameter: 3 * DabblerSpacing.space8,
            child: _centre(context, '3', 'days'),
          ),
        ),
        GallerySpecimen(
          label: 'ticks 32 · 0.75 · faint',
          child: DabblerRing.ticks(
            fraction: 0.75,
            count: 32,
            diameter: 3 * DabblerSpacing.space8,
            track: DabblerRingTrack.faint,
            child: _centre(context, '5', 'hours'),
          ),
        ),
        GallerySpecimen(
          label: 'ticks 32 · long tick',
          child: DabblerRing.ticks(
            fraction: 0.5,
            count: 32,
            diameter: 4 * DabblerSpacing.space10,
            tickLength: DabblerSpacing.space3,
            child: _centre(context, '12', 'min'),
          ),
        ),
        const GallerySpecimen(
          label: 'ticks · empty / full',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerRing.ticks(fraction: 0, diameter: DabblerSpacing.space11),
              SizedBox(width: DabblerSpacing.space4),
              DabblerRing.ticks(fraction: 1, diameter: DabblerSpacing.space11),
            ],
          ),
        ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final double f in <double>[0, 0.25, 0.72, 1])
          GallerySpecimen(
            label: 'arc · $f',
            child: DabblerRing.arc(
              fraction: f,
              child: Text(
                '${(f * 100).round()}%',
                style: DabblerType.caption1
                    .resolveForDirection(Directionality.of(context))
                    .copyWith(color: DabblerColors.of(context).textPrimary),
              ),
            ),
          ),
      ],
    ),
  ],
);
