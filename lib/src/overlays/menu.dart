import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'sheet.dart';

/// Which corner of the trigger the popover hangs from, transcribed from the
/// `placement` union in `components/overlays/Menu.d.ts:38`.
///
/// `start` and `end` are **inline** edges, not left and right: under RTL
/// [bottomStart] anchors to the trigger's right edge, which is the source's own
/// rule (`Menu.prompt.md` — *RTL behaviour*).
enum DabblerMenuPlacement {
  /// Below the trigger, inline-start edges aligned. The default.
  bottomStart,

  /// Below the trigger, inline-end edges aligned.
  bottomEnd,

  /// Above the trigger, inline-start edges aligned.
  topStart,

  /// Above the trigger, inline-end edges aligned.
  topEnd,
}

/// The semantic tone of a [DabblerMenuEntry]'s leading tile
/// (`Menu.d.ts:11-15`).
///
/// Deliberately a closed set of **semantic names**: the source states there is
/// *"no `background` / hex prop"* (`Menu.prompt.md` — *Leading-icon tone*), so
/// a tone resolves through the theme and follows dark mode rather than being
/// dictated by the call site.
enum DabblerMenuIconTone {
  /// `--color-brand-primary`.
  brand,

  /// `--color-status-success`.
  success,

  /// `--color-status-warning`.
  warning,

  /// `--color-status-error`.
  error,

  /// `--color-status-info`.
  info,

  /// `--color-text-secondary`. Not part of the `--color-status-*` API — see
  /// [DabblerMenuItem.toneColorOf].
  neutral,
}

/// A menu item's text tone — `tone` in `Menu.d.ts:16`.
enum DabblerMenuItemTone {
  /// `--color-text-primary`.
  defaultTone,

  /// `--color-status-error-strong`. Destructive actions go last, after a
  /// separator (`Menu.prompt.md` — *Composition rules*).
  destructive,
}

/// The list's accessibility role — `role` in `Menu.d.ts:52`.
enum DabblerMenuRole {
  /// `role="menu"` with `role="menuitem"` children. The default.
  menu,

  /// `role="listbox"`, which is what `Select` (DS-601) composes this list as.
  /// Flutter's nearest node role is [SemanticsRole.list]; see
  /// [DabblerMenuList] → *Roles*.
  listbox,
}

/// One row of a [DabblerMenu] — `MenuItemSpec` in `Menu.d.ts:3-28`.
///
/// A separator is an entry too, exactly as in the source, where `separator:
/// true` replaces the item rather than being a different array
/// (`Menu.jsx:135`). That keeps one ordered list, so an item inserted before a
/// separator does not have to be moved between two collections.
@immutable
class DabblerMenuEntry {
  /// An actionable row.
  const DabblerMenuEntry({
    required this.label,
    this.id,
    this.icon,
    this.iconTone,
    this.tone = DabblerMenuItemTone.defaultTone,
    this.disabled = false,
    this.selected = false,
    this.trailing,
    this.onSelect,
  }) : isSeparator = false;

  /// A hairline rule between groups — `{ separator: true }` in the source.
  const DabblerMenuEntry.separator({this.id})
      : label = '',
        icon = null,
        iconTone = null,
        tone = DabblerMenuItemTone.defaultTone,
        disabled = true,
        selected = false,
        trailing = null,
        onSelect = null,
        isSeparator = true;

  /// The row's text. `.t-subheadline`, sentence case.
  final String label;

  /// Stable identity, used as the widget key and by `Select` for its value.
  final String? id;

  /// The kebab-case Iconsax name drawn at [DabblerSizing.iconSm] (18), passed
  /// straight to [DabblerIcon]. Unlike DS-300's Tabs — which took a [Widget]
  /// slot because Icon did not exist yet — this is the source's own `string`
  /// name, because `lib/src/foundations/icon.dart` now resolves it.
  final String? icon;

  /// Omit for a bare glyph; set a tone for the 30px tinted tile.
  final DabblerMenuIconTone? iconTone;

  /// Default or destructive text colour.
  final DabblerMenuItemTone tone;

  /// Skipped by the arrow keys and type-ahead, and rendered at 0.45 opacity,
  /// but **kept in the list** (`Menu.prompt.md` — *Accessibility*).
  final bool disabled;

  /// Draws a trailing brand tick (`Menu.d.ts:19`).
  final bool selected;

  /// A node at the inline end — a shortcut hint, a count, a Badge.
  final Widget? trailing;

  /// Called with this entry when the row is chosen. The source passes the item
  /// back to its own handler (`Menu.jsx:88`).
  final ValueChanged<DabblerMenuEntry>? onSelect;

  /// Whether this entry draws a [DabblerMenuSeparator] instead of a row.
  final bool isSeparator;

