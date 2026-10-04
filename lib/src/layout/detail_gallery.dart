/// Gallery entries for the Details-screen parts: [DabblerDetailHeader],
/// [DabblerGalleryHero], [DabblerActionBar], [DabblerListRow] /
/// [DabblerListGroup] and [DabblerHeadcount] (`Details.dc.html`).
library;

import 'package:flutter/widgets.dart';

import '../cards/headcount.dart';
import '../cards/list_row.dart';
import '../controls/button.dart';
import '../controls/on_color_icon_button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../media/gallery_hero.dart';
import '../navigation/action_bar.dart';
import '../surfaces/avatar.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import 'detail_header.dart';

/// Details-screen specimens.
const List<GalleryEntry> detailGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'detail-header',
    page: 'components/detail-header',
    group: GalleryPurpose.structure,
    title: 'DetailHeader — the coloured band that opens a detail screen',
    description:
        'Buttons, translucent pills, title and place on the sport theme.',
    builder: _header,
  ),
  GalleryEntry(
    id: 'gallery-hero',
    page: 'components/gallery-hero',
    group: GalleryPurpose.structure,
    title: 'GalleryHero — paged photo hero with caption and dots',
    description: 'Two empty slides with captions and page-surface buttons.',
    builder: _gallery,
  ),
  GalleryEntry(
    id: 'action-bar',
    page: 'components/action-bar',
    group: GalleryPurpose.structure,
    title: 'ActionBar — price and call to action pinned to the bottom',
    description: 'Price with a primary action, and price with a secondary one.',
    builder: _bar,
  ),
  GalleryEntry(
    id: 'list-row',
    page: 'components/list-row',
    group: GalleryPurpose.structure,
    title: 'ListRow and ListGroup — rows on a rounded panel',
    description: 'Squad rows with tags, and a contact group with chevrons.',
    builder: _rows,
  ),
  GalleryEntry(
    id: 'headcount',
    page: 'components/headcount',
    group: GalleryPurpose.structure,
    title: 'Headcount — avatars, headline and fill bar',
    description: 'A filling game and a full one.',
    builder: _count,
  ),
];

Widget _both(Widget Function() build) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'left-to-right',
      child: Directionality(textDirection: TextDirection.ltr, child: build()),
    ),
    GallerySpecimen(
      label: 'right-to-left',
      child: Directionality(textDirection: TextDirection.rtl, child: build()),
    ),
  ],
);

Widget _header(BuildContext context) => _both(
  () => DabblerDetailHeader(
    leading: DabblerOnColorIconButton(
      icon: 'arrow-circle-left',
      mirrorInRtl: true,
      semanticLabel: 'Back',
      onPressed: () {},
    ),
    actions: <Widget>[
      DabblerOnColorIconButton(
        icon: 'share',
        semanticLabel: 'Share',
        onPressed: () {},
      ),
    ],
    chips: const <String>['Upcoming', 'Football'],
    title: 'Tuesday 5-a-side',
    place: 'Dubai Sports City',
    meta: '2.1 km away',
  ),
);

Widget _gallery(BuildContext context) => _both(
  () => DabblerGalleryHero(
    slides: const <DabblerGallerySlide>[
      DabblerGallerySlide(label: 'General'),
      DabblerGallerySlide(label: 'Space 1'),
    ],
    leading: DabblerOnColorIconButton(
      onSurface: true,
      icon: 'arrow-circle-left',
      mirrorInRtl: true,
      semanticLabel: 'Back',
      onPressed: () {},
    ),
    actions: <Widget>[
      DabblerOnColorIconButton(
        onSurface: true,
        icon: 'heart',
        semanticLabel: 'Favourite',
        onPressed: () {},
      ),
    ],
  ),
);

Widget _bar(BuildContext context) => _both(
  () => Column(
    children: <Widget>[
      DabblerActionBar(
        price: 'AED 40',
        caption: 'per player',
        primary: DabblerButton(
          label: 'Join game',
          size: DabblerButtonSize.full,
          fullWidth: true,
          onPressed: () {},
        ),
      ),
      const DabblerGap.v(DabblerSpacing.space5),
      DabblerActionBar(
        price: 'AED 120',
        caption: 'per hour',
        secondary: DabblerButton(
          label: 'Add rating',
          tone: DabblerButtonTone.neutral,
          onPressed: () {},
        ),
        primary: DabblerButton(
          label: 'Book a space',
          size: DabblerButtonSize.full,
          fullWidth: true,
          onPressed: () {},
        ),
      ),
    ],
  ),
);

Widget _rows(BuildContext context) => _both(
  () => Column(
    children: <Widget>[
      DabblerListGroup(
        children: <Widget>[
          DabblerListRow(
            leading: const DabblerAvatar(
              seed: 'Ahmed Farouk',
              size: DabblerAvatarSize.sm,
            ),
            title: 'Ahmed Farouk',
            subtitle: 'Host',
            trailing: const DabblerBadge(label: 'Host'),
            onTap: () {},
          ),
          const DabblerListRow(
            leading: DabblerAvatar(
              seed: 'Rahul Menon',
              size: DabblerAvatarSize.sm,
            ),
            title: 'Rahul Menon',
            subtitle: 'Joined 2 hours ago',
          ),
        ],
      ),
      const DabblerGap.v(DabblerSpacing.space5),
      DabblerListGroup(
        tone: DabblerListGroupTone.info,
        children: <Widget>[
          DabblerListRow(
            overline: 'Phone',
            title: '+971 4 691 0256',
            showChevron: true,
            onTap: () {},
          ),
          DabblerListRow(
            overline: 'Website',
            title: 'elitefootballarena.ae',
            showChevron: true,
            onTap: () {},
          ),
        ],
      ),
    ],
  ),
);

Widget _count(BuildContext context) => _both(
  () => const Column(
    children: <Widget>[
      DabblerHeadcount(
        avatars: DabblerAvatarGroup(
          people: <String>['Ahmed Farouk', 'Rahul Menon', 'Aisha Khan'],
          overflow: 6,
        ),
        headline: '9 of 10 players in',
        caption: '1 spot left',
        progress: 0.9,
      ),
      DabblerGap.v(DabblerSpacing.space5),
      DabblerHeadcount(
        headline: '10 of 10 players in',
        caption: 'Full',
        progress: 1,
        critical: true,
      ),
    ],
  ),
);
