<!--
Component page, D-033 ten-part template.

Tier     : Status and feedback
Sources  : lib/src/messaging/messaging_parts.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/messaging_parts_gallery.dart
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/ConversationNotice.jsx and
           ConversationNotice.prompt.md, read via DesignSync get_file on
           2026-10-02 and transcribed to a local mirror by the coordinator. No
           browser or side-by-side comparison was made.
-->

# ConversationNotice
### `DabblerConversationNotice`

ConversationNotice is a high-priority update shown inline in a conversation's timeline.

It is a thin wrapper over the Banner, not a new visual language: it adds the timeline gutters and an optional centred timestamp. Messaging introduces no colour of its own, and `critical` is an alias of `error`.

## Specimen

Info with a timestamp, success, warning with an action, error with a dismiss, and critical.

@specimen conversation-notice

## Using it

**Use it for what changes the plan.** Venue changed, game cancelled, kickoff moved, action or payment required.

**Tone is the banner's tone.** `info`, `success`, `warning`, `error`; `critical` renders exactly as `error`.

**Action and dismiss are the banner's.** `actionLabel` with `onAction` adds the banner's action button; `onDismiss` adds its dismiss target. `timestamp` adds a centred caption beneath.

## Axes

### Tone
`info`, `success`, `warning`, `error`, `critical` (alias of error).

## Direction

The 6px gutters are logical and the banner mirrors as it does everywhere; the timestamp stays centred.

## Tokens used

The status tones through the banner, secondary ink for the timestamp, spacing 3 and 6, caption-1.

## Change log

- Covered against the hand-transcribed mirror of the live source (no byte or pixel check): the banner now stretches to the thread width with only the timestamp centred, as the source's column does.

## Source

`lib/src/messaging/messaging_parts.dart`
