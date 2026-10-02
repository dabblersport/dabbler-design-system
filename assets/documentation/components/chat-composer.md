<!--
Component page, D-033 ten-part template.

Tier     : Selection and input
Sources  : lib/src/messaging/chat_composer.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/chat_composer_gallery.dart (specimen title:
           "ChatComposer — the message input")
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files components/messaging/ChatComposer.jsx
           and ChatComposer.prompt.md, tokens/{colors,spacing,typography}.css,
           read via DesignSync get_file on 2026-10-02 and transcribed verbatim
           to a local mirror by the coordinator. No browser or side-by-side
           comparison was made.
-->

# ChatComposer
### `DabblerChatComposer`

ChatComposer is the persistent input surface for composing and sending a message inside a conversation.

It is a single-line field with an optional attach and emoji target and a round send target, over an optional reply reference or row of quick replies, or replaced by a notice when the conversation cannot be posted to. It holds no backend, audio or realtime state: the draft is passed in and every action is a callback.

## Specimen

A live composer, then empty, ready, sending, disabled, reply, quick-reply and notice — see `chat_composer_gallery.dart`.

@specimen chat-composer

## Using it

**Feed the draft back.** `value` is controlled: pass what `onChange` reports back in as `value`. Send is live only when the trimmed value is not empty and the composer is not off; Enter sends under the same rule.

**Targets appear when you give them a handler.** `onAttach` shows the attach target and `onEmoji` the emoji target; send is always present. Each is a 45px button with the accessible name you pass as `attachLabel`, `emojiLabel` or `sendLabel`.

**One of three things sits above the field.** A `notice` replaces the input entirely; otherwise a `replyTo` shows the quoted message, and only when there is no reply do `quickReplies` show. Choosing a quick reply calls `onQuickReply` and does not touch the draft.

**Off means inert.** `state: sending`, `state: disabled` and `disabled: true` all sink the field and silence every target; `sending` also swaps the send glyph for a spinner.

## Axes

### State
`normal` (the source's `default`), `sending`, `disabled`.

### Above the field
Nothing, a reply reference, quick replies, or a notice that replaces the input.

## Direction

Every inset is logical, so the whole composer mirrors: attach leads and send trails, the emoji target keeps its 6px gap to the field's inline end, and the quick-reply rail starts at the inline start. The input switches to the Arabic subheadline metrics (14.1 on 23).

## Tokens used

Fills and ink: page, card and sunken surfaces, the card outline, the faint hairline, brand and on-brand, primary and secondary ink, tertiary ink for disabled glyphs. Corner: the 9px medium radius on the notice, the 24px field radius, the pill radius on targets. Spacing: 3, 6, 9, 12 and 15. Targets: the 45px touch minimum. Type: subheadline for the field, footnote at weight 500 for quick replies, caption-1 for the notice. Motion: the 80ms fast duration on the send fill.

## Change log

- Added from the live design project, design system 1.2.0 (`ChatComposer.jsx`). Deliberate deviations are listed in the class documentation: disabled glyphs and placeholder follow the text roles ruled in D-003(a) and D-025.

## Source

`lib/src/messaging/chat_composer.dart`
