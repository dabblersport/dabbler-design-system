<!--
Component page, D-033 ten-part template.

Tier     : Navigation
Sources  : lib/src/messaging/conversation_header.dart (class dartdoc, incl. the
           source-to-Dart mapping table)
           lib/src/messaging/conversation_header_gallery.dart (specimen title:
           "ConversationHeader — the top bar of a conversation")
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/ConversationHeader.jsx and
           ConversationHeader.prompt.md, tokens/{colors,spacing,typography}.css,
           read via DesignSync get_file on 2026-10-02 and transcribed to a local
           mirror by the coordinator. No browser or side-by-side comparison was
           made.
-->

# ConversationHeader
### `DabblerConversationHeader`

ConversationHeader is the top bar of a conversation: back, a tappable identity, and overflow.

It is a 52px row on the page surface with a faint bottom hairline, holding a back target, an identity block of avatar, title and subtitle that opens the conversation's details, and an overflow target. It holds no presence or typing state: the title, subtitle, typing names and every handler are passed in.

## Specimen

Default, online with a success subtitle, typing, an error subtitle on a game, and a long title — see `conversation_header_gallery.dart`.

@specimen conversation-header

## Using it

**Three targets, three names.** Back and overflow are 45px pill targets named by `backLabel` and `overflowLabel` (English defaults Back and More); the identity block is one target named by the title and the subtitle, and calls `onTitlePress`. A target without a handler stays visible and inert.

**Typing replaces the subtitle.** Pass `typing` with the names of who is typing and the subtitle line becomes the typing indicator; clear it to bring the subtitle back.

**Tone the subtitle only for state.** `subtitleTone` is muted by default; success and error use the strong status ink, for "Online" or "Game cancelled", not for decoration.

**The title never wraps.** Title and subtitle are single lines that end in an ellipsis; the avatar's seed falls back to the title.

## Axes

### Subtitle tone
`muted` (default), `success`, `error`.

### Second line
A subtitle, the typing indicator, or nothing.

## Direction

Every inset is logical, so back sits at the inline start and overflow at the inline end, and the identity text is start-aligned. The back glyph is the same arrow-circle-left in both directions, exactly as the source passes it; it is not mirrored. The title and subtitle switch to the Arabic subheadline and caption-2 metrics.

## Tokens used

Fills and ink: the page surface, the faint hairline, primary ink for title and glyphs, secondary ink for the muted subtitle, success and error strong ink. Corner: the pill radius on targets. Spacing: 3 and 6 on the row, 3 and 9 inside the identity block. Targets: the 45px touch minimum. Type: subheadline at weight 600 for the title, caption-2 for the subtitle.

## Change log

- Added from the live design project (`ConversationHeader.jsx`). The muted subtitle follows the text role ruled in D-003(a). The back arrow is not mirrored under RTL, matching the source; whether it should be is an open question.

## Source

`lib/src/messaging/conversation_header.dart`, live `components/messaging/ConversationHeader.jsx`.
