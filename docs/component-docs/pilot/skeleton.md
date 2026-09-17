<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/skeleton.dart:1-55 (DabblerSkeletonVariant in
           full, class dartdoc's flat/never-shimmer and accessibility
           sections, constructor start)
           lib/src/feedback/skeleton_gallery.dart:13 (specimen title:
           "Skeleton — variants")
           DECISIONS.md — grepped "Skeleton": no D-numbered ruling; the
           no-shimmer rule is cpo's own product principle (§5.2), cited in
           skeleton.dart's own dartdoc, not a DECISIONS.md entry — not
           linked in Change log since it isn't one.
-->

# Skeleton
### `DabblerSkeleton`

## Definition

Skeleton is placeholder geometry for content that hasn't arrived yet — the screen keeps its final
layout while data loads, so nothing jumps when the real content lands.

## Intro

Every block is a flat fill with no gradient and no travelling highlight — a shimmer is explicitly
a product-level thing this system avoids, not a stylistic default this component happens not to
use. The only motion is a whole-block opacity pulse, staggered slightly per line, which animates
the block that's already there rather than introducing a second colour moving across it.

## Specimen

All four variants — see `skeleton_gallery.dart`'s *Skeleton* section.

## Using it

**Never add a shimmer or travelling highlight to a skeleton.** It's excluded at the product level,
not just undrawn here — a gradient sweeping across the block is a shimmer by another name, whatever
it's called at the call site.

**Announce loading once, on the container around a group of skeletons — never on each block.** Every
skeleton block is hidden from assistive technology individually; a screen with twelve skeleton bars
should announce "loading" once for the whole group, not let a screen reader hit twelve identical
hidden nodes.

**Use `card` for a ready-made card-shaped placeholder rather than composing `rect` and `text`
skeletons inside your own `Card`.** It already matches the standard card shell — media block over
two text bars, inside the card hairline — so building the same shape by hand duplicates a form this
component already provides.

## Axes

### Variant
`text` (stacked bars, the last one 60% width), `rect` (one block, defaults to the touch-target-
minimum height), `circle` (an avatar-shaped well), `card` (a ready-made card shell: media over two
text bars).

### Motion
Animated (the default — a staggered opacity pulse) or static (`animate: false`).

## Tokens used

Fill: a single flat sunken-surface tone at every frame — never a second colour, even while
animating.

## Source

`lib/src/feedback/skeleton.dart`
