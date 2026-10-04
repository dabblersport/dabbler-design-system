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

## Using it

**Put it first in a `DetailPage`.** The band pads the status bar itself so it can bleed under it.

**Pass the buttons in.** `leading` and `actions` take `OnColorIconButton`s; the whole band is re-themed, so they pick up the band's on-colour with no colour argument.

**Pills are plain strings.** The band draws them as translucent pills.

## Axes

### Theme
`theme` chooses the section theme the band is painted in; default sport.

### Direction
A column of rows: buttons, pills and the place line all start at the inline start.

## Tokens used

`brandPrimary` and `onBrand` of the chosen theme, `largeTitle`, `footnote`, `caption2`, spacing steps 3–8.

## Change log

- KAN-426 fidelity rebuild — adds this component.

## Source

`lib/src/layout/detail_header.dart`
