<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/navigation/page_dots.dart (class dartdoc)
           lib/src/navigation/step_progress_gallery.dart (specimen
           "PageDots — the position under a carousel")
           design: Auth and Onboarding.dc.html:77-81, :1874-1878
-->

# PageDots
### `DabblerPageDots`

PageDots is the row of dots under a carousel that shows which page is on screen: the active page
is a wide brand pill, the others small dots.

It can be static, or each dot can jump to its page.

## Specimen

Static and tappable — see `step_progress_gallery.dart`'s *PageDots* section.

@specimen page-dots

## Using it

**Give it `onSelected` when the dots should move the carousel.** Each dot then becomes a button with
a selected state and a 45px-tall target. Without it the row is a single read-only label.

**Pass a localised `semanticLabelBuilder`.** The default reads "Page N of M" in English.

**Keep it in step with a `PageView` that runs in the same direction.** In right-to-left layouts
page one is on the right, as the pages are.

## Axes

### Active
The active dot is wide and brand-filled; the rest are small and use the strong outline colour. The
width animates as the page changes, and snaps under reduced motion.

### Interaction
Static, or tappable per dot.

## Tokens used

Dot height, idle width and gap: `space2` (6). Active width: `space8` (24). Active: `brandPrimary`.
Idle: `borderStrong` (`--outline-strong`). Radius: `pill`. Target height: `touchTargetMin`.
Motion: `base` with `easeOut`.

## Change log

- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/navigation/page_dots.dart`
