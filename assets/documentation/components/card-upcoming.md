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

@specimen card-upcoming/date

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
- KAN-429 (Meetups) — `CardUpcomingRail` is the multi-tile state of the same Upcoming section.
- Listings fidelity pass — the frame's tile: a 1px `--outline-card` hairline, the 12 corner (`--radius-lg`) and 12 padding; a 62 ring with 7px ticks (32 single, 24 on the rail) and the display numeral; the place row a compact `MetaLine`; `rail` sets the rail metrics, and a rail card in a horizontal scroller hugs its content.
- Listings fidelity pass — `month` / `day` draw the games listing's single tile (`Listings.dc.html:119-137`): a date block first, title over "venue · time", a 56 ring last.

## Source

`lib/src/cards/card_upcoming.dart`
