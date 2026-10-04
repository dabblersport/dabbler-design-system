/// Gallery entries for [DabblerFlowPage] and [DabblerTileGrid].
library;

import 'package:flutter/widgets.dart';

import '../feedback/banner.dart';
import '../forms/selectable_card.dart';
import '../forms/text_field.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_hue_tone.dart';
import 'flow_page.dart';
import 'tile_grid.dart';

/// FlowPage and TileGrid specimens.
const List<GalleryEntry> flowGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'flow-page',
    page: 'components/flow-page',
    group: GalleryPurpose.structure,
    title: 'FlowPage — the onboarding step template',
    description:
        'Back, segmented progress, title, scrolling body and one primary '
        'action; then the centred variant with a banner above the action.',
    builder: _flowPages,
  ),
  GalleryEntry(
    id: 'tile-grid',
    page: 'components/tile-grid',
    group: GalleryPurpose.structure,
    title: 'TileGrid — equal tiles, row-height cells',
    description:
        'Four columns of selectable tiles; a two-line label makes only its '
        'own row taller.',
    builder: _tileGrid,
  ),
];

const double _frameWidth = 300;
const double _frameHeight = 520;

Widget _frame(Widget page) =>
    SizedBox(width: _frameWidth, height: _frameHeight, child: page);

Widget _flowPages(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'step — back, progress, title, body, action',
      child: _frame(
        DabblerFlowPage(
          onBack: () {},
          backLabel: 'Back',
          stepCount: 5,
          stepIndex: 0,
          stepLabel: 'Step 1 of 5',
          title: 'Tell us a bit about you',
          subtitle: 'Your age keeps games age-appropriate.',
          content: const <Widget>[
            DabblerTextField(
              variant: DabblerTextFieldVariant.select,
              label: 'Date of birth',
              placeholder: 'Select your date of birth',
            ),
          ],
          primaryLabel: 'Continue',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'centred — title block and body centred, banner above the action',
      child: _frame(
        DabblerFlowPage(
          centered: true,
          title: 'Setting up your account',
          subtitle: 'This only takes a moment.',
          content: const <Widget>[
            DabblerBanner(
              tone: DabblerBannerTone.error,
              title: 'Setup did not finish',
              message: 'Nothing you entered is lost.',
            ),
          ],
          primaryLabel: 'Try again',
          onPrimary: () {},
        ),
      ),
    ),
  ],
);

Widget _tileGrid(BuildContext context) => SizedBox(
  width: _frameWidth,
  child: DabblerTileGrid(
    children: <Widget>[
      for (final (String, String) s in const <(String, String)>[
        ('football', 'Football'),
        ('padel', 'Padel'),
        ('tennis', 'Tennis'),
        ('cricket', 'Cricket'),
        ('basketball', 'Basketball'),
        ('table-tennis', 'Table Tennis'),
      ])
        DabblerSelectableCard(
          layout: DabblerSelectableCardLayout.tile,
          icon: 'game',
          title: s.$2,
          tone: DabblerHueTone.forSportKey(s.$1),
          selected: s.$1 == 'padel',
          onChanged: (_) {},
        ),
    ],
  ),
);
