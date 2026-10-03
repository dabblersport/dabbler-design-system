/// Gallery entries for [DabblerOnColorIconButton] (Alpha DS gaps 6, item 6).
///
/// Mirrors `Details.dc.html:48-58`: the game-details hero band with back on
/// the inline start and favourite + share on the inline end.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'on_color_icon_button.dart';

/// OnColorIconButton specimens.
const List<GalleryEntry> onColorIconButtonGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'on-color-icon-button',
    page: 'components/on-color-icon-button',
    group: GalleryPurpose.actions,
    title: 'OnColorIconButton — translucent buttons on a coloured hero',
    description:
        'Back, favourite (set) and share on a brand band, and a disabled '
        'one, in both directions.',
    builder: _heroes,
  ),
];

Widget _band(BuildContext context, TextDirection direction) => Directionality(
  textDirection: direction,
  child: Container(
    width: 260,
    padding: const EdgeInsets.all(DabblerSpacing.space6),
    color: DabblerColors.of(context).brandPrimary,
    child: Row(
      children: <Widget>[
        DabblerOnColorIconButton(
          icon: 'arrow-circle-left',
          semanticLabel: 'Back',
          mirrorInRtl: true,
          onPressed: () {},
        ),
        const Spacer(),
        DabblerOnColorIconButton(
          icon: 'heart',
          weight: DabblerIconWeight.bold,
          semanticLabel: 'Favourite',
          selected: true,
          onPressed: () {},
        ),
        const SizedBox(width: DabblerSpacing.space3),
        const DabblerOnColorIconButton(icon: 'share', semanticLabel: 'Share'),
      ],
    ),
  ),
);

Widget _heroes(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'left-to-right — share disabled',
      child: _band(context, TextDirection.ltr),
    ),
    GallerySpecimen(
      label: 'right-to-left — back mirrors',
      child: _band(context, TextDirection.rtl),
    ),
  ],
);