  /// Whether the arrow keys, type-ahead and Enter may land on this entry.
  bool get isActivatable => !isSeparator && !disabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DabblerMenuEntry &&
          other.label == label &&
          other.id == id &&
          other.icon == icon &&
          other.iconTone == iconTone &&
          other.tone == tone &&
          other.disabled == disabled &&
          other.selected == selected &&
          other.trailing == trailing &&
          other.onSelect == onSelect &&
          other.isSeparator == isSeparator;

  @override
  int get hashCode => Object.hash(label, id, icon, iconTone, tone, disabled,
      selected, trailing, onSelect, isSeparator);

  @override
  String toString() =>
      isSeparator ? 'DabblerMenuEntry.separator()' : 'DabblerMenuEntry($label)';
}

/// Where the popover landed, and which placement that actually is.
///
/// [DabblerMenu.positionFor] returns this rather than a bare [Offset] so a
/// caller — and the test suite — can ask *"did it flip?"* without re-deriving
/// the answer from coordinates.
@immutable
class DabblerMenuPosition {
  /// Creates a resolved position.
  const DabblerMenuPosition({required this.offset, required this.placement});

  /// The popover's top-left corner, in viewport coordinates.
  final Offset offset;

  /// The placement after flipping. Compare it with the requested one to know
  /// whether either axis flipped.
  final DabblerMenuPlacement placement;

  @override
  bool operator ==(Object other) =>
      other is DabblerMenuPosition &&
      other.offset == offset &&
      other.placement == placement;

  @override
  int get hashCode => Object.hash(offset, placement);

  @override
  String toString() => 'DabblerMenuPosition($offset, $placement)';
}

/// Menu · MenuItem · MenuSeparator — an anchored list of 2–8 actions for a
/// specific object, and the option list behind `Select` (DS-601).
///
/// Transcribed from `components/overlays/Menu.jsx`, `Menu.d.ts` and
/// `Menu.prompt.md`, with the specimen `components/overlays/overlays.card.html`
/// confirming the behaviours.
///
/// ## Two presentations, one call site
///
/// Above 480px this is an anchored popover: [DabblerColors.surfaceCard],
/// a 1px [DabblerColors.borderDefault] hairline, [DabblerRadius.lg],
/// [DabblerSpacing.space2] of padding, 200–320 wide and at most
/// [maxHeightFraction] of the viewport tall. Below it, *"the same `items`
/// render inside a `Sheet`"* (`Menu.prompt.md` — *Responsive behaviour*),
/// because a popover pinned to a 24px icon is hard to hit at phone width.
/// **Nothing in the call site changes.**
///
/// The sheet is DS-701's [DabblerSheet] **widget**, not [showDabblerSheet]:
/// Menu already owns this overlay entry, its item list and its selection
/// state, and pushing a second route would put that state behind a
/// [Navigator] the menu does not control.
///
/// ## Flat
///
/// No shadow: *"the hairline does the separating"* (`Menu.prompt.md` —
/// *Visual*). [DabblerElevation.dialogFor] is Dialog's and is not referenced.
///
/// ## Viewport-aware flipping
///
/// [positionFor] is the whole of it, and it is a pure function of the anchor
/// rect, the popover size, the viewport, the requested placement and the text
/// direction — so it is tested near all four edges directly, without a
/// pointer. It flips to the block start when the popover would overflow the
/// bottom, and to the other inline edge when it would overflow the inline one
/// (`Menu.jsx:52-60`), then clamps into the viewport as a last resort.
///
/// ## Keyboard
///
/// Owned by [DabblerMenuList]: roving arrow-key focus, Home/End, type-ahead,
/// Enter/Space. `Escape` closes and so does a pointer down outside, both
/// handled here because both are properties of being *open*.
///
/// ## RTL
///
/// Nothing in this file names `left` or `right` as a design decision.
/// [positionFor] mirrors the inline axis on [TextDirection], padding is
/// [EdgeInsetsDirectional], and text aligns to the start.
class DabblerMenu extends StatefulWidget {
  /// Creates a menu.
  const DabblerMenu({
    super.key,
    this.trigger,
    this.items = const <DabblerMenuEntry>[],
    this.placement = DabblerMenuPlacement.bottomStart,
    this.open,
    this.onOpenChanged,
    this.onSelected,
    this.label,
    this.header,
    this.fullWidth = false,
    this.closeOnSelect = true,
    this.role = DabblerMenuRole.menu,
  });

  /// `max-width: 479px` — the viewport width at or below which the menu is a
  /// sheet (`Menu.jsx:39`). 480 is the first width that stays a popover.
  static const double sheetBreakpoint = 480;

  /// `min-width: 200` (`Menu.jsx:120`). Not a spacing step; the source's own
  /// popover range.
  static const double minPopoverWidth = 200;

  /// `max-width: 320` (`Menu.jsx:120`).
  static const double maxPopoverWidth = 320;

  /// `max-height: 45dvh` (`Menu.jsx:121`), as a fraction of the viewport.
  static const double maxHeightFraction = 0.45;

