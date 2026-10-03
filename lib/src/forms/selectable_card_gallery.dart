/// Gallery entries for [DabblerSelectableCard] (Alpha DS gaps 5, item 10).
///
/// Mirrors the persona step (`Auth and Onboarding.dc.html:373-389`) and the
/// sport grid (`:392-406`).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'selectable_card.dart';

/// SelectableCard specimens.
const List<GalleryEntry> selectableCardGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'selectable-card',
    page: 'components/selectable-card',
    group: GalleryPurpose.selectionAndInput,
    title: 'SelectableCard — a card that is chosen or not',
    description:
        'Persona rows (one of many) and a sport tile grid (many of many), '
        'idle, selected and disabled.',
    builder: _cards,
  ),
];

const double _width = 300;

Widget _cards(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'row — tap to choose one',
      child: SizedBox(width: _width, child: _PersonaDemo()),
    ),
    GallerySpecimen(
      label: 'tile grid — tap to toggle',
      child: SizedBox(width: _width, child: _SportDemo()),
    ),
    GallerySpecimen(
      label: 'disabled',
      child: SizedBox(
        width: _width,
        child: DabblerSelectableCard(
          icon: 'location',
          caption: 'Host',
          title: 'I run a venue',
        ),
      ),
    ),
  ],
);

class _PersonaDemo extends StatefulWidget {
  const _PersonaDemo();

  @override
  State<_PersonaDemo> createState() => _PersonaDemoState();
}

class _PersonaDemoState extends State<_PersonaDemo> {
  int _chosen = 0;

  static const List<(String, String, String)> _personas =
      <(String, String, String)>[
        ('game', 'Player', 'I want to find games'),
        ('people', 'Organiser', 'I run games for others'),
      ];

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int i = 0; i < _personas.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: DabblerSpacing.space4),
          child: DabblerSelectableCard(
            icon: _personas[i].$1,
            caption: _personas[i].$2,
            title: _personas[i].$3,
            subtitle: 'You can add another way later in settings.',
            selected: _chosen == i,
            onChanged: (_) => setState(() => _chosen = i),
          ),
        ),
    ],
  );
}

class _SportDemo extends StatefulWidget {
  const _SportDemo();

  @override
  State<_SportDemo> createState() => _SportDemoState();
}

class _SportDemoState extends State<_SportDemo> {
  final Set<int> _on = <int>{0, 2};

  static const List<String> _sports = <String>[
    'Football',
    'Padel',
    'Basketball',
    'Tennis',
  ];

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: DabblerSpacing.space3,
    crossAxisSpacing: DabblerSpacing.space3,
    children: <Widget>[
      for (int i = 0; i < _sports.length; i++)
        DabblerSelectableCard(
          layout: DabblerSelectableCardLayout.tile,
          icon: 'cup',
          title: _sports[i],
          selected: _on.contains(i),
          onChanged: (bool v) => setState(() => v ? _on.add(i) : _on.remove(i)),
        ),
    ],
  );
}
