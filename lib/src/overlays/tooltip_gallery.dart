/// Gallery entries for [DabblerTooltip].
///
/// Mirrors the right of the trigger row on
/// `components/overlays/overlays.card.html`: a small icon-only button that
/// names itself on hover or focus.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'tooltip.dart';

/// Tooltip's specimens.
const List<GalleryEntry> tooltipGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'tooltip',
    page: 'components/tooltip',
    group: GalleryPurpose.presentation,
    title: 'Tooltip — the label for a control with no visible text',
    description: 'Hover or focus a trigger. Never the only carrier of '
        'essential information.',
    builder: _tooltips,
  ),
];

Widget _tooltips(BuildContext context) => const GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'top',
          child: DabblerTooltip(
            message: 'share game',
            child: DabblerButton(
              label: '',
              icon: 'share',
              size: DabblerButtonSize.small,
              tone: DabblerButtonTone.neutral,
            ),
          ),
        ),
        GallerySpecimen(
          label: 'bottom',
          child: DabblerTooltip(
            message: 'more actions',
            placement: DabblerTooltipPlacement.bottom,
            child: DabblerButton(
              label: '',
              icon: 'more',
              size: DabblerButtonSize.small,
              tone: DabblerButtonTone.neutral,
            ),
          ),
        ),
        GallerySpecimen(
          label: 'inline end',
          child: DabblerTooltip(
            message: 'copy link',
            placement: DabblerTooltipPlacement.end,
            child: DabblerButton(
              label: '',
              icon: 'link',
              size: DabblerButtonSize.small,
              tone: DabblerButtonTone.neutral,
            ),
          ),
        ),
      ],
    );
