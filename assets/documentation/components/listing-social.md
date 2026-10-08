<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/listing_social.dart (class dartdoc)
           lib/src/controls/listing_social_gallery.dart (specimen
           "ListingSocial — heart and share with counts")
           design: Listings.dc.html:273-279 (game card), :644-655 (meetup card),
           :2065-2066 (heart on/off glyph and colour), :24 and :28 (--share-ink)
-->

# ListingSocial
### `DabblerListingSocial`

ListingSocial is the engagement group at the end of a listing card's action row: a heart that favourites the item, and a share glyph, each with an optional count.

It is a pair of buttons the caller owns. Off, the heart is an outline in the secondary ink; on, it is a bold heart in the error colour, and it is announced as a toggle so state is never carried by colour or weight alone.

## Specimen

Off, on, with and without counts, and disabled, in both directions — see `listing_social_gallery.dart`.

@specimen listing-social

## Using it

**Put it in the card's trailing slot.** `DabblerCardGame` seats it at the inline end of the action row, beside the join button. The meetup listing card is a `DabblerCardGame`, so it uses the same slot.

**Do not use it on the venue card.** `DabblerCardVenue` keeps the bordered heart well (`DabblerFavouriteButton`): the venue card draws a well at the name row, with no share and no count.

**Always pass both labels.** The glyphs have no visible text. Name the heart for the current state (`Add to favourites` / `Remove from favourites`) and the share item (`Share`).

**Pass `favourited` and handle the callbacks.** The component does not toggle itself; the screen owns the favourite state and the call that saves it. A null callback disables that item. A null count hides the number, not the glyph.

## Axes

### State
Heart off, heart on, disabled (null callback, dimmed and announced as disabled) and keyboard-focused (the shared focus ring).

### Counts
Each item takes its own count; either, both or neither may show.

### Direction
The group follows the reading direction. Nothing inside it mirrors.

## Tokens used

Glyph size 20, glyph to count gap `space2`, between items `space5`. Count: `caption1` semibold. Heart colour: the secondary text colour when off, the error status base when on. Share colour: the secondary text colour in both modes. Touch target: `touchTargetMin` (45) as a hit-test-only area around each item. Focus ring: the shared ring.

## Change log

- Added for the Listings card engagement group (heart as favourite, share; counts optional).

## Source

`lib/src/controls/listing_social.dart`
