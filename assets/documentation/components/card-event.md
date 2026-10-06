<!--
Component page, D-033 ten-part template, as amended by D-038(b): the three
event densities are ONE page with density as the size Axis, not three
pages, because D-006 and D-022 both rule across all three together and
D-022's entire content is a comparison between them.

Tier     : Composed cards (D-038's new navigation tier inside Content
           containers)
Sources  : lib/src/cards/card_event_large.dart:1-60 (DabblerCardEventGeometry
           — read in full; the shared, D-006-derived geometry block all
           three densities read from)
           card_event_medium.dart, card_event_small.dart (not read in full
           this session — their own dartdoc defers to the shared geometry
           block already read; their gallery specimens confirmed via
           cards_gallery.dart title only)
           lib/src/cards/cards_gallery.dart:31 (specimen title: "Card —
           event, large / medium / small")
           DECISIONS.md D-006 (read in full this session), D-022 (read in
           full, prior session), D-018 (read in full, prior session —
           the card corner the cover inherits)

FINDING worth keeping visible: the design source's own CardEvent* nodes are
NOT event cards at all — D-006 found them to be three near-identical
settings rows (a mis-exported Figma node), so this component's entire
geometry is ruled by cxo directly rather than transcribed from a drawing.
Stated plainly in Using It rather than left implicit.
-->

# CardEvent
### `DabblerCardEventLarge`, `DabblerCardEventMedium`, `DabblerCardEventSmall`

CardEvent is the event card, in three densities — a cover image, a title, and the sport that owns
the visual space, built on the shared `Card` shell.

The design bundle's own exported `CardEvent*` nodes are not event cards — they're three
near-identical settings rows exported under the wrong name, verified by diff. This component's
geometry is therefore ruled directly by `cxo` rather than transcribed from a drawing, until the
correct nodes are re-exported into the design source. Every density shares one geometry block so a
future amendment is one edit, not three.

## Specimen

All three densities — see `cards_gallery.dart`'s *Card — event* section.

@specimen card-event/densities

## Using it

**Don't treat this component's numbers as transcribed from a design drawing — they're ruled,
derived from the rest of the system, pending the design source's own event-card nodes being
re-exported correctly.** If a design update changes the cover ratio, the thumbnail size, or the
overlay geometry, that's a ruling to revisit, not a drawing to re-transcribe.

**Never add a sport-icon overlay to Medium or Small.** It exists on Large only — a well eating
44% of Small's cover area is a replacement of the cover, not a mark on it, and no second, smaller
overlay step exists to reach for instead. Sport identity on Medium and Small comes from the title
and a label, not from the cover.

**Use the listing slots for a game in a list: `progress`, `price` and `action`.** All three
densities take them. Pass a `DabblerCardEventPlayers` for the "9 of 10 players in" bar and its
status note, a `DabblerCardEventPrice` for the amount and its unit, and
`DabblerCardEventListing.joinButton` for Join — it is a full-width `Button`, so `loading` shows its
spinner and `disabled` greys it for a full or past game. Progress and price share a row, price at
the inline end; Join sits under them. A card with none of the three renders exactly as before.

**The note's words carry the status, not its colour.** The bar and note take a status tone
(`warning` for almost full, `error` for full), but "1 spot left" must say so in text.

The price is `figureXl` — 22/27 bold in the sans face, as `Listings.dc.html:251` draws it.

@specimen card-event/listing

## Axes

### Density (the size Axis)
`Large` — full-bleed cover at 16:9, top corners matching the card's own corner, with the sport-icon
overlay. `Medium` — a 64×64 leading thumbnail, no overlay. `Small` — a 48×48 leading thumbnail, no
overlay (48, not 45 — off-grid values are rejected even when they'd otherwise clear the touch-target
floor).

@figure 64 lib/src/cards/card_event_large.dart#mediumThumbSide
@figure 48 lib/src/cards/card_event_large.dart#smallThumbSide
@figure 45 lib/src/tokens/dabbler_geometry.dart#touchTargetMin


## Direction

**Large's sport-icon overlay sits inset from the leading edge, not a fixed physical side.** Under
Arabic it moves to the right rather than the left — the inset is directional because the overlay's
position is meant to read as "near the start," which is a different physical edge in each script.

*Confirmed by reading `card_event_large.dart`'s geometry block directly, and by D-006's own text,
which states the leading-edge inset explicitly as "directional, which RTL requires." Not yet
checked against the gallery's direction switcher.*

## Tokens used

Cover/thumbnail corners inherit the card's own corner (16, per D-018) rather than a second, nested
corner. Thumbnail radius at Medium/Small is the 12px nested-tile step, the same one `IconTile` uses.
Overlay well fill: the card surface colour.

## Change log

- D-006 (cxo) — the design source's own event-card nodes are
  mis-exported settings rows, not event cards; rules this component's geometry directly until the
  correct nodes are re-exported.
- D-018 (cxo) — the card corner is 16, which is what Large's
  cover inherits rather than drawing a second corner of its own.
- D-022 (cxo) — the sport-icon overlay belongs to Large only;
  Medium and Small do not get a smaller version of it.

- Alpha DS gaps 6 — adds the `progress`, `price` and `action` listing slots to all three
  densities, with `DabblerCardEventPlayers`, `DabblerCardEventPrice` and
  `DabblerCardEventListing` (`Listings.dc.html:242-259`). Large's own `footer` still renders,
  under the slots.
- Listings fidelity pass — the price is `figureXl` (22/27) and its unit 11/15; the players label `footnoteTight` (13/17) and its note 11/15; `DabblerCardEventListing.cardRadius` / `cardPadding` name the listing shell.

## Source

`lib/src/cards/card_event_large.dart`, `lib/src/cards/card_event_medium.dart`,
`lib/src/cards/card_event_small.dart`, `lib/src/cards/card_event_listing.dart`
