<!--
Component page, D-033 ten-part template.

Tier     : Status and feedback
Sources  : lib/src/messaging/messaging_parts.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/messaging_parts_gallery.dart
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files components/messaging/ReactionGroup.jsx
           and ReactionGroup.prompt.md, read via DesignSync get_file on
           2026-10-02 and transcribed to a local mirror by the coordinator. No
           browser or side-by-side comparison was made.
-->

# ReactionGroup
### `DabblerReactionGroup`

ReactionGroup is the row of reaction tallies under a message.

Each tally is a 24px pill with a coordination glyph and a count, sitting inside a full 45px button so the touch target clears the platform floors without the pill growing. The viewer's own reactions are brand-tinted.

## Specimen

Mine and not mine, single and double-digit counts, an add button, and add on its own.

@specimen reaction-group

## Using it

**Pass tallies, get keys back.** `reactions` is a list of key, count and mine; pressing a pill calls `onToggle` with its key. The keys are the six coordination reactions: in, late, out, like, heart, star.

**Every tally says what it means.** The accessible name is the reaction's label and the count, such as "I'm in · 3", and a mine pill reports itself selected, so the meaning never depends on the glyph.

**Add is optional.** `onAdd` shows a round add target named by `addLabel`. With no tallies and no add, nothing renders.

## Axes

### Ownership
Mine (a light brand tint over the card, brand outline and ink, bold glyph) or not mine (card, outline, secondary ink).

## Direction

The row wraps from the inline start, so in Arabic the first tally sits on the right. The count's caption type switches to the Arabic metrics.

## Tokens used

Card surface, card outline, brand, secondary ink, tertiary ink for the add glyph. The 24px icon size as the pill height, spacing 3 and 6, the pill radius and the 45px touch minimum.

## Change log

- Covered against the hand-transcribed mirror of the live source (no byte or pixel check): tallies now wrap with a 3px run gap, and the idle ink follows the secondary text role instead of a light-only palette value, so it follows dark mode.

## Source

`lib/src/messaging/messaging_parts.dart`
