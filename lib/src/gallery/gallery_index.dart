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
library;

// `scheduler.dart` for the post-frame callback that releases the press
// tint — a scheduling mechanism, not a Material appearance. D-017.
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'gallery_entry.dart';
import 'gallery_page.dart';

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

    return GallerySections(
      children: <Widget>[
        const GalleryUsage(
          '**The Dabbler design system.** Every specimen below renders under '
          'the theme and brightness chosen above — seven section themes across '
          'two brightnesses, fourteen palettes in all. Open a tile to see that '
          'component on its own page.',
        ),
        for (final (String name, List<GalleryEntry> band) in _bands())
          GalleryGroup(
            name: '$name (${band.length})',
            children: <Widget>[
              for (final GalleryEntry entry in band)
                GalleryIndexTile(entry: entry, onTap: () => onOpen(entry)),
            ],
          ),
      ],
    );
  }
}

/// One entry's tile — the design's `.card`: white surface, 1px `--outline-card`
/// border, `--radius-lg`, 16px padding, with the press tint the design's own
/// tappable `Card` describes.
class GalleryIndexTile extends StatefulWidget {
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
  State<GalleryIndexTile> createState() => _GalleryIndexTileState();
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
class _GalleryIndexTileState extends State<GalleryIndexTile> {
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
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final (String component, String? subject) = _split(widget.entry.title);

    return Semantics(
      button: true,
      label: widget.entry.title,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  width: GalleryIndexTile.width,
                  padding: const EdgeInsets.all(DabblerSpacing.space5),
                  decoration: BoxDecoration(
                    color: pressed ? colors.surfaceSunken : colors.surfaceCard,
                    border: Border.all(color: colors.borderDefault),
                    borderRadius: DabblerRadius.lgAll,
                  ),
                  child: child,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  component,
                  style: DabblerType.callout
                      .resolveForDirection(direction)
                      .copyWith(color: colors.textPrimary),
                ),
                if (subject != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space1),
                  Text(
                    subject,
                    style: DabblerType.caption1
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
                if (widget.entry.description != null) ...<Widget>[
                  const SizedBox(height: DabblerSpacing.space3),
                  Text(
                    widget.entry.description!,
                    style: DabblerType.caption1
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textSecondary, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
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