  /// `calc(100% + var(--space-2))` — the gap between trigger and popover
  /// (`Menu.jsx:118`).
  static const double anchorGap = DabblerSpacing.space2;

  /// The viewport margin the source keeps on the inline axis — `vw - 8`
  /// (`Menu.jsx:59`). A literal in the source rather than a spacing token, and
  /// transcribed as one here; it is applied on all four edges so the clamp is
  /// symmetric.
  static const double viewportMargin = 8;

  /// The sheet detent the source opens at — `detents={[0.45]}`
  /// (`Menu.jsx:174`).
  static const List<double> sheetDetents = <double>[0.45];

  /// The element that opens the menu. It is wrapped, never rebuilt: the
  /// source's `cloneElement` adds `aria-haspopup` / `aria-expanded`, and the
  /// Flutter equivalent is the [Semantics] wrapper this widget puts around it.
  ///
  /// It must be a real interactive element — an icon Button — not a bare span
  /// (`Menu.prompt.md` — *Composition rules*).
  final Widget? trigger;

  /// The rows, in order. Separators are entries; see [DabblerMenuEntry].
  final List<DabblerMenuEntry> items;

  /// Preferred side. Flips automatically; see [positionFor].
  final DabblerMenuPlacement placement;

  /// Controlled open state. Null leaves the menu uncontrolled, which is the
  /// source's default (`Menu.jsx:29-33`).
  final bool? open;

  /// Reports every open and close, controlled or not.
  final ValueChanged<bool>? onOpenChanged;

  /// Called with the chosen entry, after its own [DabblerMenuEntry.onSelect].
  final ValueChanged<DabblerMenuEntry>? onSelected;

  /// The accessible name of the list, and the sheet's title below
  /// [sheetBreakpoint] (`Menu.d.ts:47`).
  final String? label;

  /// A node pinned above the items — `Select` passes its search field here
  /// (`Menu.d.ts:49`).
  final Widget? header;

  /// Match the trigger's width instead of the 200–320 popover range
  /// (`Menu.d.ts:51`). This is how `Select` makes its dropdown the width of
  /// its field.
  final bool fullWidth;

  /// Close after a selection. Default true (`Menu.d.ts:52`).
  final bool closeOnSelect;

  /// `menu` or `listbox`. `Select` passes `listbox`.
  final DabblerMenuRole role;

  /// Where a popover of [childSize] goes, given its trigger and the viewport.
  ///
  /// Pure, and the single source of truth for AC1. The block axis flips when
  /// the preferred side would overflow **and** the opposite side fits; the
  /// inline axis flips when the preferred edge would overflow and the opposite
  /// edge does not. Whatever survives that is clamped inside
  /// [viewportMargin], so a popover taller or wider than the space available
  /// is still fully on screen rather than half off it.
  static DabblerMenuPosition positionFor({
    required Rect anchor,
    required Size childSize,
    required Size viewport,
    required DabblerMenuPlacement placement,
    required TextDirection textDirection,
    double gap = anchorGap,
    double margin = viewportMargin,
  }) {
    final bool wantsTop = placement == DabblerMenuPlacement.topStart ||
        placement == DabblerMenuPlacement.topEnd;
    final bool wantsEnd = placement == DabblerMenuPlacement.bottomEnd ||
        placement == DabblerMenuPlacement.topEnd;

    // --- Block axis ---
    final double below = anchor.bottom + gap;
    final double above = anchor.top - gap - childSize.height;
    final bool belowFits = below + childSize.height <= viewport.height - margin;
    final bool aboveFits = above >= margin;
    final bool flipBlock =
        wantsTop ? (!aboveFits && belowFits) : (!belowFits && aboveFits);
    final bool onTop = wantsTop != flipBlock;
    double y = onTop ? above : below;

    // --- Inline axis, mirrored for RTL ---
    final bool rtl = textDirection == TextDirection.rtl;
    // Aligning the popover's inline-start edge with the trigger's means the
    // left edges in LTR and the right edges in RTL.
    final double startAligned =
        rtl ? anchor.right - childSize.width : anchor.left;
    final double endAligned =
        rtl ? anchor.left : anchor.right - childSize.width;
    bool overflows(double x) =>
        x < margin || x + childSize.width > viewport.width - margin;

    double x = wantsEnd ? endAligned : startAligned;
    bool flipInline = false;
    if (overflows(x)) {
      final double alternative = wantsEnd ? startAligned : endAligned;
      if (!overflows(alternative)) {
        x = alternative;
        flipInline = true;
      }
    }

    y = y.clamp(
      margin,
      math.max(margin, viewport.height - margin - childSize.height),
    );
    x = x.clamp(
      margin,
      math.max(margin, viewport.width - margin - childSize.width),
    );

    final bool resolvedEnd = wantsEnd != flipInline;
    return DabblerMenuPosition(
      offset: Offset(x, y),
      placement: onTop
          ? (resolvedEnd
              ? DabblerMenuPlacement.topEnd
              : DabblerMenuPlacement.topStart)
          : (resolvedEnd
              ? DabblerMenuPlacement.bottomEnd
              : DabblerMenuPlacement.bottomStart),
    );
  }

