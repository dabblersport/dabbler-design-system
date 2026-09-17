import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The two treatments a [DabblerTabs] can take, transcribed from the `variant`
/// union in `components/layout/Tabs.d.ts`.
enum DabblerTabsVariant {
  /// Content tabs: a 2px brand indicator riding over a 1px `--faint` rail.
  /// The default, and the one for "a game's overview / players / chat".
  underline,

  /// A `--surface-sunken` pill track whose selected tab is a solid brand
  /// fill. For two or three peer views; always full width.
  segmented,
}

/// One tab, transcribed from `TabItem` in `components/layout/Tabs.d.ts`.
///
/// ## `icon` and `badge` are slots, not names
///
/// The source's `TabItem.icon` is an **Iconsax name string** rendered through
/// `components/foundations/Icon.jsx`, and `TabItem.badge` is rendered through
/// `components/surfaces/Badge.jsx`. Neither of those components exists in this
/// package yet — Icon is blocked on the Iconsax dependency, which is a `cto`
/// hand-off, and Badge is a separate ticket in the cut. Carrying a bare
/// `String` icon name here would be an API this package cannot honour, so both
/// are taken as [Widget] slots the caller fills. When Icon and Badge land, the
/// caller passes `DabblerIcon(...)` / `DabblerBadge(...)` into these same slots
/// and nothing in this file changes.
///
/// The source switches the icon to its `bold` weight on the active tab and
/// renders it at 18px ([DabblerSizing.iconSm]); with a slot, that choice moves
/// to the caller, which is why [DabblerTabs] does not size or re-tint the
/// widget it is given beyond inheriting the label's colour.
@immutable
class DabblerTabItem {
  /// Creates a tab.
  ///
  /// [id] is the identity the panel is matched on — see [DabblerTabPanel] —
  /// and must be unique within one [DabblerTabs].
  const DabblerTabItem({
    required this.id,
    required this.label,
    this.icon,
    this.badge,
  });

  /// The tab's identity. `TabPanel` renders when its own `id` equals the
  /// tabs' `value`, so this string — not the tab's position — decides which
  /// panel shows.
  final String id;

  /// The tab's text. Sentence case, one or two words
  /// (`Tabs.prompt.md` — *Composition rules*).
  final String label;

  /// Optional leading widget, drawn before the label. See the class doc: the
  /// source takes an Iconsax **name**; this package takes the widget.
  final Widget? icon;

  /// Optional trailing widget, drawn after the label — a count. See the class
  /// doc: the source takes a `Badge` child; this package takes the widget.
  final Widget? badge;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerTabItem &&
          other.id == id &&
          other.label == label &&
          other.icon == icon &&
          other.badge == badge;

  @override
  int get hashCode => Object.hash(id, label, icon, badge);

  @override
  String toString() => 'DabblerTabItem($id)';
}

