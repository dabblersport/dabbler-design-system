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

The optional slots: an author photo and an author tap, media under the body, the repost action, a
reaction summary under the actions, a kind badge at the end of the author line and the author-only
view count.

@specimen post-row/slots

The open-post detail line: the full timestamp, the edited marker and the visibility line, opted into with `detail`.

@specimen post-row/detail

The open post, `DabblerOpenPost`: the post a detail screen is about, laid out as in `Post.dc.html` lines 58-126 — the author header with a Follow pill, the body at reading size, a sport pill and a place pill, the time, date and views line with the audience at the end, and the like, vibe, reply and share row.

@specimen post-row/open

A game in the Link a game sheet, `DabblerGameLinkRow`: a date tile, the title with its sport glyph, the place and time, a status badge and a check when chosen.

@specimen post-row/game-link

A repost, `DabblerRepostRow`: the reposter's header and reposted line, an optional quote, and the original post embedded in a card, or a note when the original is unavailable.

@specimen post-row/repost

## Using it

**An open post is its own component.** Give `DabblerOpenPost` the facts as strings and counts, pass `followLabel` to show the Follow pill, and own the like and vibe states. Every pill and line is omitted when its text is null.

**Give it the post's facts, already formatted.** Name, time, place and distance are strings; likes and replies are integers, drawn with Western digits in either direction.

**Body is plain text or runs.** Pass `segments` to mark hashtags and mentions as links; they take the brand colour. The run itself is not tappable — navigate from the row's tap.

**Liked and vibed are states you own.** Liked draws a bold heart in the error colour; vibed draws a bold brand-coloured glyph. Toggle them from your callbacks.

**Every action is its own button, at least 45px square.** The row's own tap opens the post. Labels for screen readers default to English; pass your own in other languages.

**The sport pill takes a glyph slot, not an emoji.** The design shows an emoji beside the sport name; the system is icons only, so the slot is a widget and is empty by default.

**Fill the optional slots from your data; the row decides nothing.** Pass `imageUrl` for the author's photo, `onAuthorTap` to open the author, `media` for the post's photos, `onRepost` only when the post can be reposted, `reactions` for the chips, `kindBadge` for a kind or origin and `views` only when the viewer is the author.

**Pass `detail` on the open post.** It adds the full timestamp, an edited marker and who can see the post above the actions, closed by a hairline. Without it the feed row is unchanged.

**Draw a repost with `DabblerRepostRow`, not a post row.** Pass the reposter's name and an already-formatted reposted line, an optional `quote`, and the original as a `DabblerPostRow` with `divider: false` in the `original` slot. When the original is gone, leave `original` empty and pass `unavailableLabel`. `detail` and `actions` draw under the card.

**Where it departs from the design.**

- The distance pill is the shared Badge: 4px block padding, bold, with a hairline, where the design is 2/8, regular and border-less.
- The action row is 45px high instead of 20, to reach the touch minimum; the design's 6px top margin and 15px bottom padding are reduced to compensate.
- The avatar and the sport pill link to other screens in the design; neither reaches 45px without changing the layout, so they are not exposed.
- The liked and vibed inks are inferred, because the script that computes them was cut off in the fetched file.
- 5px gaps take the 6px step, and 8px and 11px paddings take 9 and 12.
- The avatar's author target is the avatar's own 36px width (the design's link target), taller below it; the name is a second target.
- With a repost action and no share callback, the inert share glyph is not drawn: the actions plus more would not fit a 360px row at the 45px touch floor. Passing both share and repost needs a wider row.
- The design files draw no repost row (Profiles only names a Reposts tab), so `DabblerRepostRow` follows the app's shipped repost row, rebuilt from system parts; its reposter avatar is the post row's 36px rather than 48px so the two line up in one feed.
- The repost action, the reaction summary, the kind badge and the view count are not in the Home Feed markup; they reuse the row's own action, chip and badge parts so the feed keeps those behaviours.

## Axes

### State
Liked or not, vibed or not, with or without the divider, with or without the sport pill, role and distance.

## Direction

Every inset is logical. The avatar leads, the more action trails, and text resolves to the Arabic metrics.

## Tokens used

Ink: primary for the name, secondary for role, time, place, body and counts, tertiary for the meta glyphs and the dot, brand for link runs and a vibed glyph, error for a liked heart. Fill and line: the faint fill as the hairline, the default border on the sport pill, the info status on the distance pill. Spacing: 3, 6, 9, 12, 15 and 18. Size: the 45px touch minimum, a 36px avatar, 13px and 20px glyphs. Type: subheadline, caption-1 and caption-2.

## Change log

- KAN-433 (Home fidelity) — adds `metrics`. Drawn lays the row out as the frame measures it: a 2/8 regular-weight 11/13 type pill (17 high), 5 gaps in the meta row with the pin 4 further in, a 32 high sport pill, and a 20 high action row — glyphs and counts only, 18 apart — under 12 of air with 15 below; each action keeps its 45 target as a hit-test-only area, the row's own band reaching the 12 above and below. The deviations above (45px boxes, nearest-step gaps) describe the default, which is unchanged.
- Added from the Home Feed design file.
- Gained the opt-in open-post detail line from the Post design file (KAN-412 gaps 5).
- Alpha final follow-up — adds `DabblerRepostRow`.
- Alpha fidelity (Results) — adds `showActions` (off for the result lists, which end on the sport pill).

## Source

`lib/src/feed/post_row.dart`, `lib/src/feed/repost_row.dart`
