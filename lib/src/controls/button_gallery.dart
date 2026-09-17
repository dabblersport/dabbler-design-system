/// Gallery entries for [DabblerButton] (KAN-259 AC2).
///
/// Colocated with the component, so adding or changing Button's specimens
/// touches this file and nothing else.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'button.dart';

/// Button's specimens.
const List<GalleryEntry> buttonGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Button — tones',
    description: 'Every DabblerButtonTone at the default medium size.',
    builder: _tones,
  ),
  GalleryEntry(
    title: 'Button — sizes and states',
    description: 'The three sizes, plus disabled, loading and full-width.',
    builder: _states,
  ),
];

Widget _tones(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerButtonTone tone in DabblerButtonTone.values)
      if (tone != DabblerButtonTone.icon)
        GallerySpecimen(
          label: tone.name,
          child: DabblerButton(label: 'Join game', tone: tone, onPressed: _noop),
        ),
    const GallerySpecimen(
      label: 'icon',
      child: DabblerButton.icon(
        icon: 'heart',
        semanticLabel: 'Favourite',
        onPressed: _noop,
      ),
    ),
  ],
);

Widget _states(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerButtonSize size in DabblerButtonSize.values)
          GallerySpecimen(
            label: size.name,
            child: DabblerButton(
              label: 'Join game',
              size: size,
              onPressed: _noop,
            ),
          ),
      ],
    ),
    const GalleryWrap(
      children: <Widget>[
        GallerySpecimen(
          label: 'disabled',
          child: DabblerButton(label: 'Join game', disabled: true),
        ),
        GallerySpecimen(
          label: 'loading',
          child: DabblerButton(label: 'Join game', loading: true),
        ),
      ],
    ),
    const GallerySpecimen(
      label: 'fullWidth',
      child: DabblerButton(label: 'Join game', fullWidth: true),
    ),
  ],
);

void _noop() {}
