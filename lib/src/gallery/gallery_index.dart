/// The catalogue, presented the way the design presents a card page.
///
/// ## What this replaces
///
/// A `ListView` of `ListTile`s with trailing chevrons. That is Material's
/// index idiom, and the design has its own: a band with a small letterspaced
/// uppercase label, and the things themselves laid out as cards in a wrapping
/// grid with air around them — `Group` in every `*.card.html`.
///
/// ## Why one tile per entry, in one band
///
/// The design's own bands (`SHELLS`, `KIT COMPOSITIONS`, `TICKET`) group by
/// what a specimen *is*, and [GalleryEntry] carries no such grouping — the
/// title's `'<Component> — <what it shows>'` convention is all there is, and
/// inventing an area taxonomy here would mean editing all 24 component
/// `*_gallery.dart` files to declare one. Those files belong to their
/// components, not to the gallery shell.
///
/// So the catalogue is one band of equal tiles in title order, which is
/// alphabetical by component and therefore already puts a component's entries
/// next to each other. The tile itself carries the split: the component name
/// reads as the tile's title and the rest of the entry title as its subject,
/// so the grid scans by component without a taxonomy existing.
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

  @override
  Widget build(BuildContext context) {
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
        GalleryGroup(
          name: 'Components (${entries.length})',
          children: <Widget>[
            for (final GalleryEntry entry in entries)
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
