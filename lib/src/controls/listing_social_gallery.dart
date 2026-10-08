/// Gallery entry for [DabblerListingSocial] (the Listings card engagement
/// group, `Listings.dc.html:273-279`, `:644-655`).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'listing_social.dart';

/// ListingSocial specimens.
const List<GalleryEntry> listingSocialGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'listing-social',
    page: 'components/listing-social',
    group: GalleryPurpose.actions,
    title: 'ListingSocial — heart and share with counts',
    description:
        'Off and on, with and without counts, and disabled, in both directions.',
    builder: _group,
  ),
];

Widget _group(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'left-to-right',
      child: Directionality(textDirection: TextDirection.ltr, child: _Rows()),
    ),
    GallerySpecimen(
      label: 'right-to-left',
      child: Directionality(textDirection: TextDirection.rtl, child: _Rows()),
    ),
  ],
);

class _Rows extends StatefulWidget {
  const _Rows();

  @override
  State<_Rows> createState() => _RowsState();
}

class _RowsState extends State<_Rows> {
  bool _on = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      DabblerListingSocial(
        favourited: _on,
        onFavourite: () => setState(() => _on = !_on),
        favouriteLabel: _on ? 'Remove from favourites' : 'Add to favourites',
        favouriteCount: _on ? '15' : '14',
        onShare: () {},
        shareLabel: 'Share',
        shareCount: '6',
      ),
      DabblerListingSocial(
        favourited: true,
        onFavourite: () {},
        favouriteLabel: 'Remove from favourites',
        favouriteCount: '9',
        onShare: () {},
        shareLabel: 'Share',
      ),
      DabblerListingSocial(
        favourited: false,
        onFavourite: () {},
        favouriteLabel: 'Add to favourites',
        onShare: () {},
        shareLabel: 'Share',
      ),
      const DabblerListingSocial(
        favourited: false,
        onFavourite: null,
        favouriteLabel: 'Add to favourites',
        favouriteCount: '14',
        onShare: null,
        shareLabel: 'Share',
        shareCount: '6',
      ),
    ],
  );
}
