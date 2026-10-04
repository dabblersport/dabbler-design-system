/// Gallery entries for [DabblerSettingsHeader] and [DabblerRowGroup].
library;

import 'package:flutter/widgets.dart';

import '../forms/input_row.dart';
import '../forms/toggle.dart';
import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/avatar.dart';
import '../tokens/dabbler_colors.dart';
import 'settings_choices.dart';
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
  GalleryEntry(
    id: 'settings-choices',
    page: 'components/settings-parts',
    group: GalleryPurpose.contentContainers,
    title: 'PresetCard, OptionSegments and OptionRow — Settings choices',
    description:
        'A stack of described preset cards with the chosen one filled, a '
        'card of icon-over-label segments, and the muted hint under a group.',
    builder: _choices,
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
      label: 'colour dots',
      child: DabblerColorDots(
        colors: <Color>[
          DabblerColors.of(context).brandPrimary,
          DabblerColors.of(context).accent,
          DabblerColors.of(context).surfaceGrey,
        ],
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
    GallerySpecimen(
      label: 'row action and hint',
      child: SizedBox(
        width: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DabblerRowGroup(
              children: <Widget>[
                DabblerInputRow(
                  flat: true,
                  showDivider: false,
                  leading: const DabblerAvatar(
                    seed: 'Youssef El Khatib',
                    size: DabblerAvatarSize.md,
                  ),
                  title: 'Youssef El Khatib',
                  subtitle: '@youssef.elkhatib',
                  trailing: const DabblerRowAction(
                    label: 'Unblock',
                    onPressed: _noop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const DabblerRowHint(text: "You haven't blocked anyone."),
          ],
        ),
      ),
    ),
  ],
);

Widget _choices(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'segments',
      child: SizedBox(
        width: 360,
        child: DabblerOptionSegments(
          value: 'system',
          onChanged: (_) {},
          items: const <DabblerOptionSegment>[
            DabblerOptionSegment(id: 'light', label: 'Light', icon: 'sun-1'),
            DabblerOptionSegment(id: 'dark', label: 'Dark', icon: 'moon'),
            DabblerOptionSegment(id: 'system', label: 'System', icon: 'mobile'),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'preset cards',
      child: SizedBox(
        width: 360,
        child: Column(
          children: <Widget>[
            DabblerPresetCard(
              icon: 'global',
              title: 'Public',
              description:
                  'Your profile is visible to everyone for easy discovery',
              selected: true,
              onTap: _noop,
            ),
            const SizedBox(height: 9),
            DabblerPresetCard(
              icon: 'people',
              title: 'Friends only',
              description: 'Only your friends can see your full profile',
              onTap: _noop,
            ),
          ],
        ),
      ),
    ),
    GallerySpecimen(
      label: 'option rows',
      child: SizedBox(
        width: 360,
        child: Column(
          children: <Widget>[
            DabblerOptionRow(label: 'Anyone', selected: true, onTap: _noop),
            const SizedBox(height: 6),
            DabblerOptionRow(label: 'Friends only', onTap: _noop),
          ],
        ),
      ),
    ),
  ],
);
