import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../controls/fab.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// One destination in a [DabblerNavigationBottomBar], transcribed from
/// `NavigationBottomBarItem` in
/// `components/navigation/NavigationBottomBar.d.ts:12-19`.
@immutable
class DabblerNavigationItem {
  /// Creates a destination.
  const DabblerNavigationItem({
    required this.id,
    required this.icon,
    required this.label,
  });

  /// Stable id, compared against [DabblerNavigationBottomBar.active].
  final String id;

  /// Kebab-case Iconsax name, e.g. `home-2`. Rendered
  /// [DabblerIconWeight.bold] when active and [DabblerIconWeight.linear]
  /// otherwise — the system-wide active/inactive rule
  /// (`navigation-system.card.html` — *Anatomy*).
  final String icon;

  /// Shown **only** while this destination is active, so exactly one label is
  /// ever visible.
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerNavigationItem &&
          other.id == id &&
          other.icon == icon &&
          other.label == label;

  @override
  int get hashCode => Object.hash(id, icon, label);

  @override
  String toString() => 'DabblerNavigationItem($id)';
}

/// One create-menu tile, transcribed from `NavigationBottomBarCreateItem`
/// (`NavigationBottomBar.d.ts:21-28`).
@immutable
class DabblerNavigationCreateItem {
  /// Creates a tile.
  const DabblerNavigationCreateItem({
    required this.id,
    required this.icon,
    required this.label,
  });

  /// Stable id, passed to [DabblerNavigationBottomBar.onCreate].
  final String id;

  /// Kebab-case Iconsax name for the tile glyph. Always `linear`.
  final String icon;

  /// Label under the tile. Wraps to two lines if needed.
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerNavigationCreateItem &&
          other.id == id &&
          other.icon == icon &&
          other.label == label;

  @override
  int get hashCode => Object.hash(id, icon, label);

  @override
  String toString() => 'DabblerNavigationCreateItem($id)';
}

/// The floating bottom navigation — a **split** bar on one line: a brand pill
/// of destinations at the inline **start**, and a detached round action at the
/// inline **end**.
///
/// Transcribed from `components/navigation/NavigationBottomBar.jsx`,
/// `.d.ts` and `.prompt.md`, with the anatomy and token table confirmed against
/// the rendered specimen `components/navigation/navigation-system.card.html`.
///
/// Deliberately **not** `DabblerTabs`. The source is explicit that `Tabs`
/// switches panels of content inside one screen while the navigation bars move
/// between destinations, and that *"never use one for the other's job"*
/// (`navigation-system.card.html` — *Top vs bottom navigation*).
///
/// ## Anatomy
///
/// | part | treatment |
/// |---|---|
/// | nav pill | [DabblerColors.brandPrimary], [DabblerRadius.pill], at the inline start |
/// | inactive destination | icon only, `linear`, [DabblerColors.borderDefault] (`--neutral-400`) |
/// | active destination | a [DabblerColors.surfaceCard] chip with icon **and** label, both [DabblerColors.brandPrimary], glyph `bold` |
/// | action | a brand-filled round button, [DabblerFab.size] (56), at the inline end |
/// | create menu | a [DabblerColors.surfaceCard] card of tiles that **replaces the pill in flow**; the row bottom-aligns so it grows upward from the action's baseline |
///
/// ## Controlled or uncontrolled, twice over
///
/// Both the active destination and the menu follow the source's pair rule:
/// pass [active] / [menuOpen] to drive them, or omit and let the widget hold
/// them. This is the one place the package keeps internal state in a
/// presentation widget, and it is the source's own contract
/// (`NavigationBottomBar.jsx:38-59`).
///
/// ## Keyboard — roving focus, as in `DabblerTabs`
///
/// Only the active destination is in the tab order, the arrow keys move **and**
/// select with wrapping, and Home / End jump to the ends. The arrow keys swap
/// under RTL, so [LogicalKeyboardKey.arrowLeft] advances. That is deliberately
/// identical to `lib/src/layout/tabs.dart`: a bottom bar is the same
/// interaction family, and two different keyboard contracts for one gesture
/// would be the defect.
///
/// ## RTL — Directionality, not an `rtl` prop
///
/// **Deviation, documented.** The source carries an `rtl` prop because the web
/// component must read the closest `[dir]` at mount and cannot rely on
/// `row-reverse` (which would double-reverse inside a `[dir="rtl"]` ancestor).
/// Flutter has no such hazard: [Directionality] *is* the ambient direction, a
/// [Row] already lays out from the inline start, and every inset here is an
/// [EdgeInsetsDirectional]. Adding an `rtl` flag would let a caller contradict
/// the ambient direction, which is exactly the bug the source's note is about.
/// A caller who wants to force a direction wraps this widget in a
/// [Directionality].
///
/// ## Safe area
///
/// The card records that *"no navigation component pins a device inset … the
/// screen shell owns navigation insets"*. That is a web statement; on a device
/// the home indicator is real, so [safeArea] (default `true`) pads the block
/// end by [MediaQueryData.padding]`.bottom`. It **cannot** double-apply: an
/// ancestor [SafeArea] consumes that padding for its subtree, so the value read
/// here is already `0`. Set [safeArea] to `false` to opt out entirely.
///
/// ## Flat
///
/// The source draws a drop shadow under both the action and the menu card. The
/// package is a flat system — no shadow outside `Dialog` and `FAB`'s own
/// documented exception — so neither is drawn here.
class DabblerNavigationBottomBar extends StatefulWidget {
  /// Creates a bottom navigation bar.
  const DabblerNavigationBottomBar({
    super.key,
    this.items = defaultItems,
    this.active,
    this.defaultActive,
    this.onSelect,
    this.actionIcon = 'add',
    this.actionLabel = 'Create',
    this.onAction,
    this.closeLabel = 'Close menu',
    this.createItems = defaultCreateItems,
    this.menuOpen,
    this.defaultMenuOpen = false,
    this.onCreate,
    this.safeArea = true,
  });

