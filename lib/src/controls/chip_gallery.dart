/// Gallery entries for [DabblerChip] (KAN-259 AC2).
///
/// ## Where Chip's specimen actually lives
///
/// Not in `components/controls/controls.card.html` — that page draws Button and
/// FAB only. Chip's canonical specimen is the *Chips — selection & filtering*
/// section of `components/surfaces/identity-status.card.html`, and this row is
/// transcribed from it: three static filter chips (one selected) followed by
/// two interactive sport chips carrying an 18px leading icon, of which exactly
/// one is selected at a time.
///
/// The design draws Chip as a **live filter row**, not as a variant list, which
/// is why the selection here is stateful rather than three frozen swatches.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'chip.dart';

/// Chip's specimens.
const List<GalleryEntry> chipGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Chip — selection & filtering',
    description: 'A filter row: static chips, plus two interactive sport chips '
        'with an 18px leading icon. Tap one to move the selection.',
    builder: _chips,
  ),
];

Widget _chips(BuildContext context) => const GallerySpecimen(
  label: 'filter row',
  child: _FilterRow(),
);

class _FilterRow extends StatefulWidget {
  const _FilterRow();

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  /// `const [sport, setSport] = React.useState('tennis')`.
  String _sport = 'tennis';

  @override
  Widget build(BuildContext context) => GalleryWrap(
    children: <Widget>[
      const DabblerChip(label: 'Near me', selected: true),
      const DabblerChip(label: 'This week'),
      const DabblerChip(label: 'Free'),
      DabblerChip(
        label: 'Tennis',
        selected: _sport == 'tennis',
        onTap: () => setState(() => _sport = 'tennis'),
        leadingIcon: const DabblerIcon('game', size: DabblerSizing.iconSm),
      ),
      DabblerChip(
        label: 'Padel',
        selected: _sport == 'padel',
        onTap: () => setState(() => _sport = 'padel'),
        leadingIcon: const DabblerIcon('activity', size: DabblerSizing.iconSm),
      ),
    ],
  );
}
