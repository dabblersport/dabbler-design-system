<!--
Component page, D-033 ten-part template.

Sources : lib/src/layout/fade.dart
          lib/src/layout/fade_gallery.dart (specimen "Fade - list bottom")
          Claude Design files "Home Feed.dc.html" (lines 463, 1710) and
          "Listings.dc.html" (six places, e.g. line 274). No other file in the
          design folder uses a gradient or a mask.
-->

# Fade
### `DabblerFade`

Fade is the wash of page colour that lets a list run out beneath a bottom bar.

The design uses it in exactly one place, behind the bottom navigation bar on the Home Feed and Listings screens: `linear-gradient(to top, var(--surface-page) 62%, rgba(245,240,230,0))`. It is the one gradient in the system and is not a surface.

## Specimen

Six rows running out beneath a bar, with the page colour fading in from the bottom edge - see `fade_gallery.dart`.

@specimen fade

## Using it

**Wrap only the bar that sits at the bottom of a scrolling screen.** Put it at the bottom edge of a stack, over the list, with the bar as its child.

**Do not use it as a surface, a card background or a decoration.** The system is flat; this is the single exception, and it carries no content of its own.

**Leave the 24px under the bar.** The default inset is the design's bottom padding; pass another padding only to match a different bar.

**It takes taps across its whole box**, as the design's wrapper does, so content under the faded area is not reachable through it.

**Where it departs from the design.** The design's transparent end is a literal `rgba(245,240,230,0)`; here it is the page colour at zero alpha, so it follows the theme and dark mode.

## Axes

### Brightness
Light and dark; both ends are the page colour of the active brightness.

## Direction

The fade runs bottom to top with no horizontal component, so it does not mirror. The child's inset is directional.

## Tokens used

Surfaces: the page background role at full and zero alpha. Spacing: the 24px step for the inset. Stop: opaque up to 62% from the bottom.

## Change log

- Added for the Home Feed and Listings bottom bar (KAN-411).

## Source

`lib/src/layout/fade.dart`
