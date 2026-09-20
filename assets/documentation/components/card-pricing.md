<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/card_pricing_default.dart:1-70 (class dartdoc
           through the symbol-inversion table and the D-019 explanation)
           lib/src/cards/cards_gallery.dart:36 (specimen title: "Card —
           house, pricing, ticket")
           DECISIONS.md D-019 (read in full, prior session), D-020 (read in
           full this session), D-021 (read in full this session), D-029
           (read in full this session)

CORRECTED INVENTORY per D-038(b): there is no DabblerCardPricingSelected.
card_pricing_selected.dart declares nothing — it re-exports DabblerCardPricing
and records why. "Selected" is this page's state Axis, not a second widget,
and this page's title/class name reflects that.
-->

# CardPricing
### `DabblerCardPricing`

CardPricing is one subscription plan as a selectable tile — name and selection indicator, price,
billing note, and an optional trial pill — where the whole tile is the control, not a card beside a
separate button.

The design file ships two symbols, `Default` and `Selected`, but they are the same tree drawn on
two shells with one flag toggling which — never two widgets, so a `selected` flag decides the
whole chrome rather than porting two components that could drift apart. The file naming the two
symbols has its own trap, covered in *Using it*.

## Specimen

Alongside CardHouse and CardTicket — see `cards_gallery.dart`'s *Card — house, pricing, ticket*
section.

## Using it

**`selected: true` is what paints the filled-tick, bordered shell — read the symbol names
backwards from what you'd expect.** The design file's own two symbols are named the opposite of
what they draw: the one called `Default` paints the chosen state (filled tick) and the one called
`Selected` paints the unchosen state (empty ring). This component's own variant names are corrected
to describe what they paint, not the file's labels — do not "fix" `pricingSelected`/
`pricingUnselected` back toward the file's inverted names.

**Never add a button inside or beside this tile.** The absence of a CTA is deliberate, confirmed
against both the design file and its specimen — the whole tile is the control, and a per-option
button would ask the user to make the same choice twice for a mutually exclusive pick.

**Give the tile real selectable-option semantics, not a decorative-card-plus-disc reading.** Because
the tile is its own control with no button label anywhere on it, assistive technology needs to hear
it as one selectable option in a group — the visual disc alone doesn't convey that on its own.

**Leave the trial pill on `Badge`'s own brand tone; don't give it a private fill.** A one-step
colour drift in the design file was corrected there rather than answered with a fill override or a
separate literal pill — this component's trial pill stays an ordinary `Badge`.

## Axes

### State (selected)
`false` — sunken shell, 2px hairline border, empty ring indicator. `true` — white shell, 2px brand
border, filled brand disc with a tick.

### Trial pill
Present or absent.

## Tokens used

Shell: `pricingUnselected` or `pricingSelected` variant of `Card` — see that page. Indicator:
brand fill when selected, a plain ring when not. Trial pill: `Badge` at its brand tone, unmodified.

## Change log

- D-019 (cxo) — the two variant names are corrected to
  describe what they paint, reversing the design file's own inverted symbol names.
- D-020 (cxo) — the trial pill stays on `Badge`'s brand tone;
  a one-step drift in the design file is corrected there, not answered with a component override.
- D-021 (cxo) — confirms the missing CTA is intentional and
  rules the whole-tile selectable-option semantics this component must carry.
- D-029 (cxo) — reaffirms D-020 after re-checking the premise
  that prompted the question.

## Source

`lib/src/cards/card_pricing_default.dart`, `lib/src/cards/card_pricing_selected.dart`
