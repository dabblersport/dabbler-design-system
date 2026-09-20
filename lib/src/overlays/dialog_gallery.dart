/// Gallery entries for [DabblerDialog] (KAN-259 AC2).
///
/// A dialog is a route. These entries push a real one rather than rendering
/// the panel inline, so the scrim, the focus trap and the dismiss behaviour
/// are what the reviewer actually sees.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'dialog.dart';

/// Dialog's specimens.
const List<GalleryEntry> dialogGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'dialog/sizes',
    page: 'components/dialog',
    group: GalleryPurpose.presentation,
    title: 'Dialog — sizes (trigger)',
    description: 'Every DabblerDialogSize, pushed as a real route.',
    builder: _dialogs,
  ),
];

Widget _dialogs(BuildContext context) => GalleryWrap(
  children: <Widget>[
    for (final DabblerDialogSize size in DabblerDialogSize.values)
      GallerySpecimen(
        label: size.name,
        child: Builder(
          builder: (BuildContext context) => DabblerButton(
            label: 'Open ${size.name}',
            onPressed: () => showDabblerDialog<void>(
              context: context,
              builder: (BuildContext context) => DabblerDialog(
                size: size,
                title: 'Leave this game?',
                description: 'Your spot goes back to the pool.',
                onClose: () => Navigator.of(context).pop(),
                // Leaving a game is destructive, so the flag paints the
                // primary action rather than a hand-picked tone.
                destructive: true,
                secondaryAction: DabblerDialogAction(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                primaryAction: DabblerDialogAction(
                  label: 'Leave',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
  ],
);
