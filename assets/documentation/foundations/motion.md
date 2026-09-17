<!--
Foundations page, D-034's nine-part template. UNBLOCKED per D-040(c) — the
motion specimen shipped (KAN-301).

Sources : lib/src/tokens/dabbler_motion.dart (read in full — duration
          constants, easeOut, pressScale with the FAB deviation note,
          reduceMotion)
          lib/src/tokens/dabbler_motion_gallery.dart:1-70 (read in full —
          the three entry titles, the "why this specimen animates rather
          than tabulating" rationale, and the "what is compared against
          what" table including the labelled FAB deviation)
          DECISIONS.md — grepped "Motion"/"motion" for a dedicated ruling:
          none found; D-031's flatness territory is adjacent but doesn't
          rule motion itself, so not linked.
-->

# Motion

Motion is one duration scale, one easing curve, and one press transform — nothing in this system
moves on a value outside these, except one named, labelled exception.

Three durations cover every animated transition in the system: a fast one for press and tint
changes, a base one for indicator slides, expand/collapse and toast entry, and a slow one for sheet
and dialog entry. All of them ease with the same single curve — there's no second curve anywhere in
this system. Press feedback is a single scale value, with exactly one documented, named exception:
`Fab` presses further than everything else, because that's what the design source draws for it
specifically, and the value is `Fab`'s own rather than a second system-wide press scale.

## Specimen

Three entries — see `dabbler_motion_gallery.dart`'s *Motion* section. The durations entry runs the
same travel under the same curve at all three durations, on a continuous loop, rather than a static
table — the design source itself only tabulates duration and easing as two numbers on a page, and
this specimen is where the actual difference between 80ms and 200ms becomes visible rather than
read.

## Using it

**Never invent a second easing curve.** One curve covers every eased transition in this system —
reaching for a different one for a "smoother" feel is exactly the kind of one-off this token exists
to prevent.

**Use the fast/base/slow durations by what they're for, not by how long the transition happens to
feel right at a glance.** Fast is press and tint changes specifically; base is indicator slides,
expand/collapse and toast entry; slow is sheet and dialog entry. Picking a duration because it
"looks about right" rather than because of what's transitioning drifts the scale one component at a
time.

**Never normalise `Fab`'s 0.96 press scale onto the system's 0.98, or vice versa.** They're
deliberately different values — `Fab` owns its own, transcribed from its own drawing, and treating
them as the same value with rounding error would erase a real, documented exception.

**Respect reduced motion, but check what each component actually does under it before assuming
"stop."** Several components in this system don't simply freeze under reduced motion — a spinner
switches to a pulse rather than a static frame, because a stopped spinner reads as broken rather
than accessible. Check the specific component's own page rather than assuming one universal
reduced-motion behaviour.

## Axes

### Duration
`fast` (80ms — press, tint change), `base` (120ms — indicator slides, expand/collapse, toast
entry, overlay fade), `slow` (200ms — sheet and dialog entry).

### Easing
One curve, used everywhere: `cubic-bezier(.2, 0, .2, 1)`.

### Press scale
`0.98` (the system's only press transform), with `Fab`'s own `0.96` as the one named, documented
exception.

## Source

`lib/src/tokens/dabbler_motion.dart`
