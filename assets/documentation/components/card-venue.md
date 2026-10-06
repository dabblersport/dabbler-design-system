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

**Compose the tags from parts you already have.** `tags` takes widgets: `DabblerCardVenue.distanceTag`
for the brand distance chip, `DabblerCardVenue.rating` for the star, score and review count, and
`ListingTag` for badges such as "Top rated". `sports` takes `ListingTag.outlined`. The rows wrap.

**Leave `cover` null for a venue without a photo.** The card then starts at the name, as the design
does; it does not draw an empty grey box.

**The favourite and the trailing button are their own targets.** They keep their own button
semantics and do not open the card. Give the favourite a localised `semanticLabel`.

**Pass formatted, localised strings.** `area`, `distance`, `price` and `priceCaption` are drawn as
given; the card formats nothing.

The shell is the white card at the listing corner (18) with the frame's 15 of body padding inside
the hairline — the same shell as `CardGame`, so a mixed list reads as one family.

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

Name: headline step in `textPrimary`, two lines. Place: footnote in `textSecondary`; caption: the
tag step at regular weight; the location glyph in `textTertiary`. Price: body at semibold (16/21).
Rating: footnote-tight; star the warning status base. Price rule: `bgTertiary` (`--faint`). Shell:
`surfaceCard` inside `borderDefault`. Gaps: the 12 stack gap and 6/9 spacing steps.

## Change log

- Alpha DS gaps 6 — adds this component, from `Listings.dc.html:750-820`.
- KAN-426 (Seat B) — adds `accent` (a sport-tinted card fill, a derivation, not a frame); the `favourite` slot now takes `DabblerFavouriteButton`.
- Alpha fidelity rebuild (KAN-426) — adds the `sports` and `facilities` rows and `facility()`, from `Listings.dc.html:795-808`.
- Listings fidelity pass — the white listing shell at 18 (was the tonal card at 16); name block and tags 6 apart; `distanceTag`; outlined `ListingTag` sport chips; facility glyph 16, 5 from its caption; price 16/21 under a `--faint` rule; caption 11/15.

## Source

`lib/src/cards/card_venue.dart`
