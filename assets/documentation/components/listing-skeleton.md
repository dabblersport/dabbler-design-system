<!--
Component page, D-033 ten-part template.

Tier     : Feedback
Sources  : lib/src/feedback/listing_skeleton.dart (class dartdoc, read in full)
           lib/src/cards/listing_cards_gallery.dart (specimen
           "ListingSkeleton — game, meetup and venue placeholders")
           design: Listings.dc.html:175-190, 486-503, 724-735
-->

# ListingSkeleton
### `DabblerListingSkeleton`

ListingSkeleton is the loading placeholder for one listing card, drawn in the shape of the card that will replace it.

The Listings frame gives each listing its own skeleton on the listing card shell, and each block is a `Skeleton`, so the pulse and its reduced-motion fallback are the skeleton's own.

## Specimen

The game, meetup and venue placeholders.

@specimen listing-skeleton

## Using it

**Match the kind to the list.** A games list shows `game`, a meetups list `meetup`, a venues list `venue`; three of them fill a phone screen.

**Use it only while the first page loads.** A refresh keeps the cards on screen.

## Axes

### Kind
`game`: a tile, two lines and a block over a taller block and a bar. `meetup`: two lines and a block, a face and a line, a bar. `venue`: a media block over two lines and a bar.

@figure 160 lib/src/feedback/listing_skeleton.dart#venueMediaHeight
@figure 52 lib/src/feedback/listing_skeleton.dart#gameBlockHeight

## Direction

Fractional lines start at the inline start, so under Arabic they hug the right edge.

## Tokens used

Shell: the listing card's (`surfaceCard`, `borderDefault`, the 18 corner, the 15 body padding). Blocks: the skeleton fill on the small, medium and large radii.

## Change log

- Listings fidelity pass — adds this component, from `Listings.dc.html`; the listing screens move to it from `Skeleton.card`.

## Source

`lib/src/feedback/listing_skeleton.dart`
