<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/controls/chip_rail.dart (class dartdoc)
           lib/src/controls/chip_rail_gallery.dart (specimen "ChipRail — a
           scrolling row of selectable chips")
           design: Wallet v2.dc.html:151-157 (Transactions filter chips),
           Notifications.dc.html:56-60 (Activities category chips with counts),
           Profiles.dc.html:155-170 (sport picker)
-->

# ChipRail
### `DabblerChipRail`, `DabblerChipRailItem`

ChipRail is a horizontally scrolling row of selectable chips: the Transactions filter and period
chips, the Activities category chips with their counts, and the Profiles sport picker are all this
one control at different chip sizes.

It scrolls from the inline start, keeps the chosen chip in view, and fades the edge that more chips
run past. It can deal its chips onto two rows that scroll together. It is not a tab strip and not
the applied-filters rail.

## Specimen

Filter chips, small chips with counts, a two-row rail and an Arabic right-to-left rail — see
`chip_rail_gallery.dart`.

@specimen chip-rail

## Using it

**Pass items, own the selection.** Each `DabblerChipRailItem` carries its label, `selected`, `onTap`
and optionally a `count`, a `leadingIcon`, a sport `accent` and the primary-sport `dot`. The rail
holds no selection state; the screen sets `selected` on the chosen item.

**Pick the chip size to match the frame.** `size` is `regular` for the filter row, `small` for the
Activities rail, `large` for the sport picker.

**Give it the screen gutter as `padding`.** The first chip then lines up with the page while the
rail still scrolls edge to edge.

**Use `rows: 2` for a long set.** Chips are dealt alternately onto two rows inside one scroll view.

**Use `DabblerFilterRail` for applied filters and `DabblerTabs` for page switching.** This rail
selects one of many; the filter rail removes; tabs switch pages.

## Axes

### Rows
`1` (default) or `2`.

### Size
Passed through to every chip: `regular`, `small`, `large`.

### Edge fade
On by default: the inline-start edge fades once the content has scrolled past it and the inline-end
edge fades while more chips lie beyond it. `fade: false` removes it. The design draws no fade on its
rails, so this is the one addition to the frames and it is off-able.

### Direction
The rail starts at the inline start: the first chip is on the right and the scroll origin is the
right edge under Arabic. The fade follows the side the content is cut on.

## Tokens used

Gap: `space2` (6). Fade width: `space8` (24), in the page colour. Chips: `DabblerChip` at the
chosen size. The chosen chip is brought into view without animation.

## Change log

- KAN-426 (Seat B) — adds this component.

## Source

`lib/src/controls/chip_rail.dart`
