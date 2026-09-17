/// Gallery entries for [DabblerNavigationTopBar] and
/// [DabblerNavigationBottomBar] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'bottom_bar.dart';
import 'top_bar.dart';

/// Navigation's specimens.
const List<GalleryEntry> navigationGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Navigation — top bar',
    description: 'The wordmark, the actions and the account avatar. Safe-area '
        'padding is off here so the bar reads at gallery scale.',
    builder: _topBar,
  ),
  GalleryEntry(
    title: 'Navigation — bottom bar',
    description: 'The five destinations and the create action. Tap create to '
        'open the create menu.',
    builder: _bottomBar,
  ),
];

Widget _topBar(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default',
      child: DabblerNavigationTopBar(safeArea: false),
    ),
    GallerySpecimen(
      label: 'with actions and a border',
      child: DabblerNavigationTopBar(
        safeArea: false,
        border: true,
        actions: <DabblerNavigationAction>[
          DabblerNavigationAction(icon: 'search-normal', label: 'Search'),
          DabblerNavigationAction(icon: 'notification', label: 'Alerts'),
        ],
      ),
    ),
    GallerySpecimen(label: 'wordmark alone', child: DabblerWordmark()),
  ],
);

Widget _bottomBar(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default destinations',
      child: DabblerNavigationBottomBar(safeArea: false),
    ),
  ],
);
