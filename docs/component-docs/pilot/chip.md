<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/chip.dart (read in full through the touch-target
           and "what the source does not have" sections)
           lib/src/controls/chip_gallery.dart:27-62 (specimen contents)
           DECISIONS.md — grepped "Chip": no D-numbered ruling touches this
           component (one incidental mention inside T-083's icon-adoption
           list, one inside D-026 naming what a rejected app-kit recreation
           composes — neither rules Chip itself).

Direction section REMOVED 2026-09-18 per D-036: chip.dart reads direction at
lines 200,235, both feeding resolveForDirection (script selection) per
D-036(b)'s own named example — this is a Foundations fact, not a Chip fact.
-->

# Chip
### `DabblerChip`

## Definition

Chip is the pill-shaped control for filtering and tagging — tap to select a filter, or display a
static tag with no interaction at all.

## Intro

It has two states, not a spectrum: plain card fill and hairline when unselected, solid brand fill
when selected. A chip with no `onTap` is a static tag rather than a smaller, quieter chip — it
renders at its natural density with no enforced tap target, because it was never meant to be
tapped.

## Specimen

Selected, unselected, and a leading-icon variant — see `chip_gallery.dart`'s *Chip* section.

## Using it

**Never hardcode white for a selected chip's label.** Use the shared on-brand ink role instead. In
the `bright` theme the brand colour is amber, and the correct ink on it is dark — a hardcoded white
label would be unreadable on that one theme even though it looks fine on every other.

**Give a tappable chip an `onTap`; leave it null for a static tag.** The two read differently on
purpose: a tappable chip gets an enforced minimum tap target and grows past its visual pill height
to reach it, while a tag with no `onTap` stays as dense as it's drawn, because forcing every tag in
a dense row to touch-target size would buy no accessibility and break the layout rows of tags are
built for.

**Do not add a removable chip, a trailing icon, or a size variant.** None of the three exists in
the design source. If the product needs one, that is a design-source change to raise first, not
something to improvise here.

## Axes

### State
Unselected, selected.

### Leading icon
Present or absent — an arbitrary leading glyph slot, no trailing equivalent.

### Interactivity
Tappable (`onTap` set — enforced 45px minimum tap target) or static tag (`onTap` null — no enforced
minimum, renders at natural pill height).

## Tokens used

Fill and border: the card surface (unselected) or the selected surface variant (selected, brand
fill, transparent border rather than none, so the two states stay the same height). Label and icon
ink: `onBrand` when selected, `textPrimary` / `brandPrimary` when not — never a hardcoded white.
Focus ring and touch-target minimum are the same shared tokens every interactive control reads.

## Source

`lib/src/controls/chip.dart`
