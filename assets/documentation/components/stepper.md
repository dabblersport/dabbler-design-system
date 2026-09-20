<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/stepper.dart (read in full through the RTL section
           and constructor start)
           lib/src/forms/forms_gallery.dart:547-585 (specimen contents)
           DECISIONS.md — grepped "Stepper": no ruling touches this
           component.
-->

# Stepper
### `DabblerStepper`

Stepper is for a small bounded integer the user nudges rather than types out — a player count, a
ticket count, a set count — with the numeral itself still directly editable.

It's a direct `FieldShell` consumer — the label, box, four border states and helper/error line are
all the shell's, exactly as `TextField`'s. The one departure is deliberate: instead of handing the
shell separate row items with the shell's own gap between them, Stepper passes a single child and
zeroes the shell's inner padding, because its two 45×45 buttons need to reach the box's edge with no
gap breaking the row's symmetry.

## Specimen

Both sizes, a bound stepper at its minimum and maximum, an error state, and a disabled state — see
`forms_gallery.dart`'s *Slider and Stepper* section.

## Using it

**Let typed entry, not just the buttons, be a real path to a value.** The numeral is a genuine text
field, filtered to digits and clamped to `[min, max]` on commit — building a stepper that only
accepts button taps loses a real input path this component already provides.

**Don't fire `onChanged` expecting it on every button press near a bound.** Both the buttons and
typed entry clamp to `[min, max]`, and the callback never fires when the clamped result equals the
current value — pressing "+" at the maximum is a no-op, not a repeated call with the same number.

**Reserve the `sm` size for a dense row inside a card, not a primary form.** `md` (45px) is the
default and the one a standalone form field should use; `sm` (39px) exists for a ticket line or
similar dense context where a full-size control would overwhelm the row.

## Axes

### Size
`sm` (39px, dense rows), `md` (45px, the default).

### State
Rest, focused, filled, error, disabled — the same `FieldShell` states, inherited rather than
redefined.

@figure 39px lib/src/forms/stepper.dart#boxSizeFor
@figure 45px lib/src/tokens/dabbler_geometry.dart#touchTargetMin


## Direction

**The minus and plus buttons swap sides under Arabic like the rest of the row, but the numeral
itself stays pinned left-to-right and in Western Arabic digits.** The buttons sit in ordinary flow,
so they reorder normally; the number between them is wrapped in its own fixed left-to-right
direction, because a count is a number and numbers read left to right in both scripts, the same
reasoning CodeInput's digit boxes follow.

*Confirmed by reading `stepper.dart` directly — the numeral sits inside its own
`Directionality(textDirection: TextDirection.ltr)`, and digit rendering uses the same
Western-numeral font feature `DateField` does. Not yet checked against the gallery's direction
switcher.*

## Tokens used

Border, label and helper/error styling all come from `FieldShell` — see that page. The two button
glyphs and the numeral text use the shared icon and type roles; nothing here is a colour this
component declares on its own.

## Source

`lib/src/forms/stepper.dart`
