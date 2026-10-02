<!--
Component page. Sources: lib/src/messaging/message_thread.dart (class
dartdoc, incl. the source-to-Dart mapping table),
lib/src/messaging/message_thread_gallery.dart, and the live Claude Design
project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), files
components/messaging/MessageThread.jsx and MessageThread.prompt.md, read via
DesignSync get_file on 2026-10-02 and transcribed to a local mirror by the
coordinator. No browser or side-by-side comparison was made.
-->

# MessageThread
### `DabblerMessageThread`

MessageThread is the conversation timeline that owns message grouping, vertical rhythm and scroll anchoring.

You pass one flat, ordered list of rows — messages, day separators, the unread divider, system activity, notices and a typing row — and the thread derives every message's group position, spaces the rows and decides where the scroll rests.

## Specimen

A group thread with every row kind, a selected message, a reply, reactions, a bare image and a failed message with retry, and a direct thread with a shared game and full delivery — see `message_thread_gallery.dart`.

@specimen message-thread

## Using it

**One flat list.** A run of consecutive messages with the same direction and sender is a group; any other row breaks it. Never set a group position yourself.

**Rhythm is fixed.** Rows sit 12 apart, messages inside one group 3 apart, inside 12px timeline gutters.

**Anchor deliberately.** `bottom` rests on the newest row; `unread` rests 72px above the unread divider. The anchor is applied again whenever the anchor or the row count changes.

**Pin context with the header.** The game context strip goes in `header`; it scrolls with the rows.

**Selection and callbacks.** `selectedId` outlines the matching message; `onMessagePress` and `onReact` receive the row itself.

## Direction

The typing row's 34px inset, the gutters and every bubble are logical, so the whole timeline mirrors in Arabic with no prop.

## Tokens used

Spacing: 3 inside a group, 12 between groups and for the gutters, the 28px avatar gutter plus 6 for the typing inset. The typing bubble uses the card surface, the card outline, the 18 and 6 corners and caption-2 in secondary ink. No scrollbar is drawn.

## Change log

- Corrected against the live source: the unread anchor now rests 72px above the divider (it used a 10% viewport alignment); the scrollbar is hidden; message rows forward the edited label, retry, retry label and the sender and avatar overrides, as the source forwards every item field.

## Source

`lib/src/messaging/message_thread.dart`
