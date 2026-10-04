<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/layout/page.dart (DabblerPage)
           lib/src/layout/shell_gallery.dart (specimen "Page — the screen
           scaffold")
           Claude Design files "Home Feed.dc.html", "Article.dc.html",
           "Settings.dc.html" (DesignSync, 2026-10-03): each frame's
           `background:var(--surface-page)`. Home Feed is truncated at 256 KiB;
           Article and Settings were read in full.
-->

# Page
### `DabblerPage`

Page is the screen scaffold: the page background, the safe area, an optional top bar, the body and an optional bottom bar.

It stands in for Material's scaffold and paints nothing of Material's own; the only fill is the page background.

## Specimen

A titled top bar over a body — see `shell_gallery.dart`'s *Page* section.

@specimen page

A bar can instead float over the body: pass `bottomOverlay` and the page stacks it at the bottom
behind the page-colour fade (`overlayFade`, on by default), with the Home Feed padding — 18px at the
sides, 24px below. `overlayPadding: DabblerPage.overlayPaddingCompact` gives the Listings 12px sides.
The body is not shrunk; it keeps scrolling under the bar, and the page raises the body's bottom
padding by the overlay's measured height so a list can scroll its last row clear of it.

@specimen page/overlay

## Using it

**Put the bars in their slots, not in the body.** The top bar and bottom bar pad themselves for the status bar and the home indicator; the page adds the safe area only on an edge with no bar, so nothing is padded twice.

**Leave keyboard handling on unless the screen manages it.** By default the page lifts its content above the on-screen keyboard, the way a scaffold resizes its body.

**One page per route.** A sheet or a dialog is not a page; use `showDabblerSheet` and `showDabblerDialog` for those.

## Axes

### Slots
Body only, top bar, bottom bar, or both bars.

### Keyboard
Resized above the keyboard (default) or left alone.

### Overlay
None (default), or a floating bottom overlay with or without the fade.

## Direction

Nothing in the page is directional; the slots mirror on their own under Arabic.

## Tokens used

Ground: `bgPrimary`, the page surface. No border, no shadow, no other fill.

## Change log

- Added for the Alpha shell (DS-3, shell part).
- KAN-412 W1 — `bottomOverlay`, `overlayFade`, `overlayPadding`: a floating bar over the body with
  the fade behind it. Additive; a page without an overlay is unchanged.
- Alpha fidelity (KAN-426) — `maxContentWidth` (and `DabblerPage.readableWidth`, 480) holds the top
  bar, body and bottom bar to a phone-shaped column, centred on a wide window. Null by default.

## Source

`lib/src/layout/page.dart`, `lib/src/layout/page_overlay.dart`
