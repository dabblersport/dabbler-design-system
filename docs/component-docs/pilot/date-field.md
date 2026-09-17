<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/date_field.dart (read in full — DabblerDateFormat's
           format/parse/inBounds static methods, DabblerDateSpan, the
           DabblerDateField class dartdoc, constructor/field declarations,
           and the build() method showing it composes PickerFieldShell
           directly, not PickerField)
           lib/src/forms/forms_gallery.dart:168-171 (specimen description)
           DECISIONS.md — grepped "DateField": no ruling on this component's
           own behaviour beyond D-036(c)'s confirmation that the shared LTR
           pin is correctly attributed to PickerFieldShell, not repeated
           here.

Direction: NO section on this page, deliberately — the LTR-pin fact belongs
to PickerFieldShell, which this widget composes directly, and D-036(c)
explicitly confirms this attribution rather than a repeated per-field
section. See PickerFieldShell's own Direction section for the fact itself.
-->

# DateField
### `DabblerDateField`

## Definition

DateField is a date, or a date range, entered by typing or by picking — the field half only; it
contains no calendar of its own.

## Intro

It composes `PickerFieldShell` directly — the box, the typed entry, the `DD/MM/YYYY` formatting and
bounds checking, and the states are all this field's; the actual picker surface is deliberately not
here. The trailing button fires `onOpenPicker` and reports `open` back, and the caller attaches
whatever surface it wants there — almost always `Calendar`, used as-is rather than forked into a
field-specific variant.

## Specimen

Closed, alongside `TimeField` and `PickerField` — see `forms_gallery.dart`'s *Pickers* section.

## Using it

**Do not fork `Calendar` for a field-specific variant.** DateField's whole design depends on the
calendar staying generic — it's attached through `onOpenPicker`/`open`, not owned, specifically so
one `Calendar` implementation serves every date-picking surface in the app.

**Enforce `minimum`/`maximum` by passing them — don't re-validate the typed value yourself.**
Bounds are checked on the typed path already; an out-of-bounds parse reverts to the field's current
value rather than committing, so a caller re-checking the same bound after `onChanged` fires is
checking something that can no longer be out of range.

**Feed a chosen calendar date back through `onChanged` (or `onSpanChanged` for a range), the same
callback typing uses.** The field has one value path, not two — a picker composing its own
separate "confirm" callback would create a second source of truth for the same field.

## Axes

### Mode
Single date or range (`[DateTime?, DateTime?]` — a half-open span while only the start is chosen).

### State
The same `FieldShell` rest / focused / filled / error / disabled states, inherited through
`PickerFieldShell`.

## Tokens used

Everything visible belongs to `PickerFieldShell` — see that page.

## Source

`lib/src/forms/date_field.dart`
