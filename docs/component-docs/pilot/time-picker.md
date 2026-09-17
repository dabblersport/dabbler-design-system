<!--
Component page, D-033 ten-part template.

Group    : Date and time
Sources  : lib/src/calendar/time_picker.dart:84-182 (DabblerTimePicker's
           full class dartdoc — what's transcribed vs replaced, the DS-602
           seam, keyboard, RTL, touch targets/contrast)
           lib/src/calendar/calendar_gallery.dart:21 (specimen title:
           "TimePicker — hour, minute, period")
           DECISIONS.md D-030 (read in full this session), D-023 (read in
           full, prior session — the same blocked-tone/action-sizing
           treatment as Calendar's)

Direction: NO section. TimePicker's own "RTL" note states explicitly
"nothing in this file reverses a list, and nothing is keyed off direction"
— uniform mirroring throughout, no exception, no semantic consequence.
-->

# TimePicker
### `DabblerTimePicker`

## Definition

TimePicker is the hour, minute and meridiem picker that pairs with `Calendar` — two scrollable
columns and a segmented AM/PM control, not the drag rulers the design source draws.

## Intro

The value set, the default, the nearest-step fold and the Confirm/Cancel footer are all
transcribed exactly. What isn't ported is the drag ruler: the design's own column is a
pointer-driven strip with no keyboard path and no discrete target at all, so there's nothing to
measure a touch target against. Each column is a real listbox instead — accessible rows with
arrow-key navigation this widget drives — with the value semantics completely unchanged.

## Specimen

Hour, minute and period columns — see `calendar_gallery.dart`'s *TimePicker* section.

## Using it

**Never rebuild the design source's drag-ruler interaction on top of this component.** It was
deliberately replaced, not merely reskinned — the ruler has no keyboard path and no measurable
touch target, and reintroducing drag-only selection would reopen exactly the accessibility gap this
component exists to close.

**Let Up/Down skip disabled values rather than landing on them.** A value outside `minimum`/
`maximum` is skipped during arrow-key navigation, never selected and then rejected — build any
custom navigation the same way if you extend this component.

**Expect every move to commit immediately through `onChanged` — there's no staged value to
confirm separately.** The design source commits on every change with no intermediate "pending"
state, and this widget matches that; don't build a UI expecting a value that hasn't been reported
yet.

**Don't rely on `DabblerCalendarTextAction` staying public here either.** TimePicker's own Confirm/
Cancel row uses the same stand-in `Calendar`'s does, for the same reason — see *Change log*.

## Axes

### Value
Twelve hours, twelve five-minute steps, AM/PM.

### Bounds
`minimum`/`maximum` may disable values outside a range; disabled values are skipped, not shown as
selectable and then rejected.

## Tokens used

Row label: `textPrimary` on the card surface. Selected row: `onBrand` on `brandPrimary`. Meridiem
segment: `textPrimary` for the unselected state (a corrected deviation from a design value that
failed contrast on this card).

## Change log

- [D-023 (cxo)](../../../dabbler-docs/DECISIONS.md) — rules the Confirm/Cancel action row adopts
  `Button` at `medium`, and rules the `text` tone this widget's action row is meant to use once it
  ships. **Not yet shipped** — `DabblerCalendarTextAction` is still the stand-in.
- [D-030 (cxo)](../../../dabbler-docs/DECISIONS.md) — confirms no drawn ruler is required, because
  the design bundle itself doesn't draw one — the listbox replacement above is not a deviation from
  a requirement, it's the correct reading of what was actually specified.

## Source

`lib/src/calendar/time_picker.dart`
