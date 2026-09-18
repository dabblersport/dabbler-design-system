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
///   GalleryEntry(
///     id: 'fab/tones',
///     page: 'components/fab',
///     group: GalleryPurpose.actions,
///     title: 'Fab — tones',
///     builder: _tones,
///   ),
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

/// The nine purpose groups, fixed by `DECISIONS.md` D-033(b).
///
/// Closed by construction: an entry either names one of these nine or names
/// none at all. There is no tenth value and no free-text escape, which is what
/// KAN-295 AC1 asks for.
///
/// The nine classify **components**. Foundation entries — colour, type,
/// spacing, motion, themes, icons, sports, interaction, bidirectionality —
/// are not components and are deliberately not forced into one; they declare
/// `group: null` and are grouped by the section their [GalleryEntry.page]
/// names instead. That split is the documentation tree's own
/// (`assets/documentation/{foundations,components,patterns}/`), not an
/// invention here.
enum GalleryPurpose {
  /// Orienting the user: where they are, and how they move.
  navigation('Navigation'),

  /// Holding what you show: the shells and the composed cards built on them.
  contentContainers('Content containers'),

  /// Who or what a piece of content is.
  identityAndStatus('Identity and status'),

  /// Capturing what the user tells you.
  selectionAndInput('Selection and input'),

  /// The one input concern too large to fold into the last group.
  dateAndTime('Date and time'),

  /// Letting the user act.
  actions('Actions'),

  /// Surfacing more than the flow can hold.
  presentation('Presentation'),

  /// Telling the user what happened.
  statusAndFeedback('Status and feedback'),

  /// The one thing that separates, and nothing else.
  structure('Structure');

  const GalleryPurpose(this.label);

  /// The band label, spelled as `assets/documentation/_order.md` spells it.
  final String label;
}

/// A single entry in the gallery index.
class GalleryEntry {
  /// Creates an entry.
  const GalleryEntry({
    required this.id,
    required this.page,
    required this.group,
    required this.title,
    required this.builder,
    this.description,
  });

  /// The entry's stable identity — what a documentation page names in its
  /// `@specimen <id>` line (D-041(b), `T-085`).
  ///
  /// Deliberately **not** derived from [title]: the title is prose that `cxo`
  /// and `content-manager` revise, and an id keyed on it would break on every
  /// improvement.
  ///
  /// The scheme, derived from the filenames already under
  /// `assets/documentation/`: `<page-slug>` where a component has exactly one
  /// entry, and `<page-slug>/<axis-slug>` where it has more than one or the
  /// entry demonstrates a named axis. `<page-slug>` is always the basename of
  /// the page this entry's [page] names, so an id and its page are readable
  /// off each other.
  ///
  /// Unique across the registry. Duplicates are caught by
  /// [duplicateIds], which the index asserts on in debug builds.
  final String id;

  /// The documentation page this entry is the specimen for, as a path under
  /// `assets/documentation/` with the `.md` dropped — `'components/button'`,
  /// `'foundations/colour'`.
  ///
  /// Every value resolves to a file that exists on disk; that is the whole
  /// point of the field, and is why the scheme is the filenames rather than a
  /// parallel vocabulary.
  ///
  /// One page per entry, not one entry per page. Several entries may name the
  /// same page (`Button` has two), and a page may have no entry naming it —
  /// a documentation page whose specimen lives inside a combined entry
  /// resolves the other way, by naming that entry's [id].
  final String page;

  /// The purpose group, or `null` for a foundation entry.
  ///
  /// Required rather than optional: every entry states its group, and a
  /// foundation entry states that it has none. See [GalleryPurpose].
  final GalleryPurpose? group;

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

  /// Every [id] that more than one of [entries] declares.
  ///
  /// Empty is the only correct answer: two entries resolving to one id means
  /// a documentation page's `@specimen` line is ambiguous. [GalleryIndex]
  /// asserts on this, so every widget test that pumps the index checks it.
  static Set<String> duplicateIds(List<GalleryEntry> entries) {
    final Set<String> seen = <String>{};
    final Set<String> duplicates = <String>{};
    for (final GalleryEntry entry in entries) {
      if (!seen.add(entry.id)) duplicates.add(entry.id);
    }
    return duplicates;
  }
}
