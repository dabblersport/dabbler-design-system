/// The documentation rail — `KAN-328`, plus the shell half of `KAN-327`, plus
/// the three-level collapsing rail and the collection routing.
///
/// A `part` of `gallery_index.dart`, not a library of its own: everything here
/// is private, so nothing new reaches the barrel (`D-046` — the navigation is
/// gallery chrome, not a component). It composes the gallery's existing page
/// language ([GallerySectionLabel], [GalleryUsage], [GalleryRule]'s hairline)
/// and reuses [GalleryIndexTile]'s press tint through [_Pressable] rather than
/// inventing a second tappable-row interaction. No `Drawer`, no
/// `NavigationRail`, no `ListTile`, no shadow (`D-017`).
///
/// The pieces around it are parts of the same library, and every type in them
/// is private: the shell that holds the rail beside the content pane is
/// `gallery_index_shell.dart`, the row language, filter field and doc pane are
/// `gallery_index_rail_rows.dart`, and the section and group landing pages and
/// the card are `gallery_index_collections.dart`.
part of 'gallery_index.dart';

/// The width at or above which the rail is shown — **D-045**, with `cxo`'s
/// corrected input of 2026-09-18.
///
/// ## Not a token, and private on purpose
///
/// Nothing goes into `DabblerSpacing` or any token file and nothing is
/// exported. The system's five declared thresholds — 480
/// (`DabblerMenu.sheetBreakpoint`), 520 (`DabblerSheet.maxPanelWidth`),
/// 420/340 and 360 (`DabblerDialog`), plus `env(safe-area-inset-bottom)` — are
/// component-PRESENTATION thresholds whose call sites never branch, not a
/// layout scale. `guidelines/measurements.html` says so itself (*"Screen-
/// specific responsive CSS is not part of the measurement foundation and stays
/// with the screen"*) and `guidelines/typography.html:310` confirms it from
/// the other side (*"Typography is intentionally fixed across breakpoints"*).
/// A token here would be reached for by every future responsive component,
/// which is the harm.
///
/// ## The derivation, so it can be checked rather than trusted
///
/// The rail may only appear where the content pane still holds two index
/// tiles:
///
/// ```text
///   600  2 x GalleryIndexTile.width
/// +  15  DabblerSpacing.space5 — the GalleryGroup Wrap gap between them
/// +  48  DabblerSpacing.space8 x 2 — GalleryPaper.bodyPadding
/// + 288  _railWidth
/// +   1  the rail's hairline
/// = 952  floor
/// ```
///
/// **952, not the 951 the ruling computed: the hairline is a 1px divider and
/// the floor rises by it**, exactly as D-045 said it would. 1000 still clears
/// it — content pane 663, two tiles 615, 48px spare rather than 49. 1000
/// itself is ruled rather than measured: no source declares it, it is the
/// first round hundred above the floor.
///
/// The collection pages do not move this threshold: `D-053(b)` made their
/// card [GalleryIndexTile.width] — the same 300 the derivation above is
/// written from — so two across at the floor is the same arithmetic, not a
/// second one.
const double _sideNavBreakpoint = 1000;

/// The rail's width, including its own padding — **D-045**, `cxo` 2026-09-18.
///
/// `cxo` first derived 200 from `DabblerMenu.minPopoverWidth` and then
/// withdrew it: a `Menu` popover holds short command labels (*Edit*,
/// *Duplicate*), while this rail holds page titles from `_order.md`, the
/// longest of which — *Telling the user something happened*, 35 characters —
/// is about 280px of glyphs at `DabblerType.body`. A minimum is not a target.
///
/// 288 sits on the ramp at 12 x 24 (`DabblerSpacing.space8`). That is a
/// property of the number, **not the reason it was chosen**: it was an
/// editorial pick for a comfortable rail, and `cxo`'s own measurement is what
/// justified it afterwards. Recorded that way deliberately.
///
/// Even at 288 the three longest titles still wrap, which [_NavRow] handles
/// deliberately rather than by accident — see there.
const double _railWidth = 288;

/// The rail: `_order.md`'s own section → group → band → entry walk, in the
/// order it is authored in, collapsed to the level the reader is working at.
///
/// ## Three levels, and what a tap on each does
///
/// | level | row | tap |
/// |---|---|---|
/// | section | `Components` | opens the section landing and expands it |
/// | group | `4 · Selection and input` | opens the group landing and expands it |
/// | page | `Select` | opens the document |
///
/// A section or group row that is **already selected** collapses instead, so
/// one gesture both navigates and folds and there is no second hit target
/// competing with the row. The disclosure glyph shows which of the two the
/// next tap will do.
///
/// Before this, group rows had `onTap: () {}` — they were labels wearing a
/// row's clothes. They are destinations now, which is the substance of the
/// collection-page work: a group is a thing you can be *at*, not only a
/// heading above the things you can be at.
class _DocRail extends StatelessWidget {
  const _DocRail({
    required this.order,
    required this.selected,
    required this.expanded,
    required this.filter,
    required this.onToggle,
    required this.onOpen,
    required this.onOpenPage,
  });

