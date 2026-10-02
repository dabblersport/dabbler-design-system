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
/// | `384 x 47` frame | flexible width, content height | a Figma frame measurement |
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
  static const List<DabblerNavigationTab> defaultTabs =
      <DabblerNavigationTab>[
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

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final BorderSide line = BorderSide(
      color: colors.borderDefault,
      width: DabblerSizing.borderDefault,
    );
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(radius)),
          border: Border.fromBorderSide(line),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(radius)),
          child: DecoratedBox(
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
