<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/mutuals_card.dart (class dartdoc in full)
           lib/src/cards/panel_cards_gallery.dart (specimen title:
           "MutualsCard — avatars beside a line of context")
           Live design project components/cards/rMutualsCard.jsx, design system
           1.2.0 (read through DesignSync).
-->

# rMutualsCard
### `DabblerMutualsCard`

MutualsCard is an avatar stack beside a line of context, such as who you both follow.

It uses the same shell as the other profile cards — card fill, one-pixel outline, 12px corner and 12px padding — with the text in `footnote` at the soft ink colour. The avatars are supplied by the caller, usually an avatar group.

## Specimen

See `panel_cards_gallery.dart`'s *MutualsCard* section.

@specimen mutuals-card

## Using it

**Pass an avatar group and one sentence.** The widget holds no data.

**Leave `avatars` null for a text-only card.**

## Axes

### Content
With avatars, or text only.

## Tokens used

Corner: the 12px large radius. Padding and gap: the 12px step. Type: footnote. Colour: the card surface, card outline and soft ink.

## Change log

- Added from the live design project, design system 1.2.0 (`MutualsCard.jsx`).

## Source

`lib/src/cards/mutuals_card.dart`
