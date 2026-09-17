<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/card_house.dart:1-50 (class dartdoc through the
           geometry-deviation table)
           lib/src/cards/cards_gallery.dart:36 (specimen title: "Card —
           house, pricing, ticket")
           DECISIONS.md D-018 (read in full, prior session) — CardHouse's
           own icon-well/shell corners are D-018's primary measured
           evidence (nine card shells counted, CardHouse's is one of them),
           so linked here as well as on Card's own page.
-->

# CardHouse
### `DabblerCardHouse`

CardHouse is a house — a recurring room series — as one row: a brand-filled icon well beside the
house's name and cadence, with a full-width join action beneath it.

It composes `Card` and adds content only — fill, border, radius, padding, press and focus all come
from the shell, at the `standard` variant. The join action is a second block, not part of the same
row as the icon and name: it lives in `Card`'s footer slot, which is the action slot, not folded
into the same row as the title.

## Specimen

Alongside CardPricing and CardTicket — see `cards_gallery.dart`'s *Card — house, pricing, ticket*
section.

## Using it

**Put the row (icon well, name, cadence) in `child` and the join action in `footer` — never
combine them into one block.** The design draws them as two distinct pieces, not a single row with
a button appended; the footer slot exists specifically for a card's own action.

**Let the icon well take the nested-tile corner (12), not the card's own corner (16).** This is
the canonical example of the two-corner rule: the well nested inside the card reads correctly only
when it's visibly a smaller, separate shape from the card containing it, not the same corner
repeated at a smaller scale.

## Axes

### Content
Icon well, name, cadence text, join action — all required; no optional slots beyond what `Card`
itself already makes optional.

## Tokens used

Card fill: the `standard` variant (sunken, no border). Icon well: brand fill at the nested-tile
corner. Join action: a full-width pill at the brand fill. Padding and the join action's minimum
height both come from shared tokens rather than the design file's own literals.

## Change log

- [D-018 (cxo)](../../../../dabbler-docs/DECISIONS.md) — CardHouse's icon well (12) and shell (16) are
  among the measured evidence this ruling is built on: the two corners are deliberately different,
  not a drift to reconcile.

## Source

`lib/src/cards/card_house.dart`
