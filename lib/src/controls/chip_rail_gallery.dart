/// Gallery entries for [DabblerChipRail] and [DabblerSportAccent]
/// (KAN-426, Seat B). Mirrors `Wallet v2.dc.html:151-157`,
/// `Notifications.dc.html:56-60` and `Profiles.dc.html:155-170`.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../foundations/sport_accent.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_geometry.dart';
import 'chip.dart';
import 'chip_rail.dart';

/// ChipRail and SportAccent specimens.
const List<GalleryEntry> chipRailGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'chip-rail',
    page: 'components/chip-rail',
    group: GalleryPurpose.selectionAndInput,
    title: 'ChipRail — a scrolling row of selectable chips',
    description:
        'The Transactions filter chips, the Activities category chips with '
        'counts, a two-row rail, and the rail in right-to-left. Tap a chip to '
        'select it; the rails scroll and fade at the cut-off edge.',
    builder: _rails,
  ),
  GalleryEntry(
    id: 'sports/accent',
    page: 'foundations/sports',
    group: null,
    title: 'SportAccent — the colour a sport is drawn in',
    description:
        'The Profiles sport picker: padel, football, basketball, tennis and '
        'the All fallback as selected chips and badges, and a sport the '
        'frames do not colour.',
    builder: _accents,
  ),
];

const List<String> _period = <String>[
  'All',
  'Paid',
  'On hold',
  'Refunded',
  'Received',
  'Pending',
  'Disputed',
];

const List<String> _arPeriod = <String>[
  'الكل',
  'مدفوع',
  'معلّق',
  'مسترد',
  'مستلم',
  'قيد الانتظار',
  'متنازع عليه',
];

class _Rail extends StatefulWidget {
  const _Rail({
    required this.labels,
    this.counts = false,
    this.rows = 1,
    this.size = DabblerChipSize.regular,
  });

  final List<String> labels;
  final bool counts;
  final int rows;
  final DabblerChipSize size;

  @override
  State<_Rail> createState() => _RailState();
}

class _RailState extends State<_Rail> {
  int _on = 0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: DabblerChipRail(
      rows: widget.rows,
      size: widget.size,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space6,
      ),
      items: <DabblerChipRailItem>[
        for (int i = 0; i < widget.labels.length; i++)
          DabblerChipRailItem(
            label: widget.labels[i],
            selected: i == _on,
            count: widget.counts ? '${i + 2}' : null,
            onTap: () => setState(() => _on = i),
          ),
      ],
    ),
  );
}

Widget _rails(BuildContext context) => GalleryStack(
  children: <Widget>[
    const GallerySpecimen(
      label: 'transactions — filter chips',
      child: _Rail(labels: _period),
    ),
    const GallerySpecimen(
      label: 'activities — small chips with counts',
      child: _Rail(labels: _period, counts: true, size: DabblerChipSize.small),
    ),
    const GallerySpecimen(
      label: 'two rows',
      child: _Rail(labels: _period, rows: 2),
    ),
    GallerySpecimen(
      label: 'right-to-left',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: const _Rail(labels: _arPeriod, counts: true),
      ),
    ),
  ],
);

Widget _accentChips({required bool selected}) => Wrap(
  spacing: DabblerSpacing.space2,
  runSpacing: DabblerSpacing.space2,
  children: <Widget>[
    for (final MapEntry<String, String> e in const <String, String>{
      'padel': 'Padel',
      'football': 'Football',
      'basketball': 'Basketball',
      'tennis': 'Tennis',
      'running': 'Running (fallback)',
    }.entries)
      DabblerChip(
        label: e.value,
        selected: selected,
        size: DabblerChipSize.large,
        accent: DabblerSportAccent.of(e.key),
        leadingIcon: const DabblerIcon('game'),
        dot: e.key == 'padel',
        onTap: () {},
      ),
  ],
);

Widget _accents(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'selected chips',
      child: _accentChips(selected: true),
    ),
    GallerySpecimen(label: 'idle chips', child: _accentChips(selected: false)),
    GallerySpecimen(
      label: 'badges',
      child: Wrap(
        spacing: DabblerSpacing.space2,
        children: <Widget>[
          DabblerBadge(
            label: 'Padel',
            accent: DabblerSportAccent.padel,
            comfortable: true,
          ),
          DabblerBadge(
            label: 'Basketball',
            accent: DabblerSportAccent.basketball,
            comfortable: true,
          ),
          DabblerBadge(
            label: 'Tennis',
            accent: DabblerSportAccent.tennis,
            comfortable: true,
          ),
        ],
      ),
    ),
  ],
);
