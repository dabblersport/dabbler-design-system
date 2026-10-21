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

The six delivery states with the word spelled, the group receipt count in each tier, and the Message info drawer body — see `message_receipts_gallery.dart`.

@specimen message-delivery
@specimen message-group-receipt
@specimen receipts-sheet

## Using it

**Let the thread set the position.** Inside `DabblerMessageThread` the group position is derived for you. Set `groupPosition` by hand only for a message shown alone.

**Identity leads, metadata trails.** In group context an incoming leading message shows the 28px avatar and the sender name; only a trailing message shows the timestamp, the edited label and delivery. `showSender` and `showAvatar` override the rule.

**Delivery has six states.** Sending and retrying show the clock and dim the bubble; sent is the linear tick; delivered is the same tick one step darker; seen is the eye in the brand colour; failed is the bold danger glyph. The glyphs differ by shape as well as tone, so meaning is never colour alone. Sent means the server accepted the message, delivered means at least one recipient device received it, seen means at least one recipient viewed it.

**Direct shows a glyph; group shows one count.** Delivery shows on outgoing messages only. In a direct conversation every state shows as a glyph, and `showDeliveryLabel` spells the word on the newest outgoing message. In a group, sending, retrying and failed behave the same; once the server has the message the glyph gives way to one compact count from `receipt` — "Seen by 4 of 9", "Delivered to 7 of 9", "Seen by everyone" or "Sent". The count is a 45px button when `onReceipts` is set, and it opens the Message info drawer. Others' messages never show a count.

**Failure offers a retry.** A failed message spells "Not sent", turns its metadata to the strong error ink, and an `onRetry` handler adds a bold Retry target with a 45px minimum height.

**A new message fades in.** `fresh` fades the row in over the slow motion token; sending and retrying dim over the base token. Under reduced motion both hold still.

**Words come from `lang` or a prop.** `lang` (`en` or `ar`) selects the delivery and receipt words; `editedLabel`, `retryLabel` and `deliveryLabel` override them for any other language.

**Message info is its own body.** `DabblerReceiptsSheet` is the body of the Message info drawer: the message, three summary tiles (seen, delivered, not yet) and a list per state with the people and the time each was reached. `DabblerReceiptsSheet.show` presents it as a content-height sheet; build the widget directly to embed it. It takes data in and reports nothing out except the sheet's own close. A summary tile reads "All" instead of its count when every recipient is in the seen or delivered state, and the not-yet tile reads "Nobody" instead of 0; both words are props (`allLabel`, `nobodyLabel`) with English and Arabic defaults, and each tile announces caption and value together.

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

- Receipts stat tiles read "All" and "Nobody" in place of a full-group count and a zero (KAN-614): new optional `allLabel` and `nobodyLabel` on `DabblerReceiptsSheet`; each tile has one merged Semantics label.
- Delivery states follow messaging section 11 (KAN-580): `read` is now `seen` and draws the brand eye; delivered is the linear tick; `retrying` is new; a group message shows one receipt count in place of the glyph; a failed message spells "Not sent"; `fresh` fades a new row in. `DabblerDeliveryState.read` stays as a deprecated alias.
- Corrected against the hand-transcribed mirror of the live source (no byte or pixel check): the bubble width cap is 76% of the whole row (it was computed after removing the avatar gutter); the sender name and the reaction row now sit 3px from the bubble; the selected outline no longer adds 4px of layout around the bubble; Retry sits 3px after the glyph instead of 9px; the reply reference spans the bubble's width; the sending fade animates. Retry keeps its 45px height by growing the metadata line, because Flutter has no negative margin.

## Source

`lib/src/messaging/message.dart`
