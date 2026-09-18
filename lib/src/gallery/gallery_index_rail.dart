/// The documentation rail — `KAN-328`, plus the shell half of `KAN-327`.
///
/// A `part` of `gallery_index.dart`, not a library of its own: everything here
/// is private, so nothing new reaches the barrel (`D-046` — the navigation is
/// gallery chrome, not a component). It composes the gallery's existing page
/// language ([GallerySectionLabel], [GalleryUsage], [GalleryRule]'s hairline)
/// and reuses [GalleryIndexTile]'s press tint through [_Pressable] rather than
/// inventing a second tappable-row interaction. No `Drawer`, no
/// `NavigationRail`, no `ListTile`, no shadow (`D-017`).
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

/// The catalogue, with the documentation rail beside it above
/// [_sideNavBreakpoint].
///
/// **Below the breakpoint the rail does not render and NOTHING replaces it**
/// — no drawer, no hamburger, no off-canvas pane (D-045(c)). The reason is not
/// stylistic: the index below already *is* a sectioned navigation
/// ([GalleryIndex._bands]), so a slide-over would put a second copy of it over
/// a screen already showing it.
class _IndexLayout extends StatefulWidget {
  const _IndexLayout({
    required this.bands,
    required this.entries,
    required this.onOpen,
  });

  final List<(String, List<GalleryEntry>)> bands;

  /// Every registered entry — what a doc page's `@specimen` lines resolve
  /// through.
  final List<GalleryEntry> entries;

  final void Function(GalleryEntry entry) onOpen;

  @override
  State<_IndexLayout> createState() => _IndexLayoutState();
}

class _IndexLayoutState extends State<_IndexLayout> {
  static const DabblerDocLoader _loader = DabblerDocLoader();

  late final Future<_DocOrder> _order = _loadOrder();
  late final DabblerDocSpecimenResolver _resolver =
      DabblerDocSpecimenResolver(widget.entries);

  /// The documentation page the pane is showing, or `null` for the catalogue.
  _DocOrderEntry? _page;

  Future<_DocOrder> _loadOrder() async {
    final String? raw = await _loader.loadRaw(_DocOrder.assetName);
    if (raw == null) {
      return _DocOrder.unavailable(
        'the bundle has no `assets/documentation/${_DocOrder.assetName}`',
      );
    }
    return _DocOrder.parse(raw);
  }

  /// The catalogue: the index exactly as it is without a rail.
  Widget _catalogue() {
    return GallerySections(
      children: <Widget>[
        const GalleryUsage(
          '**The Dabbler design system.** Every specimen below renders under '
          'the theme and brightness chosen above — seven section themes across '
          'two brightnesses, fourteen palettes in all. Open a tile to see that '
          'component on its own page.',
        ),
        for (final (String name, List<GalleryEntry> band) in widget.bands)
          GalleryGroup(
            name: '$name (${band.length})',
            children: <Widget>[
              for (final GalleryEntry entry in band)
                GalleryIndexTile(
                  entry: entry,
                  onTap: () => widget.onOpen(entry),
                ),
            ],
          ),
      ],
    );
  }

