/// The collection pages — a landing page for every section and every group.
///
/// ## What the CEO asked for, and what it means structurally
///
/// > *"Collect the things related to each other, like the [cloth] design in
/// > the section. Refer to the link."* — the Apple HIG's *Getting started*.
///
/// Rendered and observed rather than inferred, that reference has **three**
/// page kinds, and only the third existed here before this file:
///
/// | kind | example there | collects | built by |
/// |---|---|---|---|
/// | SECTION landing | `Components` | one card per **group** | [_SectionLanding] |
/// | GROUP landing | `Content` | one card per **page** | [_GroupLanding] |
/// | PAGE | `Charts` | the document itself | `_DocPane` |
///
/// The taxonomy is not invented for this file and nothing here re-derives it:
/// the three levels are `_order.md`'s own `## ` section → `### ` group →
/// bullet walk, already parsed by [_DocOrder]. This file only lays that walk
/// out as pages.
///
/// ## The group level is COMPONENTS-ONLY — `D-053(f)`, verified in the file
///
/// `Foundations` and `Patterns` carry their bullets directly under the `## `
/// with no `### ` above them, and [_OrderBuilder] gives each of those one
/// implicit group named after its own section. A section landing that showed
/// "one card per group" literally would therefore draw `Foundations` a single
/// card reading *Foundations*, which is a page linking to itself. So
/// [_SectionLanding] tests for exactly that shape and collects the section's
/// **pages** instead — which is also what the reference does, where a section
/// with no sub-grouping lists its pages directly.
///
/// ## What a card shows was ruled, not chosen here — `D-053`
///
/// This file previously left the card's content as an open seam with a
/// deliberately empty picture in it, because `cxo` was ruling on it. It has:
///
/// - **(a) no card renders a live specimen, ever.** A specimen is a
///   demonstration body — several variants down an unbounded column, five of
///   them declaring interactive state — and there is no smaller thing behind
///   it. All three ways to fit one into a 300px card are defects: scaling lies
///   about measurement, clipping shows one variant of five with no sign the
///   rest exist, and self-sizing means it is not a grid. The settling argument
///   is `D-046`'s reached from the other side — a draggable `Slider` inside a
///   card whose whole surface navigates on tap is two affordances fighting
///   over one region.
/// - **(b) the card is `GalleryIndexTile`'s paint**, which is why there is now
///   exactly one of them — see [_GalleryCard].
/// - **(c) a GROUP card carries a page's title and that page's `_order.md`
///   one-liner.** Those 57 authored descriptions were parsed onto
///   [_DocOrderEntry.description] and painted **nowhere in the product**: the
///   rail paints the nine group *taglines* and no per-page line at all. The
///   card is their first surface, not a repetition of one.
/// - **(d) a SECTION card carries `'N · Name'` and the group's tagline.** The
///   ordinal stays: a card grid loses the `D-033(b)` reader-journey sequence
///   that a vertical rail preserves, and the number is the only thing left
///   carrying it.
/// - **(e) the 13 specimen-less pages get ordinary cards, with no special
///   case.** `doc_specimen_resolver.dart`'s own header explains why: a
///   page-derived inference "would appear correct on the 33 pages where the two
///   coincide and fail silently on exactly the 12 where the indirection is the
///   whole point" — and a specimen-bearing card is that same wrong inference
///   made in paint. A design needing a special case on a fifth of its
///   instances has misunderstood its subject.
///
/// Every card here reads `_order.md` and nothing else — no page-asset
/// fan-out, and so no dependency on the documentation renderer's four open
/// gaps (`KAN-330`), which would otherwise reach the cards through the pages.
///
/// `D-046`: gallery chrome, not a component. Every type below is private and
/// this is a `part`, so nothing reaches the barrel. `D-017`: no `Card`, no
/// `GridView`, no `Material`, no shadow — the surface is [_GalleryCard], which
/// is the catalogue tile's own paint.
part of 'gallery_index.dart';

/// What the content pane is showing.
///
/// A sealed family rather than a nullable `_DocOrderEntry`, because the pane
/// now has four states and three of them are not a page. [key] is what the
/// rail compares against to mark a row selected — one string per destination,
/// so the rail never has to know which variant it is looking at.
sealed class _PaneTarget {
  const _PaneTarget();

  /// The rail's selection key. Distinct across every reachable destination.
  String get key;
}

/// The catalogue of specimens — the gallery's original home pane.
class _CataloguePane extends _PaneTarget {
  const _CataloguePane();

  @override
  String get key => '@catalogue';
}

/// A section landing page.
class _SectionPane extends _PaneTarget {
  const _SectionPane(this.section);

  final _DocOrderSection section;

  @override
  String get key => '@section/${section.title}';
}

/// A group landing page.
class _GroupPane extends _PaneTarget {
  const _GroupPane(this.section, this.group);

  final _DocOrderSection section;
  final _DocOrderGroup group;

  @override
  String get key => '@group/${section.title}/${group.name}';
}

/// One documentation page.
class _PagePane extends _PaneTarget {
  const _PagePane(this.entry);

  final _DocOrderEntry entry;

  @override
  String get key => entry.page;
}

/// Whether [group] is the implicit one `_OrderBuilder` synthesises for a
/// section that carries its bullets directly.
///
/// The predicate is the same one `_DocRail._section` already uses to decide
/// not to draw a redundant nesting level, and it is spelled once here so the
/// rail and the landing pages cannot disagree about which sections have
/// groups.
bool _isImplicitGroup(_DocOrderSection section, _DocOrderGroup group) =>
    group.name == section.title;

