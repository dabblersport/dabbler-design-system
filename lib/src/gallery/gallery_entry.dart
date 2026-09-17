/// The gallery's registration type (KAN-259 AC1).
///
/// [GalleryEntry] used to live in `lib/main.dart`, which made the app shell a
/// dependency of every component that wanted to appear in the gallery — and
/// made `main.dart` the single file every component ticket had to edit. Wave 2
/// ran six tickets in parallel; a shared list in the app entry point is a
/// collision waiting for the next wave.
///
/// It lives under `lib/src/` so a component file can construct its own entries
/// without importing the app, and it is exported from the public barrel so
/// `main.dart` reaches it the same way any other consumer would.
///
/// ## The registration shape
///
/// Each component declares its own entries in a colocated `*_gallery.dart`
/// sibling:
///
/// ```dart
/// // lib/src/controls/fab_gallery.dart
/// const List<GalleryEntry> fabGalleryEntries = <GalleryEntry>[
///   GalleryEntry(title: 'Fab — tones', builder: _tones),
/// ];
/// ```
///
/// and `main.dart` spreads them:
///
/// ```dart
/// const List<GalleryEntry> galleryEntries = <GalleryEntry>[
///   ...fabGalleryEntries,
///   ...bannerGalleryEntries,
/// ];
/// ```
///
/// Adding a component is therefore one added line in `main.dart` and one new
/// file of its own — never an edit to another component's gallery file.
library;

import 'package:flutter/widgets.dart';

/// A single entry in the gallery index.
class GalleryEntry {
  /// Creates an entry.
  const GalleryEntry({
    required this.title,
    required this.builder,
    this.description,
  });

  /// The row label in the index, and the title of the entry's own screen.
  ///
  /// Conventionally `'<Component> — <what this entry shows>'`, so the index
  /// sorts and reads by component.
  final String title;

  /// Builds the entry's body. The gallery supplies the scaffold, the padding
  /// and the scroll view; this builds the specimen and nothing else.
  final WidgetBuilder builder;

  /// One line on what the entry demonstrates, shown above the specimen.
  final String? description;
}
