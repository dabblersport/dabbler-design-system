<!--
Component page, D-033 ten-part template.

Tier     : Status and feedback
Sources  : lib/src/messaging/messaging_atoms.dart (DabblerSystemMessage)
           lib/src/messaging/messaging_atoms_gallery.dart (entry system-message)
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
           files components/messaging/SystemMessage.jsx and SystemMessage.prompt.md, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
           No browser or side-by-side comparison was made.
-->

# SystemMessage
### `DabblerSystemMessage`

SystemMessage displays lightweight product-generated conversation activity that does not originate from a participant.

It is never a bubble: centred caption-1 text with no surface and no avatar, an optional 14px glyph and an optional timestamp. Use it for a player joining or leaving, a game becoming full, an invitation or a confirmed booking, anything the product says rather than a person.

## Specimen

Neutral, neutral with glyph and timestamp, and positive with glyph and timestamp. See `messaging_atoms_gallery.dart`.

@specimen system-message

## Using it

**Say it as the product.** Use it for activity, not for changes that need an action: a venue change, a cancellation or a payment due belong in ConversationNotice.

**The timestamp stays muted.** In the positive tone the text and glyph turn success-strong, but the appended ` · time` keeps the secondary ink.

**It is announced.** The line is a status region, so assistive technology reads new activity politely; the glyph is decoration and is hidden.

## Axes

### Tone
`neutral` (default) and `positive`. `positive: true` is kept as a shorthand for the positive tone.

### Content
Text alone, or with a glyph, a timestamp, or both.

## Direction

The glyph sits at the inline start and the text stays centred; the 18px inline padding is logical. Arabic text uses the Arabic caption-1 metrics (11.1 on 16). Every axis is logical, so the whole layout mirrors under right-to-left with no direction-specific parameter and no duplicate component.

## Tokens used

Ink: secondary ink for neutral text and the timestamp, tertiary ink for the neutral glyph (the source's `--subtle`, D-003(a)), success-strong for the positive tone. Spacing: 3 block, 18 inline, 6 between glyph and text. Type: caption-1.

## Source

`lib/src/messaging/messaging_atoms.dart`
