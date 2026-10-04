/// Gallery entries for [DabblerNavigationTopBar] and
/// [DabblerNavigationBottomBar].
///
/// Laid out to mirror `components/navigation/navigation.card.html`, which
/// stacks the top bar, then the bottom bar closed, then the bottom bar with
/// its create menu open, then the bottom bar in RTL — each of the bottom bars
/// in a 384-wide column, which is the width the specimen exports at and the
/// width the split bar is designed against. At full gallery width the pill and
/// the action fly apart and the bar stops reading as one object.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'bottom_bar.dart';
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
    description:
        'The wordmark, the two actions and the account avatar, as the '
        'specimen exports it. Safe-area padding is off here so the bar reads '
        'at gallery scale.',
    builder: _topBar,
  ),
  GalleryEntry(
    id: 'bottom-bar',
    page: 'components/bottom-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — bottom bar',
    description:
        'The split bar at phone width: closed, with the create menu '
        'open, and in RTL. Tap create to open the menu.',
    builder: _bottomBar,
  ),
  GalleryEntry(
    id: 'bottom-bar/icon-tones',
    page: 'components/bottom-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — bottom bar, toned create menu',
    description:
        'createItems with iconTone info / success / accent, and the '
        'action held upright (rotateActionOnOpen: false), as the Home Feed '
        'design draws it (DSG-NEW-001).',
    builder: _bottomBarTones,
  ),
  GalleryEntry(
    id: 'bottom-bar/pinned-rtl',
    page: 'components/bottom-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — bottom bar, RTL pinned',
    description:
        'mirrorInRtl: false under Arabic: the pill stays on the physical '
        'left and the action on the right, as Home_feed_—_Arabic.png draws '
        'it; the labels still read right to left.',
    builder: _bottomBarPinnedRtl,
  ),
  GalleryEntry(
    id: 'bottom-bar/badges',
    page: 'components/bottom-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — bottom bar, unread dot and count',
    description:
        'Per-item unread dot and count badge on the icon\'s '
        'top-inline-end corner, in LTR and RTL.',
    builder: _bottomBarBadges,
  ),
];

const List<DabblerNavigationItem> _badgeItems = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
  DabblerNavigationItem(
    id: 'inbox',
    icon: 'sms',
    label: 'Inbox',
    count: 3,
    badgeLabel: '3 unread',
  ),
  DabblerNavigationItem(
    id: 'games',
    icon: 'game',
    label: 'Games',
    unread: true,
    badgeLabel: 'new',
  ),
  DabblerNavigationItem(id: 'you', icon: 'user', label: 'You'),
];

Widget _bottomBarBadges(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'dot and count, LTR',
      child: SizedBox(
        width: _phoneWidth,
        child: DabblerNavigationBottomBar(
          safeArea: false,
          items: _badgeItems,
          createItems: <DabblerNavigationCreateItem>[],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'dot and count, RTL',
      child: SizedBox(
        width: _phoneWidth,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DabblerNavigationBottomBar(
            safeArea: false,
            items: _badgeItems,
            createItems: <DabblerNavigationCreateItem>[],
          ),
        ),
      ),
    ),
  ],
);

Widget _bottomBarTones(BuildContext context) => const GallerySpecimen(
  label: 'Home Feed create menu',
  child: SizedBox(
    width: _phoneWidth,
    child: DabblerNavigationBottomBar(
      safeArea: false,
      defaultMenuOpen: true,
      rotateActionOnOpen: false,
      createItems: <DabblerNavigationCreateItem>[
        DabblerNavigationCreateItem(
          id: 'post',
          icon: 'edit-2',
          label: 'Create post',
          iconTone: DabblerNavigationIconTone.info,
        ),
        DabblerNavigationCreateItem(
          id: 'game',
          icon: 'game',
          label: 'Create game',
          iconTone: DabblerNavigationIconTone.success,
        ),
        DabblerNavigationCreateItem(
          id: 'meetup',
          icon: 'people',
          label: 'Create meetup',
          iconTone: DabblerNavigationIconTone.accent,
        ),
      ],
    ),
  ),
);

Widget _bottomBarPinnedRtl(BuildContext context) => const GallerySpecimen(
  label: 'Arabic, layout unmirrored (Home Feed Arabic frame)',
  child: SizedBox(
    width: _phoneWidth,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: DabblerNavigationBottomBar(
        safeArea: false,
        mirrorInRtl: false,
        // The Arabic frame's own strings (`Home Feed.dc.html:3501`).
        items: <DabblerNavigationItem>[
          DabblerNavigationItem(id: 'feeds', icon: 'home-2', label: 'الرئيسية'),
          DabblerNavigationItem(id: 'venues', icon: 'location', label: 'ملاعب'),
          DabblerNavigationItem(id: 'games', icon: 'game', label: 'مباريات'),
          DabblerNavigationItem(
            id: 'meetups',
            icon: 'calendar',
            label: 'لقاءات',
          ),
        ],
      ),
    ),
  ),
);

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
            DabblerNavigationAction(icon: 'notification-bing', label: 'Alerts'),
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
            DabblerNavigationAction(icon: 'notification-bing', label: 'Alerts'),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'loading actions — saving',
      child: SizedBox(
        width: _phoneWidth,
        child: DabblerNavigationTopBar(
          safeArea: false,
          actions: <DabblerNavigationAction>[
            DabblerNavigationAction(
              icon: 'notification-bing',
              label: 'Alerts',
              loading: true,
            ),
            DabblerNavigationAction.text(label: 'Save', loading: true),
          ],
        ),
      ),
    ),
    GallerySpecimen(label: 'wordmark alone', child: DabblerWordmark()),
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
          child: DabblerNavigationBottomBar(safeArea: false, active: 'explore'),
        ),
      ),
    ),
  ],
);
