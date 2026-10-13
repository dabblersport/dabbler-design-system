<!--
Component page, D-033 ten-part template.

Tier     : Presentation
Sources  : lib/src/messaging/thread_skeleton.dart, connection_notice.dart,
           older_messages_pager.dart, composer_state_notice.dart,
           time_mark.dart (class dartdoc)
           lib/src/messaging/messaging_gaps_gallery.dart (specimen titles)
           KAN-508 (Messaging T13); KAN-496 report section 5 and CXO_496.md,
           which named these as design-system gaps for the game-chat screen.
           No browser or side-by-side comparison was made.
-->

# Messaging thread parts
### `DabblerThreadSkeleton` · `DabblerConnectionNotice` · `DabblerOlderMessagesPager` · `DabblerComposerStateNotice` · `DabblerTimeMark`

Five small parts a message thread needs around its messages: a placeholder while it loads, a strip when the connection drops, a control to load older messages, a strip in place of the composer when nobody can post, and a date and time tile.

None of them carries copy. Every label, line of text and countdown is passed in by the caller, and every inset, size and colour is a token.

## Specimen

ThreadSkeleton, a thread while it loads — see `messaging_gaps_gallery.dart`.

@specimen thread-skeleton

ConnectionNotice, offline and reconnecting.

@specimen connection-notice

OlderMessagesPager, idle, loading and error with retry.

@specimen older-messages-pager

ComposerStateNotice, closed and cannot send.

@specimen composer-state-notice

TimeMark, a tinted date and time tile.

@specimen time-mark

## Using it

**ThreadSkeleton** draws `rows` placeholder message rows from `DabblerSkeleton`: received rows lead with an avatar well, sent rows sit at the end edge. It is for the first page only; `semanticLabel` is the caller's own announcement.

**ConnectionNotice** is a warning strip. `visible: false` collapses it to nothing; `reconnecting` swaps the glyph for a spinner. It is a polite live region.

**OlderMessagesPager** takes a `state` of idle, loading or error. Idle is a button (`onLoad`), loading is a spinner with the caller's text, error shows the caller's text and a retry button (`onRetry`).

**ComposerStateNotice** replaces the composer when the conversation is closed (a lock on a sunken strip) or this person cannot send (a warning strip). It matches the notice `DabblerChatComposer` draws for its own `notice`, for screens that do not mount the composer.

**TimeMark** is a 36px tinted tile with a caller-formatted date and time label and an optional countdown line. It is new: the conversation context header's tile is a sport icon and is unchanged.

## Axes

### OlderMessagesPager state
`idle`, `loading`, `error`.

### ComposerStateNotice kind
`closed`, `cannotSend`.

### TimeMark tone
`brand` (default), `neutral`, `success`, `warning`, `error`.

## Direction

Every inset and alignment is logical, so rows, glyphs and text mirror in right to left. Text wraps rather than clipping, so each part grows at a 200 percent text scale.

## Tokens used

Fills and ink: the sunken surface, warning surface and strong ink, primary and secondary text, the brand and status colours for the tile tint. Spacing: the messaging gutters and the 6, 9 and 12 steps. Sizing: the 18px icon, the 36px tile, the hairline and default borders. Type: caption 1 and footnote.

## Change log

- Added for Messaging T13 (KAN-508). TimeMark is a new component, not an extraction.

## Source

`lib/src/messaging/thread_skeleton.dart`, `connection_notice.dart`, `older_messages_pager.dart`, `composer_state_notice.dart`, `time_mark.dart`
