<!--
Component page, D-033 ten-part template.

Tier     : Navigation
Sources  : lib/src/navigation/tab_bar.dart (class dartdoc in full)
           lib/src/navigation/tab_bar_gallery.dart (specimen title: "Navigation — tab bar")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rNavigationTabBar
### `DabblerNavigationTabBar`

NavigationTabBar is the four-slot icon tab bar that switches top-level sections.

A 16px frame with a one-pixel outline around a card strip with its own outline; four equal slots with 24px icons, the active one bold in the brand colour and the rest subtle. The source draws no selection state, so `activeIndex` and `onSelect` supply it, and the slot labels are semantics only.

## Specimen

See the *Navigation* section of `tab_bar_gallery.dart`.

@specimen tab-bar

## Using it

**Pass the four tabs and the active index; keep selection in the parent.** `defaultTabs` is the source's four icons.

**The labels are not drawn.** They name each slot for assistive technology; the bar shows icons only.

## Axes

### Slot
Active (bold, brand ink) or inactive (linear, subtle ink).

## Tokens used

Frame: the 16px card radius and the card outline. Slot: 12px vertical padding and the 24px icon step. Colour: the card surface, the brand role and the tertiary text role.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/navigation/tab_bar.dart`
