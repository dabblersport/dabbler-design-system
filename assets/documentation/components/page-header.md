<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/navigation/page_header.dart (class dartdoc)
           lib/src/navigation/page_header_gallery.dart (specimen
           "PageHeader — a listing screen heading")
           design: Listings.dc.html:60-100
-->

# PageHeader
### `DabblerPageHeader`

PageHeader is the heading of a listing screen: a display title, a tappable location row beneath
it, and outlined icon actions at the inline end, one of which can carry a count badge.

Its actions are 42 `--surface-card` circles inside the card hairline with a 45 hit-test-only target, and its count is an 18 brand pill; the location row and the title are `Text` and `Icon`.

## Specimen

With and without a location row — see `page_header_gallery.dart`'s *PageHeader* section.

@specimen page-header

## Using it

**Give it a `locationLabel` only when the screen is location-aware.** Null hides the row and the
header is just a title with its actions.

**Put the filter action last and pass its active-filter `count`.** The badge sits on the action's
inline end; zero draws none.

**Pass localised strings.** Every action needs a `semanticLabel`; the count is appended to it for
assistive technology.

## Axes

### Direction
The title block sits at the inline start and the actions at the inline end. The badge overhangs the
inline end of its action. Nothing names a physical side.

### Safe area
`safeArea` (default true) pads the block start by the device inset.

### Padding
`contentPadding` overrides the gutter. The collapsing listing header uses `DabblerPageHeader.listingPadding` (the end nudged a little) — `listingVenuesPadding` for Venues (nudged a little more) — because its tinted band pads the block with no bottom and the title row carries its own bottom margin; both values are in the class dartdoc.

## Tokens used

Gutter `space6` (18) inline, `space2` top, `space4` bottom. Action gap `space2`. Title
`DabblerType.title1`, location `tagTight` at medium (11/14) in `textSecondary`, glyph 13 in `brandPrimary`; actions `surfaceCard` with `borderDefault`; count `brandPrimary` with `onBrand`.

## Change log

- Alpha fidelity rebuild (KAN-426) — adds this component.
- Listings fidelity pass — actions are the frame's 42 circles (were 60×45 outlined pills); the count badge is 18 in brand (was the accent pill); the location row is 11/14 at 500 with a 13 pin.
- Listings 2026-10-08 — adds `contentPadding` with `listingPadding` and `listingVenuesPadding` for the collapsing listing header.

## Source

`lib/src/navigation/page_header.dart`
