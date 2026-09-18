/// The catalogue, presented the way the design presents a card page.
///
/// ## What this replaces
///
/// A `ListView` of `ListTile`s with trailing chevrons. That is Material's
/// index idiom, and the design has its own: a band with a small letterspaced
/// uppercase label, and the things themselves laid out as cards in a wrapping
/// grid with air around them — `Group` in every `*.card.html`.
///
/// ## Why the bands are purpose groups (KAN-295)
///
/// This comment used to argue the opposite: that [GalleryEntry] carried no
/// grouping, that the title convention was all there was, and that inventing
/// a taxonomy here would mean editing every component `*_gallery.dart` file.
/// Both halves of that are now false. The taxonomy is not invented — it is
/// `DECISIONS.md` D-033(b)'s nine purpose groups, spelled and ordered by
/// `assets/documentation/_order.md`, which is the reader-journey ordering the
/// documentation itself uses. And editing all 33 gallery files is not a cost
/// to be avoided; it is what KAN-295 did, so each entry now declares its own
/// [GalleryEntry.group] beside its own specimen, in the file that owns it.
///
/// So the catalogue is one band per group, in `_order.md`'s order, preceded
/// by a Foundations band. Foundations come first and are not one of the nine:
/// the nine classify components, and a foundation entry declares
/// `group: null` and is placed by the section its [GalleryEntry.page] names
/// (`foundations/…` versus `components/…`) — the documentation tree's own
/// split, not a tenth group.
///
/// There is no flat list kept alongside this: the grid below is built from
/// the grouping and from nothing else, so an entry with no band would not
/// render at all.
///
/// ## Why the side navigation lives in this file (KAN-328, D-045 / D-046)
///
/// Because [GalleryIndex._bands] is the one derivation of the band list and
/// `cxo` ruled that the navigation must call it rather than derive its own. A
/// second derivation is how D-044 gets undone quietly: that ruling bands
/// foundations on `page.startsWith('foundations/')` and deliberately NOT on
/// `group == null`, and the two predicates are equal today and fail
/// differently tomorrow. One shared private method makes nav/index drift
/// impossible by construction instead of caught afterwards — and a private
/// method can only be shared inside its own library, which is what puts the
/// rail here rather than in a file of its own.
///
/// D-046: gallery chrome, not a component. Nothing here is public beyond what
/// this file already exported, nothing new reaches the barrel, the band
/// headings are [GallerySectionLabel] (its own doc comment says it is exposed
/// separately for exactly this second caller), the rows reuse
/// [GalleryIndexTile]'s press tint through [_Pressable] rather than inventing
/// a second tappable-row interaction, and colour comes from [DabblerColors]
/// by role. D-017 is satisfied by composition: no `Drawer`, no
/// `NavigationRail`, no `ListTile`, no shadow.
library;

// `scheduler.dart` for the post-frame callback that releases the press
// tint — a scheduling mechanism, not a Material appearance. D-017.
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'docs/doc_loader.dart';
import 'docs/doc_page.dart';
import 'docs/doc_specimen_resolver.dart';
import 'docs/doc_view.dart';
import 'gallery_entry.dart';
import 'gallery_page.dart';

part 'gallery_index_order.dart';
part 'gallery_index_rail.dart';
part 'gallery_index_rail_rows.dart';
part 'gallery_index_collections.dart';
part 'gallery_index_shell.dart';

/// The catalogue band: every registered entry as a tappable tile.
class GalleryIndex extends StatelessWidget {
  /// Creates the catalogue.
  const GalleryIndex({super.key, required this.entries, required this.onOpen});

  /// Every registered entry, in registration order.
  final List<GalleryEntry> entries;

  /// Opens one entry's own page.
  final void Function(GalleryEntry entry) onOpen;

