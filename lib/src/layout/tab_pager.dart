import 'package:flutter/widgets.dart';

import '../tokens/dabbler_motion.dart';
import 'tabs.dart';

/// TabPager — a [DabblerTabs] header over a swipeable [PageView] body
/// (KAN-409 item 3).
///
/// ```dart
/// DabblerTabPager(
///   items: const <DabblerTabItem>[
///     DabblerTabItem(id: 'for-you', label: 'For you'),
///     DabblerTabItem(id: 'following', label: 'Following'),
///   ],
///   pages: <Widget>[forYouList, followingList],
/// );
/// ```
///
/// - **Sync both ways.** Tapping a tab animates the body to its page; swiping
///   the body moves the tab indicator. A caller-supplied [controller] that
///   jumps or animates moves the header too, because the header follows the
///   page view's own `onPageChanged`.
/// - **Each tab keeps its place.** Every page is kept alive and wrapped in a
///   [PageStorageKey] built from its item's id, so a list scrolled half-way in
///   one tab is still half-way when the user comes back.
/// - **Direction.** [PageView] lays horizontal pages out by the ambient
///   [Directionality]: under Arabic the first tab's page is on the right and
///   the user swipes leftwards to advance — matching the header, which
///   [DabblerTabs] already mirrors.
class DabblerTabPager extends StatefulWidget {
  /// A pager of [pages] headed by [items], in the same order.
  const DabblerTabPager({
    super.key,
    required this.items,
    required this.pages,
    this.initialIndex = 0,
    this.onChanged,
    this.controller,
    this.variant = DabblerTabsVariant.underline,
    this.scrollable = false,
    this.fullWidth = false,
    this.label,
    this.tabsPadding = EdgeInsets.zero,
  }) : assert(items.length == pages.length, 'every tab needs exactly one page');

  /// The tabs, in order. Each [DabblerTabItem.id] also keys its page's
  /// [PageStorage] bucket, so ids must be unique.
  final List<DabblerTabItem> items;

  /// One page per item, in the same order.
  final List<Widget> pages;

  /// The page shown first. Ignored when [controller] is given — its own
  /// `initialPage` decides.
  final int initialIndex;

  /// Called with the new index whenever the selected page changes, by tap or
  /// by swipe.
  final ValueChanged<int>? onChanged;

  /// Drives the body from outside. Owned by the caller; disposed by the
  /// caller.
  final PageController? controller;

  /// Passed to the header. See [DabblerTabs.variant].
  final DabblerTabsVariant variant;

  /// Passed to the header. See [DabblerTabs.scrollable].
  final bool scrollable;

  /// Passed to the header. See [DabblerTabs.fullWidth].
  final bool fullWidth;

  /// Passed to the header. See [DabblerTabs.label].
  final String? label;

  /// Passed to the header. See [DabblerTabs.padding].
  final EdgeInsetsGeometry tabsPadding;

  @override
  State<DabblerTabPager> createState() => _DabblerTabPagerState();
}

class _DabblerTabPagerState extends State<DabblerTabPager> {
  PageController? _own;
  late int _index;

  PageController get _controller => widget.controller ?? _own!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _own = PageController(initialPage: widget.initialIndex);
    }
    _index = widget.controller?.initialPage ?? widget.initialIndex;
  }

  @override
  void didUpdateWidget(DabblerTabPager old) {
    super.didUpdateWidget(old);
    if (widget.controller != null && _own != null) {
      _own!.dispose();
      _own = null;
    } else if (widget.controller == null && _own == null) {
      _own = PageController(initialPage: _index);
    }
    if (_index >= widget.items.length) _index = widget.items.length - 1;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _select(String id) {
    final int target = widget.items.indexWhere(
      (DabblerTabItem i) => i.id == id,
    );
    if (target < 0 || target == _index) return;
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      target,
      duration: DabblerMotion.slow,
      curve: DabblerMotion.easeOut,
    );
  }

  void _onPage(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DabblerTabs(
          items: widget.items,
          value: widget.items.isEmpty ? null : widget.items[_index].id,
          onChanged: _select,
          variant: widget.variant,
          scrollable: widget.scrollable,
          fullWidth: widget.fullWidth,
          label: widget.label,
          padding: widget.tabsPadding,
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: _onPage,
            children: <Widget>[
              for (int i = 0; i < widget.pages.length; i++)
                _KeptPage(
                  key: PageStorageKey<String>(
                    'dabbler-tab-pager/${widget.items[i].id}',
                  ),
                  child: widget.pages[i],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Keeps an off-screen page's state — and so its scroll offset — alive.
class _KeptPage extends StatefulWidget {
  const _KeptPage({super.key, required this.child});

  final Widget child;

  @override
  State<_KeptPage> createState() => _KeptPageState();
}

class _KeptPageState extends State<_KeptPage>
    with AutomaticKeepAliveClientMixin<_KeptPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
