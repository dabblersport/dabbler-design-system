<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_upcoming_rail.dart (class dartdoc)
           lib/src/cards/meetup_parts_gallery.dart (specimen "CardUpcomingRail — the narrow upcoming tile")
           design: Listings.dc.html:454-486 (Upcoming, the multi state)
-->

# CardUpcomingRail
### `DabblerCardUpcomingRail`

CardUpcomingRail is the narrow upcoming tile for a horizontal rail: a date block, the title and time, the venue and a small countdown ring.

Use `CardUpcoming` for the single state.

## Specimen

The amber and info tones, one with an Arabic title — see `meetup_parts_gallery.dart`.

@specimen card-upcoming-rail

## Using it

**Use it when the viewer has more than one upcoming meetup.** One goes in `CardUpcoming`, two or more in a rail of these.

**Pass already-formatted text.** The tile owns no clock; month, day and the countdown come from the caller.

## Axes

### Tone
Amber, info or accent, the same three tiles as `CardUpcoming`.

## Direction

The date block leads at the inline start. The ring is a clock face and does not mirror.

## Tokens used

Fill from the tile tones. Date wash from the brand at 10%. Title `subheadline` semibold, time `caption2`, place `caption1`. Ring 40, 24 ticks.

Deviation: the day is `headline` bold (17) where the design draws 18/22.

## Change log

- KAN-429 (Meetups) — the ring's number is 12/13 and its unit 6/7, as the frame draws them in the 40 ring (the unit overlapped the ticks).
- KAN-429 (Meetups) — adds this component.

## Source

`lib/src/cards/card_upcoming_rail.dart`
