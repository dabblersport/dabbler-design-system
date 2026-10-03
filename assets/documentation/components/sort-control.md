<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/overlays/sort_control.dart (class dartdoc)
           lib/src/overlays/sort_control_gallery.dart (specimen
           "SortControl — reorder a view-all list")
           design: Listings.dc.html:283, :291-299, :1800-1814
-->

# SortControl
### `DabblerSortControl`

SortControl is how a view-all list lets the reader change its order: a compact chip showing the
current choice that opens a sheet of options, or the options inline as chips.

It composes `Chip`, `Sheet` and `Menu`'s list; it paints nothing of its own.

## Specimen

The sheet and segmented variants — see `sort_control_gallery.dart`'s *SortControl* section.

@specimen sort-control

## Using it

**Use the sheet variant in a list header, the segmented variant inside a filter sheet.** The chip
keeps the header to one line; inline chips suit a panel that already lists every filter.

**Pass the localised `label`.** It is the trigger's text, the sheet title and, with the current
value, what assistive technology reads.

**`onChanged` fires only on a change.** Picking the selected option again closes the sheet and does
nothing else. A null `onChanged` disables the control.

## Axes

### Variant
`sheet` — a chip reading "label: value" that opens a content-sized sheet with a check on the
selected row. `segmented` — every option as a chip, the selected one filled.

### Direction
The sheet's check sits at the inline end and the segmented chips wrap from the inline start.

## Tokens used

Chip gap: `space3`. Chevron: `iconSm` in `textSecondary`. Everything else is `Chip`'s, `Sheet`'s
and `Menu`'s.

Deviation: the trigger's chevron sits at the chip's inline start, because `Chip` has only a
leading icon slot.

## Change log

- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/overlays/sort_control.dart`
