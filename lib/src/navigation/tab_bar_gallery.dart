/// Gallery entry for [DabblerNavigationTabBar] — `navigation.card.html`'s
/// Tab-Bar, in a 384-wide column.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'tab_bar.dart';

/// The tab bar's specimens.
const List<GalleryEntry> navigationTabBarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'tab-bar',
    page: 'components/tab-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — tab bar',
    description: 'Four icon slots at phone width; tap one to select it.',
    builder: _tabBar,
  ),
];

Widget _tabBar(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'default, first slot active',
      child: SizedBox(width: 384, child: _Selectable()),
    ),
  ],
);

class _Selectable extends StatefulWidget {
  const _Selectable();

  @override
  State<_Selectable> createState() => _SelectableState();
}

class _SelectableState extends State<_Selectable> {
  int _active = 0;

  @override
  Widget build(BuildContext context) => DabblerNavigationTabBar(
    activeIndex: _active,
    onSelect: (int i) => setState(() => _active = i),
  );
}
