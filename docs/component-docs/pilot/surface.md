<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/surfaces/surface.dart (read in full through the
           DabblerSurfaceVariant enum and the class dartdoc's "Flat" and
           "retired layer" sections)
           lib/src/surfaces/surface_gallery.dart:14 (specimen title:
           "Surface — variants")
           DECISIONS.md — grepped "Surface": no ruling touches this
           component directly.
-->

# Surface
### `DabblerSurface`

## Definition

Surface is the flat container primitive every other surface-bearing component in this system
composes — an opaque fill plus a 1px hairline, and nothing else.

## Intro

It paints exactly one `BoxDecoration`: a solid fill, a hairline, a radius. There is no shadow
parameter, no blur, no gradient — the system's flatness rule isn't a convention this component
follows, it's a constraint this component makes structurally impossible to violate, because the
API through which any of those could be introduced simply doesn't exist here.

## Specimen

All five fill steps — see `surface_gallery.dart`'s *Surface* section.

## Using it

**Reach for `DabblerSurface` under any new component that needs an opaque, flat container — never
paint a `BoxDecoration` by hand for the same job.** Depth in this system comes from fill steps and a
hairline, never from a shadow; a hand-rolled decoration is how that rule gets quietly broken one
component at a time.

**Use `grey` for a neutral inset panel, not `sunken`.** They're visually similar but distinct
roles — `sunken` is a fill step in the card/panel depth ladder, `grey` is specifically the neutral
inset panel colour. Reaching for the wrong one drifts a panel toward looking like a sunken card
instead.

**Never add a shadow, blur or gradient parameter to this primitive.** The one legal shadow in this
system belongs to Dialog alone, and it isn't reached through Surface — this component has no path
to it by design, and that absence is the whole point.

## Axes

### Variant
`card` (opaque fill plus hairline — the default, what most cards/tiles/panels/sheets/dialogs are
built on), `sunken` (a fill step with no hairline — separation comes from the step itself),
`grey` (the neutral inset panel, also borderless), `brandTint` (opaque brand tint with the card
hairline), `selected` (solid brand fill, no border).

## Tokens used

Fill varies by variant — the card surface, the sunken/grey fill steps, the brand tint, or a solid
brand fill for `selected`. Hairline: `borderDefault`, present on `card` and `brandTint` only.

## Source

`lib/src/surfaces/surface.dart`
