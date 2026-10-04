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

Toggle is a switch whose state change takes effect immediately — for a settings-style row, not for
a value the user is still assembling in a form.

That's the whole distinction between this and Checkbox: a Checkbox collects a value the user is
still building toward submitting something; a Toggle changes something right now. It carries no
label and no size prop for that reason — the label belongs to the row around it, and there is only
one size.

## Specimen

Off, on, disabled-off and disabled-on — see `forms_gallery.dart`'s *Selection* section.

@specimen checkbox/selection-controls

## Using it

**Use Toggle only where the change takes effect immediately, with nothing to submit.** If the
state is part of a form the user will confirm or cancel as a whole, that's Checkbox, not Toggle —
reaching for a Toggle there implies an immediacy the flow doesn't actually have.

**Let the surrounding row supply the label.** Toggle has none of its own — pass it as a row title,
the same way `InputRow` pairs a title with a trailing control.

**Let the track and knob motion — colour over 120ms, the knob sliding, no bounce — run as built.**
It already switches to an instant snap under reduced motion; there's nothing to configure here.

**Inside a tappable row the row is the target.** A toggle in an `InputRow` that has `onTap` lays out at its painted 28, so the row keeps the Settings rhythm; a bare toggle, or one in a row with no `onTap`, keeps the 45-point target.
**Pass `compactHitArea: true` only where the row around the switch already carries the tap.** The layout is then 28px tall and the 45px target survives as an area that is hit-tested but not laid out, so the parent has to leave about 8px free above and below the track for it to apply in full.

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

## Change log

- A toggle in a tappable input row lays out at 28 instead of 45.
- KAN-426 (final) — adds `compactHitArea` (default false): drops the 45px-tall box from layout so the switch is exactly its 28px track, as the frames lay it out.

## Source

`lib/src/forms/toggle.dart`
