<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/post_row.dart (class dartdoc, incl. the design-to-Dart
           table and deviations)
           lib/src/feed/feed_atoms.dart (shared FeedAction and FeedTappable)
           lib/src/feed/feed_gallery.dart (specimen title:
           "PostRow — one post in the feed")
           Claude Design file "Home Feed.dc.html", fetched through DesignSync
           on 2026-10-03 and truncated at the tool's 256 KiB cap: the markup is
           complete, the script data (role label, active colours, body runs)
           is not. The row is lines 285-338 of that file.
-->

# PostRow
### `DabblerPostRow`

PostRow is one post in the Home Feed list: the author's avatar, a name line, when and where it was posted, the body, a sport pill and the like, vibe, reply, share and more actions.

Every string and count is data you pass in; every interaction is a callback. The row draws nothing from the network and holds no state.

## Specimen

A default post with a hashtag run, a liked and vibed post without a divider, and an Arabic post in right-to-left — see `feed_gallery.dart`.

@specimen post-row

## Using it

**Give it the post's facts, already formatted.** Name, time, place and distance are strings; likes and replies are integers, drawn with Western digits in either direction.

**Body is plain text or runs.** Pass `segments` to mark hashtags and mentions as links; they take the brand colour. The run itself is not tappable — navigate from the row's tap.

**Liked and vibed are states you own.** Liked draws a bold heart in the error colour; vibed draws a bold brand-coloured glyph. Toggle them from your callbacks.

**Every action is its own button, at least 45px square.** The row's own tap opens the post. Labels for screen readers default to English; pass your own in other languages.

**The sport pill takes a glyph slot, not an emoji.** The design shows an emoji beside the sport name; the system is icons only, so the slot is a widget and is empty by default.

**Where it departs from the design.**

- The distance pill is the shared Badge: 4px block padding, bold, with a hairline, where the design is 2/8, regular and border-less.
- The action row is 45px high instead of 20, to reach the touch minimum; the design's 6px top margin and 15px bottom padding are reduced to compensate.
- The avatar and the sport pill link to other screens in the design; neither reaches 45px without changing the layout, so they are not exposed.
- The liked and vibed inks are inferred, because the script that computes them was cut off in the fetched file.
- 5px gaps take the 6px step, and 8px and 11px paddings take 9 and 12.

## Axes

### State
Liked or not, vibed or not, with or without the divider, with or without the sport pill, role and distance.

## Direction

Every inset is logical. The avatar leads, the more action trails, and text resolves to the Arabic metrics.

## Tokens used

Ink: primary for the name, secondary for role, time, place, body and counts, tertiary for the meta glyphs and the dot, brand for link runs and a vibed glyph, error for a liked heart. Fill and line: the faint fill as the hairline, the default border on the sport pill, the info status on the distance pill. Spacing: 3, 6, 9, 12, 15 and 18. Size: the 45px touch minimum, a 36px avatar, 13px and 20px glyphs. Type: subheadline, caption-1 and caption-2.

## Change log

- Added from the Home Feed design file.

## Source

`lib/src/feed/post_row.dart`
