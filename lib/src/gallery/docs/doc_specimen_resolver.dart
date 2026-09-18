/// Binds a page's `@specimen <id>` lines to live [GalleryEntry] specimens —
/// `T-085` part 3's second half, unblocked by `KAN-295`'s stable `id`.
///
/// ## Resolution is by id, and only by id
///
/// **Never derive a specimen from the page it appears on.** The doc→entry
/// relation is many-to-one: 58 entries cover 45 pages, and 12 documentation
/// pages have no entry naming them at all. Nine are components folded into a
/// combined specimen — `radio.md` and `toggle.md` are demonstrated by
/// `checkbox/selection-controls`, `stepper.md` by `slider/value-controls`,
/// `date-field.md`/`time-field.md`/`code-input.md`/`picker-field-shell.md` by
/// `picker-field/pickers`, `card-pricing.md`/`card-ticket.md` by
/// `card-house/composed`. The other three are the `patterns/` pages, which
/// arbitrate between components and have no specimen by nature.
///
/// A resolver that inferred the entry from the page path would appear correct on
/// the 33 pages where the two happen to coincide and fail silently on exactly
/// the 12 where the indirection is the whole point. So the `@specimen`
/// argument is read, and nothing else is.
///
/// **A page with no entry is not an error.** It is the expected state for 12 of
/// the 59 pages. Only an `@specimen` line naming an id no entry declares is a
/// finding, and it is a visible one — never a throw.
library;

import '../gallery_entry.dart';
import 'doc_page.dart';

/// Looks up [GalleryEntry] specimens by the id a doc page references.
class DabblerDocSpecimenResolver {
  /// Builds a resolver over [entries].
  ///
  /// The list is supplied by the caller rather than read from a global: the
  /// canonical `galleryEntries` lives in `lib/main.dart`, which is the gallery
  /// app and not part of this package's library surface.
  DabblerDocSpecimenResolver(List<GalleryEntry> entries)
      : _byId = <String, GalleryEntry>{
          for (final GalleryEntry entry in entries) entry.id: entry,
        };

  final Map<String, GalleryEntry> _byId;

  /// The entry declaring [id], or `null` when nothing does.
  GalleryEntry? resolve(String id) => _byId[id];

  /// Whether [id] resolves.
  bool canResolve(String id) => _byId.containsKey(id);

  /// Every id [page] references that nothing declares, in document order,
  /// deduplicated.
  ///
  /// This is the shape `KAN-324`'s gate wants: it reads the same ids the
  /// renderer reads, from the same parse, so a page cannot render a missing
  /// specimen that the gate considers fine.
  List<String> unresolvedIds(DabblerDocPage page) {
    final Set<String> seen = <String>{};
    return <String>[
      for (final String id in page.specimenIds)
        if (!canResolve(id) && seen.add(id)) id,
    ];
  }

  /// The visible text rendered in place of an id that does not resolve.
  ///
  /// Kept here rather than in the widget so the gate can assert on the same
  /// string the reader sees.
  static String missingSpecimenMessage(String id) =>
      '**Specimen not found** — no gallery entry declares the id `$id`.';
}
