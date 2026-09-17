<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/picker_field.dart (read in full through the
           constructor, field declarations and state class start)
           lib/src/forms/forms_gallery.dart:168-171 (specimen description:
           "The typed-or-picked fields, closed, plus the OTP boxes")
           DECISIONS.md — grepped "PickerField": no ruling on this
           component's own behaviour.
-->

# PickerField
### `DabblerPickerField`

PickerField is `PickerFieldShell` plus the responsive picker surface — a `Sheet` below the menu
breakpoint, an anchored `Menu` above it — for a call site that wants a typed-or-picked field
without owning an overlay itself.

`DateField` and `TimeField` each own their own picker surface and use the shell alone; PickerField
is for everything else that needs the same typed-and-picked shape without writing that presentation
branch again. It's a composition primitive, not a screen control on its own — the picker content
itself (`child`) is supplied by the caller, most often a `Calendar` or a `TimePicker`.

## Specimen

Closed, alongside `DateField` and `TimeField` — see `forms_gallery.dart`'s *Pickers* section.

## Using it

**Give it a picker as `child`; don't leave it empty expecting a default.** PickerField supplies the
shell and the responsive overlay, not the picker itself — the calendar, time grid, or whatever else
opens is entirely the caller's to build and pass in.

**Never add a second way to open the picker.** Opening on focus, on hover, or on any trigger besides
the trailing button breaks the same rule the shell states: typing has to stay possible, so the field
itself must never become picker-only.

**Let `onTextCommitted` do the parsing, on blur and Enter — not `onTextChanged` on every
keystroke.** The commit callback is where a typed string becomes a real value; treating every
keystroke as a parse attempt will reject perfectly good input mid-type.

## Axes

### Presentation
Anchored `Menu` popover above the shared breakpoint, `Sheet` below it — chosen automatically by
viewport width, not by the caller.

### State
The same `FieldShell` rest / focused / filled / error / disabled states, inherited through
`PickerFieldShell`.

## Tokens used

Everything visible belongs to `PickerFieldShell` (the box, label, border states) or to `Menu`/`Sheet`
(the open overlay) — see those pages.

## Source

`lib/src/forms/picker_field.dart`
