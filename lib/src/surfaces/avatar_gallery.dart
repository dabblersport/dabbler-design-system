/// Gallery entries for [DabblerAvatar] and [DabblerAvatarGroup] (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'avatar.dart';

/// Avatar's specimens.
const List<GalleryEntry> avatarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Avatar — sizes, badges and groups',
    description: 'The five sizes, the badge tones, and the overflow group.',
    builder: _avatars,
  ),
];

Widget _avatars(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerAvatarSize size in DabblerAvatarSize.values)
          GallerySpecimen(
            label: size.name,
            child: DabblerAvatar(seed: 'nephthys', size: size),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final DabblerAvatarBadgeTone tone
            in DabblerAvatarBadgeTone.values)
          GallerySpecimen(
            label: 'badge ${tone.name}',
            child: DabblerAvatar(
              seed: 'shu',
              size: DabblerAvatarSize.lg,
              badge: const Text('3'),
              badgeTone: tone,
            ),
          ),
      ],
    ),
    const GallerySpecimen(
      label: 'group with overflow',
      child: DabblerAvatarGroup(
        people: <String>['ma-at', 'thoth', 'hathor'],
        overflow: 4,
      ),
    ),
  ],
);
