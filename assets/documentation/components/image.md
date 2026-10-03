<!--
Component page, D-033 ten-part template.

Tier     : Content containers (media)
Sources  : lib/src/media/image.dart (class dartdoc, incl. the design-to-Dart
           table and deviations)
           lib/src/media/image_gallery.dart (specimen title:
           "Image — network photo frame")
           Claude Design file "Home Feed.dc.html", fetched through DesignSync
           on 2026-10-03 and truncated at the tool's 256 KiB cap: the markup is
           complete. The news cover is line 409; the composer media rail is
           lines 519-524. Article sizes come from NOTES-inline-read.md.
-->

# Image
### `DabblerImage`

Image is a network photo in a rounded frame, for article covers, activity thumbnails and post media.

It shows a sunken placeholder while the photo loads or when there is no address, and the same fill with a glyph when the photo cannot be loaded. It uses Flutter's own network image, so the package adds no image dependency. The design shows no paging carousel, so Image is a single image; a row of them is the caller's layout.

## Specimen

The placeholder cover, the error state with its label, a scrim with a badge over it, and a 64px thumbnail — see `image_gallery.dart`. The specimens use no real address, so nothing here reaches the network.

@specimen image

## Using it

**Size it with a height or an aspect ratio.** The width fills its parent unless you set one. The photo always covers the frame.

**Pick the corner from the radius set.** The default is the 18px extra-large corner used by news covers and article heroes; pass the 12px large corner for a thumbnail or tile.

**Turn the scrim on when text or a badge sits over the photo.** It is the one overlay wash, not a custom opacity. Put the badge in the overlay slot; it sits at the start corner, 12px in.

**Supply the error text yourself.** The package carries no strings, so the label under the glyph is yours to localise. Leave it out for the glyph alone.

**Name the image or mark it decorative.** With a semantic label it is announced as an image, or as a button named by it when you pass a tap handler. Without one it is hidden from assistive technology.

**Where it departs from the design.**

- The design's remove chip uses a literal translucent black no token carries; the scrim role is the nearest, and it washes the whole image.
- The design's placeholder hint text is not reproduced.
- The design has no error state; the glyph is the media icon.

## Axes

### State
Loading or no address, loaded, and failed; with or without scrim, overlay, label and tap handler.

## Direction

The overlay slot sits at the start corner and mirrors under right-to-left. The photo itself is never flipped.

## Tokens used

Surfaces: sunken for the fill. Overlay: the scrim role. Ink: tertiary for the error glyph, secondary for its label. Spacing: 6 and 12. Radius: the 12px large and 18px extra-large corners. Size: the 30px icon. Motion: the 120ms base duration and the ease-out curve for the fade-in. Type: caption-1.

## Change log

- Added for the Home Feed media surfaces (KAN-410).

## Source

`lib/src/media/image.dart`