  @override
  State<DabblerMenu> createState() => _DabblerMenuState();
}

class _DabblerMenuState extends State<DabblerMenu> {
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();

  bool _uncontrolledOpen = false;

  /// Whether a deferred portal change is already queued, so a rebuild storm
  /// inside one frame does not queue several.
  bool _syncQueued = false;

  bool get _open => widget.open ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    // The controller is only usable once the [OverlayPortal] has built and
    // attached itself, so an initially-open menu shows on the first frame.
    // [_syncPortal] defers the show itself; this only starts it.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        _syncPortal();
      }
    });
  }

  @override
  void didUpdateWidget(DabblerMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPortal();
  }

  /// Brings the portal into line with [_open].
  ///
  /// **Deferred whenever this runs inside a frame's build phase**, in both
  /// directions. A controlled menu is opened and closed by its owner
  /// rebuilding with a new `open`, which reaches this state through
  /// [didUpdateWidget] — and `didUpdateWidget` always runs in
  /// [SchedulerPhase.persistentCallbacks], where **both**
  /// [OverlayPortalController.show] and `hide` assert
  /// (`overlay.dart:2068` and `:2080`): either would mutate the overlay's
  /// child list while the tree is being built. Queuing the change for the end
  /// of the frame applies it on the very next one.
  ///
  /// Found by DS-601, which cannot work around it: `Select` owns `open`
  /// because its arrow rotation, its `focused || open` border and its focus
  /// return all read it, so the state change is always the owner's rebuild.
  void _syncPortal() {
    if (_open == _portal.isShowing) {
      return;
    }
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    final bool duringFrame = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (!duringFrame) {
      _apply();
      return;
    }
    if (_syncQueued) {
      return;
    }
    _syncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _syncQueued = false;
      if (mounted) {
        _apply();
      }
    });
  }

  /// Shows or hides the portal now. Only called outside the build phase.
  void _apply() {
    if (_open && !_portal.isShowing) {
      _portal.show();
    } else if (!_open && _portal.isShowing) {
      _portal.hide();
    }
  }

  void _setOpen(bool value) {
    if (widget.open == null) {
      setState(() => _uncontrolledOpen = value);
    }
    widget.onOpenChanged?.call(value);
    // A controlled menu whose owner ignores the callback stays put, which is
    // the source's behaviour too; one whose owner honours it arrives back
    // through [didUpdateWidget].
    _syncPortal();
  }

  void _close() {
    if (_open) {
      _setOpen(false);
    }
  }

  void _onSelected(DabblerMenuEntry entry) {
    entry.onSelect?.call(entry);
    widget.onSelected?.call(entry);
    if (widget.closeOnSelect) {
      _close();
    }
  }

  /// The trigger's rect in the overlay's coordinate space, or null before it
  /// has been laid out.
  Rect? _anchorRect(BuildContext overlayContext) {
    final RenderBox? anchor =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    // The overlay's own box, not the builder context's: the overlay child has
    // not been laid out when this first runs, so its render object is null.
    final RenderBox? overlay = Overlay.of(overlayContext)
        .context
        .findRenderObject() as RenderBox?;
    if (anchor == null || overlay == null || !anchor.hasSize) {
      return null;
    }
    final Offset topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlay);
    return topLeft & anchor.size;
  }

  Widget _list({required bool inSheet}) {
    return DabblerMenuList(
      items: widget.items,
      label: widget.label,
      role: widget.role,
      header: widget.header,
      onSelected: _onSelected,
      // The popover is its own surface; inside the sheet the panel already is
      // one, so the list draws no second card (`Menu.jsx:113`, where the sheet
      // branch keeps only the flex column).
      decorated: !inSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool asSheet =
        MediaQuery.sizeOf(context).width < DabblerMenu.sheetBreakpoint;

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (BuildContext overlayContext) {
        final Widget content = asSheet
            ? DabblerSheet(
                onClose: _close,
                title: widget.label,
                detents: DabblerMenu.sheetDetents,
                child: _list(inSheet: true),
              )
            : _popover(overlayContext);

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): _close,
          },
          child: FocusScope(autofocus: true, child: content),
        );
      },
      child: Semantics(
        // The source's `aria-haspopup` / `aria-expanded` on the trigger.
        expanded: _open,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _setOpen(!_open),
          child: SizedBox(
            key: _anchorKey,
            width: widget.fullWidth ? double.infinity : null,
            child: widget.trigger,
          ),
        ),
      ),
    );
  }

  Widget _popover(BuildContext overlayContext) {
    final Rect? anchor = _anchorRect(overlayContext);
    if (anchor == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: <Widget>[
        // Outside dismiss. **Deviation, documented.** The web listens for a
        // document `pointerdown` and does not block the page; a full-screen
        // absorber is the Flutter convention for a popup and also stops the
        // content behind being scrolled while the menu is open. The pointer
        // that closes the menu therefore does not also activate what is under
        // it — which is what `Menu.prompt.md` wants of a dismissal anyway.
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (PointerDownEvent _) => _close(),
          ),
        ),
        CustomSingleChildLayout(
          delegate: _DabblerMenuLayout(
            anchor: anchor,
            placement: widget.placement,
            textDirection: Directionality.of(overlayContext),
            fullWidth: widget.fullWidth,
          ),
          child: _list(inSheet: false),
        ),
      ],
    );
  }
}

