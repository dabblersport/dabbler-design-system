/// Gallery entry for [DabblerProviderMark].
///
/// Shows each vendor's official tile on a light and a dark surface, and at
/// native and reduced size. The tiles are bundled assets, so nothing here
/// reaches the network.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'provider_mark.dart';

/// The provider mark's specimens.
const List<GalleryEntry> providerMarkGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'provider-mark',
    page: 'components/provider-mark',
    group: GalleryPurpose.identityAndStatus,
    title: 'ProviderMark — vendor sign-in marks',
    description:
        'The official Google and Apple sign-in tiles, unmodified: the tile is '
        'picked by brightness, drawn at its native size or scaled square.',
    builder: _marks,
  ),
];

Widget _row(BuildContext context) => Row(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    const DabblerProviderMark.google(),
    SizedBox(width: DabblerSpacing.space4),
    const DabblerProviderMark.apple(),
    SizedBox(width: DabblerSpacing.space4),
    const DabblerProviderMark.google(size: DabblerSizing.iconLg),
    SizedBox(width: DabblerSpacing.space4),
    const DabblerProviderMark.apple(size: DabblerSizing.iconLg),
  ],
);

Widget _marks(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'native size (40 Google, 44 Apple) and 30 scaled — current theme',
      child: _row(context),
    ),
    GallerySpecimen(
      label: 'semantics excluded (inside a labelled button)',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const DabblerProviderMark.google(excludeFromSemantics: true),
          SizedBox(width: DabblerSpacing.space4),
          Text(
            'Continue with Google',
            style: TextStyle(color: DabblerColors.of(context).textPrimary),
          ),
        ],
      ),
    ),
  ],
);
