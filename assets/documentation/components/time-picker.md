<!--
Component page, D-033 ten-part template.

Group    : Date and time
Sources  : lib/src/calendar/time_picker.dart (DabblerTimePicker's class
           dartdoc — what is transcribed vs not ported, the DS-602 seam,
           keyboard, RTL, touch targets/contrast)
           lib/src/calendar/time_ruler.dart (DabblerTimeRuler's class dartdoc)
           lib/src/calendar/calendar_gallery.dart (specimen titles:
           "TimePicker — hour, minute, period", "TimeRuler — opt-in drag ruler")
           DECISIONS.md D-030 (Dabbler/dabbler-docs; read in full), D-023 (the
           action-row sizing correction and the `text` tone)

Direction: the listbox mirrors uniformly under RTL; the opt-in ruler is a
scale and is drawn left to right in both directions.
-->

# TimePicker
### `DabblerTimePicker`

TimePicker is the hour, minute and meridiem picker that pairs with `Calendar` — two scrollable
listbox columns and a segmented AM/PM control.

Each column is a real list of selectable rows with arrow-key navigation, so every option is
announced by name. The value set, the default, the nearest-step fold and the Confirm/Cancel footer are transcribed
from the live design. The live drag ruler is not the default: D-030 keeps the listbox, because the
ruler is pointer-only with no discrete target. A ruler version exists only as the separate,
opt-in `DabblerTimeRuler`, described below.

## Specimen

The listbox picker — hour and minute columns plus the meridiem pill. The second specimen is the
opt-in ruler, which is not the D-030 component.

@specimen time-picker
@specimen time-picker/ruler

## Using it

**Use `DabblerTimePicker` unless you have a reason not to.** It is the D-030 component: the
listbox is keyboard- and screen-reader-native, and it is what a user meets in every other picker
here. Its parameters are `value`, `onChanged`, `minuteStep` (default 5), `visibleRows` (default 3),
`minimum`, `maximum`, `showActions`, the two action callbacks and the accessible-name overrides.

**Let Up/Down skip disabled values rather than landing on them.** A value outside `minimum`/
`maximum` is skipped during arrow-key navigation, never selected and then rejected — build any
custom navigation the same way if you extend this component. Home and End jump to the first and
last enabled value; the keys do not wrap.

**Expect every move to commit immediately through `onChanged` — there's no staged value to
confirm separately.** The design source commits on every change with no intermediate "pending"
state, and this widget matches that; don't build a UI expecting a value that hasn't been reported
yet.

**Build this footer out of `Button` too.** TimePicker's Confirm/Cancel row follows `Calendar`'s
exactly: Cancel is the `text` tone, Confirm is the default `primary`.

**Reach the ruler only by writing `DabblerTimeRuler(...)`.** It is not the D-030 component, and no
drawn source for a scroll-wheel or ruler picker exists. It implements the live `TimePicker.jsx`
Ruler geometry as an opt-in; fidelity to live is unverified and no pixel comparison has been run.
It takes the same value, bounds and callbacks, and adds arrow-key stepping, an adjustable
accessibility role and tap-to-pick on top of the pointer-only source. `DabblerTimePicker` never
builds it.

## Axes

### Value
Twelve hours, twelve five-minute steps, AM/PM. `minuteStep` changes the minute column.

### Bounds
`minimum`/`maximum` may disable values outside a range; disabled values are skipped, not shown as
selectable and then rejected.

### Form
The listbox columns (default), or the opt-in drag ruler (`DabblerTimeRuler`).

## Direction

The listbox columns and the meridiem pill are rows, so right-to-left mirrors them: the hour column
sits on the right. Numerals stay Western Arabic and the meridiem stays the literal `AM`/`PM`. The
opt-in ruler is a scale: it ascends to the right in both directions, as the live CSS does.

## Tokens used

Row label: `textPrimary` on the card surface. Selected row: `onBrand` on `brandPrimary`. Meridiem
segment: `textSecondary` for the unselected state (the live `--muted`, mapped under D-003(a)). The
ruler adds `textPrimary` numerals fading to 20% by distance, with the centred numeral and window in
`brandPrimary`.

## Change log

- D-023 (cxo) — rules the Confirm/Cancel action row adopts `Button` at `medium`, and rules the
  `text` tone this widget's action row uses. Shipped by KAN-279 (`a90a784`). Pinned in
  `test/calendar/time_picker_test.dart`.
- D-030 (cxo) — rules the listbox correct and not rewritten, and that a scroll-wheel picker would
  come back as a new component with a drawn source and a keyboard contract. The default stays the
  listbox; the ruler is a separate opt-in class, pinned in `test/calendar/time_ruler_test.dart`.

## Source

`lib/src/calendar/time_picker.dart` (the listbox picker) and `lib/src/calendar/time_ruler.dart`
(the opt-in ruler).