/// Positions the popover with [DabblerMenu.positionFor] and constrains it to
/// the source's 200–320 × 45dvh box.
class _DabblerMenuLayout extends SingleChildLayoutDelegate {
  const _DabblerMenuLayout({
    required this.anchor,
    required this.placement,
    required this.textDirection,
    required this.fullWidth,
  });

  final Rect anchor;
  final DabblerMenuPlacement placement;
  final TextDirection textDirection;
  final bool fullWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double available =
        constraints.maxWidth - DabblerMenu.viewportMargin * 2;
    final double minWidth = fullWidth
        ? math.min(anchor.width, math.max(0, available))
        : math.min(DabblerMenu.minPopoverWidth, math.max(0, available));
    final double maxWidth = fullWidth
        ? math.max(minWidth, math.min(anchor.width, available))
        : math.max(minWidth, math.min(DabblerMenu.maxPopoverWidth, available));
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      maxHeight: constraints.maxHeight * DabblerMenu.maxHeightFraction,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      DabblerMenu.positionFor(
        anchor: anchor,
        childSize: childSize,
        viewport: size,
        placement: placement,
        textDirection: textDirection,
      ).offset;

  @override
  bool shouldRelayout(_DabblerMenuLayout oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.placement != placement ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.fullWidth != fullWidth;
}

/// The item list itself — the reusable half of DS-700.
///
/// It is public and standalone because `Select` (DS-601) and `TimePicker`
/// (DS-806) compose *this*, not [DabblerMenu]: they own their own trigger,
/// their own open state and, in TimePicker's case, their own container, and
/// the source is explicit that they must *"not fork a second popover"*
/// (`Menu.prompt.md` — *Composition rules*). Everything AC3 asks for lives
/// here, so composing the list is enough to inherit it.
///
/// ## Keyboard (AC3)
///
/// * **Roving focus.** Only the active row is in the tab order; every other
///   node carries [FocusNode.skipTraversal], the same contract DS-300's Tabs
///   set up. ArrowDown/ArrowUp cycle and wrap, Home/End jump to the ends, and
///   focus follows the active row so pointer and keyboard agree.
/// * **Type-ahead.** Typing letters jumps to the first activatable row whose
///   label starts with the buffer; the buffer resets after
///   [typeAheadTimeout] (`Menu.jsx:99`).
/// * **Enter / Space** select the active row.
/// * Disabled rows stay visible and are skipped by both
///   (`Menu.prompt.md` — *Accessibility*).
///
/// ## Roles
///
/// [DabblerMenuRole.menu] maps to [SemanticsRole.menu] with
/// [SemanticsRole.menuItem] rows; [DabblerMenuRole.listbox] maps to
/// [SemanticsRole.list] with [SemanticsRole.listItem] rows, which is the
/// closest Flutter carries — there is no `listbox` node role, and `menuItem`
/// asserts unless its ancestor is a menu, so the pair must move together.
/// An empty list drops the role entirely, because Flutter's own invariant is
/// that *"a menu cannot be empty"* (`semantics.dart:_semanticsMenu`).
class DabblerMenuList extends StatefulWidget {
  /// Creates a menu list.
  const DabblerMenuList({
    super.key,
    required this.items,
    this.label,
    this.role = DabblerMenuRole.menu,
    this.header,
    this.onSelected,
    this.decorated = true,
    this.autofocus = true,
  });

  /// `700ms` — the type-ahead buffer's reset window (`Menu.jsx:99`).
  static const Duration typeAheadTimeout = Duration(milliseconds: 700);

  /// The rows, in order.
  final List<DabblerMenuEntry> items;

  /// The list's accessible name.
  final String? label;

  /// Menu or listbox; see the class doc.
  final DabblerMenuRole role;

  /// A node above the rows, inside the same scroll area as the source's
  /// (`Menu.jsx:134`).
  final Widget? header;

  /// Called with the chosen entry. [DabblerMenu] adds closing to this.
  final ValueChanged<DabblerMenuEntry>? onSelected;

