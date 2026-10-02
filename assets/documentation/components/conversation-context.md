<!--
Component page, D-033 ten-part template.

Tier     : Content containers
Sources  : lib/src/messaging/conversation_context.dart (class dartdoc, incl.
           the source-to-Dart mapping table)
           lib/src/messaging/conversation_context_gallery.dart (specimen
           title: "ConversationContext — the activity header of a game chat")
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1
           (Dabbler Design System), files
           components/messaging/ConversationContext.jsx,
           ConversationContext.prompt.md and messaging.jsx (GAME_STATUS),
           tokens/{colors,spacing,typography}.css, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the
           coordinator. No browser or side-by-side comparison was made.
-->

# ConversationContext
### `DabblerConversationContext`

ConversationContext is the compact, state-aware activity header pinned above a game conversation.

Collapsed, it is one row: a sport tile, the title over a when-and-venue caption, a status badge and a chevron. Expanded, it adds location, participants, organiser and actions, and nothing more; it is not a copy of the game details screen. It holds no data of its own: every value is passed in and the toggle is a callback.

## Specimen

Collapsed, a live toggle, expanded with every row, cancelled, completed and an Arabic header — see `conversation_context_gallery.dart`.

@specimen conversation-context

## Using it

**Collapse is controlled.** Pass `collapsed` and flip it in `onToggle`. The whole header row is one button that reports its expanded state to assistive technology.

**Rows appear when you give them content.** `mapLabel` shows the location row, with a button when `mapActionLabel` is set; `participants` shows the avatar row, with `spots` beneath; `organizer` shows the crown row, after `organizerLabel`; `actions` shows small buttons, the first primary and the rest outlined unless an action sets its own tone.

**Status drives the treatment, not the surface.** The badge follows the activity status and `statusLabel` overrides its words. A cancelled activity strikes its title and turns the tile to the error colour; a completed one only mutes the tile.

## Axes

### Status
Open, full, confirmed, starting soon, in progress, completed and cancelled.

### Collapse
Collapsed shows the header only; expanded adds the divider and whichever rows have content.

## Direction

Every inset is logical, so the whole header mirrors: the tile leads and the chevron trails at the inline end. Arabic text uses the Arabic footnote and caption sizes, 0.9px smaller than Latin.

## Tokens used

Fills and ink: card and sunken surfaces, the card outline, the faint hairline, brand, primary and secondary ink, the error status colour. Corner: the 12px large radius on the card and the 9px medium radius on the map row. Spacing: 6, 9 and 12. Targets: the 45px touch minimum on the header. Type: footnote at weights 700 and 600, caption-1. Motion: the 120ms base duration and the ease-out curve on the chevron, dropped under reduced motion.

## Change log

- Added from the live design project (`ConversationContext.jsx`). The map button takes an `onMapAction` handler, which the source does not wire. Muted ink follows the text roles ruled in D-003(a).

## Source

`lib/src/messaging/conversation_context.dart`
