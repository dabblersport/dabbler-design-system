/// Gallery entries for [DabblerTabs] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'tabs.dart';

const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'upcoming', label: 'Upcoming'),
  DabblerTabItem(id: 'past', label: 'Past', badge: Text('3')),
  DabblerTabItem(id: 'saved', label: 'Saved'),
];

/// Tabs' specimens.
const List<GalleryEntry> tabsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'tabs/variants',
    page: 'components/tabs',
    group: GalleryPurpose.navigation,
    title: 'Tabs — variants',
    description: 'Underline and segmented, plus the panel that follows the '
        'selected id.',
    builder: _tabs,
  ),
];

Widget _tabs(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'underline',
      child: DabblerTabs(items: _items, value: 'upcoming'),
    ),
    GallerySpecimen(
      label: 'segmented',
      child: DabblerTabs(
        items: _items,
        value: 'past',
        variant: DabblerTabsVariant.segmented,
      ),
    ),
    GallerySpecimen(
      label: 'panel',
      child: DabblerTabPanel(
        id: 'upcoming',
        value: 'upcoming',
        child: Text('The upcoming panel.'),
      ),
    ),
  ],
);