  /// Home / Explore / Games / You — the source's own `ITEMS`
  /// (`NavigationBottomBar.jsx:25-30`).
  static const List<DabblerNavigationItem> defaultItems =
      <DabblerNavigationItem>[
    DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
    DabblerNavigationItem(
        id: 'explore', icon: 'search-normal', label: 'Explore'),
    DabblerNavigationItem(id: 'games', icon: 'game', label: 'Games'),
    DabblerNavigationItem(id: 'you', icon: 'user', label: 'You'),
  ];

  /// Create post / Create game / Create meetup — the source's `CREATE_ITEMS`
  /// (`NavigationBottomBar.jsx:32-36`).
  static const List<DabblerNavigationCreateItem> defaultCreateItems =
      <DabblerNavigationCreateItem>[
    DabblerNavigationCreateItem(
        id: 'post', icon: 'edit-2', label: 'Create post'),
    DabblerNavigationCreateItem(
        id: 'game', icon: 'game', label: 'Create game'),
    DabblerNavigationCreateItem(
        id: 'meetup', icon: 'people', label: 'Create meetup'),
  ];

  /// The destinations, in visual order.
  final List<DabblerNavigationItem> items;

  /// Controlled active id. Omit to let the widget manage it.
  final String? active;

  /// Initial active id when uncontrolled. Defaults to the first item.
  final String? defaultActive;

  /// Called with the newly selected id on tap, arrow key, Home or End.
  final ValueChanged<String>? onSelect;

  /// Iconsax name for the detached action. `add` by default.
  final String actionIcon;

  /// The action's accessible name while the menu is closed. It is icon-only,
  /// so this is its only name.
  final String actionLabel;

  /// Fired when the action is tapped, with the menu's **new** open state.
  final ValueChanged<bool>? onAction;

  /// The action's accessible name while the menu is open.
  final String closeLabel;

  /// The create-menu tiles.
  final List<DabblerNavigationCreateItem> createItems;

  /// Controlled menu state. Omit to let the widget manage it.
  final bool? menuOpen;

  /// Initial menu state when uncontrolled.
  final bool defaultMenuOpen;

  /// Fired with the tapped tile's id. The menu closes itself when uncontrolled.
  final ValueChanged<String>? onCreate;

  /// Whether to pad the block end by the device's bottom inset. See the class
  /// doc — this cannot double-apply under an ancestor [SafeArea].
  final bool safeArea;

