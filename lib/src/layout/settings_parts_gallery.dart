/// Gallery entries for [DabblerSettingsHeader] and [DabblerRowGroup].
library;

import 'package:flutter/widgets.dart';

import '../forms/input_row.dart';
import '../forms/toggle.dart';
import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/avatar.dart';
import 'settings_parts.dart';

/// The Settings parts' specimens.
const List<GalleryEntry> settingsPartsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'settings-parts',
    page: 'components/settings-parts',
    group: GalleryPurpose.contentContainers,
    title: 'SettingsHeader and RowGroup — the Settings page parts',
    description:
        'The tinted hero with version pill, title and identity row, and a '
        'titled card of rows with value, toggle and destructive rows.',
    builder: _parts,
  ),
];

void _noop() {}

Widget _parts(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'hero',
      child: SizedBox(
        width: 360,
        child: DabblerSettingsHeader(
          versionLabel: 'Version 1.7.8',
          title: 'Settings',
          subtitle:
              'Manage your account, preferences, and notifications all in '
              'one place.',
          identity: const DabblerInputRow(
            flat: true,
            showDivider: false,
            leading: DabblerAvatar(
              seed: 'dabbler.pro',
              size: DabblerAvatarSize.md,
            ),
            title: 'dabbler.pro@proton.me',
            subtitle: 'Account, password & security',
            value: '',
            onTap: _noop,
          ),
        ),
      ),
    ),
    GallerySpecimen(
      label: 'group',
      child: SizedBox(
        width: 360,
        child: DabblerRowGroup(
          header: 'Security',
          note: 'Protect your account with additional security measures',
          children: <Widget>[
            DabblerInputRow(
              flat: true,
              showDivider: false,
              leading: const DabblerIcon('shield-tick'),
              title: 'Two-factor authentication',
              subtitle: 'Add an extra layer of security',
              trailing: DabblerToggle(checked: false, onChanged: (_) {}),
            ),
            const DabblerInputRow(
              flat: true,
              showDivider: false,
              leading: DabblerIcon('logout'),
              title: 'Sign out',
              tone: DabblerInputRowTone.destructive,
              onTap: _noop,
            ),
          ],
        ),
      ),
    ),
  ],
);
