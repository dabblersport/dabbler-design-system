<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/activity_row.dart (class dartdoc, incl. the
           design-to-Dart table and deviations)
           lib/src/feed/feed_atoms.dart (shared FeedTappable)
           lib/src/feed/feed_gallery.dart (specimen title:
           "ActivityRow — one entry in the Active tab")
           Claude Design file "Home Feed.dc.html", fetched through DesignSync
           on 2026-10-03 and truncated at the tool's 256 KiB cap: the markup is
           complete, the script data is not. The row is lines 341-401 of that
           file.
-->

# ActivityRow
### `DabblerActivityRow`

ActivityRow is one entry in the Home Feed's Active tab: who did what, where and when, with an optional action pill, a count, and a Live or sport badge at the end.

The leading widget is yours: a person's avatar, a group of avatars, or a `DabblerActivitySystemTile` for a venue or a notice. A `DabblerActivityGroupHeader` introduces each run of rows.

## Specimen

A group with a filled action and a Live badge, a system tile with an outlined action and a sport badge, a person with a count, and an Arabic row in right-to-left — see `feed_gallery.dart`.

@specimen activity-row

A `thumbnail` widget draws a 40px rounded cover at the end of the row.

@specimen activity-row/thumbnail

## Using it

**Pass the leading widget, not a kind.** A small avatar for a person, an avatar group for several people, a system tile for anything that is not a person.

**Actor and verb read as one sentence.** The actor is in primary ink and the verb in secondary; the subject follows on its own line.

**The meta line is optional piece by piece.** Place, time and distance each draw only when given, with their glyphs and dots; the line wraps.

**The action is filled or outlined.** Filled is the brand colour. The pill is 33px high inside a 45px button, so it stays where the design puts it and is easy to hit.

**Live and sport badges are separate.** Live draws a green badge with a dot; a sport label draws a neutral outlined badge.

**Where it departs from the design.**

- The card's fill and border are the design's own override of the system card; its two neutral values are not tokens, so the nearest roles, the grey surface and the default border, stand in.
- The action pill's colours are computed in the part of the script that was cut off; filled and outlined are read from the sample data, and the colours are inferred.
- The Live and sport badges are the shared Badge: 4px block padding and bold, where the design is 3px and regular, and the sport badge's ink is primary where the design uses the softer ink.
- 5px gaps take the 6px step.

## Axes

### Action
Filled, outlined, or none; with or without a count.

### Badge
Live, sport, both, or neither.

## Direction

The leading widget starts the row and the badges end it; the meta line reflows. Text resolves to the Arabic metrics and numbers are drawn with Western digits.

## Tokens used

Surface: the grey inset surface with the default border and the 24px corner. Ink: primary for the actor, secondary for the verb, subject, meta text and count, tertiary for the meta glyphs, brand and on-brand for a filled action, success for the Live badge and a live group label. Spacing: 3, 6, 9, 12 and 15. Size: the 45px touch minimum, a 33px pill, 13px glyphs and a 40px system tile. Type: subheadline, footnote and caption-1.

## Change log

- Alpha fidelity (Notifications) — `DabblerActivityGroupHeader.count` (the `3 items` caption between label and rule) and `dense` (`padding:9px 0 3px`); `Notifications.dc.html:109-112`.
- Added from the Home Feed design file.

## Source

`lib/src/feed/activity_row.dart`
