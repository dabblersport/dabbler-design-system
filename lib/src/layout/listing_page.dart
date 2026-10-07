import 'package:flutter/widgets.dart';

import '../controls/filter_rail.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_geometry.dart';
import 'tabs.dart';

/// How a [DabblerListingPage] paints its header band (`Listings.dc.html`
/// 2026-10-08, the frame's `data-head`).
enum DabblerListingHead {
  /// No band: the page ground (`data-head="none"`).
  none,

  /// The section's brand at 14% over the card colour (`data-head="tint"`:
  /// Games, Venues).
  tint,

  /// The accent tile surface (`data-head="accent"`: Meetups).
  accent,
}

/// ListingPage — a listing screen's collapsing header over its pages
/// (`Listings.dc.html` 2026-10-08).
///
/// ```dart
/// DabblerListingPage(
///   head: DabblerListingHead.tint,
///   header: DabblerPageHeader(
///     title: 'Games',
///     safeArea: false,
///     contentPadding: DabblerPageHeader.listingPadding,
///   ),
///   tabs: const <DabblerTabItem>[
///     DabblerTabItem(id: 'all', label: 'All sports'),
///   ],
///   filters: applied,
///   clearAllLabel: 'Clear all',
///   onClearAll: reset,
///   pages: <Widget>[gamesList],
/// );
/// ```
///
/// ## What is pinned and what folds
///
/// The header band — the title row ([header]), the sport [tabs] and the
/// applied-[filters] rail — stays above the list. Scrolling a page past
/// [collapseAt] collapses the band, and scrolling back under [expandAt]
/// expands it (the frame's hysteresis): the tabs always fold away; the title
/// row folds with them once filters are applied, so only the filters stay
/// pinned; with no filters the title row stays. Each part folds its height
/// and fades over 200ms ease-out (`max-height` and `opacity` transitions in
/// the frame); under reduced motion it jumps.
///
/// ## The band
///
/// [head] chooses the band's colour: [DabblerListingHead.tint] is
/// `color-mix(brand 14%, card)` and [DabblerListingHead.accent] the accent tile
/// surface. The band bleeds up under the status bar: this widget pads the top
/// inset inside it, and reports the colour through [onBandColor] so the shell
/// (or the platform chrome) can carry it — see `DabblerTopFill`. Everything is drawn with the ambient
/// [DabblerColors], so an enclosing section theme (the app re-tints the brand per section) re-tints the band.
///
/// ## Pages
///
/// One page per tab, swiped or reached by tapping a tab; each is kept alive,
/// so a list scrolled half-way is still half-way when the user comes back.
/// Pages run edge to edge: each insets its own content by the 18 gutter.
class DabblerListingPage extends StatefulWidget {
  /// A listing of [pages], one per entry of [tabs].
  const DabblerListingPage({
    super.key,
    required this.header,
    required this.tabs,
    required this.pages,
    required this.filters,
    required this.clearAllLabel,
    required this.onClearAll,
    this.head = DabblerListingHead.tint,
    this.onBandColor,
  }) : assert(tabs.length == pages.length, 'every tab needs one page');

  /// The title row — normally a `DabblerPageHeader` built with
  /// `safeArea: false` and `contentPadding: DabblerPageHeader.listingPadding`.
  final Widget header;

  /// The sport tabs, in page order.
  final List<DabblerTabItem> tabs;

  /// One page per tab.
  final List<Widget> pages;

  /// The applied filters, drawn as a rail under the tabs. Empty draws none.
  final List<DabblerFilterRailItem> filters;

  /// The rail's "Clear all" label.
  final String clearAllLabel;

  /// Called by "Clear all".
  final VoidCallback onClearAll;

  /// How the band is painted.
  final DabblerListingHead head;

  /// Called after the band's colour changes with it, and with null when the
  /// band goes away ([DabblerListingHead.none], or the page leaves).
  final ValueChanged<Color?>? onBandColor;

  /// Scrolled past this the band collapses (`y > 40`).
  static const double collapseAt = 40;

  /// Scrolled back under this it expands (`y < 8`).
  static const double expandAt = 8;

  /// The tint's share of the brand — `color-mix(brand 14%, card)`.
  static const double tintShare = 0.14;

  /// The tab rail sits 12 under the title row (`margin-top: 12`).
  static const double tabsTop = DabblerSpacing.space4;

  /// The filters rail sits 9 under the tabs.
  static const double filtersUnderTabs = DabblerSpacing.space3;

  /// With the tabs folded and the title row showing, 12 under the title row.
  static const double filtersUnderTitle = DabblerSpacing.space4;

  /// With both folded, 6 keeps the rail off the status area.
  static const double filtersPinned = DabblerSpacing.space2;

