<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/layout/listing_page.dart (class dartdoc)
           lib/src/layout/listing_page_gallery.dart (specimen
           "ListingPage — the collapsing listing header")
           design: Listings.dc.html (2026-10-08)
-->

# ListingPage
### `DabblerListingPage`

ListingPage is a listing screen's collapsing header over its pages: a tinted band holding the title row, the sport tabs and the applied-filters rail, above one scrolling page per tab.

Scrolling a page folds the band, so the list gets the room, and scrolling back unfolds it.

## Specimen

A tinted band with filters applied, and an accent band with none — see `listing_page_gallery.dart`'s *ListingPage* section.

@specimen listing-page

## Using it

**Pass a `DabblerPageHeader` built with `safeArea: false` and `contentPadding: DabblerPageHeader.listingPadding` as `header`.** The page pads the status-bar inset itself, inside the band, so the band bleeds under the status bar.

**Pass `onFiltersTap` (and a localised `filtersTapSemanticLabel`) to open the filter sheet from the rail.** It is forwarded to `DabblerFilterRail.onTap`: a tap on the rail background or a pill body calls it; remove glyphs and "Clear all" keep their own handlers. Null changes nothing.

**Pass one page per tab, in order, each inset by the 18 gutter.** Pages run edge to edge so horizontal rails can bleed; each page is kept alive, so its scroll position survives a tab change.

**Read the band's colour from `onBandColor`.** It reports the colour after it changes, and null when the page leaves; the shell can paint it under the status bar (`DabblerTopFill`) and the platform chrome can follow it.

**What folds.** Past a scroll of 40 the band collapses (it expands again under 8): the tabs always fold; the title row folds with them once filters are applied, so only the filters stay pinned; with no filters the title row stays.

## Axes

### Head
`DabblerListingHead.tint` is the section's brand mixed over the card colour at the tint share (Games, Venues); `accent` is the accent tile surface, in its dark tone in dark mode (Meetups); `none` paints no band.

### Direction
The band, tabs and rail follow the reading direction; the tabs mirror on their own.

## Tokens used

`brandPrimary`, `surfaceCard`, `bgPrimary`, the accent tile surface; spacing `space2`, `space3`, `space4`, `space6`; motion `slow` on `easeOut` for the fold (reduced motion jumps).

## Change log

- Listings 2026-10-08 — adds this component: the collapsing, section-tinted header (`data-head`, the `max-height`/`opacity` transitions and the 40/8 scroll hysteresis).
- Listings match — optional `onFiltersTap` and `filtersTapSemanticLabel` forward to the filter rail's `onTap` and `tapSemanticLabel`.

## Source

`lib/src/layout/listing_page.dart`
