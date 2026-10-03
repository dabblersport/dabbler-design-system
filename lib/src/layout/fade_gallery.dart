/// Gallery entries for [DabblerFade] (KAN-411).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'fade.dart';

/// Fade's specimens.
const List<GalleryEntry> fadeGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'fade',
    page: 'components/fade',
    group: GalleryPurpose.structure,
    title: 'Fade — list bottom',
    description:
        'Rows running out beneath a bar, with the page colour fading '
        'in from the bottom edge.',
    builder: _fade,
  ),
];

Widget _fade(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      GallerySpecimen(
        label: 'under a bar',
        child: SizedBox(
          width: 320,
          height: 240,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  for (int i = 0; i < 6; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: DabblerSpacing.space3,
                      ),
                      child: SizedBox(
                        height: DabblerSizing.touchTargetMin,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: DabblerRadius.lgAll,
                            border: Border.all(color: colors.borderDefault),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: DabblerFade(
                  child: SizedBox(
                    height: DabblerSizing.touchTargetMin,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.brandPrimary,
                        borderRadius: DabblerRadius.pillAll,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
