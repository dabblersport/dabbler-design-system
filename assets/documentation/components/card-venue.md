<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_venue.dart (class dartdoc, read in full)
           lib/src/cards/listing_cards_gallery.dart (specimen "CardVenue —
           a venue in a listing")
           design: Listings.dc.html:750-820 (the venue card)
-->

# CardVenue
### `DabblerCardVenue`

CardVenue is a venue in a listing — a cover photo, the venue's name and where it is, a row of tags,
a favourite action, and the price it starts from, built on the shared `Card` shell.

It draws no shell of its own: surface, border, corner, padding, press and focus are `Card`'s, so a
venue reads as the same family as the event cards it sits beside.

## Specimen

With a cover and without — see `listing_cards_gallery.dart`'s *CardVenue* section.

@specimen card-venue

## Using it

**Compose the tags from parts you already have.** `tags` takes widgets: `DabblerCardVenue.rating`
for the star, score and review count, and `Chip` or `Badge` for distance, sports and badges such as
"Top rated". The row wraps.

**Leave `cover` null for a venue without a photo.** The card then starts at the name, as the design
does; it does not draw an empty grey box.

**The favourite and the trailing button are their own targets.** They keep their own button
semantics and do not open the card. Give the favourite a localised `semanticLabel`.

**Pass formatted, localised strings.** `area`, `distance`, `price` and `priceCaption` are drawn as
given; the card formats nothing.

**Deviation:** the design's card corner is 18 and its body padding 15. The card keeps `Card`'s own
corner (16) and padding (18) so every card in a list matches.

## Axes

### Cover
A 170px cover over the sunken surface while it loads, or none.

@figure 170 lib/src/cards/card_venue.dart#coverHeight

### Price row
Caption and price beside a trailing action above a hairline, or none.

## Direction

Everything is directional: the favourite sits at the inline end of the name, the tags wrap from the
inline start, and the price row puts the price at the start and the action at the end. Under
Arabic all of it mirrors.

## Tokens used

Name: headline step in `textPrimary`, two lines. Place and caption: footnote and caption-2 in
`textSecondary`; the location glyph in `textTertiary`. Price: callout at semibold. Rating star: the
warning status base. Hairline: `borderDefault`. Gaps: the 12 stack gap and 6/9 spacing steps.

## Change log

- Alpha DS gaps 6 — adds this component, from `Listings.dc.html:750-820`.
- KAN-426 (Seat B) — adds `accent` (a sport-tinted card fill, a derivation, not a frame); the `favourite` slot now takes `DabblerFavouriteButton`.
- Alpha fidelity rebuild (KAN-426) — adds the `sports` and `facilities` rows and `facility()`, from `Listings.dc.html:795-808`.

## Source

`lib/src/cards/card_venue.dart`
