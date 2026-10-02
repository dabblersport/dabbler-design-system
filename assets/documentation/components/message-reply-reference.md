<!--
Component page, D-033 ten-part template.

Tier     : Content containers
Sources  : lib/src/messaging/messaging_parts.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/messaging_parts_gallery.dart
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/MessageReplyReference.jsx and
           MessageReplyReference.prompt.md, read via DesignSync get_file on
           2026-10-02 and transcribed to a local mirror by the coordinator. No
           browser or side-by-side comparison was made.
-->

# MessageReplyReference
### `DabblerMessageReplyReference`

MessageReplyReference is the quoted message shown above a reply.

It appears in two places, inside a message bubble and in the composer's reply preview, so it is one shared part rather than private markup in either. It is always secondary: a small sender line and a two-line quote behind a 2px leading rule.

## Specimen

In an incoming bubble, in an outgoing bubble, above the composer with cancel, and quoting an attachment.

@specimen message-reply-reference

## Using it

**Pick the variant for where it sits.** `message` inside an incoming bubble rules in brand; `onBrand` inside an outgoing bubble rules and writes in the on-brand colour; `composer` adds the sunken fill at the 9px radius.

**Quote text or an attachment.** Pass `content` for a text message, or `attachmentLabel` for a photo or file, which leads with the gallery glyph. The quote clamps to two lines.

**Cancel is a real button.** Give `onCancel` and a 45px cancel target appears at the inline end, named by `cancelLabel` (English default "Cancel reply").

## Axes

### Variant
`message`, `onBrand`, `composer`.

### Body
Quoted text, or an attachment label.

## Direction

The rule, the start padding and the cancel target are all logical, so in Arabic the rule sits on the right and cancel on the left. Caption type switches to the Arabic metrics.

## Tokens used

Brand, on-brand, sunken surface, secondary ink for the quote and tertiary ink for the cancel glyph. Spacing 3 and 9; the 9px medium radius; the 45px touch minimum; caption-1, and caption-2 at weight 700.

## Change log

- Covered against the hand-transcribed mirror of the live source (no byte or pixel check): the 9px gap before cancel and the 6px pull of cancel into the end padding were added; the sender line no longer truncates; the cancel glyph takes the tertiary role, which is the light value of the source's muted. The source's negative block margin on cancel is not ported, so with cancel the composer variant is taller than the source.

## Source

`lib/src/messaging/messaging_parts.dart`
