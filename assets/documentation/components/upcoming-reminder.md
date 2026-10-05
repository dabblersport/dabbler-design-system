<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/upcoming_reminder.dart (class dartdoc, incl. the
           design-to-Dart table and deviations)
           lib/src/feed/feed_gallery.dart (specimen title:
           "UpcomingReminder — the next games on the Home Feed")
           Claude Design file "Home Feed.dc.html", the reminder strip, card,
           stack and list (lines 94-262).
-->

# UpcomingReminder
### `DabblerUpcomingReminder`

UpcomingReminder is the Home Feed's block for the games you are going to: the next one as a card with a date tile and a countdown ring, the others folded under it as a stack, or opened as a short list, or the whole block folded to a one-line strip.

The caller owns the state and every label. The block holds no state of its own, so a screen decides whether it is open, folded or dismissed.

## Specimen

One game, three games stacked, the opened list, the strip and an Arabic block in right-to-left — see `feed_gallery.dart`.

@specimen upcoming-reminder

## Using it

**Pass the games soonest first.** An empty list draws nothing. One game is a card; two or more fold the rest under it.

**Give the ring a fraction and two words.** The ring shows how much of the countdown window has elapsed, with a big figure over its unit in the centre (`2` over `hours`).

**Own the state in the screen.** `collapsed` shows the strip and `expanded` opens the list; `onDismiss`, `onExpandStrip` and `onToggleExpanded` flip them.

**Where it departs from the design.**

- The strip's text is one ellipsised line, where the design scrolls it.
- A swipe on the card does not dismiss it; the close button does.
- The 5px and 9px gaps take the nearest steps of the 3px ramp.

## Axes

### State
One game or several; stacked or opened; open or folded to the strip; with or without the See all footer (more than three games).

## Direction

The date tile leads and the ring trails; both mirror under right-to-left, the ring itself keeps its clockwise fill, and type resolves to the Arabic metrics. Figures are drawn with Western digits.

## Tokens used

Surfaces: card for the game and the peeking sheets, sunken for the second sheet and the list date tiles, brand tint for the date tile, grey for the strip. Ink: primary, secondary, and brand for the month, day, See all and the short countdown. Radius: 6, 9 and 12. Size: the 45px touch minimum, a 56px ring and 18px close glyph. Type: title-3, headline, subheadline, footnote, caption-1 and caption-2.

## Change log

- KAN-433 (Home fidelity) — adds `metrics` (`DabblerFeedMetrics.touch` default, `.drawn`). Drawn lays the block out as the frame measures it: a 25 high title row whose hide button is a 34 box bleeding 8 past the end edge in English and sitting flush in Arabic (the frame's margin is physical), the front card 82 high (56 of content, 12 of padding, the hairline outside), two 42 high sheets peeking out 7 and 14 inset, a 32 toggle 3 under the stack, and the folded strip 30 high with a brand dot, a divider, the ticker line and a chevron inside the frame's physical `0 6 0 9` padding. Touch is unchanged.
- Added from the Home Feed design file.

## Source

`lib/src/feed/upcoming_reminder.dart`
- KAN-433 (Home fidelity, opened list) — `drawn` also lays the opened list out as the frame measures it (`Home Feed.dc.html:196-216`): each row is **61** (a 1px rule that stays transparent on the first row, 8 / 12 padding, a 44 content floor), a **34 x 39** date tile (42 in Arabic, whose day figure has 23 leading), a 10 gap before the title column and again before the brand countdown, the list's hairline takes its own 1px each side (124 for two rows), the `See all` footer is 36 and `Show less` sits 6 under the list. Named tokens `DabblerHomeFrame.upcomingTileWidth`, `upcomingRowGap`, `upcomingRowPadV`, `upcomingRowMinContent`. Touch is unchanged.
- KAN-433 (strip fill) — the drawn folded strip fills with the faint step (`--faint`, `DabblerColors.bgTertiary`, `Home Feed.dc.html:82`), not the grey inset panel; light and dark follow the role. Touch is unchanged.
