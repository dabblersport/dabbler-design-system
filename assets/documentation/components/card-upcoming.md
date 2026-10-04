<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_upcoming.dart (class dartdoc)
           lib/src/cards/card_upcoming_gallery.dart (specimen "CardUpcoming —
           a game you are in, counting down")
           design: Listings.dc.html:139-170 (the Upcoming rail)
-->

# CardUpcoming
### `DabblerCardUpcoming`

CardUpcoming is a game the viewer is in, on a tinted tile: a countdown ring with the number and unit
in its centre, the title, the date line and the place.

It composes `Card` (with a tile-tone fill), `Ring`, `Text` and `Icon`.

## Specimen

Amber and info tones — see `card_upcoming_gallery.dart`'s *CardUpcoming* section.

@specimen card-upcoming

## Using it

**Pass the countdown already worked out.** `fraction` is how far through the window the game is;
`countdownValue` and `countdownUnit` are the localised centre text.

**Put several in a horizontal rail with a fixed `width`.** A single tile can take the full width.

## Axes

### Tone
`amber`, `info` or `accent` — the decorative tile tones, carrying no state meaning.

### Direction
The ring leads at the inline start. The ring is a clock face and does not mirror.

## Tokens used

Fill: `tileAmber`, `tileInfo` or `tileAccent` surface. Ring: `DabblerRing.ticks`, 24 ticks, faint
track. Gap `space4`.

## Change log

- Alpha fidelity rebuild (KAN-426) — adds this component, and a `fill` override on `Card`.

## Source

`lib/src/cards/card_upcoming.dart`