  /// Whether to draw the popover card — surface, hairline, radius and padding.
  /// `false` inside a Sheet, which is already the surface.
  final bool decorated;

  /// Whether the list takes focus when it appears, so the arrow keys work
  /// without a click first (`Menu.jsx:163`).
  final bool autofocus;

  @override
  State<DabblerMenuList> createState() => _DabblerMenuListState();
}

class _DabblerMenuListState extends State<DabblerMenuList> {
  List<FocusNode> _nodes = <FocusNode>[];
  int _active = -1;
  String _typed = '';
  Timer? _typedReset;

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(DabblerMenuList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  @override
  void dispose() {
    _typedReset?.cancel();
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// One [FocusNode] per entry, with the roving tab order applied: every node
  /// but the active one is skipped in traversal.
  void _syncNodes() {
    final int count = widget.items.length;
    if (_nodes.length != count) {
      for (final FocusNode node in _nodes.skip(count)) {
        node.dispose();
      }
      _nodes = <FocusNode>[
        ..._nodes.take(count),
        for (int i = _nodes.length; i < count; i++)
          FocusNode(debugLabel: 'DabblerMenuList item $i'),
      ];
    }
    if (_active >= count) {
      _active = -1;
    }
    for (int i = 0; i < count; i++) {
      _nodes[i].skipTraversal = i != _active;
    }
  }

  List<int> get _activatable => <int>[
        for (int i = 0; i < widget.items.length; i++)
          if (widget.items[i].isActivatable) i,
      ];

  void _setActive(int index, {bool focus = true}) {
    if (index < 0 || index >= widget.items.length) {
      return;
    }
    setState(() {
      _active = index;
      _syncNodes();
    });
    if (focus) {
      _nodes[index].requestFocus();
    }
  }

  /// `(at + dir + list.length) % list.length`, cycling over activatable rows
  /// only (`Menu.jsx:78-84`).
  void _move(int direction) {
    final List<int> list = _activatable;
    if (list.isEmpty) {
      return;
    }
    final int at = list.indexOf(_active);
    final int next = at == -1
        ? (direction > 0 ? 0 : list.length - 1)
        : (at + direction + list.length) % list.length;
    _setActive(list[next]);
  }

  void _select(int index) {
    if (index < 0 || index >= widget.items.length) {
      return;
    }
    final DabblerMenuEntry entry = widget.items[index];
    if (!entry.isActivatable) {
      return;
    }
    widget.onSelected?.call(entry);
  }

  /// Typing letters jumps to the first activatable label that starts with the
  /// buffer; the buffer resets after [DabblerMenuList.typeAheadTimeout].
  bool _typeAhead(String character) {
    // A timer, not a wall-clock comparison: the buffer's life is a real
    // scheduled event, so it is observable — and, in a test, controllable.
    _typed += character;
    _typedReset?.cancel();
    _typedReset = Timer(DabblerMenuList.typeAheadTimeout, () => _typed = '');
    final String needle = _typed.toLowerCase();
    for (final int i in _activatable) {
      if (widget.items[i].label.toLowerCase().startsWith(needle)) {
        _setActive(i);
        return true;
      }
    }
    return false;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    // A listbox is driven by its composer (`Select` owns its own field
    // keyboard); only a menu handles keys itself (`Menu.jsx:110`).
    if (widget.role != DabblerMenuRole.menu || widget.items.isEmpty) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.home) {
      final List<int> list = _activatable;
      if (list.isNotEmpty) {
        _setActive(list.first);
      }
    } else if (key == LogicalKeyboardKey.end) {
      final List<int> list = _activatable;
      if (list.isNotEmpty) {
        _setActive(list.last);
      }
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _select(_active);
    } else {
      final String? character = event.character;
      if (character == null ||
          character.isEmpty ||
          character.trim().isEmpty ||
          character.length != 1) {
        return KeyEventResult.ignored;
      }
      return _typeAhead(character)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);

    final List<Widget> rows = <Widget>[
      if (widget.header != null) widget.header!,
      for (int i = 0; i < widget.items.length; i++)
        if (widget.items[i].isSeparator)
          DabblerMenuSeparator(key: ValueKey<String>('sep-${_keyOf(i)}'))
        else
          DabblerMenuItem(
            key: ValueKey<String>(_keyOf(i)),
            label: widget.items[i].label,
            icon: widget.items[i].icon,
            iconTone: widget.items[i].iconTone,
            tone: widget.items[i].tone,
            disabled: widget.items[i].disabled,
            selected: widget.items[i].selected,
            trailing: widget.items[i].trailing,
            active: _active == i,
            role: widget.role,
            focusNode: _nodes[i],
            // Hover moves the active row so pointer and keyboard agree
            // (`Menu.prompt.md` — *Behaviour*), without stealing focus.
            onHover: () => _setActive(i, focus: false),
            onSelect: () => _select(i),
          ),
    ];

    Widget list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );

    if (widget.items.isNotEmpty) {
      list = Semantics(
        container: true,
        explicitChildNodes: true,
        role: widget.role == DabblerMenuRole.menu
            ? SemanticsRole.menu
            : SemanticsRole.list,
        label: widget.label,
        child: list,
      );
    }

    Widget scroller = SingleChildScrollView(
      // `overflow-y: auto` (`Menu.jsx:121`); the column is short, so it only
      // scrolls once the 45dvh cap bites.
      child: list,
    );

    if (widget.decorated) {
      scroller = DecoratedBox(
        decoration: BoxDecoration(
          // `--surface-card`, `1px solid --outline-card`, `--radius-lg`
          // (`Menu.jsx:123-125`). No shadow.
          color: colors.surfaceCard,
          border: Border.all(
            color: colors.borderDefault,
            width: DabblerSizing.borderDefault,
          ),
          borderRadius: DabblerRadius.lgAll,
        ),
        child: Padding(
          // `padding: var(--space-2)` (`Menu.jsx:126`).
          padding: const EdgeInsets.all(DabblerSpacing.space2),
          child: scroller,
        ),
      );
    }

    return Focus(
      autofocus: widget.autofocus,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: scroller,
    );
  }

