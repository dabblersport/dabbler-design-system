<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/slider.dart (read in full through the "RTL" and
           "Keyboard" sections)
           lib/src/forms/forms_gallery.dart:163-166 (specimen description:
           "Distance, price range, marks and disabled")
           DECISIONS.md — grepped "Slider": no ruling touches this component.
-->

# Slider
### `DabblerSlider`

Slider is a value, or a bounded range of two values, on a continuous axis — dragged or stepped, not
tapped to a discrete state.

Where Toggle, Checkbox, Radio and Stepper each commit a discrete value on a tap, Slider is a
continuous drag: pressing anywhere on the track jumps to that value and starts dragging, and in
range mode the nearer thumb is the one that moves. It composes no field shell — it has no box, no
border states, no helper line — and shares only the tokens, the focus ring and the touch-target
floor with the rest of the form controls.

## Specimen

A single-value distance slider, a two-thumb price range with marks, and a disabled state — see
`forms_gallery.dart`'s *Slider and Stepper* section.

## Using it

**Give `marks` in value space, not pixel space.** Tick positions are values along the axis
(`[0, 50, 100, 150, 200]` for a 0–200 range), never coordinates — the component places them, and
they're decorative to assistive technology, not a second set of stops.

**Reach for `DabblerSlider.range` for a bounded pair of values, not two independent sliders.** Range
mode's nearer-thumb-moves behaviour and its shared fill between the two thumbs only exist on the
range constructor — two single sliders side by side don't coordinate with each other at all.

**Trust the axis inversion under Arabic; don't add your own direction handling on top of it.**
Paint, pointer math and the arrow-key mapping all already invert together so "increase" is always
the direction the fill visually grows — see *Direction*. Anything layered on top of that would
double-invert it.

## Axes

### Mode
Single value or range (two thumbs, bounded pair, nearer thumb moves on drag).

### Marks
Present (tick positions in value space) or absent.

### State
Enabled, disabled.

## Direction

**The whole axis inverts under Arabic, in three coordinated places, not just the paint.** The track
fill and every thumb are positioned from the logical start rather than a physical side, so the
minimum ends up on the right under RTL automatically. Pointer position is measured physically and
then inverted to match, since a finger or cursor position is always physical even when the layout
isn't. And the arrow keys swap, so the key that grows the fill is always the one pointing the
direction it visually grows — "increase" is never the wrong-feeling key in either script.

*Confirmed by reading `slider.dart` directly — paint uses `PositionedDirectional`, pointer maths
explicitly inverts under `TextDirection.rtl`, and the arrow-key mapping is stated as swapped in the
same section. Not yet checked against the gallery's direction switcher.*

## Tokens used

Track: `bgTertiary`. Fill: `brandPrimary`. Thumb: `surfaceCard` fill with a `borderStrong` ring.
Readout text uses the caption type style. Focus ring and the 45px touch-target minimum per thumb
are the same shared tokens every other form control reads.

## Source

`lib/src/forms/slider.dart`
