<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/cards/card.dart (read in full through the constructor
           start — DabblerCardVariant enum in full, class dartdoc including
           the slots table, flat/press, radius and padding sections)
           lib/src/cards/cards_gallery.dart:26 (specimen title: "Card —
           variants")
           DECISIONS.md D-018 (read in full), D-019 (read in full, prior
           session)

RESOLVED by D-038: Content containers splits into two labelled navigation
tiers (not a tenth group) — Shells (this page's five, plus Surface, Section,
Accordion, IconTile) and Composed cards (four further pages: CardEvent,
CardHouse, CardPricing, CardTicket — see those files). D-038(b) also
corrected the inventory: there are six widgets across seven files, not
seven widgets — card_pricing_selected.dart declares nothing and
"Selected" is an Axis of the CardPricing page, not a separate class; and
the three CardEvent densities are one page with density as its Axis, not
three, since D-006/D-022 both rule across all three together. EmptyState
remains separately named under Status and feedback, unaffected.
-->

# Card
### `DabblerCard`

Card is the shared chrome every specific card in this system composes — one shell in five paint
variants, never redrawn per card type.

Nine of the design source's content-specific cards (event, room, active-room, house, poll, pricing)
are drawn on five distinct shells, and this component is exactly those five, settled once so that
each specific card only has to supply content. It has four optional slots — a full-bleed media
strip, a padded header, a padded body, a padded footer — and never imposes a layout direction on
what a caller puts in any of them.

## Specimen

All five variants — see `cards_gallery.dart`'s *Card — variants* section.

@specimen card/variants

## Using it

**Supply content, never chrome.** Fill, border colour and width, corner radius, inner padding and
the gap between slots are all settled here — a specific card re-deriving any of them is exactly the
drift this shell exists to prevent.

**Use `pricingSelected` for the chosen plan and `pricingUnselected` for every other one — never the
reverse.** These names were deliberately inverted from an earlier, backwards reading of the same
two shells; read literally, `pricingSelected` is the one that's currently selected.

**Let `media` sit outside the padding; don't wrap it to match the header/body/footer inset.** It's
the one slot drawn full-bleed to the card's own corner radius — a cover image or `CardTicket`'s
coloured header strip both depend on reaching the edge.

**A tappable card darkens while pressed, as the live card does.** Its fill mixes 94% with black
over 80ms (live `Card.jsx`), derived from the card's own resolved fill, and the system's shared
press scale still applies on top. Don't add a second press effect of your own.

## Axes

### Variant
`standard` (sunken fill, no border — the default, used by most content cards), `outlined` (sunken
fill, hairline), `white` (card fill, hairline — used by `EmptyState`'s inline form and panel cards),
`pricingSelected` (card fill, 2px brand border — the chosen plan), `pricingUnselected` (sunken
fill, 2px hairline — every other plan).

### Slots
Media (unpadded, full-bleed), header, child, footer — all padded, all optional, all stretched to
the card's width.

### Interactivity
Tappable (`onTap` set — gets the pressed-fill tint, the shared press scale and focus ring) or inert.

@figure 2px lib/src/cards/card.dart#borderWidthOf
@figure 2px lib/src/cards/card.dart#borderWidthOf


## Tokens used

Fill and border vary by variant — see *Axes* — resolved through the shared colour set. Corner
radius: 16 (a dedicated card-corner step, not the general 12px radius step used for a tile *inside*
a card). Padding: 16, the live `Card.jsx` value, as a documented override. The `cardPadding` token (18)
is deliberately left unchanged because the ticket card still uses it; the two differ on purpose.

## Change log

- D-018 (cxo) — the card corner is 16, a dedicated step, not
  12; 12 remains the corner of a tile nested inside a card, which is a different thing measuring the
  same as an old, wrong assumption.
- Ruling cdispatch-5e71152a — the live pressed-fill tint (94% with black, 80ms) is restored on
  tappable cards; padding 16 retained as a documented override of the 18 token.
- D-019 (cxo) — the pricing variant names, inverted from an
  earlier reading — `pricingSelected` draws the chosen plan, `pricingUnselected` every other one.

## Source

`lib/src/cards/card.dart`
