/// The gallery shell — the rail beside a swapping content pane.
///
/// A `part` of `gallery_index.dart` like the rail, the rows and the collection
/// pages, and for the same reason (`D-046`): every type here is private and a
/// part is never exported. It was split out of `gallery_index_rail.dart` when
/// the collection routing was added — that file reached 501 lines against the
/// 500-line rule (`013`), and the shell is the natural seam because it is the
/// only piece that holds state for all four destinations.
part of 'gallery_index.dart';

/// The catalogue, with the documentation rail beside it above
/// [_sideNavBreakpoint].
///
/// **Below the breakpoint the rail does not render and NOTHING replaces it**
/// — no drawer, no hamburger, no off-canvas pane (D-045(c)). The reason is not
/// stylistic: the index below already *is* a sectioned navigation
/// ([GalleryIndex._bands]), so a slide-over would put a second copy of it over
/// a screen already showing it.
///
/// ## Why the pane swaps and nothing is pushed
///
/// Every destination — the catalogue, a section landing, a group landing, a
/// page — is a [_PaneTarget] swapped into the content pane. A pushed route
/// would cover the whole screen including the rail it was selected from, and
/// a rail the reader loses the moment they use it is not a rail. That applies
/// to the cards as much as to the rows: opening a group from a section card
/// swaps the pane and leaves the rail standing, with that group's row now
/// expanded and selected.
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
  late final DabblerDocSpecimenResolver _resolver = DabblerDocSpecimenResolver(
    widget.entries,
  );

  final TextEditingController _filter = TextEditingController();

  /// What the pane is showing.
  _PaneTarget _target = const _CataloguePane();

  /// The [_PaneTarget.key]s of every section and group whose children are
  /// showing in the rail.
  ///
  /// Held here rather than inside `_DocRail` so that navigating from a **card**
  /// expands the rail too: the rail and the pane are two views of one position,
  /// and a section card that opened a group without moving the rail would make
  /// them disagree.
  final Set<String> _expanded = <String>{};

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  Future<_DocOrder> _loadOrder() async {
    final String? raw = await _loader.loadRaw(_DocOrder.assetName);
    if (raw == null) {
      return _DocOrder.unavailable(
        'the bundle has no `assets/documentation/${_DocOrder.assetName}`',
      );
    }
    return _DocOrder.parse(raw);
  }

  /// Moves the pane to [target] and opens every rail level above it.
  void _go(_PaneTarget target, {List<String> expand = const <String>[]}) {
    setState(() {
      _target = target;
      _expanded.addAll(expand);
      if (target is _SectionPane) _expanded.add(target.key);
      if (target is _GroupPane) {
        // The group's own row lives inside its section's disclosure, so
        // expanding only the group would select a row that is not drawn —
        // which is what opening a group from a SECTION CARD did before this
        // line: the pane moved and the rail did not.
        _expanded
          ..add(_SectionPane(target.section).key)
          ..add(target.key);
      }
    });
  }

  void _toggle(String key) {
    setState(() {
      if (!_expanded.remove(key)) _expanded.add(key);
    });
  }

  /// Opens a page, expanding the section and group that contain it.
  void _openPage(_DocOrder order, _DocOrderEntry entry) {
    final List<String> ancestors = <String>[];
    for (final _DocOrderSection section in order.sections) {
      for (final _DocOrderGroup group in section.groups) {
        if (group.entries.any((_DocOrderEntry e) => e.page == entry.page)) {
          ancestors
            ..add(_SectionPane(section).key)
            ..add(_GroupPane(section, group).key);
        }
      }
    }
    _go(_PagePane(entry), expand: ancestors);
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

  /// The content pane for the current [_target].
  Widget _pane(_DocOrder? order) {
    final Widget body = switch (_target) {
      _CataloguePane() => _catalogue(),
      _SectionPane(:final _DocOrderSection section) => _SectionLanding(
        section: section,
        onOpenGroup: (_DocOrderGroup group) => _go(_GroupPane(section, group)),
        onOpenPage: (_DocOrderEntry entry) =>
            order == null ? _go(_PagePane(entry)) : _openPage(order, entry),
      ),
      _GroupPane(
        :final _DocOrderSection section,
        :final _DocOrderGroup group,
      ) =>
        _GroupLanding(
          group: group,
          onOpenPage: (_DocOrderEntry entry) => _go(
            _PagePane(entry),
            expand: <String>[
              _SectionPane(section).key,
              _GroupPane(section, group).key,
            ],
          ),
        ),
      _PagePane(:final _DocOrderEntry entry) => _DocPane(
        key: ValueKey<String>(entry.page),
        entry: entry,
        loader: _loader,
        resolver: _resolver,
      ),
    };

    return SingleChildScrollView(
      child: Align(alignment: AlignmentDirectional.topStart, child: body),
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
                      // The rail reads `_filter.text` but is stateless, so
                      // nothing would rebuild it as the query is typed —
                      // `_FilterField` only rebuilds itself. This is what
                      // makes the filter reach the rows.
                      : ListenableBuilder(
                          listenable: _filter,
                          builder: (BuildContext context, Widget? _) =>
                              _DocRail(
                                order: order,
                                selected: _target.key,
                                expanded: _expanded,
                                filter: _filter,
                                onToggle: _toggle,
                                onOpen: _go,
                                onOpenPage: (_DocOrderEntry entry) =>
                                    _openPage(order, entry),
                              ),
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
                    child: _pane(order),
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
