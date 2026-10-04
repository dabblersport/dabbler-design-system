/// Gallery entries for [DabblerIconList].
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'card.dart';
import 'icon_list.dart';

/// IconList specimens.
const List<GalleryEntry> iconListGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'icon-list',
    page: 'components/icon-list',
    group: GalleryPurpose.contentContainers,
    title: 'IconList — a titled list with one glyph per line',
    description: 'In a white card, with and without a title.',
    builder: _lists,
  ),
];

const double _width = 300;

Widget _lists(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'titled, in a card',
      child: SizedBox(
        width: _width,
        child: DabblerCard(
          variant: DabblerCardVariant.white,
          child: DabblerIconList(
            title: 'Don’t forget',
            items: <String>[
              'Only confirm when you know you can play.',
              'Respect the organiser’s rules and kickoff time.',
              'Turning up is what builds your reputation.',
            ],
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'untitled',
      child: SizedBox(
        width: _width,
        child: DabblerIconList(
          items: <String>['Accurate details.', 'Changes shared early.'],
        ),
      ),
    ),
  ],
);
