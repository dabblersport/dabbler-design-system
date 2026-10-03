<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/ring.dart (class dartdoc in full)
           lib/src/feedback/ring_gallery.dart (specimen title:
           "Ring — tick countdown and completion arc")
           Design: Wallet (Payment v2) ring(fraction,total,big,small); Listings
           gauge(); Sport Profile v2 completion ring (inline svg in the design,
           painted here with a CustomPainter — the system has no inline SVG).
-->

# Ring
### `DabblerRing`

Ring is a gauge drawn as a ring — either a countdown of radial ticks or a single completion arc —
with a slot in the middle for the number it stands for.

The value is a fraction from 0 to 1, clamped, never a percentage. Both forms start at twelve
o'clock and run clockwise. Ticks are the countdown form: the first rounded `fraction × count` of
them take the brand colour and the rest a neutral track. The arc is the completion form: a full
neutral circle with a round-capped brand arc over it.

## Specimen

The 24- and 32-tick rings with a centre in both track roles, an empty and a full ring, and the
completion arc at four fractions — see `ring_gallery.dart`'s *Ring* section.

@specimen ring

## Using it

**Use `.ticks` for time running down and `.arc` for how complete something is.** The design
draws countdowns (a game starting, a payment window) as ticks and profile or sport completion as
an arc; they are the same widget so the centre slot, semantics and value contract match.

**Put the number in the centre, not on the ring.** A big figure over a small unit
(`3` over `days`) is the pattern in the source screens; pass it as `child`.

**Replace the announced value when a percentage is the wrong thing to say.** The ring announces a
rounded percentage by default; a countdown should pass `semanticValue: '3 days left'` and a
`semanticLabel` naming what is counting.

**Pass `fraction` as 0–1, never 0–100.** A ring given `72` is clamped to full.

## Axes

### Form
`.ticks` (a count of radial ticks — two dozen or thirty-two in the design — each a fixed-width rounded stroke) and
`.arc` (a track circle plus a round-capped arc; empty draws no arc rather than a dot).

### Track
`outline` (the unfilled ticks' default, the card outline role) and `faint` (the arc's default, the
tertiary background role). The design uses both, so it is a choice, not a guess.

### Tick length
Six pixels by default and nine for the Wallet's large ring.

@figure 6px lib/src/tokens/dabbler_geometry.dart#space2
@figure 9px lib/src/tokens/dabbler_geometry.dart#space3

## Direction

**The ring does not mirror under Arabic by default.** The design drives both forms with a
rotation transform and a dash offset, neither of which flips with direction, and a ring reads like
a clock face — clockwise everywhere. `mirrorInRtl: true` opts one use into a counter-clockwise
fill in RTL; the centre content lays out in the ambient direction either way.

## Tokens used

Fill: the brand colour. Track: the card outline role for ticks, the tertiary background role for
the arc. Tick length and the arc's default size and stroke come from the spacing ramp. The 2px
tick width has no token and is a named constant on the widget — rounding it to the 3px step would
close the gap between ticks.

## Source

`lib/src/feedback/ring.dart`
