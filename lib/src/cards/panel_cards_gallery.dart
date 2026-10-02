/// Gallery entries for the profile panel family: [DabblerPanelCard],
/// [DabblerChecklistPanel], [DabblerMemberListPanel] and [DabblerMutualsCard].
///
/// The live design project's `cards.card.html` draws these as one group; the
/// four specimens here are the same compositions with injected data.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/avatar.dart';
import 'checklist_panel.dart';
import 'member_list_panel.dart';
import 'mutuals_card.dart';
import 'panel_card.dart';

/// The panel family's specimens.
const List<GalleryEntry> panelCardsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'panel-card',
    page: 'components/panel-card',
    group: GalleryPurpose.contentContainers,
    title: 'PanelCard — the framed panel',
    description:
        'Every frame tone, a dark panel, a collapsed panel, and a '
        'checklist body.',
    builder: _panels,
  ),
  GalleryEntry(
    id: 'checklist-panel',
    page: 'components/checklist-panel',
    group: GalleryPurpose.contentContainers,
    title: 'ChecklistPanel — the task rows',
    description: 'Open and done rows on the card and ink panels.',
    builder: _checklists,
  ),
  GalleryEntry(
    id: 'member-list-panel',
    page: 'components/member-list-panel',
    group: GalleryPurpose.contentContainers,
    title: 'MemberListPanel — the people rows',
    description: 'Add and remove states on the card and ink panels.',
    builder: _members,
  ),
  GalleryEntry(
    id: 'mutuals-card',
    page: 'components/mutuals-card',
    group: GalleryPurpose.contentContainers,
    title: 'MutualsCard — avatars beside a line of context',
    description: 'An avatar group beside its text.',
    builder: _mutuals,
  ),
];

const List<DabblerChecklistItem> _tasks = <DabblerChecklistItem>[
  DabblerChecklistItem(label: 'Book the court', done: true),
  DabblerChecklistItem(label: 'Confirm eight players'),
  DabblerChecklistItem(label: 'Bring a second ball'),
];

const List<DabblerMember> _people = <DabblerMember>[
  DabblerMember(name: 'Alen Rahman', role: 'Organiser', added: true),
  DabblerMember(name: 'Mariam Al Suwaidi', role: 'Regular'),
  DabblerMember(name: 'Carlos Alvarez', role: 'New'),
];

Widget _panels(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerPanelCardTone tone in DabblerPanelCardTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerPanelCard(
          tone: tone,
          title: 'This week',
          footerLabel: 'View all tasks',
          onFooter: () {},
          onPrev: () {},
          onNext: () {},
          child: const DabblerChecklistPanel(items: _tasks),
        ),
      ),
    const GallerySpecimen(
      label: 'dark',
      child: DabblerPanelCard(
        dark: true,
        title: 'Crew',
        footerLabel: 'View all',
        child: DabblerMemberListPanel(people: _people, dark: true),
      ),
    ),
    GallerySpecimen(
      label: 'collapsed',
      child: DabblerPanelCard(
        title: 'Collapsed',
        collapsed: true,
        onToggle: () {},
        child: const DabblerChecklistPanel(items: _tasks),
      ),
    ),
  ],
);

Widget _checklists(BuildContext context) => const GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'card',
      child: SizedBox(width: 300, child: DabblerChecklistPanel(items: _tasks)),
    ),
  ],
);

Widget _members(BuildContext context) => const GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'card',
      child: SizedBox(
        width: 300,
        child: DabblerMemberListPanel(people: _people),
      ),
    ),
  ],
);

Widget _mutuals(BuildContext context) => const GalleryWrap(
  children: <Widget>[
    GallerySpecimen(
      label: 'with an avatar group',
      child: SizedBox(
        width: 340,
        child: DabblerMutualsCard(
          avatars: DabblerAvatarGroup(
            people: <String>['Alen Rahman', 'Bushra Riaz', 'Carlos Alvarez'],
            overflow: 12,
          ),
          text: 'Followed by Bushra, Carlos and 12 others you follow',
        ),
      ),
    ),
  ],
);
