<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/fab.dart (read in full through the shadow
           declaration)
           lib/src/controls/fab_gallery.dart:24-67 (specimen contents)
           DECISIONS.md — D-004 (accent-indigo, applies to the `indigo`
           tone's known defect the same way it does to Button's `accent`),
           D-005 (corner radius 21, read in full, prior session), D-031
           (flatness/shadow — FAB's exception, read in full, prior session)
-->

# Fab
### `DabblerFab`

Fab is the one floating action button — a single 56×56 control carrying one glyph, for the one
primary action a screen wants reachable from anywhere on it.

It merges what used to be four separate FAB symbols into one component with a tone modifier. It is
also the single deliberate exception to this system's flat, no-shadow surfaces — see *Using it* for
why, and do not read that exception as license to add a shadow anywhere else.

## Specimen

All four tones — see `fab_gallery.dart`'s *FAB — tones* section.

## Using it

**Reserve Fab for the one primary action a screen wants reachable from anywhere on it.** It floats
over scrolling content rather than sitting on a card or a page, which is what its shadow is for —
see the next rule. A screen with more than one Fab has stopped using it for what it's for.

**Do not remove Fab's shadow, and do not add one anywhere else in this system.** Every other
surface here is flat by rule. Fab keeps a shadow because it floats over arbitrary content with no
surface of its own to sit flush against — without it, it reads as stuck to whatever happens to be
underneath it. That reasoning is specific to floating over content; it does not generalise to
"important things get a shadow."

**Give Fab a `semanticLabel`.** It carries a glyph and no text, so without one it announces to
assistive technology as an unlabelled button.

**Do not treat the `indigo` tone's fill as a stable value yet.** It resolves through the same known
colour defect Button's `accent` tone does — see *Change log*.

## Axes

### Tone
Four: `indigo` (the source's `default` tone — a reserved word in Dart), `primary` (the theme's
brand purple — the default), `accent` (the theme's accent pink), `dark` (sunken neutral surface).

### State
Enabled, disabled (45% opacity, every handler withheld — no partial-disabled state).

## Tokens used

Fill by tone: `brandPrimary` (primary), `accent` (accent), `surfaceSunken` (dark), and the `indigo`
tone's known-defect stand-in (see *Change log*). Label ink: `onBrand` for the three brand-adjacent
tones, `textPrimary` for `dark`. Corner radius and focus ring are the same shared tokens every other
control reads; the drop shadow is this component's own declared value, not a shared elevation
token — see *Using it*.

## Change log

- D-004 (cxo) — the `indigo` tone's fill is the same known,
  documented defect as Button's `accent`: a stand-in for a token the design source's own colour
  file has not yet declared.
- D-005 (cxo) — confirms the 21px corner as this system's
  deliberate choice over the Figma file's fully-round default.
- D-031 (cxo) — confirms Fab's shadow as this system's one
  deliberate exception to flatness, and rules that the bottom navigation bar's own floating action
  inherits this same exception rather than needing one of its own.

## Source

`lib/src/controls/fab.dart`
