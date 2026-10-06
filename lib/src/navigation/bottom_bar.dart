import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../controls/fab.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../surfaces/badge.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_dark_provisional.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

part 'bottom_bar_badge.dart';
part 'bottom_bar_icon_tone.dart';

/// One destination in a [DabblerNavigationBottomBar], transcribed from
/// `NavigationBottomBarItem` in
/// `components/navigation/NavigationBottomBar.d.ts:12-19` (unverified: file not mirrored).
@immutable
class DabblerNavigationItem {
  /// Creates a destination.
  const DabblerNavigationItem({
    required this.id,
    required this.icon,
    required this.label,
    this.unread = false,
    this.count,
    this.badgeLabel,
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

  /// Whether a count-less unread dot (a `DabblerBadge.dot`) sits on the
  /// icon's top-inline-end corner. Default false. See
  /// [DabblerNavigationItemBadge].
  final bool unread;

  /// A count pill (a `DabblerBadge`) on the icon's top-inline-end corner,
  /// shown when positive and capped at `99+`. It wins over [unread]. Null or
  /// zero draws no pill.
  final int? count;

  /// What the indicator means, appended to the item's accessible name:
  /// `Inbox, 3 unread`. The package ships no localised strings, so the host
  /// supplies it (as the top bar's `unreadLabel`). Without it a count is
  /// appended as its bare text and a dot adds nothing.
  final String? badgeLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerNavigationItem &&
          other.id == id &&
          other.icon == icon &&
          other.label == label &&
          other.unread == unread &&
          other.count == count &&
          other.badgeLabel == badgeLabel;

  @override
  int get hashCode => Object.hash(id, icon, label, unread, count, badgeLabel);

  @override
  String toString() => 'DabblerNavigationItem($id)';
}

/// One create-menu tile, transcribed from `NavigationBottomBarCreateItem`
/// (`NavigationBottomBar.d.ts:21-28`, unverified: file not mirrored).
@immutable
class DabblerNavigationCreateItem {
  /// Creates a tile.
  const DabblerNavigationCreateItem({
    required this.id,
    required this.icon,
    required this.label,
    this.iconTone = DabblerNavigationIconTone.neutral,
  });

  /// Stable id, passed to [DabblerNavigationBottomBar.onCreate].
  final String id;

  /// Kebab-case Iconsax name for the tile glyph. Always `linear`.
  final String icon;

  /// Label under the tile. Wraps to two lines if needed.
  final String label;

  /// The glyph plate's fill. Defaults to [DabblerNavigationIconTone.neutral].
  final DabblerNavigationIconTone iconTone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerNavigationCreateItem &&
          other.id == id &&
          other.icon == icon &&
          other.label == label &&
          other.iconTone == iconTone;

  @override
  int get hashCode => Object.hash(id, icon, label, iconTone);

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
/// ## Flat, with the two exceptions D-031 names
///
/// The source draws a drop shadow under both the action and the menu card, and
/// the previous cut dropped both on a blanket flatness reading.
/// `DECISIONS.md` **D-031** settles it: flatness holds, but `--elevation-2` is
/// scoped to **transient overlays**, not to Dialog alone, so the **create
/// menu** carries it; and the **action** inherits `FAB`'s own existing
/// documented shadow exception. Nothing else in this widget is elevated.
class DabblerNavigationBottomBar extends StatefulWidget {
  /// Creates a bottom navigation bar.
  const DabblerNavigationBottomBar({
    super.key,
    this.items = defaultItems,
    this.active,
    this.defaultActive,
    this.onSelect,
    this.actionIcon = 'add',
    this.actionOpenIcon,
    this.actionLabel = 'Create',
    this.onAction,
    this.closeLabel = 'Close menu',
    this.createItems = defaultCreateItems,
    this.menuOpen,
    this.defaultMenuOpen = false,
    this.onCreate,
    this.safeArea = true,
    this.rotateActionOnOpen = true,
    this.mirrorInRtl = true,
  });

  /// Home / Explore / Games / You — the source's own `ITEMS`
  /// (`NavigationBottomBar.jsx:23-28`).
  static const List<DabblerNavigationItem> defaultItems =
      <DabblerNavigationItem>[
        DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
        DabblerNavigationItem(
          id: 'explore',
          icon: 'search-normal',
          label: 'Explore',
        ),
        DabblerNavigationItem(id: 'games', icon: 'game', label: 'Games'),
        DabblerNavigationItem(id: 'you', icon: 'user', label: 'You'),
      ];

  /// Create post / Create game / Create meetup — the source's `CREATE_ITEMS`
  /// (`NavigationBottomBar.jsx:30-34`).
  static const List<DabblerNavigationCreateItem> defaultCreateItems =
      <DabblerNavigationCreateItem>[
        DabblerNavigationCreateItem(
          id: 'post',
          icon: 'edit-2',
          label: 'Create post',
        ),
        DabblerNavigationCreateItem(
          id: 'game',
          icon: 'game',
          label: 'Create game',
        ),
        DabblerNavigationCreateItem(
          id: 'meetup',
          icon: 'people',
          label: 'Create meetup',
        ),
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

  /// Iconsax name the action draws **while the menu is open**, in the same
  /// `bold` weight and [DabblerColors.onBrand] tint as [actionIcon]. Null (the
  /// default) keeps [actionIcon] in both states, so existing callers are
  /// unchanged.
  ///
  /// The Home Feed frame passes `close-circle` (its `fabIcon: createMenuOpen ?
  /// 'close-circle' : 'add'`, `Home Feed.dc.html`): the bold glyph is a
  /// filled disc with the ✕ cut out, so on the brand action it reads as an
  /// [DabblerColors.onBrand] disc carrying a brand ✕. The swap cross-fades
  /// over [DabblerMotion.slow] on [DabblerMotion.easeOut] — the duration the
  /// rotation uses — and is instant under reduced motion. Pair it with
  /// `rotateActionOnOpen: false`, or the open glyph turns 45° as well.
  final String? actionOpenIcon;

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

  /// Every destination's hit box: `height: 44` / `width: 44`
  /// (`NavigationBottomBar.jsx:150,152`).
  ///
  /// **Transcribed literally, against the token.** `--touch-target-min` is 45
  /// and the previous cut snapped to it; the rendered specimen draws 44, and a
  /// 1px taller pill reads as a visibly fatter bar next to the 56 action.
  /// Recorded as a token conflict rather than resolved in favour of the ramp.
  static const double itemSize = DabblerSizing.navItem;

  /// `gap: on ? 8 : 0` on the active chip (`NavigationBottomBar.jsx:149`).
  /// Off the base-3 grid; transcribed rather than rounded to `--space-3` (9).
  static const double activeGap = 8;

  /// `gap: 8` between create tiles (`NavigationBottomBar.jsx:89`). Off-grid,
  /// transcribed.
  static const double createGridGap = 8;

  /// `gap: 7` between a create tile's plate and its label
  /// (`NavigationBottomBar.jsx:104`). Off-grid, transcribed.
  static const double createTileGap = 7;

  /// `size={26}` on the action glyph and on each create-tile glyph
  /// (`NavigationBottomBar.jsx:116,193`). Off the 18/24/30 icon ramp;
  /// transcribed, because 24 visibly under-fills the 56 action.
  static const double glyph26 = DabblerSizing.navGlyphLarge;

  /// `fontSize: 12.5, fontWeight: 500` on the create-tile label
  /// (`NavigationBottomBar.jsx:119-124`).
  static const double createLabelSize = 12.5;

  /// The create tile's glyph plate height — `height: 62`
  /// (`NavigationBottomBar.jsx:110`).
  ///
  /// Off the base-3 grid and stated here rather than borrowed from a spacing
  /// step that happens to be near it.
  static const double createTileHeight = DabblerSizing.navCreateTile;

  /// Whether the action glyph turns [actionOpenTurns] while the menu is open.
  /// The Home Feed design pins it upright
  /// (`[aria-label="Close menu"] > span { transform: rotate(0deg) }`); pass
  /// false for that. Defaults to true, the component source's 45°.
  final bool rotateActionOnOpen;

  /// Whether the bar's layout mirrors under an RTL [Directionality]. Default
  /// true: the pill sits at the inline start and the action at the inline end,
  /// so in Arabic the pill is on the right.
  ///
  /// Pass false to keep the layout **physically** as in LTR (pill on the left,
  /// action on the right, items in the same left-to-right order) while the
  /// labels, the create-menu captions and the type keep following the ambient
  /// direction. The Home Feed frame draws the Arabic bar exactly this way
  /// (`Home_feed_—_Arabic.png`: its component's `autoRtl` probe reads the
  /// direction it has just set, so it never flips). Roving-focus arrow keys
  /// follow the layout, so they stay physical too. Ignored under LTR.
  final bool mirrorInRtl;

  /// Turns of rotation the action makes when the menu opens: 45°
  /// (`NavigationBottomBar.jsx:190`), i.e. an eighth turn, which is what
  /// [AnimatedRotation] takes.
  static const double actionOpenTurns = 0.125;

  /// The create menu's grid is `repeat(min(n, 4), 1fr)`
  /// (`NavigationBottomBar.jsx:88`), so tiles beyond the fourth wrap.
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

  /// Whether the layout follows an ambient RTL (see
  /// [DabblerNavigationBottomBar.mirrorInRtl]).
  bool get _mirrors =>
      widget.mirrorInRtl || Directionality.of(context) != TextDirection.rtl;

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
    final bool rtl =
        Directionality.of(context) == TextDirection.rtl && _mirrors;
    final LogicalKeyboardKey forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final LogicalKeyboardKey back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;

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
      crossAxisAlignment: open
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
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

    final Widget bar = widget.safeArea
        // Zero under an ancestor SafeArea, which has already consumed it.
        ? Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: row,
          )
        : row;
    // Only the layout is pinned: the type and text direction below are read
    // from the ambient context (this State's), not from this wrapper.
    return _mirrors
        ? bar
        : Directionality(textDirection: TextDirection.ltr, child: bar);
  }

  /// The nav pill: `padding: '6px 9px'` (`--space-2` / `--space-3`),
  /// `gap: 6` (`--space-2`), `borderRadius: 9999`
  /// (`NavigationBottomBar.jsx:131-137`).
  ///
  ///
  /// The pill **hugs its content** — `display: flex` with no `flex-grow`
  /// (`NavigationBottomBar.jsx:131-137`): it ends [DabblerSpacing.space3]
  /// after its last item, and the row's `space-between` leaves the free space
  /// between the pill and the action, never inside the pill. The active chip
  /// is as wide as its padding, glyph, gap and label; it never fills.
  ///
  /// On a column too narrow for that natural width the pill degrades in a
  /// fixed order, and never overflows: first the active label ellipsizes (the
  /// inactive squares keep KAN-240's 44 touch floor); only once the active
  /// chip is down to its padding, glyph and gap do the inactive squares give
  /// way, down to their glyph ([_inactiveExtent]).
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
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            final double inactive = _inactiveExtent(constraints.maxWidth);
            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DabblerSpacing.space2,
              children: <Widget>[
                for (int i = 0; i < widget.items.length; i++)
                  // Only the active item is Flexible, and loose: it hugs its
                  // content whenever the content fits, and only ellipsizes on
                  // a column too narrow for it. Sharing the space equally
                  // capped an active chip at a third of the pill and collapsed
                  // its label.
                  if (i == active)
                    Flexible(child: _item(colors, index: i, active: true))
                  else
                    _item(colors, index: i, active: false, extent: inactive),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The active chip's floor: `padding: '0 18px'` around the glyph and the
  /// `gap: 8`, its label ellipsized away. Below it the chip's own row would
  /// overflow.
  static const double _activeFloor =
      DabblerSpacing.space6 * 2 +
      DabblerSizing.iconMd +
      DabblerNavigationBottomBar.activeGap;

  /// The inactive items' width in a pill whose content box may be at most
  /// [available] wide: [DabblerNavigationBottomBar.itemSize] (the 44 square,
  /// KAN-240's touch floor) whenever the active chip can still keep its
  /// [_activeFloor] beside them, else the equal share left over, floored at
  /// the glyph ([DabblerSizing.iconMd]). Only a narrow column with four or
  /// more destinations (320 wide) ever reaches the share.
  double _inactiveExtent(double available) {
    final int count = widget.items.length;
    final int inactiveCount = _activeIndex < 0 ? count : count - 1;
    if (inactiveCount == 0 || !available.isFinite) {
      return DabblerNavigationBottomBar.itemSize;
    }
    final double activeFloor = _activeIndex < 0 ? 0 : _activeFloor;
    final double share =
        (available - DabblerSpacing.space2 * (count - 1) - activeFloor) /
        inactiveCount;
    return share.clamp(
      DabblerSizing.iconMd,
      DabblerNavigationBottomBar.itemSize,
    );
  }

  Widget _item(
    DabblerColors colors, {
    required int index,
    required bool active,
    double extent = DabblerNavigationBottomBar.itemSize,
  }) {
    final DabblerNavigationItem item = widget.items[index];
    final Duration duration = DabblerMotion.reduceMotion(context)
        ? Duration.zero
        : DabblerMotion.base;

    final Widget glyph = DabblerNavigationItemBadge.wrap(
      item: item,
      colors: colors,
      glyph: DabblerIcon(
        item.icon,
        weight: active ? DabblerIconWeight.bold : DabblerIconWeight.linear,
        size: DabblerSizing.iconMd,
        // `--neutral-400` is `--outline-card`, i.e.
        // [DabblerColors.borderDefault] (`tokens/colors.css:36`). The active
        // chip's content is the brand.
        color: active ? colors.brandPrimary : colors.borderDefault,
      ),
    );

    // Width is the content's own: an inactive item is its icon at the 44px
    // minimum (a square), an active one grows by `padding: '0 18px'`
    // (`--space-6`) around icon + label. It is NOT a `width: null <-> 44`
    // tween: `AnimatedContainer` cannot interpolate between finite and
    // unbounded constraints (an assertion in debug, a collapsed item in
    // release), which broke the first tap. The fill and padding still fade; the
    // width follows the content at once (an `AnimatedSize` here overflows the
    // label row for a frame while it shrinks).
    final Widget body = AnimatedContainer(
      duration: duration,
      curve: DabblerMotion.easeOut,
      constraints: const BoxConstraints(
        minWidth: DabblerNavigationBottomBar.itemSize,
        minHeight: DabblerNavigationBottomBar.itemSize,
        maxHeight: DabblerNavigationBottomBar.itemSize,
      ),
      padding: active
          ? const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space6,
            )
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: active ? colors.surfaceCard : null,
        borderRadius: DabblerRadius.pillAll,
      ),
      // `Center` with factors of 1 rather than the container's own `alignment`:
      // an aligned container fills the width it is offered, which made the
      // active chip (a `Flexible`) swallow the whole pill. The factors hug the
      // content, and the 44 minimum still centres a lone glyph.
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // `gap: on ? 8 : 0` — transcribed literally, see [activeGap].
          spacing: active ? DabblerNavigationBottomBar.activeGap : 0,
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
                  textDirection: Directionality.of(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: DabblerNavigationItemBadge.semanticLabel(item),
      onTap: () => _select(index),
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _select(index),
          child: DabblerFocusRing(
            focusNode: _nodes[index],
            borderRadius: DabblerRadius.pillAll,
            // An inactive item is exactly [extent] wide: the 44 square, or the
            // narrower share [_inactiveExtent] gives it on a column too narrow
            // even for an ellipsized active chip. Always a ConstrainedBox (a no-op
            // when active) so switching items keeps the tree, and the fill
            // fade, intact; outside the AnimatedContainer, which cannot tween
            // a finite width against an unbounded one.
            child: ConstrainedBox(
              constraints: active
                  ? const BoxConstraints()
                  : BoxConstraints.tightFor(width: extent),
              child: DabblerPressScale.gesture(child: body),
            ),
          ),
        ),
      ),
    );
  }

