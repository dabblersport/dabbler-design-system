/// Gallery entry for [DabblerAvatar]'s image-URL form (KAN-409 item 1).
///
/// The gallery ships no photo and calls no third-party host, so the specimen
/// shows what is deterministic: the seed portrait standing in for a missing
/// URL and for one that cannot load.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'avatar.dart';

/// The image-URL avatar's specimens.
const List<GalleryEntry> avatarImageGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'avatar/image',
    page: 'components/avatar',
    group: GalleryPurpose.identityAndStatus,
    title: 'Avatar — image URL',
    description:
        'A network photo in the same circle; the seed portrait shows '
        'while it loads, when the URL is empty, and when it fails.',
    builder: _image,
  ),
];

Widget _image(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'no URL — seed portrait',
      child: DabblerAvatar(seed: 'Dana Halabi', size: DabblerAvatarSize.lg),
    ),
    GallerySpecimen(
      label: 'unreachable URL — falls back to the same seed',
      child: DabblerAvatar(
        seed: 'Dana Halabi',
        size: DabblerAvatarSize.lg,
        imageUrl: 'https://invalid.example/avatar.png',
      ),
    ),
  ],
);
