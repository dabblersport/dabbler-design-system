<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/toggle.dart (read in full through the touch-target
           section)
           lib/src/forms/forms_gallery.dart:405-418 (specimen contents)
           DECISIONS.md — grepped "Toggle": no entry rules this component
           (one incidental mention inside D-026, listing what a rejected
           app-kit recreation composes — not a ruling on Toggle itself).
-->

# Toggle
### `DabblerToggle`

## Definition

Toggle is a switch whose state change takes effect immediately — for a settings-style row, not for
a value the user is still assembling in a form.

## Intro

That's the whole distinction between this and Checkbox: a Checkbox collects a value the user is
still building toward submitting something; a Toggle changes something right now. It carries no
label and no size prop for that reason — the label belongs to the row around it, and there is only
one size.

## Specimen

Off, on, disabled-off and disabled-on — see `forms_gallery.dart`'s *Selection* section.

## Using it

**Use Toggle only where the change takes effect immediately, with nothing to submit.** If the
state is part of a form the user will confirm or cancel as a whole, that's Checkbox, not Toggle —
reaching for a Toggle there implies an immediacy the flow doesn't actually have.

**Let the surrounding row supply the label.** Toggle has none of its own — pass it as a row title,
the same way `InputRow` pairs a title with a trailing control.

**Let the track and knob motion — colour over 120ms, the knob sliding, no bounce — run as built.**
It already switches to an instant snap under reduced motion; there's nothing to configure here.

## Axes

### State
Off, on, disabled-off, disabled-on.

## Direction

**The knob sits at the directional end of the track when on, not at a fixed physical side.** In
Arabic that puts it on the physical left rather than the right when the toggle is on — the same
"towards the end of the row" reading LTR gives it, achieved by aligning to the logical end of the
track rather than by mirroring a left-fixed position.

*Confirmed by reading `toggle.dart` directly — the knob's alignment is `AlignmentDirectional`, not
a fixed side. Not yet checked against the gallery's direction switcher.*

## Tokens used

Track: `brandPrimary` when on, `borderDefault` when off. Knob: `surfaceCard`. Focus ring and the
45px touch-target minimum are the same shared tokens every interactive control reads.

## Source

`lib/src/forms/toggle.dart`
