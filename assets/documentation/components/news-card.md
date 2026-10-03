<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/news_card.dart (class dartdoc, incl. the design-to-Dart
           table and deviations)
           lib/src/feed/feed_atoms.dart (shared FeedAction and FeedTappable)
           lib/src/feed/feed_gallery.dart (specimen title:
           "NewsCard — one story in the News tab")
           Claude Design file "Home Feed.dc.html", fetched through DesignSync
           on 2026-10-03 and truncated at the tool's 256 KiB cap: the markup is
           complete, the script data is not. The card is lines 407-436 of that
           file.
-->

# NewsCard
### `DabblerNewsCard`

NewsCard is one story in the News tab: a rounded media block with a sport pill over its corner, the like, comment and view figures with the story's age, then the title and a two-line excerpt.

The media is a slot, so the card adds no image dependency. Titles and excerpts are supplied by the caller.

## Specimen

A default story, a liked story without a divider, and an Arabic story in right-to-left — see `feed_gallery.dart`.

@specimen news-card

## Using it

**Pass the media as a widget.** Anything that fills its box works; the sunken surface shows behind it and while it loads. The block is 210px high with an 18px corner.

**Counts are integers.** Likes and comments are buttons when you pass a callback; views are a plain figure and are left out when null. Digits are Western in either direction.

**The excerpt clamps to two lines.** The title does not clamp.

**The whole card opens the story** when you pass a tap handler. Like and comment are separate buttons, each at least 45px square.

**Where it departs from the design.**

- The sport pill is the shared Badge, which is bold where the design is regular weight.
- The action row is 45px high instead of 18, and the 9px gaps either side of it are dropped to compensate.
- The liked ink is inferred, because the script that computes it was cut off in the fetched file.
- The design's image placeholder hint is not reproduced.

## Axes

### State
Liked or not, with or without the divider, with or without media, sport pill, excerpt and views.

## Direction

The pill sits at the start corner and the age trails at the end; both mirror under right-to-left, and type resolves to the Arabic metrics.

## Tokens used

Ink: primary for the title, secondary for the excerpt, age and figures, error for a liked heart. Surfaces: sunken behind the media, the faint fill as the hairline. Spacing: 6, 12, 15, 18 and 21. Radius: the 18px extra-large corner. Size: the 45px touch minimum and 18px glyphs. Type: headline, subheadline and caption-1.

## Change log

- Added from the Home Feed design file.

## Source

`lib/src/feed/news_card.dart`