/// A section's real groups, or an empty list where it has none.
List<_DocOrderGroup> _realGroups(_DocOrderSection section) => section.groups
    .where((_DocOrderGroup g) => !_isImplicitGroup(section, g))
    .toList();

/// The heading block every collection page opens with.
///
/// [GalleryPageHeader] is the *app* header and already sits above the pane, so
/// a second one would draw two title rows. This is the page-level heading
/// instead: the name at `title2`, the authored tagline under it, then the
/// section or group intro as ordinary [GalleryUsage] prose.
class _CollectionHeading extends StatelessWidget {
  const _CollectionHeading({
    required this.title,
    required this.intro,
    this.tagline,
  });

  final String title;
  final String? tagline;
  final List<String> intro;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: DabblerType.title2
              .resolveForDirection(direction)
              .copyWith(color: colors.textPrimary),
        ),
        if (tagline != null) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space2),
          Text(
            tagline!,
            style: DabblerType.callout
                .resolveForDirection(direction)
                .copyWith(color: colors.textTertiary),
          ),
        ],
        for (final String paragraph in intro) ...<Widget>[
          const SizedBox(height: DabblerSpacing.space4),
          GalleryUsage(paragraph),
        ],
      ],
    );
  }
}

/// A section landing page: a grid of cards, one per group.
///
/// Where the section has no real groups — `Foundations`, `Patterns` — it
/// collects that section's **pages** instead. See the library comment: a
/// literal reading would draw one card pointing at the page you are already on.
class _SectionLanding extends StatelessWidget {
  const _SectionLanding({
    required this.section,
    required this.onOpenGroup,
    required this.onOpenPage,
  });

  final _DocOrderSection section;
  final void Function(_DocOrderGroup group) onOpenGroup;
  final void Function(_DocOrderEntry entry) onOpenPage;

  @override
  Widget build(BuildContext context) {
    final List<_DocOrderGroup> groups = _realGroups(section);

    return GallerySections(
      children: <Widget>[
        _CollectionHeading(title: section.title, intro: section.intro),
        if (groups.isEmpty)
          _CardGrid(
            children: <Widget>[
              for (final _DocOrderEntry entry in section.entries)
                _GalleryCard(
                  title: entry.title,
                  description: entry.description,
                  onTap: () => onOpenPage(entry),
                ),
            ],
          )
        else
          _CardGrid(
            children: <Widget>[
              for (final _DocOrderGroup group in groups)
                _GalleryCard(
                  // D-053(d): the ordinal stays. A vertical rail carries the
                  // D-033(b) reader-journey sequence by its own order; a card
                  // grid does not, and the number is then the only thing left
                  // that does. `number` is null only for an implicit group,
                  // which never reaches this branch.
                  title: group.number == null
                      ? group.name
                      : '${group.number} · ${group.name}',
                  description: group.tagline,
                  onTap: () => onOpenGroup(group),
                ),
            ],
          ),
      ],
    );
  }
}

/// A group landing page: a grid of cards, one per page in that group.
///
/// `_order.md`'s inner band labels (`**Shells**`, `**Composed cards**`) are
/// kept: they are an authored split inside group 2 and dropping them here
/// would lose editorial structure the file went to the trouble of writing.
class _GroupLanding extends StatelessWidget {
  const _GroupLanding({required this.group, required this.onOpenPage});

  final _DocOrderGroup group;
  final void Function(_DocOrderEntry entry) onOpenPage;

  @override
  Widget build(BuildContext context) {
    return GallerySections(
      children: <Widget>[
        _CollectionHeading(
          title: group.number == null
              ? group.name
              : '${group.number} · ${group.name}',
          tagline: group.tagline,
          intro: group.intro,
        ),
        for (final _DocOrderBand band in group.bands)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (band.label != null) ...<Widget>[
                GallerySectionLabel(band.label!),
                const SizedBox(height: DabblerSpacing.space4),
              ],
              _CardGrid(
                children: <Widget>[
                  for (final _DocOrderEntry entry in band.entries)
                    _GalleryCard(
                      title: entry.title,
                      // D-053(c): these 57 authored one-liners are parsed by
                      // `_order.md`'s reader and painted nowhere else in the
                      // product — the rail paints the nine group taglines and
                      // no per-page line at all. This is their first surface.
                      description: entry.description,
                      onTap: () => onOpenPage(entry),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

/// The wrapping card grid.
///
/// A [Wrap], not a `GridView`: the column count is a consequence of the pane's
/// width and the card's, which is how [GalleryGroup] already reflows and how
/// the design's own `Group` body works (`flex;gap;wrap`). No `GridView`, no
/// `SliverGridDelegate`, no breakpoint.
///
/// ## The column count is not a target — `D-053(b)`
///
/// The reference happens to show three across, and an earlier draft of this
/// file derived a 320px card from that figure. `cxo` ruled it a **viewport
/// coincidence**: three-up at 1400px is what 1400px does to Apple's card, not
/// a property of a card. The width is [GalleryIndexTile.width] — 300, the
/// catalogue's own — and the [Wrap] decides the rest. Two per row just above
/// the rail breakpoint is the correct answer there, not a degraded one.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DabblerSpacing.space5,
      runSpacing: DabblerSpacing.space5,
      children: children,
    );
  }
}