  /// The detached action: [DabblerFab.size] (56) round, brand-filled, its glyph
  /// rotating 45° into an ✕ while the menu is open, or swapping to
  /// [DabblerNavigationBottomBar.actionOpenIcon] when one is set.
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
                  // D-031: the detached action inherits `FAB`'s own existing
                  // documented shadow exception — it IS a FAB, at
                  // [DabblerFab.size], and the source draws the shadow
                  // (`NavigationBottomBar.jsx:184`). Deliberately
                  // [DabblerFab.shadow] and not [DabblerElevation.dialogFor];
                  // `fab.dart` is explicit that the two are different shadows.
                  boxShadow: DabblerFab.shadow,
                ),
                child: AnimatedRotation(
                  turns: open && widget.rotateActionOnOpen
                      ? DabblerNavigationBottomBar.actionOpenTurns
                      : 0,
                  duration: duration,
                  curve: DabblerMotion.easeOut,
                  // Cross-fades closed glyph <-> [actionOpenIcon]. With no
                  // open icon the key never changes, so nothing animates.
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: DabblerMotion.easeOut,
                    switchOutCurve: DabblerMotion.easeOut,
                    child: _actionGlyph(colors, _actionGlyphName(open)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The glyph the action draws: [DabblerNavigationBottomBar.actionOpenIcon]
  /// while open when one is set, else [DabblerNavigationBottomBar.actionIcon].
  String _actionGlyphName(bool open) =>
      open ? (widget.actionOpenIcon ?? widget.actionIcon) : widget.actionIcon;

  Widget _actionGlyph(DabblerColors colors, String name) => DabblerIcon(
    name,
    key: ValueKey<String>(name),
    weight: DabblerIconWeight.bold,
    // `size={26}` (`NavigationBottomBar.jsx:193`) — off the 18/24/30 ramp,
    // transcribed: 24 under-fills the 56 disc.
    size: DabblerNavigationBottomBar.glyph26,
    color: colors.onBrand,
  );

  /// The create menu: a card of tiles that replaces the pill **in flow**.
  ///
  /// `padding: 12` (`--space-4`), `gap: 8` (off-grid, transcribed),
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
          spacing: DabblerNavigationBottomBar.createGridGap,
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
        // (`NavigationBottomBar.jsx:53-59, 96-98`). The source's 160/180ms sit
        // between the tokens; `--motion-slow` (200) is the enter duration the
        // system uses for a panel.
        key: ValueKey<int>(tiles.length),
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: DabblerMotion.easeOut,
        builder: (BuildContext context, double t, Widget? child) => Opacity(
          opacity: t,
          // On the first frame `t` is 0, and an [Opacity] of 0 drops its
          // subtree from the semantics tree. The menu publishes
          // [SemanticsRole.menu], which asserts *"a menu cannot be empty"* —
          // so the enter animation's own first frame tripped it. The tiles are
          // a real menu throughout the fade; keep them announced.
          alwaysIncludeSemantics: true,
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
            // `DECISIONS.md` **D-031**: the create menu joins Dialog in
            // carrying `--elevation-2`, the system's one legal shadow, which
            // the ruling scopes to transient overlays rather than to Dialog
            // alone. The source draws a shadow here
            // (`NavigationBottomBar.jsx:93`) and the previous cut dropped it
            // on a blanket flatness reading.
            //
            // [DabblerElevation]'s own doc still says *"Dialog (DS-702)
            // only"*. That is now stale; the tokens file is not this ticket's
            // to edit, so it is reported rather than changed here.
            boxShadow: DabblerElevation.dialogFor(colors.brightness),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DabblerNavigationBottomBar.createGridGap,
            children: rows,
          ),
        ),
      ),
    );
  }

  Widget _tile(DabblerColors colors, DabblerNavigationCreateItem tile) {
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      // `gap: 7` — transcribed literally, see [createTileGap].
      spacing: DabblerNavigationBottomBar.createTileGap,
      children: <Widget>[
        Container(
          height: DabblerNavigationBottomBar.createTileHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // `--neutral-200` is `--surface-sunken` (`tokens/colors.css:34`)
            // by default; per-tile tone per DSG-NEW-001.
            color: dabblerNavigationIconPlateFor(tile.iconTone, colors),
            borderRadius: DabblerRadius.xlAll,
          ),
          child: DabblerIcon(
            tile.icon,
            // `size={26}` (`NavigationBottomBar.jsx:116`) — off-ramp,
            // transcribed.
            size: DabblerNavigationBottomBar.glyph26,
            color: colors.textPrimary,
          ),
        ),
        Text(
          tile.label,
          textAlign: TextAlign.center,
          textDirection: Directionality.of(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          // `fontSize: 12.5, fontWeight: 500, color: var(--text-body)`
          // (`NavigationBottomBar.jsx:119-124`).
          //
          // `--text-body` is referenced exactly once in the whole design source
          // and declared nowhere in `tokens/`; **`DECISIONS.md` D-007(1)** rules
          // it a defect rather than a missing token. The rendered specimen
          // paints it as ordinary body ink on the card, so it resolves to
          // [DabblerColors.textPrimary] here.
          //
          // The previous cut instead mirrored the *destination* label —
          // subheadline (15) at `--brand-primary` — which draws the tiles'
          // captions half again too large and purple against a white card. The
          // drawing wins: 12.5 / medium / body ink.
          style: DabblerType.caption1
              .resolveForDirection(Directionality.of(context))
              .copyWith(
                fontSize: DabblerNavigationBottomBar.createLabelSize,
                height: 1.25,
                color: colors.textPrimary,
                fontWeight: DabblerType.medium,
              ),
        ),
      ],
    );

    return Semantics(
      container: true,
      button: true,
      // `role="menuitem"` (`NavigationBottomBar.jsx:101`). Also a framework
      // requirement, not just a transcription: a node carrying
      // [SemanticsRole.menu] asserts *"a menu cannot be empty"* unless its
      // children carry [SemanticsRole.menuItem]. The menu published the role
      // and the tiles did not, so opening the create menu tripped the
      // assertion — invisible until the gallery gained a specimen that opens
      // it.
      role: SemanticsRole.menuItem,
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
