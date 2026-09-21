/// Gallery entries for [DabblerNavigationTopBar], [DabblerNavigationTabBar] and
/// [DabblerNavigationBottomBar].
///
/// Laid out to mirror `components/navigation/navigation.card.html`, which
/// stacks the top bar, then the four-tab bar, then the bottom bar closed, then
/// the bottom bar with its create menu open, then the bottom bar in RTL — each
/// of the last four in a 384-wide column, which is the width the specimen
/// exports at and the width the split bar is designed against. At full gallery
/// width the pill and the action fly apart and the bar stops reading as one
/// object.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'bottom_bar.dart';
import 'tab_bar.dart';
import 'top_bar.dart';

/// The specimen's export width (`navigation.card.html` — `width: 384`).
const double _phoneWidth = 384;

/// Navigation's specimens.
const List<GalleryEntry> navigationGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'top-bar',
    page: 'components/top-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — top bar',
    description: 'The wordmark, the two actions and the account avatar, as the '
        'specimen exports it. Safe-area padding is off here so the bar reads '
        'at gallery scale.',
    builder: _topBar,
  ),
  GalleryEntry(
    id: 'tab-bar',
    page: 'components/tab-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — tab bar',
    description: 'The flat four-tab strip the specimen draws between the top '
        'bar and the split bottom bar: icon-only, equal widths, brand-tinted '
        'bold glyph on the active tab.',
    builder: _tabBar,
  ),
  GalleryEntry(
    id: 'bottom-bar',
    page: 'components/bottom-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — bottom bar',
    description: 'The split bar at phone width: closed, with the create menu '
        'open, and in RTL. Tap create to open the menu.',
    builder: _bottomBar,
  ),
];

Widget _topBar(BuildContext context) => const GalleryStack(
      children: <Widget>[
        GallerySpecimen(
          // The specimen's own top bar carries the border and radius, and its
          // two trailing glyphs are `sms` and `notification-bing`.
          label: 'as the specimen draws it',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationTopBar(
              safeArea: false,
              border: true,
              actions: <DabblerNavigationAction>[
                DabblerNavigationAction(icon: 'sms', label: 'Messages'),
                DabblerNavigationAction(
                  icon: 'notification-bing',
                  label: 'Alerts',
                ),
              ],
            ),
          ),
        ),
        GallerySpecimen(
          label: 'on a screen — no frame',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationTopBar(
              safeArea: false,
              actions: <DabblerNavigationAction>[
                DabblerNavigationAction(icon: 'sms', label: 'Messages'),
                DabblerNavigationAction(
                  icon: 'notification-bing',
                  label: 'Alerts',
                ),
              ],
            ),
          ),
        ),
        GallerySpecimen(label: 'wordmark alone', child: DabblerWordmark()),
      ],
    );

Widget _tabBar(BuildContext context) => const GalleryStack(
      children: <Widget>[
        GallerySpecimen(
          label: 'as the specimen draws it — first tab active',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationTabBar(),
          ),
        ),
        GallerySpecimen(
          label: 'a later tab active',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationTabBar(active: 'messages'),
          ),
        ),
        GallerySpecimen(
          label: 'RTL — the tabs mirror',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: _phoneWidth,
              child: DabblerNavigationTabBar(active: 'explore'),
            ),
          ),
        ),
      ],
    );

Widget _bottomBar(BuildContext context) => const GalleryStack(
      children: <Widget>[
        GallerySpecimen(
          label: 'closed',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationBottomBar(safeArea: false),
          ),
        ),
        GallerySpecimen(
          label: 'create menu open',
          child: SizedBox(
            width: _phoneWidth,
            child: DabblerNavigationBottomBar(
              safeArea: false,
              defaultMenuOpen: true,
            ),
          ),
        ),
        GallerySpecimen(
          label: 'RTL — pill and action swap sides',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: _phoneWidth,
              child: DabblerNavigationBottomBar(
                safeArea: false,
                active: 'explore',
              ),
            ),
          ),
        ),
      ],
    );
