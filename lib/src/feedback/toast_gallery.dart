/// Gallery entries for [DabblerToast] (KAN-259 AC2).
///
/// A toast is an overlay: it is shown through [DabblerToasts], which needs a
/// [DabblerToastProvider] above it. The gallery app installs one at its root,
/// so these entries are triggers rather than inline specimens — rendering a
/// toast in place would show the chrome without the behaviour.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'toast.dart';

/// Toast's specimens.
const List<GalleryEntry> toastGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'toast/tones',
    page: 'components/toast',
    group: GalleryPurpose.statusAndFeedback,
    title: 'Toast — tones (trigger)',
    description: 'Each button shows a real toast through DabblerToasts, '
        'queued and capped by the controller the app installs.',
    builder: _toasts,
  ),
];

Widget _toasts(BuildContext context) => GalleryStack(
  children: <Widget>[
    GalleryWrap(
      children: <Widget>[
        for (final DabblerToastTone tone in DabblerToastTone.values)
          GallerySpecimen(
            label: tone.name,
            child: DabblerButton(
              label: 'Show ${tone.name}',
              onPressed: () => DabblerToasts.show(
                DabblerToastSpec(message: 'Game saved.', tone: tone),
              ),
            ),
          ),
      ],
    ),
    GallerySpecimen(
      label: 'with action',
      child: DabblerButton(
        label: 'Show with action',
        onPressed: () => DabblerToasts.show(
          DabblerToastSpec(
            message: 'Game cancelled.',
            tone: DabblerToastTone.warning,
            action: DabblerToastAction(label: 'Undo', onPressed: () {}),
          ),
        ),
      ),
    ),
    const GallerySpecimen(
      label: 'the widget itself, out of the overlay',
      child: DabblerToast(message: 'Game saved.'),
    ),
  ],
);