  final _DocOrder order;

  /// The current [_PaneTarget.key].
  final String selected;

  /// The keys of expanded sections and groups.
  final Set<String> expanded;

  final TextEditingController filter;
  final void Function(String key) onToggle;
  final void Function(_PaneTarget target) onOpen;
  final void Function(_DocOrderEntry entry) onOpenPage;

  /// Whether [text] matches the current query. An empty query matches
  /// everything, which is what makes the filter additive rather than a mode.
  bool _matches(String text) {
    final String query = filter.text.trim().toLowerCase();
    return query.isEmpty || text.toLowerCase().contains(query);
  }

  bool get _filtering => filter.text.trim().isNotEmpty;

  /// A section is shown while filtering if its own name matches or anything
  /// under it does — otherwise a filter would hide the only row that says
  /// where the matches live.
  bool _sectionVisible(_DocOrderSection section) =>
      _matches(section.title) ||
      section.groups.any(_groupVisible);

  bool _groupVisible(_DocOrderGroup group) =>
      _matches(group.name) ||
      group.entries.any((_DocOrderEntry e) => _matches(e.title));

  /// While filtering every visible level is open: a match hidden inside a
  /// collapsed group is a match the reader cannot see, which is the one
  /// failure a filter must not have.
  bool _isExpanded(String key) => _filtering || expanded.contains(key);

  /// Navigating to a row that is already where you are folds it instead.
  void _rowTap(_PaneTarget target) {
    if (selected == target.key && expanded.contains(target.key)) {
      onToggle(target.key);
      return;
    }
    onOpen(target);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(end: DabblerSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: DabblerSpacing.space4),
            child: _FilterField(controller: filter),
          ),
          _NavRow(
            label: 'All specimens',
            emphasised: true,
            selected: selected == const _CataloguePane().key,
            onTap: () => onOpen(const _CataloguePane()),
          ),
          // `start-here.md` is linked from the file's lead prose rather than
          // from a bullet — the 58th of its 58 links, and the only one under
          // no section. A top-level row is also where a reader expects it.
          if (order.startHere != null && _matches(order.startHere!.title))
            _NavRow(
              label: order.startHere!.title,
              emphasised: true,
              selected: selected == order.startHere!.page,
              onTap: () => onOpen(_PagePane(order.startHere!)),
            ),
          if (order.isUnavailable)
            Padding(
              padding: const EdgeInsets.only(top: DabblerSpacing.space5),
              child: GalleryUsage(
                '**Reading order not available** — ${order.unavailableReason}',
              ),
            ),
          for (final _DocOrderSection section in order.sections)
            if (section.entries.isNotEmpty && _sectionVisible(section))
              ..._section(section),
        ],
      ),
    );
  }

  List<Widget> _section(_DocOrderSection section) {
    final String key = _SectionPane(section).key;
    final bool open = _isExpanded(key);

    return <Widget>[
      const SizedBox(height: DabblerSpacing.space5),
      _NavRow(
        label: section.title,
        emphasised: true,
        expanded: open,
        selected: selected == key,
        onTap: () => _rowTap(_SectionPane(section)),
      ),
      if (open)
        for (final _DocOrderGroup group in section.groups)
          if (_groupVisible(group)) ..._group(section, group),
    ];
  }

  List<Widget> _group(_DocOrderSection section, _DocOrderGroup group) {
    // A section whose bullets hang directly off it (Foundations, Patterns)
    // parses to one implicit group named after the section; drawing a row for
    // it would draw a nesting level the file does not have, so its entries
    // hang off the section row instead.
    final bool implicit = _isImplicitGroup(section, group);
    final String key = _GroupPane(section, group).key;
    final bool open = implicit || _isExpanded(key);

    return <Widget>[
      if (!implicit)
        _NavRow(
          label: group.number == null
              ? group.name
              : '${group.number} · ${group.name}',
          // The authored clause after the heading's em dash — *orienting the
          // user: where they are, and how they move*. It is editorial
          // judgement written into `_order.md` for a reader who does not yet
          // know which group their problem lives in, which is exactly the
          // reader looking at a nav, so it is shown rather than parsed and
          // dropped.
          detail: group.tagline,
          emphasised: true,
          indented: true,
          expanded: open,
          selected: selected == key,
          onTap: () => _rowTap(_GroupPane(section, group)),
        ),
      if (open)
        for (final _DocOrderBand band in group.bands) ...<Widget>[
          if (band.label != null &&
              band.entries.any((_DocOrderEntry e) => _matches(e.title)))
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                DabblerSpacing.space4 + (implicit ? 0 : DabblerSpacing.space4),
                DabblerSpacing.space3,
                0,
                DabblerSpacing.space1,
              ),
              child: GallerySectionLabel(band.label!),
            ),
          for (final _DocOrderEntry entry in band.entries)
            if (_matches(entry.title))
              _NavRow(
                label: entry.title,
                indented: true,
                depth: implicit ? 0 : 1,
                selected: selected == entry.page,
                onTap: () => onOpenPage(entry),
              ),
        ],
    ];
  }
}
