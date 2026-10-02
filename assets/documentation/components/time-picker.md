<!--
Component page, D-033 ten-part template.

Group    : Date and time
Sources  : lib/src/calendar/time_picker.dart:84-182 (DabblerTimePicker's
           full class dartdoc — what's transcribed vs replaced, the DS-602
           seam, keyboard, RTL, touch targets/contrast)
           lib/src/calendar/calendar_gallery.dart:21 (specimen title:
           "TimePicker — hour, minute, period")
           DECISIONS.md D-030 (read in full this session), D-023 (read in
           full, prior session — the action-row sizing correction and the
           `text` tone, since shipped; the same treatment as Calendar's)

Direction: NO section. TimePicker's own "RTL" note states explicitly
"nothing in this file reverses a list, and nothing is keyed off direction"
— uniform mirroring throughout, no exception, no semantic consequence.
-->

# TimePicker
### `DabblerTimePicker`

TimePicker is the hour, minute and meridiem picker that pairs with `Calendar` — two horizontal
drag rulers under a fixed centre window and a segmented AM/PM control, as the live design draws it.

The value set, the default, the nearest-step fold, the ruler geometry and the Confirm/Cancel footer
are compared value-by-value against the live `TimePicker.jsx`. The ruler's source is pointer-only,
so each ruler also takes arrow-key navigation, an adjustable accessibility role and tap-to-pick.

## Specimen

Hour, minute and period columns — see `calendar_gallery.dart`'s *TimePicker* section.

@specimen time-picker

## Using it

**Keep the keyboard and tap paths when you restyle the rulers.** The live ruler has neither; they
were added so the drag-only drawing stays reachable without a pointer.

**Let the arrow keys skip disabled values rather than landing on them.** A value outside `minimum`/
`maximum` is skipped during arrow-key navigation, never selected and then rejected — build any
custom navigation the same way if you extend this component.

**Expect every move to commit immediately through `onChanged` — there's no staged value to
confirm separately.** The design source commits on every change with no intermediate "pending"
state, and this widget matches that; don't build a UI expecting a value that hasn't been reported
yet.

**Build this footer out of `Button` too.** TimePicker's Confirm/Cancel row follows `Calendar`'s
exactly: Cancel is the `text` tone, Confirm is the default `primary`. The shared
`DabblerCalendarTextAction` stand-in both used to carry is gone — see *Change log*.

## Axes

### Value
Twelve hours, twelve five-minute steps, AM/PM.

### Bounds
`minimum`/`maximum` may disable values outside a range; disabled values are skipped, not shown as
selectable and then rejected.

## Tokens used

Numerals: `textPrimary` fading to 20% by distance, the centred numeral and the window in
`brandPrimary`. Meridiem segment: `textSecondary` for the unselected state (the live `--muted`).

## Change log

- D-023 (cxo) — rules the Confirm/Cancel action row adopts
  `Button` at `medium`, and rules the `text` tone this widget's action row uses. Shipped by
  KAN-279 (`a90a784`), which also deleted the `DabblerCalendarTextAction` stand-in. Pinned in
  `test/calendar/time_picker_test.dart`.
- Compared against live `TimePicker.jsx` (2026-10-02): the listbox columns that D-030 had read as
  the correct specification were replaced by the live drag rulers (height 64, pitch 46, window,
  pin, ticks, numeral opacity), keeping keyboard, semantics and tap. D-030 needs a `cxo` re-read.

## Source

`lib/src/calendar/time_picker.dart`
