<!--
Component page, D-033 ten-part template.

Tier     : Selection and input
Sources  : lib/src/feed/attachment_chip.dart (class dartdoc, incl. the
           design-to-Dart table and deviations)
           lib/src/feed/thread_gallery.dart (specimen title:
           "AttachmentChip — a removable attachment")
           Claude Design file "Post.dc.html" (alpha-plan design set). The
           thumbnail is lines 541-546; the place pill is line 547.
-->

# AttachmentChip
### `DabblerAttachmentChip`

AttachmentChip is one attachment waiting in a composer: a photo or GIF thumbnail, or an icon and a label such as a place, with a button to remove it.

The chip holds no state; removing is your callback.

## Specimen

A thumbnail with its remove button and a place pill, then both in right-to-left — see `thread_gallery.dart`.

@specimen attachment-chip

## Using it

**Pass a thumbnail for media, or an icon and a label for anything else.** With a thumbnail the chip is a 96px square tile; without one it is a pill.

**Name the remove button in the user's language.** It is its own button, at least 45px, announced by its label; leave out the callback to hide it.

**Name the thumbnail.** The thumbnail is announced as an image by its semantic label; a pill is read by its label.

**Where it departs from the design.**

- The remove button's translucent black has no token; the scrim role is the nearest, with an on-brand glyph.
- The place pill's brand tint has no token; the pill is the card surface with a hairline and a brand icon.
- The painted remove circle keeps 22px; its touch target is 45px at the same corner.
- 5px insets take the 6px step, and 8 and 9px paddings take 9.

## Axes

### Kind
Thumbnail or pill.

### State
With or without the remove button and a tap.

### Shape
`size` gives a thumbnail an exact non-square box, and `aspectRatio` widens it from the thumbnail
height instead. `borderRadius` takes another radius token for a smaller tile; the large corner stays
the default.

## Direction

The remove button sits at the end corner and mirrors under right-to-left; the pill's icon leads.

## Tokens used

Surfaces: sunken behind a thumbnail, card for the pill. Overlay: the scrim role behind the remove glyph. Ink: primary for the label, secondary for the pill's remove glyph, brand for the pill icon, on-brand for the thumbnail's remove glyph. Line: the default border. Spacing: 6 and 9. Size: the 45px touch minimum, a 22px remove circle, 14px glyphs. Radius: the large corner and pill. Type: caption-1.

## Change log

- Added from the Post design file (KAN-412 gaps 5).
- DS gaps 6 — non-square thumbnails and a radius override.

## Source

`lib/src/feed/attachment_chip.dart`
