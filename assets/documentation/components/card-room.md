<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_room.dart (class dartdoc in full)
           lib/src/cards/room_cards_gallery.dart (specimen title: "CardRoom — a room")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rCardRoom
### `DabblerCardRoom`

CardRoom is a room as a card: its name, its topic and a stack of participant avatars ending in a count.

A sunken card with the small room name over the bold topic and, on the trailing side, 36px avatars stepping 28px apart with a brand-tinted `+N` chip. Seeds and text are supplied by the caller.

## Specimen

See the *CardRoom* section of `room_cards_gallery.dart`.

@specimen card-room

## Using it

**Pass the seeds in stack order and the overflow text.** Without seeds or an overflow label no stack is drawn.

**The chip text is `caption-2` at weight 700.** The source's 10px is below the ramp floor and was ruled to 11.

## Axes

### Content
With or without avatars and the overflow chip.

## Tokens used

Corner: the 16px card radius. Padding: 16. Type: caption-2 and subheadline. Colour: the sunken surface, text roles and the brand tint.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/cards/card_room.dart`
