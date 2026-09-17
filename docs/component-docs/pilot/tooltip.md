<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/tooltip.dart (read in full through the
           constructor and Duration constants)
           lib/src/overlays/tooltip_gallery.dart:18 (specimen title:
           "Tooltip — the label for a control with no visible text")
           DECISIONS.md — grepped "Tooltip": no ruling touches this
           component.

Direction: NO section. Placement uses inline start/end, which mirrors
uniformly under RTL — no exception, no semantic consequence.
-->

# Tooltip
### `DabblerTooltip`

## Definition

Tooltip is a short label for a control that carries no visible text of its own — an icon-only
button, most often.

## Intro

It's the one place in this system where the relationship between ink and paper inverts: a dark
panel carrying light text, rather than the other way round. It opens on hover or keyboard focus
after a short delay, or on long-press on touch, and closes the moment the pointer or focus leaves —
which is exactly why it can never be the only place information lives.

## Specimen

Every placement — see `tooltip_gallery.dart`'s *Tooltip* section.

## Using it

**Never make a tooltip the only place a user can learn something they need.** It's unavailable to
a touch user who taps rather than holds, invisible in print, and gone the instant a pointer moves
away — anything the interface actually depends on the user knowing belongs in the interface itself,
not in a tooltip.

**Wrap the specific control the message describes, never a whole card or row.** Tooltip's hover and
focus triggers are scoped to exactly what it wraps — wrapping something larger raises the tooltip
for the wrong reason and hides it wherever the user is actually looking.

**Keep the message to a few words in sentence case.** It's a label, not an explanation — if it
needs more than a short phrase, that content belongs somewhere with more room and less time
pressure than a hover state gives it.

**Rely on the accessible name reaching a screen reader even when the visual panel never
shows.** The message is published as the subtree's own accessible tooltip regardless of whether the
hover/focus/long-press panel is ever triggered — don't duplicate it with a separate semantic label.

## Axes

### Placement
`top` (the default), `bottom`, `start`, `end` — the latter two are inline edges, not fixed sides.

### Trigger
Hover or keyboard focus (short delay), or long-press on touch (a longer, separate delay).

## Tokens used

Panel: `textPrimary` fill with `surfaceCard` text — the one inverted ink/paper pairing in this
system. No shadow; the one legal shadow belongs to Dialog alone.

## Source

`lib/src/overlays/tooltip.dart`