  /// Every destination's hit box, and the action's diameter floor:
  /// `--touch-target-min` (45), which clears the ticket's 44 floor.
  ///
  /// **Deviation, documented.** The source's item is `height: 44`
  /// (`NavigationBottomBar.jsx:141`); the card's own token table names
  /// `--touch-target-min · 45px` as *"the floor every navigation target
  /// clears"*. 45 satisfies both, so the token wins over the inline value.
  static const double itemSize = DabblerSizing.touchTargetMin;

  /// The create tile's glyph plate height — `height: 62`
  /// (`NavigationBottomBar.jsx:112`).
  ///
  /// Off the base-3 grid and stated here rather than borrowed from a spacing
  /// step that happens to be near it.
  static const double createTileHeight = 62;

  /// Turns of rotation the action makes when the menu opens: 45°
  /// (`NavigationBottomBar.jsx:190`), i.e. an eighth turn, which is what
  /// [AnimatedRotation] takes.
  static const double actionOpenTurns = 0.125;

  /// The create menu's grid is `repeat(min(n, 4), 1fr)`
  /// (`NavigationBottomBar.jsx:86`), so tiles beyond the fourth wrap.
  static const int createColumns = 4;

  @override
  State<DabblerNavigationBottomBar> createState() =>
      _DabblerNavigationBottomBarState();
}