  /// The bands, in `_order.md`'s order: foundations, then the nine groups.
  ///
  /// An entry reaches exactly one band. Foundations is chosen by the section
  /// [GalleryEntry.page] names rather than by `group == null` alone, so a
  /// component entry that forgot its group would land nowhere and be visibly
  /// missing rather than quietly filed under foundations.
  List<(String, List<GalleryEntry>)> _bands() {
    final List<GalleryEntry> foundations = entries
        .where((GalleryEntry e) => e.page.startsWith('foundations/'))
        .toList();

    return <(String, List<GalleryEntry>)>[
      if (foundations.isNotEmpty) ('Foundations', foundations),
      for (final GalleryPurpose purpose in GalleryPurpose.values)
        if (entries.any((GalleryEntry e) => e.group == purpose))
          (
            purpose.label,
            entries.where((GalleryEntry e) => e.group == purpose).toList(),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    assert(
      GalleryEntry.duplicateIds(entries).isEmpty,
      'Two gallery entries declare the same id: '
      '${GalleryEntry.duplicateIds(entries)}. An id is what a documentation '
      "page's @specimen line resolves through, so a collision makes that "
      'line ambiguous. Ids are unique across the whole registry, not per '
      'file.',
    );

    if (entries.isEmpty) {
      // Kept from the old index, and still describing a real regression
      // rather than a first-run state: every component failing to register.
      return const GalleryUsage(
        '**No components registered.** Every component contributes its own '
        'entries; an empty catalogue means none of them reached '
        '`galleryEntries`.',
      );
    }

    return _IndexLayout(
      bands: _bands(),
      entries: entries,
      onOpen: onOpen,
    );
  }
}

/// One entry's tile — the design's `.card`: white surface, 1px `--outline-card`
/// border, `--radius-lg`, 16px padding, with the press tint the design's own
/// tappable `Card` describes.
class GalleryIndexTile extends StatelessWidget {
  /// Creates a tile.
  const GalleryIndexTile({super.key, required this.entry, required this.onTap});

  /// The entry this tile opens.
  final GalleryEntry entry;

  /// Opens it.
  final VoidCallback onTap;

  /// The tile's fixed width. Three across a desktop review window, one across
  /// a phone, without a breakpoint: [Wrap] does the reflow.
  static const double width = 300;

  @override
  Widget build(BuildContext context) {
    final (String component, String? subject) = _split(entry.title);
    return _GalleryCard(
      title: component,
      subject: subject,
      description: entry.description,
      semanticLabel: entry.title,
      onTap: onTap,
    );
  }
}

/// ## Releasing the press is deferred to the next frame
///
/// Tapping a tile pushes a route, and pushing a route locks the widget tree
/// while it builds. The gesture arena then resolves the tap and fires
/// `onTapCancel` — during that lock. Marking anything dirty there throws
/// *"setState() called when widget tree was locked"*, which is a real crash
/// rather than a test artefact; `test/gallery_theme_switcher_test.dart` caught
/// it on the very tap that opens an entry.
///
/// Swapping `setState` for a [ValueNotifier] does **not** fix it — a
/// [ValueListenableBuilder] calls `setState` of its own when the value
/// changes, so the throw simply moves. What fixes it is deferring: the release
/// is applied in a post-frame callback, by which time the push has finished
/// and the tree is unlocked. Pressing *down* is never inside a lock, so that
/// edge is applied immediately and the tint still appears at once.
///
/// This was `_GalleryIndexTileState`'s own state until KAN-328. It became a
/// widget of its own so the band rail's rows carry the **same** interaction
/// rather than a second one written beside it (`cxo`, D-046) — the tile and
/// the row now differ only in what they paint.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.onTap,
    required this.builder,
    this.semanticLabel,
  });

  final VoidCallback onTap;
  final Widget Function(BuildContext context, bool pressed) builder;
  final String? semanticLabel;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  /// Clears the press tint once the frame that may be locked has ended.
  void _release() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pressed.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _pressed.value = true,
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ValueListenableBuilder<bool>(
            valueListenable: _pressed,
            builder: (BuildContext context, bool pressed, Widget? child) =>
                widget.builder(context, pressed),
          ),
        ),
      ),
    );
  }
}

/// **The one card treatment in this gallery** — `D-053(b)`.
///
/// ## Why there is exactly one of these
///
/// This was `GalleryIndexTile`'s own build method until `D-053`. The
/// collection pages needed a card too, and `cxo` ruled that **two card
/// treatments in one gallery is the defect** — which file holds the shared one
/// being the implementer's call. It is here because this is where the paint
/// was already written and where the catalogue's tile still reads it from; a
/// sibling written beside it would have been identical by intention and
/// divergent by the first edit.
///
/// The paint is unchanged from the tile, line for line: `--surface-card` on a
/// 1px `--outline-card` border at `--radius-lg`, [DabblerSpacing.space5]
/// padding, [GalleryIndexTile.width], and [_Pressable]'s 90ms
/// `--surface-sunken` press tint.
///
/// ## No fixed height, no `maxLines`, no ellipsis — `D-053(b)`
///
/// Ragged card bottoms are what the catalogue already does, and they are the
/// correct trade: truncating authored prose to tidy a grid spends the payload
/// to buy neatness. A [Wrap] row is as tall as its tallest card and the next
/// row starts below it, which costs nothing but a ragged edge.
///
/// ## [description] is markup, not a string — `D-053(i)`
///
/// It renders through [GalleryUsage], whose type is already this card's
/// description role exactly (`caption1`, `--ink-soft`, height 1.5) and which
/// additionally paints the design's two inline treatments. That is not a
/// flourish: `_order.md:166` writes *"Skeleton, Spinner, ProgressBar or
/// Button's `loading` state"*, and a bare [Text] would paint the backticks.
/// **One of the 57 descriptions is affected** — which is the shape of case a
/// [Text] passes on 56 of and fails on, silently, on the one.
///
/// On a description with no markup the two are identical, so routing the
/// catalogue's own tiles through it is a strict superset and not a change of
/// appearance. [GalleryUsage.maxWidth] is 640 and never binds inside a 300px
/// card.
class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.title,
    required this.onTap,
    this.subject,
    this.description,
    this.semanticLabel,
  });

  /// The card's name, at `callout` in `--ink`.
  final String title;

  /// A second line at `caption1` in `--muted` — the catalogue tile's *what
  /// this entry shows* half. `null` on a collection card, which has no such
  /// half.
  final String? subject;

  /// The authored one-liner, in [GalleryUsage]'s markup. `null` where there
  /// is none.
  final String? description;

  /// The untruncated announcement, where it differs from [title].
  final String? semanticLabel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return _Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel ?? title,
      builder: (BuildContext context, bool pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: GalleryIndexTile.width,
        padding: const EdgeInsets.all(DabblerSpacing.space5),
        decoration: BoxDecoration(
          color: pressed ? colors.surfaceSunken : colors.surfaceCard,
          border: Border.all(color: colors.borderDefault),
          borderRadius: DabblerRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: DabblerType.callout
                  .resolveForDirection(direction)
                  .copyWith(color: colors.textPrimary),
            ),
            if (subject != null) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space1),
              Text(
                subject!,
                style: DabblerType.caption1
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textTertiary),
              ),
            ],
            if (description != null) ...<Widget>[
              const SizedBox(height: DabblerSpacing.space3),
              GalleryUsage(description!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Splits `'<Component> — <what this entry shows>'` into its two halves.
///
/// Falls back to the whole string as the component when an entry does not use
/// the convention, rather than guessing a split point.
(String, String?) _split(String title) {
  const String separator = ' — ';
  final int at = title.indexOf(separator);
  if (at < 0) return (title, null);
  return (title.substring(0, at), title.substring(at + separator.length));
}
