<!--
Component page, D-033 ten-part template.

Tier     : Status and feedback
Sources  : lib/src/messaging/messaging_atoms.dart (DabblerTypingIndicator)
           lib/src/messaging/messaging_atoms_gallery.dart (entry typing-indicator)
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
           files components/messaging/TypingIndicator.jsx and TypingIndicator.prompt.md, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
           No browser or side-by-side comparison was made.
-->

# TypingIndicator
### `DabblerTypingIndicator`

TypingIndicator shows three animated dots, optionally with a name line, while someone is typing.

The dots are 4px pills in the text colour, pulsing over 1200ms with a 180ms stagger; the line is caption-1 in the secondary ink. It is the only animation in the messaging set.

## Specimen

One, two and three-plus names, no names, a label override and dots only. See `messaging_atoms_gallery.dart`.

@specimen typing-indicator

## Using it

**Pass names, or a label.** One name reads "Mina is typing", two read "Mina and Omar are typing", three or more read "Mina and 2 others are typing". These English phrases are defaults; pass `label` to replace the phrase entirely, which Arabic requires.

**Dots only is decorative.** `dotsOnly` draws the dots alone and announces nothing; pair it with a text label elsewhere, as MessageThread and ConversationRow do. The text form is a polite live region.

**Reduced motion keeps the dots.** When the platform asks for reduced motion the animation stops and the three dots stay visible at full opacity.

## Axes

### Names
None, one, two, three or more.

### Form
With text, or dots only.

## Direction

The dots lead at the inline start and the text follows, so the order mirrors. Arabic text uses the Arabic caption-1 metrics (11.1 on 16). Every axis is logical, so the whole layout mirrors under right-to-left with no direction-specific parameter and no duplicate component.

## Tokens used

Ink: secondary ink for dots and text. Spacing: 3 between dots, 6 between dots and text. Type: caption-1. Motion: a 1200ms cycle, 180ms stagger, ease-in-out per keyframe.

## Source

`lib/src/messaging/messaging_atoms.dart`
