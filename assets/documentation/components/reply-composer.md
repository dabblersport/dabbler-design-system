<!--
Component page, D-033 ten-part template.

Tier     : Selection and input
Sources  : lib/src/feed/reply_composer.dart (class dartdoc, incl. the
           design-to-Dart table and deviations)
           lib/src/feed/thread_gallery.dart (specimen title:
           "ReplyComposer — the reply bar under a post")
           Claude Design file "Post.dc.html" (alpha-plan design set). The
           resting bar is lines 329-341; the composing frame is lines 525-580.
-->

# ReplyComposer
### `DabblerReplyComposer`

ReplyComposer is the bar pinned under a post's replies: an optional "Replying to" line with a cancel, a slot for attachment previews, attach buttons, the field and the send button.

It is safe as a page's bottom bar: it pads the home indicator itself while the keyboard is closed and drops that padding once the keyboard is open.

## Specimen

Resting with attach buttons, replying to someone with an attachment and a multi-line field, sending, and an Arabic bar in right-to-left — see `thread_gallery.dart`.

@specimen reply-composer

## Using it

**Composing is a mode.** Set `composing` and the bar draws the composing frame: previews and a multi-line field inside a brand-bordered editor, with the attach glyphs, the `counter` and a pill Reply button under it.

@specimen reply-composer/composing

**Send hands you the text; you clear it.** The send button is live only when the field has text, unless you allow an attachment-only reply. In single-line mode Enter sends; in multi-line mode Enter adds a line and the field grows up to its maximum.

**Show who is being replied to.** Pass the target and a cancel callback; the line reads "Replying to" and the target in the brand colour, with a cancel button at the end.

**Put previews in the attachments slot.** A row of AttachmentChips is the usual content; the bar draws whatever you pass above the input row.

**Attach buttons are yours to define.** Each has a glyph, a name and a callback; mark one active when something of its kind is attached.

**Sending shows a spinner.** While sending, and when the bar is disabled, the send button is drawn and announced as disabled.

**Where it departs from the design.**

- The 42px send button and field take the 45px touch minimum.
- The 14px field text takes the 15px subheadline.
- The 95px add tile and 96px preview keep their sizes; 42px controls take 45px targets.

## Axes

### State
Resting, ready, sending and disabled; with or without the reply line, attachments and attach buttons; single or multi-line.

### Text actions
`DabblerReplyComposerAction.text` puts a short word such as GIF in a pill instead of a glyph; the
word is also the button's name. Deviation: the Post design draws only glyph actions, so the pill
borrows the input's pill corner and the glyphs' tint.

## Direction

Attach buttons lead, send trails, the cancel sits at the end, and the field aligns to the start of the text direction.

## Tokens used

Surfaces: page for the bar, sunken for the field and the idle send button. Ink: primary for text, secondary for the hint, the lead-in and idle glyphs, tertiary for disabled glyphs, brand for the target, an active glyph and the ready send button, on-brand for its glyph. Line: the faint fill above the bar, the default border on the field. Spacing: 3, 6, 9, 12 and 15. Size: the 45px touch minimum, 22px, 20px and 18px glyphs. Radius: pill, or the extra-extra-large corner when multi-line. Motion: the fast duration and ease-out curve, none under reduced motion. Type: subheadline and caption-1.

## Change log

- Added from the Post design file (KAN-412 gaps 5).
- DS gaps 6 — text attach actions.
- Composing mode, counter and Reply pill from the Post design.

## Source

`lib/src/feed/reply_composer.dart`
