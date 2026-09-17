/// Gallery entries for [DabblerFab] (KAN-259 AC2).
///
/// Transcribed from the FAB row of `components/controls/buttons.card.html`,
/// which labels itself *"default · primary · accent · dark · disabled"* and
/// passes a specific glyph per tone: `add` on `default`, the **bold**
/// `microphone-2` on `primary` and `accent`, the linear `microphone-2` on
/// `dark`, and `add` again on the disabled primary. The previous version of
/// this file drew the same `add` glyph on all four tones and omitted the
/// disabled FAB entirely, so the specimen showed neither the bold icon weight
/// the design reserves for primary actions nor the 45% disabled state.
library;

import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_geometry.dart';
import 'fab.dart';

/// Fab's specimens.
const List<GalleryEntry> fabGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'FAB — tones',
    description: '56×56 on a 21px squircle corner. The FAB carries the '
        "system's one documented shadow exception.",
    builder: _tones,
  ),
];

Widget _tones(BuildContext context) => const GallerySpecimen(
  label: 'default · primary · accent · dark · disabled',
  child: GalleryWrap(
    children: <Widget>[
      DabblerFab(
        tone: DabblerFabTone.indigo,
        semanticLabel: 'Create game',
        onPressed: _noop,
        child: DabblerIcon('add', size: DabblerSizing.iconMd),
      ),
      DabblerFab(
        semanticLabel: 'Record',
        onPressed: _noop,
        child: DabblerIcon(
          'microphone-2',
          weight: DabblerIconWeight.bold,
          size: DabblerSizing.iconMd,
        ),
      ),
      DabblerFab(
        tone: DabblerFabTone.accent,
        semanticLabel: 'Record',
        onPressed: _noop,
        child: DabblerIcon(
          'microphone-2',
          weight: DabblerIconWeight.bold,
          size: DabblerSizing.iconMd,
        ),
      ),
      DabblerFab(
        tone: DabblerFabTone.dark,
        semanticLabel: 'Record',
        onPressed: _noop,
        child: DabblerIcon('microphone-2', size: DabblerSizing.iconMd),
      ),
      // `disabled` on this widget is the absence of a handler.
      DabblerFab(
        semanticLabel: 'Create game',
        child: DabblerIcon('add', size: DabblerSizing.iconMd),
      ),
    ],
  ),
);

void _noop() {}
