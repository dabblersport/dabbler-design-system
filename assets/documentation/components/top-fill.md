<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/layout/top_fill.dart (class dartdoc)
           lib/src/layout/listing_page_gallery.dart (specimen
           "TopFill — the band under the status bar")
           design: Listings.dc.html (2026-10-08, the 50px status row)
-->

# TopFill
### `DabblerTopFill`

TopFill paints the top safe-area inset in one colour over its child, so a tinted header can bleed up under the status bar.

A null colour, or no inset, paints nothing: the widget is then just its child.

## Specimen

A 44 inset filled with the accent band colour — see `listing_page_gallery.dart`'s *TopFill* section.

@specimen top-fill

## Using it

**Put it around the page, not the header.** The screen can only draw inside the safe area; the strip sits above it in the same stack.

**Feed it the band's colour.** `DabblerListingPage.onBandColor` reports it, and reports null when the page leaves.

**It never takes pointer input.**

## Direction

Nothing here is directional.

## Tokens used

None of its own: the colour is passed in.

## Change log

- Listings 2026-10-08 — adds this component.

## Source

`lib/src/layout/top_fill.dart`
