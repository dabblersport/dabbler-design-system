<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/layout/detail_header.dart (class dartdoc)
           lib/src/layout/detail_gallery.dart (specimen "DetailHeader")
           design: Details.dc.html:46-77 (game-details hero)
-->

# DetailHeader
### `DabblerDetailHeader`

DetailHeader is the coloured band that opens a detail screen: round buttons, translucent pills, the title and a place line, painted in a section theme (the sport green for a game).

It is the first thing in a `DabblerDetailPage`: it pads the status bar itself so the colour runs up under it, and re-themes everything inside so the buttons you pass take the band's own on-colour.

## Specimen

Back and share, two pills, the title and a place with a distance, in both directions — see `detail_gallery.dart`.

@specimen detail-header

The amber tile band the meetup details frame draws:

@specimen detail-header/tile

## Using it

**Put it first in a `DetailPage`.** The band pads the status bar itself so it can bleed under it.

**Pass the buttons in.** `leading` and `actions` take `OnColorIconButton`s; the whole band is re-themed, so they pick up the band's on-colour with no colour argument.

**Pills are plain strings.** The band draws them as translucent pills.

## Axes

### Theme
`theme` chooses the section theme the band is painted in; default sport.

### Direction
A column of rows: buttons, pills and the place line all start at the inline start.

**System bars.** `DabblerDetailHeader.fillOf(context, tile:, theme:)` returns the colour the band paints (the tile's surface, else the section theme's `brandPrimary`, for the context's brightness). `build()` fills through the same function, so the two cannot drift. Use it so the status bar can follow the header: pass the same `tile` / `theme` the header gets.

## Tokens used

`brandPrimary` and `onBrand` of the chosen theme, `largeTitle`, `footnote`, `caption2`, spacing steps 3–8.

## Change log

- KAN-426 fidelity rebuild — adds this component.
- KAN-429 (Meetups) — adds `tile` (paint the band in a decorative tile instead of a section theme, the meetup frame's amber band) and `extra` (a third fact after the meta). Pair `tile` with `OnColorIconButton.onTile`.
- Adds `DabblerDetailHeader.fillOf` — the band's fill as an API so the system bars can follow the header fill; `build()` uses the same function. No visual change.
- Details dark (Details.dc.html 2026-10-08) — the tile bands resolve through `tile*Tone`, and ink on the amber band is the amber tone's ink (`#141414`) in both modes; light is unchanged.

## Source

`lib/src/layout/detail_header.dart`
