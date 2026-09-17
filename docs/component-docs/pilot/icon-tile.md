<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/surfaces/icon_tile.dart (read in full through the class
           dartdoc's composition, geometry and "where the port differs"
           sections)
           lib/src/surfaces/icon_tile_gallery.dart:24 (specimen title:
           "IconTile — the 45×45 tinted glyph container")
           DECISIONS.md D-018 (read in full, prior session) — linked because
           IconTile's own 12px corner is the canonical instance of D-018's
           "12 is the corner of a tile inside a card" rule (confirmed: this
           file's own geometry table cites --radius-lg, the same step D-018
           names for a nested tile).
-->

# IconTile
### `DabblerIconTile`

## Definition

IconTile is the 45×45 tinted square that holds one glyph — a composition of `Surface`'s box and
`Icon`'s glyph, restating neither.

## Intro

The box — fill, hairline, radius — is entirely `Surface`'s; the glyph — the Iconsax lookup, the
weight fallback, the missing-name placeholder — is entirely `Icon`'s. This file states only the
three numbers that are genuinely its own: the 45px size, the 12px corner, and the 24px glyph size,
and even those three are tokens, not literals.

## Specimen

Every tone — see `icon_tile_gallery.dart`'s *IconTile* section.

## Using it

**Reach for the brand tone by default; the three decorative tones (`amber`, `info`, `accent`) are
for the specific roles the token layer names, not a free colour choice.** There is no arbitrary-colour
option — a tone the design draws that isn't one of these four is a gap to report against the token
layer, not a colour to invent on the spot.

**Don't pass a 10%/28% custom tint expecting it to match the design source exactly.** The brand
tone resolves through the same shared token the rest of the system's brand tint uses, which is the
later, authoritative version of the same intent — matching it exactly rather than re-deriving the
original mix percentages is the point.

**Only the three decorative tones carry no hairline; the brand tone does.** If a tile looks like
it's missing its border, check which tone it's on before assuming a defect — flat decorative fills
and the bordered brand tint are two different visual treatments by design, not an inconsistency.

## Axes

### Tone
`brand` (the default — brand tint with the card hairline), `amber`, `info`, `accent` (decorative
tile roles, flat fill, no hairline).

### Interactivity
Tappable (gets the shared press scale and focus ring) or inert.

## Tokens used

Size: the 45px touch-target-minimum step. Corner: the 12px radius step (the same one D-018 rules is
a nested tile's corner, not a card's). Glyph: the 24px icon-medium step. Tone fill: the brand tint
surface variant, or one of the three decorative tile roles.

## Change log

- [D-018 (cxo)](../../../dabbler-docs/DECISIONS.md) — confirms the 12px corner as the ruled corner
  for a tile nested inside a card, distinct from the card's own 16px corner.

## Source

`lib/src/surfaces/icon_tile.dart`
