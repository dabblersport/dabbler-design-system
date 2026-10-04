import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../foundations/sport_accent.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'chip.dart';

/// One chip in a [DabblerChipRail].
@immutable
class DabblerChipRailItem {
  /// A chip labelled [label]; [onTap] selects it.
  const DabblerChipRailItem({
    required this.label,
    this.selected = false,
    this.onTap,
    this.count,
    this.leadingIcon,
    this.accent,
    this.dot = false,
  });

  /// The chip text, already localised.
  final String label;

  /// Whether this is the chosen chip.
  final bool selected;

  /// Called on tap. Null makes a static tag.
  final VoidCallback? onTap;

  /// A small count after the label, already localised — see
  /// [DabblerChip.count].
  final String? count;

  /// A glyph before the label.
  final Widget? leadingIcon;

  /// Colours the chip by sport — see [DabblerChip.accent].
  final DabblerSportAccent? accent;

  /// The primary-sport mark — see [DabblerChip.dot].
  final bool dot;
}

/// ChipRail — a plain horizontal rail of selectable chips: one scrolling row,
/// or two rows that scroll together, with the selected chip scrolled into view
/// and a fade at the edge that more chips run past.
///
/// Drawn from the rails the frames repeat: the Transactions filter and period
/// chips (`Wallet v2.dc.html:151-157`, `gap: 6`, a gutter of 18, no
/// scrollbar), the Activities category chips with counts
/// (`Notifications.dc.html:56-60`) and the Profiles sport picker
/// (`Profiles.dc.html:155-170`). Each is a row of [DabblerChip]s at a 6 gap
/// that scrolls horizontally; none is a tab strip (no underline, no pager —
/// that is `DabblerTabs`) and none removes chips (that is
/// `DabblerFilterRail`).
///
/// ```dart
/// DabblerChipRail(
///   padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
///   items: <DabblerChipRailItem>[
///     DabblerChipRailItem(label: 'All', selected: tab == 0, onTap: () => pick(0)),
///     DabblerChipRailItem(label: 'Paid', selected: tab == 1, onTap: () => pick(1)),
///   ],
/// )
/// ```
///
/// ## Why not `DabblerFilterRail` or `DabblerTabs`
///
/// `DabblerFilterRail` is the *applied-filters* rail: every chip is selected
/// and removable, and it ends in "Clear all". `DabblerTabs` is the underlined
/// page switcher with its own label-fit rules. Neither expresses "one chip
/// selected out of many", so this is a third thing, not an option on either.
///
/// ## Rows
///
/// [rows] `2` deals the chips alternately onto two rows inside the one
/// scrollable, so the rows scroll together and a long set stays within a
/// narrow screen. Rows are staggered by index, not balanced by width.
///
/// ## Edge fade
///
/// While the content runs past an edge, that edge is faded over
/// [fadeExtent] (24) into the page, so a cut-off chip reads as "more". It is
/// removed when the scroll reaches that end; [fade] false turns it off. The
/// design draws no fade on its rails — this is the one addition the brief
/// asked for, and it is off-able.
///
/// ## RTL
///
/// The rail starts at the inline start: the first chip is at the right under
/// Arabic and the scroll origin is the right edge. The edge fade follows the
/// side the content is cut on.
class DabblerChipRail extends StatefulWidget {
  /// A rail of [items].
  const DabblerChipRail({
    super.key,
    required this.items,
    this.rows = 1,
    this.size = DabblerChipSize.regular,
    this.padding = EdgeInsetsDirectional.zero,
    this.fade = true,
    this.controller,
  }) : assert(rows == 1 || rows == 2, 'a chip rail has one or two rows');

  /// The chips, in reading order.
  final List<DabblerChipRailItem> items;

  /// `1` (default) or `2`.
  final int rows;

  /// The chips' height class. The Activities rail is [DabblerChipSize.small],
  /// the sport picker [DabblerChipSize.large].
  final DabblerChipSize size;

  /// Padding inside the scroll area — the screen gutter, so the first chip
  /// aligns with the page while the rail still scrolls edge to edge.
  final EdgeInsetsGeometry padding;

  /// Whether the cut-off edge fades out.
  final bool fade;

  /// An external scroll controller.
  final ScrollController? controller;

  /// The gap between chips and between the two rows — [DabblerSpacing.space2]
  /// (6, `gap: 6px`).
  static const double gap = DabblerSpacing.space2;

  /// The fade's width — [DabblerSpacing.space8] (24).
  static const double fadeExtent = DabblerSpacing.space8;

  /// Finds the scrollable in a test.
  static const Key scrollKey = ValueKey<String>('dabbler-chip-rail-scroll');