  String _keyOf(int index) => widget.items[index].id ?? 'item-$index';
}

/// One row — `MenuItem` in `Menu.jsx:195`.
///
/// Public because the source exports it, and because a composer that builds
/// its own rows (a `Select` option with a custom trailing node) needs the same
/// row rather than a lookalike.
///
/// ## Measurements
///
/// Minimum height [DabblerSizing.touchTargetMin] (45 — above the 44 floor),
/// [DabblerSpacing.space3] between glyph, label and trailing node,
/// [DabblerRadius.md] corners, inline padding [DabblerSpacing.space3], or
/// [DabblerSpacing.space2] when a tinted tile is present *"so the row height
/// is unchanged"* (`Menu.prompt.md` — *Leading-icon tone*). The active row
/// fills with [DabblerColors.bgTertiary] over [DabblerMotion.fast].
class DabblerMenuItem extends StatelessWidget {
  /// Creates a menu row.
  const DabblerMenuItem({
    super.key,
    required this.label,
    this.icon,
    this.iconTone,
    this.tone = DabblerMenuItemTone.defaultTone,
    this.disabled = false,
    this.active = false,
    this.selected = false,
    this.trailing,
    this.onSelect,
    this.onHover,
    this.focusNode,
    this.role,
  });

  /// The key the tinted tile carries, so it is findable without matching the
  /// row's own [AnimatedContainer] fill.
  static const Key tileKey = ValueKey<String>('DabblerMenuItem.tile');

  /// The tinted tile's side — `width: 30, height: 30` (`Menu.jsx:214`), which
  /// is [DabblerSizing.iconLg].
  static const double tileSide = DabblerSizing.iconLg;

  /// `12%` — the tone's share of the tile fill (`Menu.jsx:216`). The source
  /// mixes with `transparent`, not white, so it composites over any surface;
  /// the Flutter equivalent is an alpha on the tone itself.
  static const double tileTintOpacity = 0.12;

  /// `opacity: 0.45` on a disabled row (`Menu.jsx:236`).
  static const double disabledOpacity = 0.45;

  /// The row's text.
  final String label;

  /// Kebab-case Iconsax name for the leading glyph.
  final String? icon;

  /// Tinted tile tone, or null for a bare glyph.
  final DabblerMenuIconTone? iconTone;

  /// Default or destructive.
  final DabblerMenuItemTone tone;

  /// Inert, dimmed, and skipped by the keyboard — but still listed.
  final bool disabled;

  /// Whether this is the roving-focus row: it carries the hover/active fill.
  final bool active;

  /// Draws the trailing brand tick.
  final bool selected;

  /// A node at the inline end.
  final Widget? trailing;

  /// Tap / Enter handler.
  final VoidCallback? onSelect;

  /// Called when a pointer enters the row.
  final VoidCallback? onHover;

  /// The roving focus node supplied by [DabblerMenuList].
  final FocusNode? focusNode;

  /// Which node role the row reports; see [DabblerMenuList] → *Roles*.
  ///
  /// Null — the default — reports **no** role. A bare row outside a list must
  /// not claim [SemanticsRole.menuItem]: Flutter asserts that *"a menu item
  /// must be a child of a menu or a menu bar"* (`semantics.dart:387`), so the
  /// role is the list's to grant, and [DabblerMenuList] grants it.
  final DabblerMenuRole? role;

