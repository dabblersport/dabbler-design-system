/// Gallery entry for [DabblerFavouriteButton] (KAN-426, Seat B).
/// Mirrors `Listings.dc.html:774-776` and `Favourites.dc.html:60-62`.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'favourite_button.dart';

/// FavouriteButton specimens.
const List<GalleryEntry> favouriteButtonGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'favourite-button',
    page: 'components/favourite-button',
    group: GalleryPurpose.actions,
    title: 'FavouriteButton — the heart well on a venue card',
    description:
        'Off (tap to toggle), on, disabled and the plain round form, in both directions.',
    builder: _wells,
  ),
];

Widget _wells(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'left-to-right',
      child: Directionality(textDirection: TextDirection.ltr, child: _Wells()),
    ),
    GallerySpecimen(
      label: 'right-to-left',
      child: Directionality(textDirection: TextDirection.rtl, child: _Wells()),
    ),
  ],
);

class _Wells extends StatefulWidget {
  const _Wells();

  @override
  State<_Wells> createState() => _WellsState();
}

class _WellsState extends State<_Wells> {
  bool _on = false;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      DabblerFavouriteButton(
        selected: _on,
        semanticLabel: _on ? 'Remove from favourites' : 'Add to favourites',
        onPressed: () => setState(() => _on = !_on),
      ),
      const DabblerFavouriteButton(
        selected: true,
        semanticLabel: 'Remove from favourites',
      ),
      const DabblerFavouriteButton(
        selected: false,
        semanticLabel: 'Add to favourites',
      ),
      const DabblerFavouriteButton(
        plain: true,
        selected: true,
        semanticLabel: 'Remove from favourites',
      ),
    ],
  );
}
