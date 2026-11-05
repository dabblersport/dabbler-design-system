import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';

/// One tab of a [DabblerNavigationTabBar].
@immutable
class DabblerNavigationTab {
  /// A tab drawn from the Iconsax glyph [icon].
  const DabblerNavigationTab({required this.icon, required this.label});

  /// The Iconsax name, e.g. `home-2`. The active tab draws it bold, the others
  /// linear (`NavigationTabBar.jsx`: bold `home-2`, linear for the rest).
  final String icon;

  /// The accessible name — the source draws no text, so the label is semantics
  /// only.
  final String label;
}

/// NavigationTabBar — the four-slot icon tab bar that switches top-level
/// sections.
///
/// Ported from the live design project's
/// `components/navigation/NavigationTabBar.jsx` and `.d.ts` (Figma node `8:47`,
/// design system 1.2.0): a 16-radius frame with a 1px card outline around a
/// card-filled inner strip with its own 1px outline, four equal slots with 12px
/// vertical padding, 24px icons, the active slot in the brand colour and the
/// rest in the subtle ink.
///
/// | Source | Here | Why |
/// |---|---|---|
/// | `width: 384`, `maxWidth: 384` | [barWidth], as a **max** | the tabs are `flexGrow: 1`, so the strip is happy narrower |
/// | `height: 47`, content-box | [barHeight] 49 (47 + two 1px shell borders) | the specimen rendered from `navigation.card.html` measures 49 rows of ink (KAN-292) |
/// | slots are `text1..text4` React nodes | [tabs] (icon name plus label) | injected view-model; the default four are [defaultTabs] |
/// | no selection state (the first slot is simply drawn active) | [activeIndex] and [onSelect] | a tab bar that cannot select is not usable; the source's drawing is the default `activeIndex` of 0 |
/// | `Inter` on the slot spans | not applied | the span only wraps an icon; the face is not shipped |
class DabblerNavigationTabBar extends StatelessWidget {
  /// A tab bar.
  const DabblerNavigationTabBar({
    super.key,
    this.tabs = defaultTabs,
    this.activeIndex = 0,
    this.onSelect,
  });

  /// The slots, left to right (mirrors in RTL).
  final List<DabblerNavigationTab> tabs;

  /// The selected slot.
  final int activeIndex;

  /// Called with the tapped slot's index.
  final ValueChanged<int>? onSelect;

  /// The source's four defaults — `home-2`, `search-normal`, `add-circle`,
  /// `sms` (`NavigationTabBar.d.ts`).
  static const List<DabblerNavigationTab> defaultTabs = <DabblerNavigationTab>[
    DabblerNavigationTab(icon: 'home-2', label: 'Home'),
    DabblerNavigationTab(icon: 'search-normal', label: 'Search'),
    DabblerNavigationTab(icon: 'add-circle', label: 'Create'),
    DabblerNavigationTab(icon: 'sms', label: 'Messages'),
  ];

  /// The frame radius — `borderRadius: 16`.
  static const double radius = DabblerRadius.card;

  /// A slot's vertical padding — `padding: '12px 0'`.
  static const double slotPadding = DabblerSpacing.space4;

  /// The icon size — `size={24}`.
  static const double iconSize = DabblerSizing.iconMd;

  /// `width: 384` / `maxWidth: 384` — applied as a maximum, so the bar does not
  /// stretch across a tablet and leave the glyphs marooned.
  static const double barWidth = 384;

  /// `height: 47` — the shell's **content** height, not the height it draws at.
  /// See [barHeight].
  static const double barContentHeight = 47;

  /// The height the bar occupies: **49**. The export's `height: 47` is
  /// content-box, so the shell's two 1px borders sit outside it; the specimen
  /// rendered headless from `navigation.card.html` measures 49 rows of ink.
  static const double barHeight =
      barContentHeight + 2 * DabblerSizing.borderDefault;

  /// The inner row's natural height: 50 (1 border + 12 padding + the 24 glyph +
  /// 12 padding + 1 border). It overflows [barContentHeight] and the shell
  /// clips the overflow from the block end, so the row's bottom border is never
  /// drawn.
  static const double rowHeight =
      2 * DabblerSizing.borderDefault + 2 * slotPadding + iconSize;

  /// `lineHeight: "20px"` on the span that holds each glyph. It does not set
  /// the row's height ([rowHeight] does, from the 24 glyph); kept as the
  /// transcribed value of the declaration.
  static const double glyphLineHeight = 20;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final BorderSide line = BorderSide(
      color: colors.borderDefault,
      width: DabblerSizing.borderDefault,
    );
    final Widget row = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.fromBorderSide(line),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: _Slot(
                tab: tabs[i],
                active: i == activeIndex,
                onTap: onSelect == null ? null : () => onSelect!(i),
              ),
            ),
        ],
      ),
    );
    return Semantics(
      container: true,
      // Align loosens a tight host width so the cap holds there too: a
      // ConstrainedBox alone cannot narrow a parent that forces a width.
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: barWidth),
          child: SizedBox(
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(radius)),
                border: Border.fromBorderSide(line),
              ),
              // The row keeps its natural [rowHeight] in the 47 content box and
              // is clipped from the block end, not squeezed.
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(radius)),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: OverflowBox(
                    alignment: AlignmentDirectional.topStart,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: row,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatefulWidget {
  const _Slot({required this.tab, required this.active, required this.onTap});

  final DabblerNavigationTab tab;
  final bool active;
  final VoidCallback? onTap;

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final Color ink = widget.active ? colors.brandPrimary : colors.textTertiary;
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DabblerNavigationTabBar.slotPadding,
      ),
      child: Center(
        heightFactor: 1,
        child: DabblerIcon(
          widget.tab.icon,
          weight: widget.active
              ? DabblerIconWeight.bold
              : DabblerIconWeight.linear,
          size: DabblerNavigationTabBar.iconSize,
          color: ink,
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.tab.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: widget.onTap != null,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (bool v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: DabblerFocusRing.visible(
              visible: _focused,
              borderRadius: DabblerRadius.smAll,
              child: DabblerPressScale(pressed: _pressed, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
