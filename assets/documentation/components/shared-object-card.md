<!--
Component page, D-033 ten-part template.

Tier     : Content containers
Sources  : lib/src/messaging/messaging_shared_object_card.dart (class dartdoc,
           incl. the source-to-Dart mapping table)
           lib/src/messaging/messaging_parts_gallery.dart
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/SharedObjectCard.jsx and
           SharedObjectCard.prompt.md, read via DesignSync get_file on
           2026-10-02 and transcribed to a local mirror by the coordinator. No
           browser or side-by-side comparison was made.
-->

# SharedObjectCard
### `DabblerSharedObjectCard`

SharedObjectCard is a game, venue or player shared inside a conversation.

It is the one anatomy the three shared kinds have in common, sized to sit inside a 268px bubble, on a decorative pastel ground per kind with complementary pastel chips. The card itself is not a button; its call to action is.

## Specimen

A game with status, meta, footnote and call to action; a venue with its photo slot and chips; a player with chips.

@specimen shared-object-card

## Using it

**Pick the kind.** `game` leads with a 36px sport tile, the title and a status badge; `venue` leads with a 120px photo slot; `player` leads with a medium avatar.

**Supply the photo.** The venue photo is a widget you pass as `photo`; without one the slot shows `photoPlaceholder` (English default "Venue photo").

**Add what the kind needs.** `meta` lines take a bold brand glyph and text; `chips` show on venue and player; `footnote` shows on a game; `cta` with `onPress` adds a full-width small primary button.

## Axes

### Kind
`game` (info ground, accent chips), `venue` (info ground, card chips), `player` (accent ground, info chips).

## Direction

Every row starts at the inline start, so in Arabic the sport tile and avatar sit on the right and the badge on the left. Title, caption and footnote type switch to the Arabic metrics.

## Tokens used

The decorative info and accent tile surfaces, card surface, card outline, brand, primary and secondary ink. Spacing 6, 9 and 12, the 12px large radius, subheadline at weight 700, caption-1 and footnote.

## Change log

- Covered against the live source: chips now actually paint their pastel fill, footnotes show on games only and chips on venues and players only, only a game title truncates, the empty venue slot shows its placeholder, and meta text follows the secondary role instead of a light-only palette value. The prompt file says card surface; the source paints the pastel ground, and the source was followed. The tile surfaces have no dark value, so the ground stays pastel in dark mode, as in the source.

## Source

`lib/src/messaging/messaging_shared_object_card.dart`
