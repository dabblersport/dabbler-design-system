<!--
Component page, D-033 ten-part template.

Tier     : Identity and status
Sources  : lib/src/messaging/messaging_atoms.dart (DabblerConversationAvatar)
           lib/src/messaging/messaging_atoms_gallery.dart (entry conversation-avatar)
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
           files components/messaging/ConversationAvatar.jsx and ConversationAvatar.prompt.md, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
           No browser or side-by-side comparison was made.
-->

# ConversationAvatar
### `DabblerConversationAvatar`

ConversationAvatar is a conversation's identity: the avatar plus the badge that says what kind of conversation it is.

It is an interim composition rather than a new primitive: Avatar cannot yet carry an icon badge or a presence dot, so messaging composes them here until Avatar gains them (DSG-NEW-008). Kinds differ by glyph, never by a per-kind colour, so all four read apart in every section theme and in dark mode.

## Specimen

The four kinds and the online dot at 48, then the header size 36. See `messaging_atoms_gallery.dart`.

@specimen conversation-avatar

## Using it

**Pick the kind.** `player` shows no badge, `squad` the people glyph, `huddle` the global glyph and `game` the sport glyph (football when no sport is given).

**Size by place.** 48 in the inbox, 36 in a header. The badge tile is 40% of the size and its glyph 62% of the tile.

**Presence is for players.** `online` draws a success dot ringed in the page colour, and only for the player kind. Badge and dot are decoration: give the kind and presence as text too.

## Axes

### Kind
`player`, `squad`, `huddle`, `game`.

### Size
The inbox size and the header size, given in pixels as described under Using it; the avatar steps between its md, sm and xs sizes.

### Presence
Offline or online, player only.

## Direction

The badge and the dot sit at the inline-end bottom corner, so they move to the left in right-to-left; the badge overhangs that corner by 2px. Every axis is logical, so the whole layout mirrors under right-to-left with no direction-specific parameter and no duplicate component.

## Tokens used

Fills: the card surface and card outline for the badge, primary ink for its glyph, the success colour and page surface for the dot. Corner: the 6px small radius on the badge, the pill on the dot. Size: the 1px default border on the badge, a 2px ring on the dot.

## Source

`lib/src/messaging/messaging_atoms.dart`
