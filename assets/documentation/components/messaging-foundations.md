<!--
Component page. Sources: lib/src/messaging/messaging_foundations.dart,
lib/src/messaging/message_thread_gallery.dart, and the live Claude Design
project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), file
components/messaging/messaging.jsx, read via DesignSync get_file on
2026-10-02 and transcribed to a local mirror by the coordinator. No browser
or side-by-side comparison was made.
-->

# Messaging foundations
### `DabblerMessagingSpacing`

Messaging foundations are the conversation rhythm and the four semantic maps that every messaging component reads.

They are not a component: they hold the thirteen spacing values chat uses, the conversation kind glyphs, the activity statuses, the delivery states and the reaction set, plus the shared press behaviour, so that no screen chooses its own.

## Specimen

The thirteen rhythm values drawn to scale, the kind glyphs, the status map, the delivery glyphs in their tones and the six reactions — see `message_thread_gallery.dart`.

@specimen messaging-foundations

## Using it

**Rhythm.** Timeline gutters, top and bottom, and the gap between groups are 12; inside a group, sender to content, content to metadata and the system message padding are 3; avatar to bubble and reply to content are 6; the avatar gutter is 28; the reaction gap is 0 because the reaction row's own target spaces it; the bubble pads 9 by 12.

**Kind glyphs.** A squad shows the people glyph and a huddle the global glyph; a player shows none and a game defers to its sport icon.

**Activity status.** Open, full and completed are labels and take the neutral tint; confirmed and in progress are success, starting soon is warning and cancelled is error.

**Delivery.** Sending is a linear clock and sent a linear tick, both in tertiary ink; delivered is a bold tick in secondary ink; read is a bold tick in brand; failed is a bold danger glyph in the strong error ink.

**Reactions.** I'm in, running late, can't make it, nice, love it and standout, as Iconsax glyphs and never emoji.

**Press.** `DabblerMessagingTap` gives every messaging control the 0.98 press scale, the shared focus ring and Enter or Space activation.

## Tokens used

Spacing steps 3, 6, 9 and 12. Ink roles: tertiary, secondary, brand and the strong error ink. Motion: the shared press scale.

## Change log

- Delivery tones corrected: delivered used a light-only palette literal and now uses the secondary ink role, which is the same value in light and follows dark mode; sending and sent move to tertiary ink so the source's distinction between muted and soft ink survives.

## Source

`lib/src/messaging/messaging_foundations.dart`
