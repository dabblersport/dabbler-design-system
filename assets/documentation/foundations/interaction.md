<!--
Foundations page, D-034's nine-part template. UNBLOCKED: specimen already
ships as 'Interaction — focus ring, press scale, scrim'
(interaction_gallery.dart:22).

Sources : lib/src/interaction/focus_ring.dart (read in full)
          lib/src/interaction/press_scale.dart (read in full)
          lib/src/interaction/scrim.dart (read in full)
          DECISIONS.md D-017 (read in full, prior session), D-031 (skimmed,
          prior session — cited here only for the "scrim is the elevation"
          connection to flatness, confirmed by scrim.dart's own dartdoc
          rather than re-read in full this session)
-->

# Interaction
### `DabblerFocusRing`, `DabblerPressScale`, `DabblerScrim`

Three primitives carry every interactive affordance in this system — one focus ring, one press
scale, one overlay wash — and no component draws its own version of any of them.

Each primitive wraps an arbitrary child and assumes nothing about what it is: no tap handler, no
gesture logic, no colour of its own beyond what the primitive itself needs. A Button, a Chip, a
Card and a Rating star all press with the same scale and timing; a Sheet, a Dialog and a mobile
Menu all sit on the same wash. Flutter's `Theme.of(context)` is never the source for any of
them — see *Using it*.

## Specimen

The focus ring, press scale and scrim, each shown on and off — see `interaction_gallery.dart`.

## Using it

**Never build a component-specific focus ring, press effect or overlay wash.** These three
primitives are the whole of this system's interaction language on purpose — a fourth, private
version anywhere is a fork of a rule that is supposed to be the same everywhere.

**Draw the focus ring with an outline, never a shadow.** It appears only on keyboard focus, not on
a mouse or touch press — matching CSS `:focus-visible` rather than `:focus` — and it paints rather
than lays out, so showing it never moves or resizes anything around it.

**Treat the scrim as the elevation, not as a shadow you still owe the panel above it.** This is a
flat system with no drop shadows; separation between an overlay and the page behind it comes from
the scrim's wash plus the panel's own hairline, not from anything painted under the panel.

**Use `Theme.of(context)` for none of this.** Importing `material.dart` for the mechanism these
primitives need — focus tracking, pointer handling — is allowed; painting from Material's own
theme, ink or ripple is not, here or anywhere else in this system.

## Axes

### Focus ring
On keyboard focus only (`FocusHighlightMode.traditional` — a mouse or touch press never raises it).
2px outline, 2px offset, coloured from the active theme's focus-ring role.

### Press scale
Scales to 0.98 over 80ms with an ease-out curve, then back on release. Two forms: the primitive
tracks the pointer itself, or a caller that already tracks pressed state drives it directly.

### Scrim
45% ink wash in light, 65% ink-950 in dark. Fades in and out over 120ms ease-out. Optionally
absorbs a dismiss tap; otherwise inert and pass-through.

### Reduced motion
The focus ring has no animation either way, so there's nothing to switch off. Press scale still
happens under reduced motion — removing it would leave a press with no feedback at all — but the
transition becomes instant rather than eased. The scrim's fade becomes instant the same way.

@figure 2px lib/src/interaction/focus_ring.dart#ringWidth
@figure 2px lib/src/interaction/focus_ring.dart#ringOffset


## Change log

- D-017 (cxo) — rules the mechanism-vs-appearance line these three
  primitives sit exactly on: importing Material for behaviour is allowed, inheriting its paint is
  not.
- D-034 (cxo) — rules the Foundations page template this page
  follows.

## Source

`lib/src/interaction/focus_ring.dart`, `lib/src/interaction/press_scale.dart`,
`lib/src/interaction/scrim.dart`
