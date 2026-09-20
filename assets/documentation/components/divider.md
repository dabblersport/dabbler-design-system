<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/layout/divider.dart:1-78 (DabblerDividerOrientation, class
           dartdoc through "When not to use one")
           lib/src/layout/divider_gallery.dart:14 (specimen title: "Divider
           — horizontal, labelled, vertical")
           DECISIONS.md D-014 (read in full this session)
-->

# Divider
### `DabblerDivider`

Divider is the only line this system draws between things — it replaces every hand-rolled top
border, horizontal rule, and one-pixel spacer in the product.

Its two weights are named by what they separate, not by how dark they are: the default weight
separates things inside one container, `strong` separates one container from another. Both are
always exactly one pixel in either orientation — there's no weight prop, because the design source
hard-codes the line rather than offering a range.

## Specimen

Horizontal, labelled, and vertical — see `divider_gallery.dart`'s *Divider* section.

## Using it

**Don't reach for a Divider between cards in a feed, under a Section heading, or directly above a
Sheet footer or Dialog action row.** Spacing already separates feed cards; `Section` already
carries its own structure under a heading; Sheet and Dialog action rows already carry their own
separation. A Divider in any of those places is a redundant second signal for a separation that
already exists.

**Never use a Divider to fake elevation.** This is a flat system — a line under something is a
separator, not a substitute for the shadow this system doesn't draw.

**Give a labelled divider its label as real content, not decoration.** The plain rule is
decorative and excluded from the accessibility tree; the labelled variant deliberately keeps its
label in the tree, because a word like "or" between two sections carries real meaning a screen
reader needs to hear.

**Don't expect a labelled vertical divider.** The label is horizontal-only in the design source —
a vertical rule is always plain.

## Axes

### Orientation
`horizontal` (fills the available width) or `vertical` (stretches to the parent's cross size, with
a 24px minimum).

### Label
Present (horizontal only) or absent.

@figure 24px lib/src/tokens/dabbler_geometry.dart#space8


## Tokens used

Default weight: `bgTertiary` — the faint paper step, for separating things inside one container.
`strong`: `borderDefault` — the card outline, for separating one container from another. Always
exactly 1px in either orientation.

## Change log

- D-014 (cxo) — confirms the two-weight mapping follows the
  token file exactly, and that the unused `borderStrong` role elsewhere in the system is not a
  Divider defect — Divider was never meant to reach it.

## Source

`lib/src/layout/divider.dart`