/// Tabs — **content** tabs, switching between panels inside one screen.
///
/// Transcribed from `components/layout/Tabs.jsx`, `Tabs.d.ts` and
/// `Tabs.prompt.md`, with the measurements confirmed against the rendered
/// specimen `components/controls/buttons.card.html:140-165`.
///
/// Deliberately **not** a navigation bar. The source is explicit that
/// `NavigationTabBar` / `NavigationBottomBar` switch top-level app sections and
/// that *"never use one for the other's job"*; this switches panels of one
/// object — a game's overview / players / chat, a profile's stats / games /
/// mutuals.
///
/// ## Identity, not position
///
/// The active tab is the one whose [DabblerTabItem.id] equals [value], and
/// [DabblerTabPanel] renders on the same `id == value` test
/// (`Tabs.jsx:31, 154`). Reordering [items] therefore never changes which panel
/// is shown. A [value] that matches nothing falls back to the first tab, which
/// is what the source's `Math.max(0, findIndex(...))` does with `findIndex`'s
/// `-1`.
///
/// ## Controlled, like the source
///
/// This widget holds no selection state. It reports [onChanged] and redraws
/// when the caller passes a new [value] — the same contract as the source's
/// `value` / `onChange` pair. A null [onChanged] leaves the tabs inert but
/// visually unchanged, matching the source's optional handler.
///
/// ## Measurements
///
/// | | underline | segmented |
/// |---|---|---|
/// | height | 45 ([DabblerSizing.touchTargetMin]) | 45 track |
/// | gap | 15 ([DabblerSpacing.space5]) | 3 ([DabblerSpacing.space1]) |
/// | indicator | 2px [DabblerColors.brandPrimary] | — (solid fill) |
/// | rail | 1px [DabblerColors.bgTertiary] (`--faint`) | — |
/// | track | — | [DabblerColors.surfaceSunken], [DabblerRadius.pill] |
///
/// Labels are [DabblerType.subheadline] at [DabblerType.medium] when active and
/// [DabblerType.regular] otherwise. Flat throughout: no shadow, no gradient.
///
/// ## Keyboard — roving focus
///
/// Only the active tab is in the tab order ([FocusNode.skipTraversal] on every
/// other), so one Tab press enters the strip and the next leaves it. Inside it,
/// the arrow keys **move and select**, wrapping at both ends, and Home / End
/// jump to the ends. Every tab carries the shared [DabblerFocusRing]; no tab
/// draws a ring of its own.
///
/// ## RTL
///
/// Nothing in this file names `left` or `right`. Visual order reverses with
/// normal flow; the indicator is measured from the **inline start** and
/// positioned with [AnimatedPositionedDirectional]; the scroller is nudged
/// along the same inline-start axis; and the arrow keys swap, so
/// [LogicalKeyboardKey.arrowLeft] advances under RTL. That is the source's own
/// rule (`Tabs.jsx:59-63`, `Tabs.prompt.md` — *RTL behaviour*).
class DabblerTabs extends StatefulWidget {
  /// Creates a tab strip.
  const DabblerTabs({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.variant = DabblerTabsVariant.underline,
    this.scrollable = false,
    this.fullWidth = false,
    this.label,
  });

  /// The tabs, in visual order. `items` in the source, defaulting to empty.
  final List<DabblerTabItem> items;

  /// The active [DabblerTabItem.id]. A value matching no item selects the
  /// first tab.
  final String? value;

  /// Called with the newly selected id on tap, arrow key, Home or End.
  final ValueChanged<String>? onChanged;

  /// `underline` content tabs, or a `segmented` pill track.
  final DabblerTabsVariant variant;

  /// Turns the strip into a horizontal scroller that keeps the active tab in
  /// view. Ignored by [DabblerTabsVariant.segmented], which the source always
  /// lays out full width.
  final bool scrollable;

  /// Splits the available width evenly between the tabs. Always true in
  /// effect for [DabblerTabsVariant.segmented].
  final bool fullWidth;

  /// The accessible name of the tab strip — `aria-label` on the tablist.
  final String? label;

  @override
  State<DabblerTabs> createState() => _DabblerTabsState();
}

class _DabblerTabsState extends State<DabblerTabs> {
  /// Measured on the [Row], so `start` is content-relative and unaffected by
  /// the scroller's offset.
  final GlobalKey _stripKey = GlobalKey();
  final ScrollController _scroll = ScrollController();

  List<GlobalKey> _tabKeys = <GlobalKey>[];
  List<FocusNode> _nodes = <FocusNode>[];

  /// The indicator's inline-start offset and width, in logical pixels.
  /// Null until the first frame has been measured — the source starts at
  /// `{ start: 0, size: 0 }` and measures in an effect, so there is one frame
  /// with no indicator either way.
  double? _start;
  double? _size;

  /// The measured index, so a rebuild that changes nothing does not re-measure.
  int _measuredIndex = -1;
  double _measuredWidth = -1;

  /// `--space-4` (12): the source's scroll-into-view margin, `Tabs.jsx:50-51`.
  static const double _scrollMargin = DabblerSpacing.space4;

