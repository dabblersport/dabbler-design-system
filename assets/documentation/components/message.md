<!--
Component page. Sources: lib/src/messaging/message.dart (class dartdoc, incl.
the source-to-Dart mapping table), lib/src/messaging/message_thread_gallery.dart,
and the live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
(Dabbler Design System), files components/messaging/Message.jsx and
Message.prompt.md, read via DesignSync get_file on 2026-10-02 and transcribed
to a local mirror by the coordinator. No browser or side-by-side comparison
was made.
-->

# Message
### `DabblerMessage`

Message is the one bubble that displays participant-authored content inside a Dabbler conversation.

It covers incoming and outgoing, direct and group, text, reply, image and shared-object content, reactions, metadata and every delivery state with props alone; there is no separate incoming, outgoing, image or reply bubble. Geometry, grouping corners and rhythm are owned by the component, so no screen sets padding, colour or radius.

## Specimen

Each group position for incoming and outgoing bubbles, every delivery state, a reply with reactions and the edited label, a bare image, a shared game, and the selected and read-only states — see `message_thread_gallery.dart`.

@specimen message

## Using it

**Let the thread set the position.** Inside `DabblerMessageThread` the group position is derived for you. Set `groupPosition` by hand only for a message shown alone.

**Identity leads, metadata trails.** In group context an incoming leading message shows the 28px avatar and the sender name; only a trailing message shows the timestamp, the edited label and delivery. `showSender` and `showAvatar` override the rule.

**Delivery is reduced in groups.** Delivery shows on outgoing messages only. In direct conversations every state shows; in group conversations only sending and failed surface, because per-message receipts for a dozen people are noise.

**Failure offers a retry.** A failed message turns its metadata to the strong error ink, and an `onRetry` handler adds a bold Retry target with a 45px minimum height.

**Every string is a prop.** `editedLabel` and `retryLabel` default to English and are yours to localise.

## Axes

### Ownership
Incoming sits on the card surface with a hairline; outgoing fills with brand on on-brand ink and aligns to the inline end.

### Group position
Single, first, middle and last. Free corners take the extra-large radius; the sender's own block-end corner is always the small-radius tail; the own block-start corner tightens to the small radius wherever the run continues from above.

### State
Normal, selected (a brand outline drawn outside the bubble at the focus-ring offset, taking no layout space) and read-only (no press, no button role). Pressed takes the shared press scale while held. Sending fades the bubble.

## Direction

Every corner and inset is logical, so an Arabic conversation mirrors with no prop: an incoming bubble's tail sits at the bottom right and outgoing bubbles align left. Content switches to the Arabic subheadline metrics.

## Tokens used

The selected outline is 2px at a 2px offset; press scale 0.98; sending opacity 0.7. Surfaces: card fill with the card outline for incoming, brand and on-brand for outgoing. Ink: primary for content, secondary for sender and metadata, the strong error ink on failure. Corners: 18, 12 for an image, 6 for the tail. Spacing: 3, 6, 9 and 12, plus the 28px avatar gutter. Type: subheadline for content, caption-1 for sender and metadata. Motion: the 120ms base duration on the sending fade.

## Change log

- Corrected against the live source: the bubble width cap is 76% of the whole row (it was computed after removing the avatar gutter); the sender name and the reaction row now sit 3px from the bubble; the selected outline no longer adds 4px of layout around the bubble; Retry sits 3px after the glyph instead of 9px; the reply reference spans the bubble's width; the sending fade animates. Retry keeps its 45px height by growing the metadata line, because Flutter has no negative margin.

## Source

`lib/src/messaging/message.dart`
