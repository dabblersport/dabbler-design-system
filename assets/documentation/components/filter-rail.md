<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/controls/filter_rail.dart (class dartdoc)
           lib/src/controls/filter_rail_gallery.dart (specimen "FilterRail —
           the applied filters, removable")
           design: Listings.dc.html:101-111, :291-299
-->

# FilterRail
### `DabblerFilterRail`, `DabblerFilterGroup`

FilterRail is the applied-filters rail under a listing's tabs, one selected removable chip per
filter followed by a "Clear all" action, and its companion FilterGroup is the labelled group of
option chips inside a filter sheet.

Both compose `Chip` and `Button`; they paint nothing of their own.

## Specimen

The rail and the group — see `filter_rail_gallery.dart`'s *FilterRail* section.

@specimen filter-rail

## Using it

**Pass every applied filter as an item.** Each chip's remove control clears that one filter; the
rail renders nothing when there are none.

**Pass a localised `clearAllLabel`.** A null `onClearAll` hides the action.

**Use FilterGroup for the sheet.** One group per filter dimension, the chosen option selected.

## Axes

### Direction
Chips start at the inline start; "Clear all" follows the last chip. The rail scrolls horizontally
when it overflows.

## Tokens used

Chip gap `space2` (rail), `space3` (group). Caption `footnote` semibold in `textSecondary`.

## Change log

- Alpha fidelity rebuild (KAN-426) — adds these components.

## Source

`lib/src/controls/filter_rail.dart`