  /// Sub-pixel slack, so a rounding difference never provokes a jump. Not a
  /// design value — a floating-point one.
  static const double _scrollEpsilon = 0.01;

  int get _activeIndex {
    final int found =
        widget.items.indexWhere((DabblerTabItem i) => i.id == widget.value);
    // `Math.max(0, findIndex(...))` — Tabs.jsx:31.
    return found < 0 ? 0 : found;
  }

  bool get _segmented => widget.variant == DabblerTabsVariant.segmented;

  /// Segmented tabs are always full width (`Tabs.prompt.md` — *Responsive*),
  /// and the source never scrolls them.
  bool get _fullWidth => widget.fullWidth || _segmented;
  bool get _scrollable => widget.scrollable && !_segmented;

  @override
  void initState() {
    super.initState();
    _syncChildren();
  }

  @override
  void didUpdateWidget(DabblerTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncChildren();
    _scheduleMeasure();
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  /// Keeps one [GlobalKey] and one [FocusNode] per item, and applies the
  /// roving tab order: every node but the active one is skipped in traversal.
  void _syncChildren() {
    final int count = widget.items.length;
    if (_nodes.length != count) {
      for (final FocusNode node in _nodes.skip(count)) {
        node.dispose();
      }
      _nodes = <FocusNode>[
        ..._nodes.take(count),
        for (int i = _nodes.length; i < count; i++)
          FocusNode(debugLabel: 'DabblerTabs tab $i'),
      ];
      _tabKeys = <GlobalKey>[
        ..._tabKeys.take(count),
        for (int i = _tabKeys.length; i < count; i++) GlobalKey(),
      ];
    }
    final int active = _activeIndex;
    for (int i = 0; i < count; i++) {
      _nodes[i].skipTraversal = i != active;
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  /// Measures the active tab against the strip and moves the indicator, then
  /// nudges the scroller so the tab stays in view.
  ///
  /// The source reads `offsetLeft` / `offsetWidth` and converts to an
  /// inline-start offset under RTL with
  /// `scrollWidth - (offsetLeft + offsetWidth)` (`Tabs.jsx:41-43`). The Flutter
  /// equivalent is [RenderBox.localToGlobal] against the strip, mirrored the
  /// same way — and the strip's own width is the content width, because the
  /// [Row] is the scroller's child rather than its viewport.
  void _measure() {
    if (!mounted || widget.items.isEmpty) {
      return;
    }
    final int active = _activeIndex;
    final RenderBox? strip =
        _stripKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? tab = active < _tabKeys.length
        ? _tabKeys[active].currentContext?.findRenderObject() as RenderBox?
        : null;
    if (strip == null || tab == null || !strip.hasSize || !tab.hasSize) {
      return;
    }

    final double dx = tab.localToGlobal(Offset.zero, ancestor: strip).dx;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double start =
        rtl ? strip.size.width - (dx + tab.size.width) : dx;
    final double size = tab.size.width;

    if (_start != start || _size != size) {
      setState(() {
        _start = start;
        _size = size;
      });
    }
    _measuredIndex = active;
    _measuredWidth = strip.size.width;

    _keepInView(start: start, size: size);
  }

  /// Keeps the active tab inside the scroller by adjusting the scroller's own
  /// offset — **never** an ensure-visible that could scroll an ancestor. That
  /// is the source's rule verbatim: *"never `scrollIntoView`, which would
  /// scroll the whole page"* (`Tabs.jsx:45-53`).
  void _keepInView({required double start, required double size}) {
    if (!_scrollable || !_scroll.hasClients) {
      return;
    }
    final ScrollPosition position = _scroll.position;
    if (!position.hasViewportDimension || !position.hasContentDimensions) {
      return;
    }
    // Scroll offset runs from the inline start in both directions, which is
    // exactly the axis `start` is measured on.
    final double viewport = position.viewportDimension;
    final double offset = position.pixels;
    final double end = start + size;

    double? target;
    if (start < offset) {
      target = start - _scrollMargin;
    } else if (end > offset + viewport) {
      target = end - viewport + _scrollMargin;
    }
    if (target == null) {
      return;
    }
    final double clamped = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((clamped - offset).abs() > _scrollEpsilon) {
      _scroll.jumpTo(clamped);
    }
  }

  // --- Keyboard: roving focus ---

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (widget.items.isEmpty) {
      return KeyEventResult.ignored;
    }
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    // The source swaps the keys, not the order: ArrowLeft advances in RTL.
    final LogicalKeyboardKey forward =
        rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight;
    final LogicalKeyboardKey back =
        rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft;

    if (event.logicalKey == forward) {
      _move(1);
    } else if (event.logicalKey == back) {
      _move(-1);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _select(0);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _select(widget.items.length - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Arrow keys move **and** select, wrapping at both ends —
  /// `(activeIndex + dir + items.length) % items.length`, `Tabs.jsx:55-57`.
  void _move(int direction) {
    final int count = widget.items.length;
    _select((_activeIndex + direction + count) % count);
  }

  /// Selects [index] and moves focus onto it.
  ///
  /// **Deviation, deliberate.** The source moves focus for the arrow keys
  /// (`Tabs.jsx:62`) but not for Home / End, which leaves the keyboard focus
  /// on a tab that the roving tab order has just removed from traversal. Focus
  /// follows selection here in all four cases; anything else contradicts the
  /// roving-tabindex contract the same file sets up.
  void _select(int index) {
    final DabblerTabItem item = widget.items[index];
    widget.onChanged?.call(item.id);
    if (index < _nodes.length) {
      _nodes[index].requestFocus();
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final int active = _activeIndex;

    // Re-measure whenever the active tab or the available width changes. The
    // width check is what catches a resize with no state change at all.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }
      final RenderBox? strip =
          _stripKey.currentContext?.findRenderObject() as RenderBox?;
      final bool resized =
          strip != null && strip.hasSize && strip.size.width != _measuredWidth;
      if (_measuredIndex != active || resized) {
        _measure();
      }
    });

    final List<Widget> tabs = <Widget>[
      for (int i = 0; i < widget.items.length; i++)
        _buildTab(
          context,
          index: i,
          colors: colors,
          direction: direction,
          active: i == active,
        ),
    ];

    Widget strip = Row(
      key: _stripKey,
      // A non-scrolling strip fills the available inline extent, as the
      // source's block-level flex container does, so the rail spans it too.
      mainAxisSize: _scrollable ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: _segmented ? DabblerSpacing.space1 : DabblerSpacing.space5,
      children: tabs,
    );

    // The tablist annotation wraps the Row and nothing else. Both the
    // scroller and the indicator stack contribute semantics nodes of their
    // own, and a node between the tabBar and its tabs breaks Flutter's
    // `SemanticsRole.tabBar` invariant — *"Children of TabBar must have the
    // tab role"* (`semantics.dart:_semanticsTabBar`).
    strip = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      label: widget.label,
      child: strip,
    );

    if (_segmented) {
      strip = _segmentedTrack(colors, strip);
    } else {
      strip = _underlineStack(colors, strip);
    }

    return Focus(
      // The strip itself is never a focus stop; it only listens, so an arrow
      // key pressed on any tab is handled here.
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: strip,
    );
  }

  /// `--surface-sunken` pill track, 45 tall, with `--space-1` of inline
  /// padding (`Tabs.jsx:82-85`).
  ///
  /// **Deviation, documented.** The source puts 3px of padding on all four
  /// sides of the track and gives each tab a 39px min-height
  /// (`calc(var(--touch-target-min) - var(--space-2))`), which paints correctly
  /// but leaves the tab's own hit area 39px tall — under the 44px floor this
  /// ticket requires. Here the track keeps its inline padding, each tab's hit
  /// box is the full 45, and the 3px block padding is applied **inside** the
  /// tab so the painted pill is still exactly 39. Identical pixels; a hit area
  /// that clears 45×45.
  Widget _segmentedTrack(DabblerColors colors, Widget strip) {
    return Container(
      height: DabblerSizing.touchTargetMin,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: strip,
    );
  }

  /// The underline stack: a 1px `--faint` rail across the block end, the tab
  /// strip, and the 2px brand indicator riding over the rail.
  ///
  /// **Deviation, documented.** The source draws the indicator at
  /// `bottom: -1` so it straddles the container's own 1px bottom border
  /// (`Tabs.jsx:141`). A Flutter [Stack] child at a negative offset would be
  /// outside the painted bounds; instead the rail is a sibling at the block
  /// end and the 2px indicator is drawn over it at the same edge. The result
  /// on screen — a 2px brand bar covering the rail beneath the active tab — is
  /// the same.
  Widget _underlineStack(DabblerColors colors, Widget strip) {
    Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        strip,
        if (_start != null && _size != null && widget.items.isNotEmpty)
          AnimatedPositionedDirectional(
            duration: DabblerMotion.reduceMotion(context)
                ? Duration.zero
                : DabblerMotion.base,
            curve: DabblerMotion.easeOut,
            start: _start,
            bottom: 0,
            width: _size,
            height: _indicatorHeight,
            child: ColoredBox(color: colors.brandPrimary),
          ),
      ],
    );

    if (_scrollable) {
      content = SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        // The source hides the scrollbar (`scrollbarWidth: 'none'`).
        child: content,
      );
    }

    return Stack(
      children: <Widget>[
        // Painted first, so the indicator above covers it. Spans the strip's
        // full inline extent, which is what `border-block-end` does.
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: SizedBox(
            height: DabblerSizing.borderDefault,
            child: ColoredBox(color: colors.bgTertiary),
          ),
        ),
        content,
      ],
    );
  }

  /// The indicator is 2px — the specimen's own figure
  /// (`buttons.card.html:158`). It is not a spacing step, so it is stated
  /// here rather than borrowed from a token that happens to equal it.
  static const double _indicatorHeight = 2;

  Widget _label(String text, TextStyle style) => Text(
        text,
        style: style,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required DabblerColors colors,
    required TextDirection direction,
    required bool active,
  }) {
    final DabblerTabItem item = widget.items[index];

    final Color foreground = _segmented
        ? (active ? colors.onBrand : colors.textSecondary)
        : (active ? colors.textPrimary : colors.textSecondary);

    final TextStyle style = DabblerType.subheadline
        .resolveForDirection(direction)
        .copyWith(
          color: foreground,
          fontWeight: active ? DabblerType.medium : DabblerType.regular,
        );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      // `gap: var(--space-2)` between glyph, label and badge — Tabs.jsx:107.
      spacing: DabblerSpacing.space2,
      children: <Widget>[
        if (item.icon != null) item.icon!,
        // `whiteSpace: nowrap` — Tabs.jsx:112. Inside a scroller the label is
        // never squeezed, so it is laid out at its natural width; a
        // [Flexible] there would meet unbounded constraints and throw.
        if (_scrollable)
          _label(item.label, style)
        else
          Flexible(child: _label(item.label, style)),
        if (item.badge != null) item.badge!,
      ],
    );

    // The painted body. Colour and background change over `--motion-base`,
    // matching the source's `transition: background …, color …`
    // (`Tabs.jsx:121`); the underline variant has no background to animate.
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;

    final Widget body = _segmented
        ? AnimatedContainer(
            duration: duration,
            curve: DabblerMotion.easeOut,
            // 45 − `--space-2` = 39: the source's own tab height.
            height: DabblerSizing.touchTargetMin - DabblerSpacing.space2,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space5,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? colors.brandPrimary : null,
              borderRadius: DabblerRadius.pillAll,
            ),
            child: content,
          )
        : Container(
            constraints: const BoxConstraints(
              minWidth: DabblerSizing.touchTargetMin,
              minHeight: DabblerSizing.touchTargetMin,
            ),
            alignment: Alignment.center,
            child: content,
          );

    // The hit box. `HitTestBehavior.opaque` is what lets the segmented tab's
    // target be the full 45 while its pill paints 39.
    final Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onChanged == null
          ? null
          : () {
              widget.onChanged!.call(item.id);
              _nodes[index].requestFocus();
            },
      child: SizedBox(
        height: DabblerSizing.touchTargetMin,
        child: Center(
          widthFactor: _fullWidth ? null : 1,
          child: DabblerFocusRing(
            focusNode: _nodes[index],
            borderRadius:
                _segmented ? DabblerRadius.pillAll : BorderRadius.zero,
            child: body,
          ),
        ),
      ),
    );

    final Widget tab = Semantics(
      key: _tabKeys[index],
      container: true,
      role: SemanticsRole.tab,
      selected: active,
      label: item.label,
      // `aria-controls={`tabpanel-${item.id}`}` — Tabs.jsx:103.
      controlsNodes: <String>{DabblerTabPanel.semanticsIdentifier(item.id)},
      // Always present: Flutter asserts that *"a tab must have a tap action"*,
      // so an inert strip reports a tab that does nothing rather than a tab
      // that is not a tab. The source's optional `onChange` is honoured by the
      // call itself being a no-op.
      onTap: () => widget.onChanged?.call(item.id),
      child: ExcludeSemantics(child: tappable),
    );

    if (_fullWidth) {
      return Expanded(child: tab);
    }
    // **Deviation, documented.** The source's tabs are `flex: 0 0 auto` and a
    // CSS overflow is silent; a Flutter [Row] overflow is a reported error.
    // A loose [Flexible] keeps the natural width whenever it fits and lets the
    // labels ellipsise instead of overflowing when it does not — which is what
    // `scrollable` exists to avoid in the first place.
    return _scrollable ? tab : Flexible(child: tab);
  }
}

