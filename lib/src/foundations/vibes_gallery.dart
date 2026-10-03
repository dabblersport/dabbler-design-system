/// Gallery entry for the [DabblerVibe] token set (KAN-411).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'vibes.dart';

/// The vibes' specimens.
const List<GalleryEntry> vibesGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'vibes/all',
    page: 'foundations/vibes',
    group: null,
    title: 'Vibes — every vibe',
    description:
        'All 119 vibes as the design\'s pills, unselected, then the '
        'same set selected. Label and tone only; no emoji.',
    builder: _vibes,
  ),
];

Widget _vibes(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return GalleryStack(
    children: <Widget>[
      for (final bool selected in <bool>[false, true])
        GalleryWrap(
          children: <Widget>[
            for (final DabblerVibe vibe in DabblerVibe.values)
              _Pill(vibe: vibe, colors: colors, selected: selected),
          ],
        ),
    ],
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.vibe,
    required this.colors,
    required this.selected,
  });

  final DabblerVibe vibe;
  final DabblerColors colors;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final DabblerVibeColors tone = vibe.resolve(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? tone.selectedSurface : tone.surface,
        borderRadius: DabblerRadius.pillAll,
        border: Border.all(
          color: selected ? tone.selectedBorder : tone.border,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DabblerSpacing.space5,
          vertical: DabblerSpacing.space3,
        ),
        child: Text(
          vibe.label,
          style: DabblerType.subheadline
              .resolveForDirection(Directionality.of(context))
              .copyWith(color: tone.ink),
        ),
      ),
    );
  }
}
