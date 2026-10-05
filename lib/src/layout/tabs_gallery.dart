/// Gallery entries for [DabblerTabs] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_layout.dart';
import 'tabs.dart';

const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'upcoming', label: 'Upcoming'),
  DabblerTabItem(id: 'past', label: 'Past', badge: Text('3')),
  DabblerTabItem(id: 'saved', label: 'Saved'),
];

const List<DabblerTabItem> _feedItems = <DabblerTabItem>[
  DabblerTabItem(id: 'for-you', label: 'For you'),
  DabblerTabItem(id: 'following', label: 'Following'),
  DabblerTabItem(id: 'nearby', label: 'Nearby'),
  DabblerTabItem(id: 'active', label: 'Active'),
  DabblerTabItem(id: 'news', label: 'News'),
];

/// Tabs' specimens.
const List<GalleryEntry> tabsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'tabs/variants',
    page: 'components/tabs',
    group: GalleryPurpose.navigation,
    title: 'Tabs — variants',
    description:
        'Underline and segmented, plus the panel that follows the '
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
      label:
          'feed — the Home Feed rail: 21 apart, regular weight, 3px underline',
      child: DabblerTabs(
        items: _feedItems,
        value: 'for-you',
        variant: DabblerTabsVariant.feed,
        scrollable: true,
        padding: DabblerInsets.feedScreen,
      ),
    ),
    GallerySpecimen(
      label: 'feed, Arabic (the frame\'s own tab labels)',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerTabs(
          items: <DabblerTabItem>[
            DabblerTabItem(id: 'for-you', label: 'لك'),
            DabblerTabItem(id: 'following', label: 'أتابعهم'),
            DabblerTabItem(id: 'nearby', label: 'بالقرب'),
            DabblerTabItem(id: 'active', label: 'نشط'),
            DabblerTabItem(id: 'news', label: 'أخبار'),
          ],
          value: 'for-you',
          variant: DabblerTabsVariant.feed,
          scrollable: true,
          padding: DabblerInsets.feedScreen,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'segmented, long Arabic labels, labelFit: fit (DS gaps 6)',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerTabs(
          items: <DabblerTabItem>[
            DabblerTabItem(id: 'games', label: 'المباريات القريبة'),
            DabblerTabItem(id: 'meetups', label: 'لقاءات هذا الأسبوع'),
            DabblerTabItem(id: 'venues', label: 'الملاعب'),
          ],
          value: 'games',
          variant: DabblerTabsVariant.segmented,
          labelFit: DabblerTabsLabelFit.fit,
        ),
      ),
    ),
    GallerySpecimen(
      label: 'nothing selected (allowNoSelection, null value)',
      child: DabblerTabs(items: _items, allowNoSelection: true),
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
