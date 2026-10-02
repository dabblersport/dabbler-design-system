<!--
Component page, D-033 ten-part template.

Tier     : Selection and input
Sources  : lib/src/messaging/messaging_parts.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/messaging_parts_gallery.dart
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files components/messaging/ReactionPicker.jsx
           and ReactionPicker.prompt.md, read via DesignSync get_file on
           2026-10-02 and transcribed to a local mirror by the coordinator. No
           browser or side-by-side comparison was made.
-->

# ReactionPicker
### `DabblerReactionPicker`

ReactionPicker is the pill of six reactions a person chooses from.

It is shown on long-press or above a message's action sheet: a card pill with a hairline holding six 45px round targets, where a reaction already applied is filled in brand.

## Specimen

Nothing chosen, then two reactions already applied.

@specimen reaction-picker

## Using it

**Choosing calls back with a key.** `onPick` receives the chosen reaction's key; the picker holds no state.

**Show what is already applied.** Pass those keys as `active`; each one fills in brand with a bold on-brand glyph and reports itself selected.

**The group is named.** `groupLabel` (English default "React") names the group, and each target carries the reaction's own name.

## Axes

### Target state
Idle or active.

## Direction

The six targets run from the inline start, so the order mirrors in Arabic.

## Tokens used

Card surface, card outline, brand, on-brand, secondary ink. Spacing 3 and 6, the pill radius, the 45px touch minimum.

## Change log

- Covered against the live source: the idle glyph follows the secondary text role instead of a light-only palette value, and an idle target paints no fill.

## Source

`lib/src/messaging/messaging_parts.dart`
