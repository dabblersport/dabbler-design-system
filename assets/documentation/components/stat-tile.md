<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/stat_tile.dart (class dartdoc in full)
           lib/src/cards/stat_tile_gallery.dart (specimen title:
           "StatTile — the bento stat tile")
           Live design project components/cards/StatTile.jsx and
           StatTile.d.ts, design system 1.2.0 (read through DesignSync).
-->

# StatTile
### `DabblerStatTile`

StatTile is the bento stat tile used across the profile screens: a large value, a bold caption and an optional sub-line.

It sits in a six-column `DabblerStatGrid` at one of three footprints — `small`, `hero` or `wide` — in one of eight tones, with optional line art bled off the inline end. A tile with `onTap` becomes a button (or a link) with the shared focus ring and press scale; it is at least 45px tall and its trailing affordance mirrors in right-to-left.

## Specimen

Every tone, a bento grid and an interactive tile — see `stat_tile_gallery.dart`'s *StatTile* section.

@specimen stat-tile

## Using it

**Put tiles in a `DabblerStatGrid`; it places them by span and row the way the source's CSS grid does.** A tile on its own fills whatever box it is given.

**Pass `onTap` only when the tile really navigates.** A non-interactive tile is inert and unfocusable; an interactive one is a button, or a link when `link` is set, and its name is the value, label and sub-line read together unless you pass `semanticLabel`.

**The art is yours to supply.** `art` takes an `ImageProvider`; the package ships no illustration. On the `brand` and `ink` tones the art knocks out to white, as in the source.

**The value's type is a documented display-numeral exception.** `small` draws 26/30 on the title-1 face and `hero` 46/48 on the large-title face; neither size is a ramp step, and the exception is recorded rather than rounded. The `-0.01em` tracking the source applies to the value is not applied: no ramp step declares tracking, so the value keeps the step's zero and the difference is recorded as a design-source change request.

**Turn on `fitValue` wherever the value is data.** A count that grows or a localised number can be
wider than the tile. By default the value clips, as the source does; with `fitValue: true` it
scales down to fit instead, never below `minValueScale` (0.6 of its size), and ellipsises past that
floor rather than losing digits mid-glyph.

**Put a glyph above the value with `icon`.** The Details screen's tiles draw an 18px icon over the
figure (`Details.dc.html:96-99`). It takes the tile's ink and is decorative — the value and label
carry the meaning.

**Use `rowExtent: DabblerStatGrid.detailsRowHeight` for the Details grids.** They use 100px rows
(`Details.dc.html:93`); the default stays 78.

**Deviation:** the design's 4px gap under the icon is off the base-3 grid; it is drawn at 3.

@specimen stat-tile/icon-fit

**The Settings tile is its own size.** `DabblerStatTileSize.setting` is 3 columns by 1 row with a bold sans value over a regular caption, the way the Settings root draws its bento.

## Axes

### Size
`small` (2 columns by 1 row), `hero` (4 by 2), `wide` (6 by 2); `span` and `rows` override the footprint.

@figure 2 lib/src/cards/stat_tile.dart#DabblerStatTileSize
@figure 1 lib/src/cards/stat_tile.dart#DabblerStatTileSize
@figure 4 lib/src/cards/stat_tile.dart#DabblerStatTileSize
@figure 6 lib/src/cards/stat_tile.dart#DabblerStatTileSize

### Tone
`card`, `sunken`, `brand`, `ink`, `amber`, `info`, `accent`, `danger`.

### Interactivity
Inert, a button, or a link.

## Tokens used

Corner: the 18px extra-large radius. Fill and ink: the surface, brand, ink, status-error and decorative tile roles. Type: title-1, large-title and title-2 for the value, footnote at weight 600 for the label, caption-1 for the sub-line.

## Change log

- Added from the live design project, design system 1.2.0 (`StatTile.jsx` with `href` and `trailing`, 1.1.0 DSG-002).

- Alpha DS gaps 6 — adds `icon`, `fitValue` and `minValueScale` to `DabblerStatTile`,
  `DabblerStatTileValue`, and `rowExtent` with `detailsRowHeight` to `DabblerStatGrid`. All off
  by default.

## Source

`lib/src/cards/stat_tile.dart`, `lib/src/cards/stat_tile_value.dart`
