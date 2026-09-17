/// Gallery entries for the interaction layer — [DabblerFocusRing],
/// [DabblerPressScale] and [DabblerScrim] (KAN-259 AC2, and the DS-200 stub
/// that ticket's AC4 requires).
///
/// These three are primitives other components compose rather than screens in
/// their own right, so one colocated file covers the layer.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_geometry.dart';
import 'focus_ring.dart';
import 'press_scale.dart';
import 'scrim.dart';

/// The interaction layer's specimens.
const List<GalleryEntry> interactionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Interaction — focus ring, press scale, scrim',
    description: 'The three primitives every other component composes. Tab '
        'to the first to raise a real keyboard-focus ring.',
    builder: _interaction,
  ),
];

Widget _interaction(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'FocusRing — self-driven (tab to it)',
      child: DabblerFocusRing(
        borderRadius: DabblerRadius.mdAll,
        child: _Chip(label: 'Focus me'),
      ),
    ),
    GallerySpecimen(
      label: 'FocusRing — visible, painted unconditionally',
      child: DabblerFocusRing.visible(
        visible: true,
        borderRadius: DabblerRadius.mdAll,
        child: _Chip(label: 'Always ringed'),
      ),
    ),
    GallerySpecimen(
      label: 'PressScale — gesture form (press and hold)',
      child: DabblerPressScale.gesture(child: _Chip(label: 'Press me')),
    ),
    GallerySpecimen(
      label: 'PressScale — pressed, held down',
      child: DabblerPressScale(pressed: true, child: _Chip(label: 'Pressed')),
    ),
    GallerySpecimen(
      label: 'Scrim — over content',
      child: SizedBox(
        width: 200,
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DabblerSurface.card(center: true, child: Text('Behind')),
            DabblerScrim(),
          ],
        ),
      ),
    ),
  ],
);

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DabblerSurface.grey(
    center: true,
    padding: const EdgeInsets.symmetric(
      horizontal: DabblerSpacing.space6,
      vertical: DabblerSpacing.space4,
    ),
    child: Text(label),
  );
}