  /// The rail's `padding-bottom: 6`.
  static const double filtersBottom = DabblerSpacing.space2;

  /// The screen gutter — `padding: 0 18px`.
  static const double gutter = DabblerSpacing.space6;

  @override
  State<DabblerListingPage> createState() => _DabblerListingPageState();
}

class _DabblerListingPageState extends State<DabblerListingPage> {
  final PageController _pager = PageController();
  int _index = 0;
  bool _collapsed = false;
  Color? _reported;
  bool _hasReported = false;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final double y = n.metrics.pixels;
    if (!_collapsed && y > DabblerListingPage.collapseAt) {
      setState(() => _collapsed = true);
    } else if (_collapsed && y < DabblerListingPage.expandAt) {
      setState(() => _collapsed = false);
    }
    return false;
  }

  void _select(String id) {
    final int target = widget.tabs.indexWhere((DabblerTabItem t) => t.id == id);
    if (target < 0 || target == _index || !_pager.hasClients) return;
    _pager.animateToPage(
      target,
      duration: DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
    );
  }

  Color _band(DabblerColors colors) => switch (widget.head) {
    DabblerListingHead.none => colors.bgPrimary,
    DabblerListingHead.tint => Color.lerp(
      colors.surfaceCard,
      colors.brandPrimary,
      DabblerListingPage.tintShare,
    )!,
    DabblerListingHead.accent => DabblerColors.tileAccent.surface,
  };

  void _report(Color? band) {
    if (_hasReported && _reported == band) return;
    _hasReported = true;
    _reported = band;
    final ValueChanged<Color?>? cb = widget.onBandColor;
    if (cb == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cb(band);
    });
  }

  @override
  void deactivate() {
    final ValueChanged<Color?>? cb = widget.onBandColor;
    if (cb != null && _reported != null) {
      _reported = null;
      _hasReported = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => cb(null));
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool hasFilters = widget.filters.isNotEmpty;
    final bool showTitle = !_collapsed || !hasFilters;
    final bool showTabs = !_collapsed;
    final bool banded = widget.head != DabblerListingHead.none;
    final Color band = _band(colors);
    _report(banded ? band : null);
    final double top = MediaQuery.paddingOf(context).top;
    final Duration d = DabblerMotion.durationOf(context, DabblerMotion.slow);

    final double filtersTop = showTabs
        ? DabblerListingPage.filtersUnderTabs
        : (showTitle
              ? DabblerListingPage.filtersUnderTitle
              : DabblerListingPage.filtersPinned);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ColoredBox(
          color: band,
          child: Padding(
            padding: EdgeInsets.only(top: top),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Collapse(open: showTitle, child: widget.header),
                _Collapse(
                  open: showTabs,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: DabblerListingPage.tabsTop,
                    ),
                    child: DabblerTabs(
                      variant: DabblerTabsVariant.listing,
                      scrollable: true,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: DabblerListingPage.gutter,
                      ),
                      items: widget.tabs,
                      value: widget.tabs[_index].id,
                      onChanged: _select,
                    ),
                  ),
                ),
                if (hasFilters)
                  AnimatedPadding(
                    duration: d,
                    curve: DabblerMotion.easeOut,
                    padding: EdgeInsetsDirectional.only(
                      top: filtersTop,
                      bottom: DabblerListingPage.filtersBottom,
                    ),
                    child: DabblerFilterRail(
                      items: widget.filters,
                      clearAllLabel: widget.clearAllLabel,
                      onClearAll: widget.onClearAll,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: DabblerListingPage.gutter,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView(
              controller: _pager,
              onPageChanged: (int i) => setState(() => _index = i),
              children: <Widget>[
                for (int i = 0; i < widget.pages.length; i++)
                  _KeptPage(
                    key: PageStorageKey<String>(
                      'dabbler-listing-page/${widget.tabs[i].id}',
                    ),
                    child: widget.pages[i],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Folds [child] to nothing and back: height over 200ms ease-out and the
/// opacity with it.
class _Collapse extends StatelessWidget {
  const _Collapse({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Duration d = DabblerMotion.durationOf(context, DabblerMotion.slow);
    return ClipRect(
      child: AnimatedAlign(
        alignment: AlignmentDirectional.topStart,
        heightFactor: open ? 1 : 0,
        duration: d,
        curve: DabblerMotion.easeOut,
        child: AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: d,
          curve: DabblerMotion.easeOut,
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _KeptPage extends StatefulWidget {
  const _KeptPage({super.key, required this.child});

  final Widget child;

  @override
  State<_KeptPage> createState() => _KeptPageState();
}

class _KeptPageState extends State<_KeptPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
