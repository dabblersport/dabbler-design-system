<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/layout/tile_grid.dart (class dartdoc)
           lib/src/layout/flow_gallery.dart (specimen
           "TileGrid — equal tiles, row-height cells")
           design: Auth and Onboarding.dc.html:401-413
-->

# TileGrid
### `DabblerTileGrid`

TileGrid lays tiles in a fixed number of equal columns, where the tiles of a row take the height of the tallest in that row.

It is the sport step's grid: a two-line label such as *Table Tennis* makes only its own row taller, instead of clipping or leaving every tile too tall.

## Specimen

Six selectable sport tiles in four columns, one with a two-line label — see `flow_gallery.dart`'s *TileGrid* section.

@specimen tile-grid

## Using it

**Pass the tiles in reading order.** The first tile sits at the inline start of the first row.

**A short last row keeps the column width.** Empty cells take the place of missing tiles so the tiles line up with the rows above.

**It does not scroll.** Put it in a scrolling body such as `FlowPage`'s.

**Don't use it for a long lazy list.** Every tile is built at once.

## Axes

### Columns
`columns`, four by default.

### Gap
`gap` between tiles, across and down. `space3` by default.

### Direction
Rows fill from the inline start — the right edge in right-to-left layouts.

## Tokens used

`space3` gap.

## Change log

- Alpha fidelity rebuild (auth2) — adds this component.

## Source

`lib/src/layout/tile_grid.dart`
