<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/comment_row.dart (class dartdoc, incl. the design-to-Dart
           table and deviations)
           lib/src/feed/thread_gallery.dart (specimen title:
           "CommentRow — one reply under a post")
           Claude Design file "Post.dc.html" (alpha-plan design set). The
           top-level reply is lines 285-300; a nested reply is lines 306-317.
-->

# CommentRow
### `DabblerCommentRow`

CommentRow is one reply under a post: the author's avatar, a name line with a handle and a relative time, the body, an optional attached image or GIF, and the like and reply actions.

Every string and count is data you pass in; every interaction is a callback. Replies nest by depth, each level lining up with its parent's text.

## Specimen

A top-level reply with a handle and the replies toggle, a liked nested reply, a reply with an attached image, and an Arabic reply in right-to-left — see `thread_gallery.dart`.

@specimen comment-row

## Using it

**Give it the reply's facts, already formatted.** Name, handle and time are strings; the like count is an integer, drawn with Western digits in either direction. Pass a time slot instead of the time when the relative time updates live.

**Nest with depth, not with layout.** Depth zero is a top-level reply. Each deeper level indents by the parent avatar and its gap, and takes the smaller avatar and type; the divider is drawn at depth zero only unless you say otherwise.

**Attach media in the attachment slot.** Pass an Image for a photo or GIF, sized by you; the row clips it to the large corner.

**Every action is its own button, at least 45px square.** The heart toggles the like, Reply starts a reply, and the replies toggle shows or hides the nested replies when you pass its label. The more action appears only with its callback.

**Long press opens the context menu.** Pass the long-press callback; it works with or without a tap and is exposed to assistive technology as the long-press action.

**Where it departs from the design.**

- 4px and 2px gaps take the 3px step; the nested avatar is 28px, not 30.
- The 14px name and body take the 15px subheadline; the nested reply's 13 and 14 take the 13px footnote.
- The action row is 45px high instead of 16, to reach the touch minimum.
- The design draws no media in a reply; the attachment slot is an addition.
- The "Joined the game" chip is content: pass it in the attachment slot.

## Axes

### Depth
Top-level or nested, at any depth.

### State
Liked or not, with or without the replies toggle, more action, attachment and divider.

## Direction

Every inset is logical. The avatar leads, the more action trails, and the depth indent grows from the start edge.

## Tokens used

Ink: primary for the name, secondary for handle, time, body and Reply, tertiary for the dot, brand for the replies toggle, error for a liked heart. Line: the faint fill as the hairline. Spacing: 3, 6, 9, 12 and 15. Size: the 45px touch minimum, 36px and 28px avatars, 18px glyphs. Radius: the large corner for an attachment. Type: subheadline, footnote and caption-1.

## Change log

- Added from the Post design file (KAN-412 gaps 5).

## Source

`lib/src/feed/comment_row.dart`
