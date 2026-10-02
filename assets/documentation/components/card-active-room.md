<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_active_room.dart (class dartdoc in full)
           lib/src/cards/room_cards_gallery.dart (specimen title: "CardActiveRoom — a live room")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rCardActiveRoom
### `DabblerCardActiveRoom`

CardActiveRoom is a live room: its name and topic, an unmute pill, the current speaker with a speaking badge, and a join pill.

It composes only the avatar and icon components and owns no audio or room state. The speaking dot is drawn as a shape rather than the source's Inter glyph, and every label and callback is injected.

## Specimen

See the *CardActiveRoom* section of `room_cards_gallery.dart`.

@specimen card-active-room

## Using it

**Pass the speaker seed and the callbacks.** `onMute` and `onJoin` are optional; without them the pills are inert.

**The type is `footnote` at weights 600 and 700 and `caption-1`.** The source's 19.5 and 18 leadings snap to the ramp.

## Axes

### Pills
The mute pill (outlined) and the join pill (brand fill).

## Tokens used

Corner: the 16px card radius and the pill radius. Colour: the sunken and card surfaces, the brand role and the muted ink. Type: footnote and caption-1.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/cards/card_active_room.dart`