  /// The pane swaps rather than the navigator pushing: a pushed route covers
  /// the whole screen, rail included, and a rail the reader loses the moment
  /// they use it is not a rail.
  Widget _pane() {
    final _DocOrderEntry? page = _page;
    if (page == null) {
      return SingleChildScrollView(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: _catalogue(),
        ),
      );
    }
    return _DocPane(
      key: ValueKey<String>(page.page),
      entry: page,
      loader: _loader,
      resolver: _resolver,
      onClose: () => setState(() => _page = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // GalleryPaper's padding is already outside this widget, so it is
        // added back rather than the constant being adjusted: the threshold
        // is a viewport figure.
        final double viewport =
            constraints.maxWidth + GalleryPaper.bodyPadding.horizontal;
        if (viewport < _sideNavBreakpoint) {
          return SingleChildScrollView(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: _catalogue(),
            ),
          );
        }

        return FutureBuilder<_DocOrder>(
          future: _order,
          builder: (BuildContext context, AsyncSnapshot<_DocOrder> snapshot) {
            final _DocOrder? order = snapshot.data;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: _railWidth,
                  child: order == null
                      ? const SizedBox.shrink()
                      : _DocRail(
                          order: order,
                          selected: _page?.page,
                          onOpen: (_DocOrderEntry entry) =>
                              setState(() => _page = entry),
                          onCatalogue: () => setState(() => _page = null),
                        ),
                ),
                // GalleryRule's hairline, drawn on the other axis: separation
                // is a 1px line in `--outline-card`, never a shadow (D-046).
                SizedBox(
                  width: 1,
                  child: ColoredBox(
                    color: DabblerColors.of(context).borderDefault,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: DabblerSpacing.space8,
                    ),
                    child: _pane(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// The rail: `_order.md`'s own section -> group -> band -> entry walk, in the
/// order it is authored in.
class _DocRail extends StatelessWidget {
  const _DocRail({
    required this.order,
    required this.selected,
    required this.onOpen,
    required this.onCatalogue,
  });

  final _DocOrder order;

  /// The page path currently in the pane, or `null` for the catalogue.
  final String? selected;

  final void Function(_DocOrderEntry entry) onOpen;
  final VoidCallback onCatalogue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(end: DabblerSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NavRow(
            label: 'All specimens',
            emphasised: true,
            selected: selected == null,
            onTap: onCatalogue,
          ),
          // `start-here.md` is linked from the file's lead prose rather than
          // from a bullet — the 58th of its 58 links, and the only one under
          // no section. A top-level row is also where a reader expects it.
          if (order.startHere != null)
            _NavRow(
              label: order.startHere!.title,
              emphasised: true,
              selected: selected == order.startHere!.page,
              onTap: () => onOpen(order.startHere!),
            ),
          if (order.isUnavailable)
            Padding(
              padding: const EdgeInsets.only(top: DabblerSpacing.space5),
              child: GalleryUsage(
                '**Reading order not available** — ${order.unavailableReason}',
              ),
            ),
          for (final _DocOrderSection section in order.sections)
            if (section.entries.isNotEmpty) ..._section(section),
        ],
      ),
    );
  }

  List<Widget> _section(_DocOrderSection section) {
    return <Widget>[
      const SizedBox(height: DabblerSpacing.space6),
      Padding(
        padding: const EdgeInsets.only(bottom: DabblerSpacing.space3),
        child: GallerySectionLabel(section.title),
      ),
      for (final _DocOrderGroup group in section.groups) ...<Widget>[
        // A section whose bullets hang directly off it (Foundations,
        // Patterns) parses to one implicit group named after the section;
        // repeating that name would draw a nesting level the file does not
        // have.
        if (group.name != section.title)
          _NavRow(
            label: group.number == null
                ? group.name
                : '${group.number} · ${group.name}',
            // The authored clause after the heading's em dash — *orienting
            // the user: where they are, and how they move*. It is editorial
            // judgement written into `_order.md` for a reader who does not
            // yet know which group their problem lives in, which is exactly
            // the reader looking at a nav, so it is shown rather than parsed
            // and dropped.
            detail: group.tagline,
            emphasised: true,
            selected: false,
            onTap: () {},
          ),
        for (final _DocOrderBand band in group.bands) ...<Widget>[
          if (band.label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DabblerSpacing.space4,
                DabblerSpacing.space3,
                0,
                DabblerSpacing.space1,
              ),
              child: GallerySectionLabel(band.label!),
            ),
          for (final _DocOrderEntry entry in band.entries)
            _NavRow(
              label: entry.title,
              indented: true,
              selected: selected == entry.page,
              onTap: () => onOpen(entry),
            ),
        ],
      ],
    ];
  }
}

/// One rail row.
///
/// ## The wrap is deliberate, which is the whole point
///
/// At a 288 rail a third-level row has about 252px of text, and the three
/// longest titles — *Telling the user something happened* is the worst at
/// ~280px — do not fit on one line. `cxo` ruled that a two-line row is
/// acceptable and an **accidental** one is not, and left the mechanism here.
///
/// The mechanism chosen is **wrap to at most two lines, then ellipsize**, with
/// the full title always on the [Semantics] node. Two lines because the titles
/// are prose and their tail is what distinguishes them (*Telling the user
/// something happened* versus *Nothing to show*) — a one-line ellipsis would
/// cut exactly the distinguishing half. The ellipsis is the floor under it, so
/// a longer title added tomorrow degrades visibly rather than silently
/// clipping, and a screen reader is never given the truncated string.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
    this.emphasised = false,
    this.indented = false,
  });

  final String label;

  /// A second line under [label] — a group's authored tagline. Held to the
  /// same two-line rule as the label itself.
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  /// A group heading or a top-level destination: ink rather than soft ink.
  final bool emphasised;

  /// A leaf under a group.
  final bool indented;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);

    return _Pressable(
      onTap: onTap,
      // The untruncated strings, so an ellipsis is never what a screen reader
      // is given.
      semanticLabel: detail == null ? label : '$label. $detail',
      builder: (BuildContext context, bool pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        padding: EdgeInsetsDirectional.fromSTEB(
          indented ? DabblerSpacing.space4 : DabblerSpacing.space3,
          DabblerSpacing.space2,
          DabblerSpacing.space3,
          DabblerSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: pressed || selected ? colors.surfaceSunken : null,
          borderRadius: DabblerRadius.smAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DabblerType.footnote
                  .resolveForDirection(direction)
                  .copyWith(
                    color: selected || emphasised
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: selected || emphasised
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
            ),
            if (detail != null)
              Text(
                detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: DabblerType.caption2
                    .resolveForDirection(direction)
                    .copyWith(color: colors.textTertiary, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }
}

/// One documentation page in the content pane.
///
/// The render itself is [DabblerDocPageView], which already existed and is not
/// restyled here (`D-041(c)4`); this is the loading seam around it, which is
/// the shell half `KAN-327` asks for.
class _DocPane extends StatefulWidget {
  const _DocPane({
    super.key,
    required this.entry,
    required this.loader,
    required this.resolver,
    required this.onClose,
  });

  final _DocOrderEntry entry;
  final DabblerDocLoader loader;
  final DabblerDocSpecimenResolver resolver;
  final VoidCallback onClose;

  @override
  State<_DocPane> createState() => _DocPaneState();
}

class _DocPaneState extends State<_DocPane> {
  late final Future<DabblerDocPage> _page = widget.loader.load(
    widget.entry.page,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: FutureBuilder<DabblerDocPage>(
          future: _page,
          builder: (
            BuildContext context,
            AsyncSnapshot<DabblerDocPage> snapshot,
          ) {
            final DabblerDocPage? page = snapshot.data;
            if (page == null) {
              // A frame or two: the corpus is in the bundle, so this resolves
              // immediately in practice. Never a Material progress indicator.
              return const SizedBox(height: DabblerSpacing.space11);
            }
            return DabblerDocPageView(page: page, resolver: widget.resolver);
          },
        ),
      ),
    );
  }
}
