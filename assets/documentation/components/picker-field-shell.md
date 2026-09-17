<!--
Component page, D-033 ten-part template. Internal primitive, same shape as
FieldShell's page — D-036(a) names this component's own pinned segments as
its worked example of family 1 (an exception to mirroring), so this page's
Direction section is the most load-bearing one written so far.

Group    : Selection and input
Sources  : lib/src/forms/picker_field_shell.dart (read in full: class
           dartdoc, constructor/field declarations, the typed-input Widget
           build section carrying the LTR pin at ~lines 247-258)
           lib/src/forms/picker_field.dart:1-90 (library-level dartdoc,
           part-file rationale)
           DECISIONS.md — grepped "PickerFieldShell": no ruling on its own
           behaviour beyond D-036(a) citing it as a worked Direction example
           (not a behavioural ruling, so not linked in Change log).
-->

# PickerFieldShell
### `DabblerPickerFieldShell`

PickerFieldShell is the shell every typed-or-picked field paints from — `FieldShell` carrying a
real text input plus a trailing 45×45 brand-tinted button that opens a picker.

It's an internal composition primitive, not a public control: `DateField` and `TimeField` import it
directly, and `PickerField` composes it and adds the responsive presentation branch on top. It is
not `TextField`'s `select` variant, even though both are built on the same `FieldShell` — a picker
field must stay typeable, so its shell is a real input with a trailing icon button, never a button
pretending to be a field.

## Specimen

Closed date and time fields, each carrying this shell — see `forms_gallery.dart`'s *Pickers*
section.

## Using it

**Never treat opening the picker as the only way to set a value.** Typing has to stay possible —
that's the whole reason this shell exists instead of reusing `TextField`'s `select` variant, whose
box isn't a real input at all. A keyboard user must be able to fill the field without ever opening
the picker overlay.

**The overlay is the caller's, not this shell's.** `onOpenPressed` only reports that the trailing
button was tapped — building, anchoring and dismissing the actual picker surface belongs to
whichever field composes this shell (`DateField`, `TimeField`, `PickerField`).

**Commit typed text on blur and Enter, not on every keystroke.** `onCommit` fires at those two
points by design, so the caller's parsing logic runs once against a finished string, not once per
character against a string that isn't done yet.

## Axes

### Focus state
Focused when the field itself has focus, or when the picker it fronts is open — `focused || open`
drives the shell's border the same way a plain field's own focus does.

## Direction

**The typed value's text run is pinned to left-to-right, independent of the field's own mirrored
chrome.** A date or time string is a number, and `/` and `:` are bidi-neutral — without pinning,
the run can reorder against surrounding Arabic and a value like `05/09/2026` would render as
`2026/09/05`. The fix pins only the editable run itself; the label, the box, the trailing button and
the button's inset still mirror normally, because that's `FieldShell`'s and it reads the ambient
direction like everything else built on it.

*Confirmed by reading `picker_field_shell.dart` directly — the typed `TextField`'s own
`textDirection` is explicitly set to `TextDirection.ltr`, with a comment naming the bidi-neutral
separator problem this solves. Not yet checked against the gallery's direction switcher.*

## Tokens used

Trailing button: brand-tinted icon on a 45×45 target. Everything else — label, border states,
helper/error line, focus colour — comes from `FieldShell`; see that page.

## Source

`lib/src/forms/picker_field_shell.dart`