/// The panel a [DabblerTabs] tab controls.
///
/// Transcribed from `TabPanel` in `components/layout/Tabs.jsx:151-158`. Wire
/// [id] and [value] to the same strings as the tabs:
///
/// ```dart
/// DabblerTabs(items: items, value: tab, onChanged: (String id) => …),
/// DabblerTabPanel(id: 'overview', value: tab, child: …),
/// ```
///
/// ## `id == value`, and nothing else
///
/// The panel renders **only** when its own [id] equals [value] — an identity
/// match on the string, never the tab's position. Reordering the tabs cannot
/// change which panel is shown, and a panel whose id no longer appears in the
/// strip simply never renders.
///
/// The source returns `null` when the ids do not match. A Flutter build cannot
/// return null, so the miss returns a zero-size [SizedBox.shrink]: it
/// contributes no paint, no semantics and no space, which is the same outcome.
class DabblerTabPanel extends StatelessWidget {
  /// Creates a tab panel.
  const DabblerTabPanel({
    super.key,
    required this.id,
    required this.value,
    this.child,
  });

  /// This panel's identity. Must equal a [DabblerTabItem.id].
  final String id;

  /// The tabs' current `value`. The panel renders when it equals [id].
  final String? value;

  /// The panel's content.
  final Widget? child;

  /// The semantics identifier a panel for [id] carries, and the string the
  /// matching tab names in its `controlsNodes`.
  ///
  /// This is the Flutter equivalent of the source's `id="tabpanel-${id}"` /
  /// `aria-controls="tabpanel-${id}"` pair (`Tabs.jsx:103, 156`): the two
  /// sides are generated from one function so they cannot drift apart.
  static String semanticsIdentifier(String id) => 'tabpanel-$id';

  @override
  Widget build(BuildContext context) {
    if (id != value) {
      return const SizedBox.shrink();
    }
    return Semantics(
      container: true,
      role: SemanticsRole.tabPanel,
      identifier: semanticsIdentifier(id),
      // `tabIndex={0}` — the panel is itself a tab stop, so keyboard focus
      // leaving the strip lands on the content it just selected.
      child: Focus(child: child ?? const SizedBox.shrink()),
    );
  }
}
