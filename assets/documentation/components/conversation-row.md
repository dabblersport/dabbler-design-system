<!--
Component page, D-033 ten-part template.

Tier     : Identity and status
Sources  : lib/src/messaging/conversation_row.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/conversation_row_gallery.dart (specimen title:
           "ConversationRow — one conversation in the inbox")
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/ConversationRow.jsx and
           ConversationRow.prompt.md, tokens/{colors,spacing,typography}.css,
           read via DesignSync get_file on 2026-10-02 and transcribed to a
           local mirror by the coordinator. No browser or side-by-side
           comparison was made.
-->

# ConversationRow
### `DabblerConversationRow`

ConversationRow is one conversation in the inbox, shown as a single navigational row.

It combines the conversation's identity, its latest activity, a timestamp and the unread or status information. Player, squad, huddle and game conversations are the same component: the kind changes only the small tile on the avatar.

## Specimen

Player, squad, huddle and game rows, read and unread, muted, typing, a capped count, a status badge, and an Arabic row in right-to-left — see `conversation_row_gallery.dart`.

@specimen conversation-row

## Using it

**Give it what the inbox already knows.** Title and timestamp are required and already formatted; the preview is the latest message, and a sender adds a bold prefix for group conversations. The avatar is seeded from the seed, or the title when there is none.

**Unread is a count, not a flag.** Above zero the title goes bold, the timestamp takes the brand colour and a count badge appears; above the cap, ninety-nine by default, the badge reads 99+.

**Muted changes two things.** A small volume-slash glyph sits before the timestamp, and the count badge takes the quiet neutral tone. The glyph is decoration, so say that a conversation is muted somewhere a screen reader can reach.

**Typing replaces the preview** with the shared typing indicator, built from the sender's name or your own label.

**A third line is optional.** A status badge, with a semantic tone and an optional glyph, and a short kind label appear only when you pass them.

**Tappable only when you give it a handler.** With a tap handler the row is one focusable button whose accessible name is composed from its content; pressing tints it with the sunken surface. Without one it is plain content.

## Axes

### Kind
Player, squad, huddle, game (the game tile shows the sport).

### State
Read or unread, muted, typing, online (player only), with or without the status line, with or without the divider.

## Direction

Every inset is logical: the avatar leads and the timestamp trails on either side, the count badge sits at the inline end, and the title, preview, timestamp and kind label switch to the Arabic metrics.

## Tokens used

Fills and ink: primary ink for the title, secondary ink for preview, read timestamp, mute glyph and kind label, brand for an unread timestamp, sunken surface when pressed, the faint fill as the hairline. Spacing: 3, 6, 12 and 18. Size: the 45px touch minimum and a 48px avatar. Type: subheadline at 600 or 700, footnote, caption-1 and caption-2. Motion: the 80ms fast duration on the press tint.

## Change log

- Added from the live design project (`ConversationRow.jsx`). Deliberate deviations are listed in the class documentation: the preview is plain text, the unread badge now takes the live 6px inline padding and 24px minimum width, and the read and unread preview inks share the secondary text role under D-003(a).

## Source

`lib/src/messaging/conversation_row.dart`