class _DabblerNavigationBottomBarState
    extends State<DabblerNavigationBottomBar> {
  late String? _activeUncontrolled = widget.defaultActive;
  late bool _openUncontrolled = widget.defaultMenuOpen;
  List<FocusNode> _nodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(DabblerNavigationBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _open => widget.menuOpen ?? _openUncontrolled;

  /// `props.active ?? uncontrolled`, with the source's
  /// `defaultActive ?? items[0]?.id` fallback (`NavigationBottomBar.jsx:39-41`).
  String? get _activeId {
    final String? controlled = widget.active;
    if (controlled != null) {
      return controlled;
    }
    return _activeUncontrolled ??
        (widget.items.isEmpty ? null : widget.items.first.id);
  }

  /// The active index, or `-1` when nothing matches. Unlike `DabblerTabs` — a
  /// strip that must always show one selected tab — a bar can legitimately be
  /// on a route none of its destinations owns, in which case no chip expands.
  int get _activeIndex =>
      widget.items.indexWhere((DabblerNavigationItem i) => i.id == _activeId);

  /// One [FocusNode] per destination, with the roving tab order applied: every
  /// node but the active one is skipped in traversal.
  void _syncNodes() {
    final int count = widget.items.length;
    if (_nodes.length != count) {
      for (final FocusNode node in _nodes.skip(count)) {
        node.dispose();
      }
      _nodes = <FocusNode>[
        ..._nodes.take(count),
        for (int i = _nodes.length; i < count; i++)
          FocusNode(debugLabel: 'DabblerNavigationBottomBar item $i'),
      ];
    }
    final int active = _activeIndex;
    for (int i = 0; i < count; i++) {
      // With no match the first node keeps the tab order, so the bar is still
      // reachable by keyboard.
      _nodes[i].skipTraversal = i != (active < 0 ? 0 : active);
    }
  }

  void _select(int index) {
    if (index < 0 || index >= widget.items.length) {
      return;
    }
    final DabblerNavigationItem item = widget.items[index];
    if (widget.active == null) {
      setState(() => _activeUncontrolled = item.id);
    }
    widget.onSelect?.call(item.id);
    _nodes[index].requestFocus();
  }

  /// `(activeIndex + dir + n) % n` — wrapping at both ends, as in
  /// `DabblerTabs` and the source's `Tabs.jsx:55-57`.
  void _move(int direction) {
    final int count = widget.items.length;
    if (count == 0) {
      return;
    }
    final int from = _activeIndex < 0 ? 0 : _activeIndex;
    _select((from + direction + count) % count);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        widget.items.isEmpty) {
      return KeyEventResult.ignored;
    }
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
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

  void _toggleMenu() {
    final bool next = !_open;
    if (widget.menuOpen == null) {
      setState(() => _openUncontrolled = next);
    }
    widget.onAction?.call(next);
  }

  void _create(String id) {
    widget.onCreate?.call(id);
    if (widget.menuOpen == null) {
      setState(() => _openUncontrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final bool open = _open;

    final Widget row = Row(
      // `alignItems: open ? 'flex-end' : 'center'` — so the card grows upward
      // from the action's baseline (`NavigationBottomBar.jsx:76`).
      crossAxisAlignment:
          open ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // `gap: 12` — `--space-4`.
      spacing: DabblerSpacing.space4,
      children: <Widget>[
        if (open)
          Expanded(child: _menu(colors))
        else
          Flexible(child: _pill(colors)),
        _action(colors, open: open),
      ],
    );

    if (!widget.safeArea) {
      return row;
    }
    // Zero under an ancestor SafeArea, which has already consumed it.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: row,
    );
  }

  /// The nav pill: `padding: '6px 9px'` (`--space-2` / `--space-3`),
  /// `gap: 6` (`--space-2`), `borderRadius: 9999`
  /// (`NavigationBottomBar.jsx:131-137`).
  Widget _pill(DabblerColors colors) {
    final int active = _activeIndex;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: DabblerSpacing.space2,
          horizontal: DabblerSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: colors.brandPrimary,
          borderRadius: DabblerRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DabblerSpacing.space2,
          children: <Widget>[
            for (int i = 0; i < widget.items.length; i++)
              Flexible(child: _item(colors, index: i, active: i == active)),
          ],
        ),
      ),
    );
  }

  Widget _item(
    DabblerColors colors, {
    required int index,
    required bool active,
  }) {
    final DabblerNavigationItem item = widget.items[index];
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;

    final Widget glyph = DabblerIcon(
      item.icon,
      weight: active ? DabblerIconWeight.bold : DabblerIconWeight.linear,
      size: DabblerSizing.iconMd,
      // `--neutral-400` is `--outline-card`, i.e. [DabblerColors.borderDefault]
      // (`tokens/colors.css:36`). The active chip's content is the brand.
      color: active ? colors.brandPrimary : colors.borderDefault,
    );

    final Widget body = AnimatedContainer(
      duration: duration,
      curve: DabblerMotion.easeOut,
      height: DabblerNavigationBottomBar.itemSize,
      // Inactive is a square of exactly the target size; active grows by
      // `padding: '0 18px'` (`--space-6`) around icon + label.
      width: active ? null : DabblerNavigationBottomBar.itemSize,
      padding: active
          ? const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space6)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? colors.surfaceCard : null,
        borderRadius: DabblerRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // `gap: on ? 8 : 0`. 8 is off the base-3 grid; `--space-3` (9) is the
        // step the system carries and the nearest to it.
        spacing: active ? DabblerSpacing.space3 : 0,
        children: <Widget>[
          glyph,
          if (active)
            Flexible(
              child: Text(
                item.label,
                // `fontSize: 15, fontWeight: 500` — `.t-subheadline` at
                // `--weight-medium`.
                style: DabblerType.subheadline
                    .resolveForDirection(Directionality.of(context))
                    .copyWith(
                      color: colors.brandPrimary,
                      fontWeight: DabblerType.medium,
                    ),
                // `whiteSpace: 'nowrap'`.
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: item.label,
      onTap: () => _select(index),
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _select(index),
          child: DabblerFocusRing(
            focusNode: _nodes[index],
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(child: body),
          ),
        ),
      ),
    );
  }

  /// The detached action: [DabblerFab.size] (56) round, brand-filled, its glyph
  /// rotating 45° into an ✕ while the menu is open.
  Widget _action(DabblerColors colors, {required bool open}) {
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.slow;

    return Semantics(
      container: true,
      button: true,
      expanded: open,
      label: open ? widget.closeLabel : widget.actionLabel,
      onTap: _toggleMenu,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleMenu,
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.pillAll,
            child: DabblerPressScale.gesture(
              child: Container(
                width: DabblerFab.size,
                height: DabblerFab.size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  borderRadius: DabblerRadius.pillAll,
                ),
                child: AnimatedRotation(
                  turns: open ? DabblerNavigationBottomBar.actionOpenTurns : 0,
                  duration: duration,
                  curve: DabblerMotion.easeOut,
                  child: DabblerIcon(
                    widget.actionIcon,
                    weight: DabblerIconWeight.bold,
                    // The card's token table: `--icon-md · 24px` is *"every
                    // navigation glyph — the native Iconsax grid"*. The source's
                    // inline 26 is off that grid and off the 18/24/30 steps.
                    size: DabblerSizing.iconMd,
                    color: colors.onBrand,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The create menu: a card of tiles that replaces the pill **in flow**.
  ///
  /// `padding: 12` (`--space-4`), `gap: 8` → `--space-3` (9, the nearest step),
  /// `borderRadius: var(--radius-xxl)` (`NavigationBottomBar.jsx:84-100`).
  Widget _menu(DabblerColors colors) {
    final List<DabblerNavigationCreateItem> tiles = widget.createItems;
    final int columns = tiles.length < DabblerNavigationBottomBar.createColumns
        ? (tiles.isEmpty ? 1 : tiles.length)
        : DabblerNavigationBottomBar.createColumns;

    final List<Widget> rows = <Widget>[
      for (int start = 0; start < tiles.length; start += columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DabblerSpacing.space3,
          children: <Widget>[
            for (int i = start; i < start + columns; i++)
              Expanded(
                child: i < tiles.length
                    ? _tile(colors, tiles[i])
                    // The last row of a wrapped grid keeps its columns, so the
                    // tiles in it stay the width of the ones above.
                    : const SizedBox.shrink(),
              ),
          ],
        ),
    ];

    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.slow;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.menu,
      child: TweenAnimationBuilder<double>(
        // `opacity 0 → 1`, `scale .92 → 1` on the frame after mount
        // (`NavigationBottomBar.jsx:50-56, 96-98`). The source's 160/180ms sit
        // between the tokens; `--motion-slow` (200) is the enter duration the
        // system uses for a panel.
        key: ValueKey<int>(tiles.length),
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: DabblerMotion.easeOut,
        builder: (BuildContext context, double t, Widget? child) => Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.92 + 0.08 * t,
            // `transformOrigin: bottom left|right` — the inline end, bottom.
            alignment: AlignmentDirectional.bottomEnd.resolve(
              Directionality.of(context),
            ),
            child: child,
          ),
        ),
        child: Container(
          padding: const EdgeInsetsDirectional.all(DabblerSpacing.space4),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: DabblerRadius.xxlAll,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DabblerSpacing.space3,
            children: rows,
          ),
        ),
      ),
    );
  }

  Widget _tile(DabblerColors colors, DabblerNavigationCreateItem tile) {
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      // `gap: 7` → `--space-2` (6), the nearest step.
      spacing: DabblerSpacing.space2,
      children: <Widget>[
        Container(
          height: DabblerNavigationBottomBar.createTileHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // `--neutral-200` is `--surface-sunken` (`tokens/colors.css:34`).
            color: colors.surfaceSunken,
            borderRadius: DabblerRadius.xlAll,
          ),
          child: DabblerIcon(
            tile.icon,
            size: DabblerSizing.iconMd,
            color: colors.textPrimary,
          ),
        ),
        Text(
          tile.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          // `NavigationBottomBar.jsx:121` sets this label to `--text-body`,
          // which is referenced exactly once in the whole design source and
          // declared nowhere in `tokens/`. On the web it silently inherits;
          // Flutter cannot inherit a name that does not exist.
          //
          // **Resolved by `DECISIONS.md` D-007(1):** `--text-body` is a
          // **defect, not a missing token** — it is not added to `colors.css`.
          // The create-tile label instead takes the same role its sibling
          // label in this same widget already takes: the destination-item
          // label at `:503-510`, which is [DabblerType.subheadline] at
          // `--brand-primary`, weight medium. The ruling names the mechanism
          // (mirror the sibling), not a hex, so nothing is invented here.
          style: DabblerType.subheadline
              .resolveForDirection(Directionality.of(context))
              .copyWith(
                color: colors.brandPrimary,
                fontWeight: DabblerType.medium,
              ),
        ),
      ],
    );

    return Semantics(
      container: true,
      button: true,
      label: tile.label,
      onTap: () => _create(tile.id),
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _create(tile.id),
          child: DabblerFocusRing(
            borderRadius: DabblerRadius.xlAll,
            child: DabblerPressScale.gesture(child: body),
          ),
        ),
      ),
    );
  }
}