  @override
  State<DabblerChipRail> createState() => DabblerChipRailState();
}

/// The rail's state. Public only so a test can read which edges are faded.
class DabblerChipRailState extends State<DabblerChipRail> {
  /// Whether the inline-start edge is faded (content scrolled past it).
  @visibleForTesting
  bool get fadingStart => _fadeStart;

  /// Whether the inline-end edge is faded (more chips beyond it).
  @visibleForTesting
  bool get fadingEnd => _fadeEnd;

  ScrollController? _own;
  final List<GlobalKey> _keys = <GlobalKey>[];
  bool _fadeStart = false;
  bool _fadeEnd = false;
  int? _lastSelected;

  ScrollController get _controller =>
      widget.controller ?? (_own ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _scheduleReveal();
  }

  @override
  void didUpdateWidget(DabblerChipRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    _scheduleReveal();
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _syncKeys() {
    while (_keys.length < widget.items.length) {
      _keys.add(GlobalKey());
    }
    if (_keys.length > widget.items.length) {
      _keys.removeRange(widget.items.length, _keys.length);
    }
  }

  int? get _selected {
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].selected) return i;
    }
    return null;
  }

  /// Brings the chosen chip into view when the selection changes (and on
  /// mount), without animation — a long rail opens on the chip it is set to.
  void _scheduleReveal() {
    final int? selected = _selected;
    if (selected == _lastSelected) return;
    _lastSelected = selected;
    if (selected == null) return;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || selected >= _keys.length) return;
      final BuildContext? target = _keys[selected].currentContext;
      if (target == null || !_controller.hasClients) return;
      // Scroll the rail's own viewport only. `Scrollable.ensureVisible` walks
      // every ancestor scrollable, which would also scroll the page that
      // holds the rail.
      final RenderObject? chip = target.findRenderObject();
      if (chip == null) return;
      final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
        chip,
      );
      if (viewport == null) return;
      final ScrollPosition position = _controller.position;
      position.jumpTo(
        viewport
            .getOffsetToReveal(chip, 0.5)
            .offset
            .clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  bool _onMetrics(ScrollMetrics metrics) {
    final bool start = metrics.pixels > metrics.minScrollExtent + 0.5;
    final bool end = metrics.pixels < metrics.maxScrollExtent - 0.5;
    if (start != _fadeStart || end != _fadeEnd) {
      setState(() {
        _fadeStart = start;
        _fadeEnd = end;
      });
    }
    return false;
  }

  Widget _chip(int i) {
    final DabblerChipRailItem item = widget.items[i];
    return KeyedSubtree(
      key: _keys[i],
      child: DabblerChip(
        label: item.label,
        selected: item.selected,
        onTap: item.onTap,
        count: item.count,
        leadingIcon: item.leadingIcon,
        accent: item.accent,
        dot: item.dot,
        size: widget.size,
      ),
    );
  }

  Widget _row(Iterable<int> indices) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: DabblerChipRail.gap,
    children: <Widget>[for (final int i in indices) _chip(i)],
  );

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final int count = widget.items.length;
    final Widget content = widget.rows == 1
        ? _row(Iterable<int>.generate(count))
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DabblerChipRail.gap,
            children: <Widget>[
              _row(<int>[for (int i = 0; i < count; i += 2) i]),
              _row(<int>[for (int i = 1; i < count; i += 2) i]),
            ],
          );

    Widget rail = SingleChildScrollView(
      key: DabblerChipRail.scrollKey,
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: content,
    );

    if (widget.fade) {
      final TextDirection direction = Directionality.of(context);
      final DabblerColors colors = DabblerColors.of(context);
      rail = NotificationListener<ScrollMetricsNotification>(
        onNotification: (ScrollMetricsNotification n) => _onMetrics(n.metrics),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification n) => _onMetrics(n.metrics),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (Rect bounds) {
              final double f = bounds.width == 0
                  ? 0
                  : (DabblerChipRail.fadeExtent / bounds.width).clamp(0, 0.5);
              final Color clear = colors.bgPrimary.withValues(alpha: 0);
              final Color solid = colors.bgPrimary;
              return LinearGradient(
                begin: AlignmentDirectional.centerStart.resolve(direction),
                end: AlignmentDirectional.centerEnd.resolve(direction),
                colors: <Color>[
                  _fadeStart ? clear : solid,
                  solid,
                  solid,
                  _fadeEnd ? clear : solid,
                ],
                stops: <double>[0, f, 1 - f, 1],
              ).createShader(bounds);
            },
            child: rail,
          ),
        ),
      );
    }
    return rail;
  }
}
