/// Gallery entry for [DabblerNavigationAction.unread] (KAN-409 item 2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'top_bar.dart';

/// The unread dot's specimens.
const List<GalleryEntry> topBarUnreadGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'top-bar/unread',
    page: 'components/top-bar',
    group: GalleryPurpose.navigation,
    title: 'Navigation — top bar unread dot',
    description:
        'The 9px brand dot on the notification action, in LTR and '
        'mirrored in RTL. No count.',
    builder: _unread,
  ),
];

const List<DabblerNavigationAction> _actions = <DabblerNavigationAction>[
  DabblerNavigationAction(icon: 'search-normal', label: 'Search'),
  DabblerNavigationAction(
    icon: 'notification-bing',
    label: 'Notifications',
    unread: true,
    unreadLabel: 'unread',
  ),
];

Widget _unread(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'LTR',
      child: DabblerNavigationTopBar(
        actions: _actions,
        avatarSeed: 'Moataz Mustapha',
        safeArea: false,
      ),
    ),
    GallerySpecimen(
      label: 'RTL',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerNavigationTopBar(
          actions: _actions,
          avatarSeed: 'Moataz Mustapha',
          safeArea: false,
        ),
      ),
    ),
  ],
);
