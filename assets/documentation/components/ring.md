<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/ring.dart (class dartdoc in full)
           lib/src/feedback/ring_gallery.dart (specimen title:
           "Ring — tick countdown and completion arc")
           Design: Wallet (Payment v2) ring(fraction,total,big,small); Listings
           gauge(); Sport Profile v2 completion ring (inline svg in the design,
           painted here with a CustomPainter — the system has no inline SVG).
           Progress form: components/feedback/status-feedback.card.html,
           ProgressBar section ("ProgressRing is the one new primitive");
           lib/src/feedback/action_area_gallery.dart (specimen title:
           "Ring — progress").
-->

# Ring
### `DabblerRing`

Ring is a gauge drawn as a ring — a countdown of radial ticks, a single completion arc, or a progress ring — with a slot in the middle for what it stands for.

The value is a fraction from 0 to 1, clamped, never a percentage. Both forms start at twelve
o'clock and run clockwise. Ticks are the countdown form: the first rounded `fraction × count` of
them take the brand colour and the rest a neutral track. The arc is the completion form: a full
neutral circle with a round-capped brand arc over it. Progress is the design's `ProgressRing`: the
Spinner's own thin ring and faint track carrying a value, spinning when it has none.

## Specimen

The 24- and 32-tick rings with a centre in both track roles, an empty and a full ring, and the
completion arc at four fractions — see `ring_gallery.dart`'s *Ring* section.

@specimen ring

The progress form on its own — small and large, indeterminate, in a status tone, and around an
icon. On the Action Area it sits on the action footprint so the bar can report progress without
expanding (see `NavigationActivity`).

@specimen ring/progress

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

**Use `.progress` for work in flight, not for a score or a countdown.** It is a loading indicator
with a value: omit the value and it becomes the spinner, turning (or pulsing under reduced motion).
Determinate, it announces as a progress bar with its value; indeterminate, as a status.

## Axes

### Form
`.ticks` (a count of radial ticks — two dozen or thirty-two in the design — each a fixed-width rounded stroke) and
`.arc` (a track circle plus a round-capped arc; empty draws no arc rather than a dot), and
`.progress` (the Spinner's stroke and faint track with a value arc, or a turning arc when there is
no value).

### Progress tone
`brand` (the default), `inherit` (the ambient ink), `onBrand` for a ring on a brand fill, or a
status tone, which paints that status's base.

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
fill in RTL; the centre content lays out in the ambient direction either way. The progress form has
no such option: progress direction is never mirrored.

## Tokens used

Fill: the brand colour. Track: the card outline role for ticks, the tertiary background role for
the arc. The progress form takes the progress bar's tone for its indicator and the Spinner's stroke,
track opacity, arc share and periods for the rest. Tick length and the arc's default size and stroke come from the spacing ramp. The 2px
tick width has no token and is a named constant on the widget — rounding it to the 3px step would
close the gap between ticks.

## Source

`lib/src/feedback/ring.dart`