  /// The colour a [DabblerMenuIconTone] resolves to, against [colors].
  ///
  /// `ICON_TONES` (`Menu.jsx:190-197`) verbatim: brand is
  /// `--color-brand-primary`, the four status tones are the bare
  /// `--color-status-<tone>` — [DabblerStatusColor.base], the indicator role —
  /// and `neutral` is `--color-text-secondary`.
  ///
  /// `neutral` is **not** a member of the `--color-status-*` API and therefore
  /// has no [DabblerColors] field, exactly as DS-502's Badge found
  /// (`DabblerBadge.neutralStatusOf`); it is built from the paper ramp here
  /// too, and by the same reasoning — the API does not gain a fifth status
  /// because one component needs a fifth name.
  static Color toneColorOf(DabblerMenuIconTone tone, DabblerColors colors) =>
      switch (tone) {
        DabblerMenuIconTone.brand => colors.brandPrimary,
        DabblerMenuIconTone.success => colors.success.base,
        DabblerMenuIconTone.warning => colors.warning.base,
        DabblerMenuIconTone.error => colors.error.base,
        DabblerMenuIconTone.info => colors.info.base,
        DabblerMenuIconTone.neutral => colors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool tinted = iconTone != null && icon != null;

    // `tone="destructive"` items are `--color-status-error-strong`, which
    // `Menu.prompt.md` — *Theme behaviour* says clears 4.5:1 on the card in
    // both modes.
    final Color foreground = tone == DabblerMenuItemTone.destructive
        ? colors.error.strong
        : colors.textPrimary;

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      // `gap: var(--space-3)` (`Menu.jsx:229`).
      spacing: DabblerSpacing.space3,
      children: <Widget>[
        if (icon != null) _leading(colors, foreground),
        Expanded(
          child: Text(
            label,
            // `.t-subheadline`, `text-align: start` (`Menu.jsx:247`).
            style: DabblerType.subheadline
                .resolveForDirection(direction)
                .copyWith(color: foreground),
            textAlign: TextAlign.start,
          ),
        ),
        ?trailing,
        if (selected)
          DabblerIcon(
            'tick-circle',
            weight: DabblerIconWeight.bold,
            size: DabblerSizing.iconSm,
            color: colors.brandPrimary,
          ),
      ],
    );

    final Widget filled = AnimatedContainer(
      duration: DabblerMotion.reduceMotion(context)
          ? Duration.zero
          : DabblerMotion.fast,
      curve: DabblerMotion.easeOut,
      constraints: const BoxConstraints(
        minHeight: DabblerSizing.touchTargetMin,
      ),
      padding: EdgeInsetsDirectional.symmetric(
        // Tightened to `--space-2` when a tile is present so the row height is
        // unchanged (`Menu.jsx:232`).
        horizontal: tinted ? DabblerSpacing.space2 : DabblerSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: active && !disabled ? colors.bgTertiary : Colors.transparent,
        borderRadius: DabblerRadius.mdAll,
      ),
      child: row,
    );

    final Widget interactive = DabblerFocusRing(
      focusNode: focusNode,
      borderRadius: DabblerRadius.mdAll,
      enabled: !disabled,
      canRequestFocus: !disabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : onSelect,
        child: DabblerPressScale.gesture(
          enabled: !disabled,
          child: filled,
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: !disabled,
      selected: selected,
      role: switch (role) {
        null => null,
        DabblerMenuRole.menu => SemanticsRole.menuItem,
        DabblerMenuRole.listbox => SemanticsRole.listItem,
      },
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: disabled || onHover == null
            ? null
            : (PointerEnterEvent _) => onHover!(),
        child: disabled
            ? Opacity(opacity: disabledOpacity, child: interactive)
            : interactive,
      ),
    );
  }

  /// A bare 18px glyph, or the same glyph in a 30px tinted tile.
  Widget _leading(DabblerColors colors, Color foreground) {
    final DabblerMenuIconTone? tone = iconTone;
    if (tone == null) {
      return DabblerIcon(
        icon!,
        size: DabblerSizing.iconSm,
        color: foreground,
      );
    }
    final Color tint = toneColorOf(tone, colors);
    return SizedBox(
      key: tileKey,
      width: tileSide,
      height: tileSide,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint.withValues(alpha: tileTintOpacity),
          borderRadius: DabblerRadius.mdAll,
        ),
        child: Center(
          child: DabblerIcon(
            icon!,
            size: DabblerSizing.iconSm,
            color: tint,
          ),
        ),
      ),
    );
  }
}

/// The hairline between groups — `MenuSeparator` in `Menu.jsx:262`.
///
/// `height: 1`, `--faint` (whose semantic role is
/// [DabblerColors.bgTertiary], the same token DS-701's Sheet footer draws
/// with), `margin-block: var(--space-1)`, `margin-inline: var(--space-2)`.
class DabblerMenuSeparator extends StatelessWidget {
  /// Creates a separator.
  const DabblerMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: DabblerSpacing.space1,
        horizontal: DabblerSpacing.space2,
      ),
      child: SizedBox(
        height: DabblerSizing.borderDefault,
        child: ColoredBox(color: colors.bgTertiary),
      ),
    );
  }
}
