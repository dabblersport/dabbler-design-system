<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/media/gallery_hero.dart (class dartdoc)
           lib/src/layout/detail_gallery.dart (specimen "GalleryHero")
           design: Details.dc.html:386-418 (venue gallery)
-->

# GalleryHero
### `DabblerGalleryHero`

GalleryHero is the paged photo hero that opens a venue: full-width slides that snap, caption pills, a dot indicator and the screen's own round buttons over the photograph.

It pages with a swipe in the reading direction, captions each slide at the inline start, and carries the screen's back and favourite buttons over the photograph.

## Specimen

Two empty slides with captions, back and favourite on page-coloured circles, in both directions — see `detail_gallery.dart`.

@specimen gallery-hero

## Using it

**One slide per photograph.** A slide with no `imageUrl` shows the sunken ground, and may carry a `child` (a sport glyph) until a photo exists.

**Buttons use `onSurface`.** Pass `OnColorIconButton(onSurface: true)` for the page-coloured circles the design draws over a photo.

## Axes

### Slides
One slide draws no dots. Several draw a long active dot and small idle ones.

### Direction
The pager runs in the reading direction; captions and buttons mirror.

**System bars.** An image hero has no single fill colour: each slide is a `DabblerImage` (its sunken ground until the picture loads), so a screen that opens with this hero cannot ask it for a status-bar colour the way it can with `DabblerDetailHeader.fillOf`. Until a decision is made (a scrim colour the hero draws under the status bar, or a seed colour taken from the image), such a screen keeps the page background in the status bar. Not implemented.

## Tokens used

`bgPrimary`, `textPrimary`, `caption2`, `DabblerImage`'s sunken ground, spacing steps, `DabblerMotion.base`.

## Change log

- KAN-426 fidelity rebuild — adds this component.

## Source

`lib/src/media/gallery_hero.dart`
