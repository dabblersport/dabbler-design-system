/// Gallery entries for [DabblerProfileRow] and [DabblerLinkChip].
///
/// The specimens mirror `Profiles.dc.html`: the games rows (weekday over day),
/// the figure-over-caption rows in each status tint, and the copy-link chip in
/// both states.
library;

import 'package:flutter/widgets.dart';

import '../controls/link_chip.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'profile_row.dart';

/// ProfileRow's and LinkChip's specimens.
const List<GalleryEntry> profileRowGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'profile-row',
    page: 'components/profile-row',
    group: GalleryPurpose.contentContainers,
    title: 'ProfileRow — the profile list row',
    description:
        'A lead block, title, sub-line and tag on a card or a status tint.',
    builder: _rows,
  ),
  GalleryEntry(
    id: 'link-chip',
    page: 'components/link-chip',
    group: GalleryPurpose.contentContainers,
    title: 'LinkChip — copy the profile link',
    description: 'The small pill beside a handle, idle and copied.',
    builder: _link,
  ),
];

Widget _rows(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'games — weekday over day',
      child: SizedBox(
        width: 360,
        child: Column(
          children: <Widget>[
            DabblerProfileRow(
              title: 'Padel doubles',
              subtitle: '7:00 PM · Reform Padel Club · 3/4',
              lead: '19',
              leadCaption: 'Tue',
              captionFirst: true,
              tag: 'Joined',
              tone: DabblerProfileRowTone.info,
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'figure over caption, every tint',
      child: SizedBox(
        width: 360,
        child: Column(
          children: <Widget>[
            for (final DabblerProfileRowTone t in DabblerProfileRowTone.values)
              DabblerProfileRow(
                title: 'Tuesday padel doubles',
                subtitle: 'Weekly, Tue 7:00 PM',
                lead: '3/4',
                leadCaption: 'filled',
                tag: t.name,
                tone: t,
              ),
          ],
        ),
      ),
    ),
  ],
);

Widget _link(BuildContext context) => GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'idle',
      child: DabblerLinkChip(semanticLabel: 'Copy profile link', onTap: () {}),
    ),
    GallerySpecimen(
      label: 'copied',
      child: DabblerLinkChip(
        semanticLabel: 'Copy profile link',
        copied: true,
        copiedLabel: 'Link copied',
        onTap: () {},
      ),
    ),
  ],
);
