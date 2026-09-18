/// Gallery entries for [DabblerAvatar] and [DabblerAvatarGroup] (KAN-259 AC2).
///
/// The rows mirror the design specimen
/// `components/surfaces/identity-status.card.html` → *"Avatars — identity"*,
/// down to the seed strings. The seeds matter: Multiavatar hashes the seed, so
/// the same five names produce the same five faces here and on the design page,
/// which is what makes the two screenshots comparable at all. The previous
/// entry drew all five sizes from **one** seed — five copies of one face, where
/// the specimen shows five different people — and put a `Text('3')` in the
/// corner badge where the specimen draws a 10px bold white glyph.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import 'avatar.dart';

/// Avatar's specimens.
const List<GalleryEntry> avatarGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'avatar',
    page: 'components/avatar',
    group: GalleryPurpose.identityAndStatus,
    title: 'Avatar — sizes, badges and groups',
    description: 'Sizes xs 28 · sm 36 · md 48 · lg 64 · xl 80; the three badge '
        'tones; and AvatarGroup with its +N overflow.',
    builder: _avatars,
  ),
];

/// `<Avatar seed="…" size="…" />` — the specimen's five seeds, in its order.
const List<(String, DabblerAvatarSize)> _people =
    <(String, DabblerAvatarSize)>[
  ('Alen Rahman', DabblerAvatarSize.xs),
  ('Bushra Riaz', DabblerAvatarSize.sm),
  ('Carlos Alvarez', DabblerAvatarSize.md),
  ('Dana Halabi', DabblerAvatarSize.lg),
  ('Elias Noor', DabblerAvatarSize.xl),
];

/// The corner-badge row: seed, size, glyph and tone, from the specimen.
const List<(String, DabblerAvatarSize, String, DabblerAvatarBadgeTone)>
    _badged = <(String, DabblerAvatarSize, String, DabblerAvatarBadgeTone)>[
  ('Alen Rahman', DabblerAvatarSize.sm, 'tick-circle',
      DabblerAvatarBadgeTone.primary),
  ('Alen Rahman', DabblerAvatarSize.md, 'star', DabblerAvatarBadgeTone.accent),
  ('Dana Halabi', DabblerAvatarSize.md, 'microphone-2',
      DabblerAvatarBadgeTone.indigo),
];

/// `size={10}` on every badge glyph in the specimen.
const double _badgeGlyphSize = 10;

Widget _avatars(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final (String seed, DabblerAvatarSize size) in _people)
          GallerySpecimen(
            label: '${size.name} ${size.diameter.toInt()}',
            child: DabblerAvatar(seed: seed, size: size),
          ),
      ],
    ),
    GalleryWrap(
      children: <Widget>[
        for (final (
              String seed,
              DabblerAvatarSize size,
              String glyph,
              DabblerAvatarBadgeTone tone
            ) in _badged)
          GallerySpecimen(
            label: 'badge ${tone.name}',
            child: Builder(
              builder: (BuildContext context) => DabblerAvatar(
                seed: seed,
                size: size,
                badgeTone: tone,
                // `<Icon … type="bold" size={10} color="var(--neutral-white)"
                // />` — the badge's own ink, which the widget supplies.
                badge: DabblerIcon(
                  glyph,
                  weight: DabblerIconWeight.bold,
                  size: _badgeGlyphSize,
                  color: DabblerColors.of(context).onBrand,
                ),
              ),
            ),
          ),
      ],
    ),
    const GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'group',
          child: DabblerAvatarGroup(
            people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
          ),
        ),
        GallerySpecimen(
          label: 'group · +42',
          child: DabblerAvatarGroup(
            people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
            overflow: 42,
          ),
        ),
        GallerySpecimen(
          label: 'group · +6',
          child: DabblerAvatarGroup(
            people: <String>['Rami Haddad', 'Leo Fernandes'],
            overflow: 6,
          ),
        ),
      ],
    ),
  ],
);
