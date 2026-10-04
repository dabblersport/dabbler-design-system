<!--
Component page, D-033 ten-part template.

Tier     : Controls
Sources  : lib/src/controls/rsvp_cta.dart (class dartdoc)
           lib/src/cards/meetup_parts_gallery.dart (specimen "RsvpCta — the call to action in every RSVP state")
           design: Details.dc.html:359-364 and the cta() map :681-702
-->

# RsvpCta
### `DabblerRsvpCta`

RsvpCta is the call to action for a meetup, in every state the RSVP can be: join, request, going, interested, pending, full, closed, cancelled, started, not visible and not allowed.

The state picks the colour, the glyph and whether the pill takes a press; the words come from the caller.

## Specimen

All eleven states, and the card size — see `meetup_parts_gallery.dart`.

@specimen rsvp-cta

## Using it

**Pass the state, not a colour.** Going is the success status, interested and full the warning status, pending the info status, cancelled the error status; closed, started, not visible and not allowed are the inert sunken pill.

**Let the label carry the meaning.** The glyph and colour only reinforce it.

**Put it in an `ActionBar` as `primary`** at the bar size, or as a game card's `action` at the card size.

## Axes

### State
Eleven, listed above. Six take a press and five are inert.

### Size
`bar` and `card`: the bar's pill is the full button height, the card's is the touch-target minimum.

### Loading
Blocks presses and keeps the look.

## Direction

The glyph leads the label; the pill is centred and symmetrical.

## Tokens used

Fill, ink and border from the status roles (`surface`, `strong`, `base`), the brand fill, or `surfaceSunken` with `textTertiary` when inert. Border 2, pill radius, glyph `iconSm`, label `subheadline` semibold.

## Change log

- KAN-429 (Meetups) — adds this component.

## Source

`lib/src/controls/rsvp_cta.dart`
