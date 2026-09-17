<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/time_field.dart (read in full through
           DabblerTimeFormat's format/parse — the meridiem section and the
           flexible-parse fold; confirmed it composes PickerFieldShell
           directly at line 270, same pattern as DateField)
           lib/src/forms/forms_gallery.dart:168-171 (specimen description)
           DECISIONS.md — grepped "TimeField": no ruling on this component's
           own behaviour.

Direction: NO section on this page, same reasoning as DateField — the LTR
pin belongs to PickerFieldShell, which this composes directly.
-->

# TimeField
### `DabblerTimeField`

## Definition

TimeField is a time of day, entered by typing or by picking, always in `H:MM AM` form — the field
half only; it contains no time picker of its own.

## Intro

Like DateField, it composes `PickerFieldShell` directly and leaves the picker surface entirely to
the caller. Two things about its format are deliberate design decisions, not oversights: the
meridiem is always the literal `AM`/`PM`, never localised, and the numerals are always Western
Arabic — the product's time format is `H:MM AM` in both scripts, not a value that translates.

## Specimen

Closed, alongside `DateField` and `PickerField` — see `forms_gallery.dart`'s *Pickers* section.

## Using it

**Never localise the meridiem.** `AM`/`PM` are constants this system draws literally, not a locale
lookup — building a translated meridiem would produce a value the rest of the product doesn't
write anywhere else.

**Let typed entry accept loose formats; don't force a single exact pattern.** `6pm`, `6:00 PM`,
`18:30` and `6.30 pm` all parse to the same value — a stricter validator layered on top would
reject input the field itself already accepts correctly.

**Know that a bare 24-hour hour like `18:30` folds to 12-hour on parse, but `00:30` is rejected, not
folded to `12:30 AM`.** That's a transcribed edge from the source rather than a design choice to
extend — the paired `TimePicker` has no distinct "12 AM" column either, so the field doesn't invent
one on the typed path.

## Axes

### State
The same `FieldShell` rest / focused / filled / error / disabled states, inherited through
`PickerFieldShell`.

## Tokens used

Everything visible belongs to `PickerFieldShell` — see that page.

## Source

`lib/src/forms/time_field.dart`
