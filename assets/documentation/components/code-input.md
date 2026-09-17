<!--
Pilot page, D-033 ten-part template, component path (the "easy" assembly
case — .prompt.md and dartdoc both strong, per the original audit).

Group    : Selection and input
Sources  : CodeInput.prompt.md (design source, read in full)
           lib/src/forms/code_input.dart (read in full)
           lib/src/forms/forms_gallery.dart:634-648 (specimen contents)
           DECISIONS.md — grepped for "CodeInput": no entry rules this
           component directly (one incidental mention inside D-013, about
           Section, using CodeInput only as a correct comparator).

Direction section upgraded 2026-09-18 from "confirmed by reading" to "confirmed
by sight" — team-lead rendered it in the gallery's now-live direction switcher
and reports the digit-order claim holds exactly as written. Change log section
omitted per D-033's own rule ("omitted where none does") and D-034(a)'s
general "omit, never stub" principle.
-->

# CodeInput
### `DabblerCodeInput`

CodeInput is a fixed-length row of digit boxes for entering a one-time code or PIN — phone
verification, email codes, payment PINs.

Each digit is its own box, six by default, and the whole row is one control: paste or autofill
fills every box from wherever it lands, typing advances automatically, and completion is what
triggers verification, not a separate submit button. It is a `TextField` in what it captures — a
short numeric string — and deliberately not one in how it renders: see *Using it* for why it
composes no field shell.

## Specimen

Four boxes filled, six boxes partially filled, a masked four-digit PIN, an error state, and a
disabled state — see `forms_gallery.dart`'s *CodeInput* section.

## Using it

**Never wrap CodeInput in `FieldShell`.** Every other field in this system draws from the shared
shell; this one draws its own boxes, with no label, helper or error line. A shell would add a
45-minimum, 24-radius frame around a grid of 45×54, 12-radius boxes it was never asked to hold.

**Pair an error state with a `Banner` or a message line below — never rely on the boxes alone.**
The boxes carry only the error hairline; there is no room inside CodeInput for "that code didn't
work," so the words for it belong outside the component.

**Trigger verification from completion, not from a submit button.** The component reports a full
code as its own event; a separate button asking the user to confirm what they already finished
typing adds a step the code entry itself already answers. Show progress with a loading button
instead.

**Every box is a real input, not a styled span.** Screen readers and password managers only work
if each digit is its own focusable field — this is why CodeInput cannot be built as one text field
with a monospace mask.

**The digit order does not follow the ambient text direction.** See *Direction*.

## Axes

### State
Default (empty or partially filled), filled, masked (PIN entry — digits render as dots), error
(hairline only, no message), disabled.

### Length
Any positive box count; the design source's own specimens use both 4 and the default of 6.

## Direction

**CodeInput's digit order stays left-to-right even when the rest of the screen is in Arabic.** A
verification code is a number, and numbers read left to right in both scripts — mirroring the
boxes would change the value the user sees, not just its layout. The row is wrapped in an explicit
left-to-right direction that applies only to the boxes themselves; everything around
them — the row's position on the screen, its start alignment — still follows the ambient
direction normally. Arrow-key movement between boxes follows the same pinned order, so the "next
digit" key always means the same box regardless of script.

*Confirmed by sight in the gallery's direction switcher (team-lead, 2026-09-18): under RTL the
chrome and labels mirror to the right while the digit boxes read left-to-right and unmirrored.*

## Tokens used

Box fill and hairline: `surfaceCard` / `bgSecondary` (disabled) and `borderDefault`, swapping to
the error status tone's `base` role when `error` is set. Focus ring and touch-target-minimum sizing
are the same shared tokens every other field control reads. Digit text uses the display type
style at the size the field shell would otherwise use for a value.

## Source

`lib/src/forms/code_input.dart`
