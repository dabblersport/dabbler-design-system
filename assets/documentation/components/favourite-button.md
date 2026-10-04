<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/favourite_button.dart (class dartdoc)
           lib/src/controls/favourite_button_gallery.dart (specimen
           "FavouriteButton — the heart well on a venue card")
           design: Listings.dc.html:774-776 (venue card well), :2035-2036
           (the on/off glyph and colour), Favourites.dc.html:60-62 (the same
           heart as a remove control)
-->

# FavouriteButton
### `DabblerFavouriteButton`

FavouriteButton is the small square well with a heart that saves a venue, game or any listing to
favourites: a card-coloured, hairline-bordered, 12-radius well around an 18px heart.

It is a toggle the caller owns. Off, the heart is an outline in the secondary ink; on, it is a bold
heart in the error colour, and it is announced as a toggle so the state is never carried by colour
or weight alone.

## Specimen

Off, on, disabled and plain wells in both directions — see `favourite_button_gallery.dart`.

@specimen favourite-button

## Using it

**Put it at the inline end of the venue name.** `DabblerCardVenue` has a `favourite` slot for exactly
this; the heart is not directional, so nothing mirrors under Arabic and only its position follows
the reading direction.

**Always pass `semanticLabel`.** The button has no visible text. Name the action for the current
state: `Add to favourites` when off, `Remove from favourites` when on.

**Pass `selected` and handle `onPressed`.** The button does not toggle itself; the screen owns the
saved state and the call that saves it. `onPressed: null` disables it.

## Axes

### State
Off, on (`selected`), disabled (`onPressed: null`, dimmed and announced as disabled) and
keyboard-focused (the shared focus ring at the well's radius).

### Plain
`plain` draws the borderless round form of the Favourites list's remove control: the same heart with no
well, for a row already on the page surface.

### Direction
Placed by its parent row. Nothing inside it mirrors.

**Deviation (target):** the painted well is the design's size, under the touch-target floor, so it
is laid out inside a floor-sized square and the hit area clears the floor. In a card header the row
is therefore taller than the design's well.

## Tokens used

Fill and hairline: the card surface. Corner: `lg` (12). Padding: 6 plus the 1px hairline. Glyph:
`iconSm` (18), the secondary text colour when off and the error status base when on. Touch target:
`touchTargetMin`. Focus ring: the shared ring.

## Change log

- KAN-426 (Seat B) — adds this component, replacing the icon `Button` the venue card's favourite slot used.

## Source

`lib/src/controls/favourite_button.dart`
