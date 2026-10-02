<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_poll.dart (class dartdoc in full)
           lib/src/cards/room_cards_gallery.dart (specimen title: "CardPoll — a poll result")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rCardPoll
### `DabblerCardPoll`

CardPoll is a poll result: a tinted question header, one bar per option and a footer with the vote count and an end-poll link.

The question sits on a brand-tinted band; each option is a pill bar filled to its fraction beside its percentage; the footer carries the vote count and an underlined `end poll` link. All text is supplied by the caller and the card takes its width from the column.

## Specimen

See the *CardPoll* section of `room_cards_gallery.dart`.

@specimen card-poll

## Using it

**Pass fractions from 0 to 1 with their labels.** Option colours default to the brand colour then the accent pink; override per option.

**Type is recorded overrides on named steps.** The question is `subheadline` at weight 700, percentages `caption-1` at 700, and the footer `caption-2`; the source's 22.5 and 16.5 leadings snap to the ramp.

## Axes

### Options
One bar per option; the first is brand, later ones pink by default.

## Tokens used

Corner: the 16px card radius. Header tint: the brand colour at 13.3%. Bars: the 8px height and the pill radius. Type: subheadline, caption-1, caption-2 and body.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/cards/card_poll.dart`
