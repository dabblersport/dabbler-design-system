/// Gallery entries for [DabblerMenu] (KAN-259 AC2).
///
/// The menu owns its own trigger, so these entries render the composed widget
/// and the reviewer opens it — no inline panel.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'menu.dart';

const List<DabblerMenuEntry> _entries = <DabblerMenuEntry>[
  DabblerMenuEntry(label: 'Share', icon: 'share'),
  DabblerMenuEntry(label: 'Edit', icon: 'edit'),
  DabblerMenuEntry.separator(),
  DabblerMenuEntry(
    label: 'Delete',
    icon: 'trash',
    tone: DabblerMenuItemTone.destructive,
  ),
  DabblerMenuEntry(label: 'Archive', disabled: true),
];

/// Menu's specimens.
const List<GalleryEntry> menuGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'menu/placements',
    page: 'components/menu',
    group: GalleryPurpose.presentation,
    title: 'Menu — placements, and the list on its own',
    description: 'Tap a trigger to open. DabblerMenuList is the same content '
        'without the overlay, for layout review.',
    builder: _menus,
  ),
];

Widget _menus(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerMenuPlacement placement
            in DabblerMenuPlacement.values)
          GallerySpecimen(
            label: placement.name,
            child: DabblerMenu(
              placement: placement,
              items: _entries,
              label: 'Game actions',
              trigger: const DabblerButton(label: 'Actions'),
            ),
          ),
      ],
    ),
    const GallerySpecimen(
      label: 'DabblerMenuList, inline',
      child: DabblerMenuList(items: _entries),
    ),
  ],
);
