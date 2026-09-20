<!--
Component page, D-033 ten-part template.

Group    : Date and time
Sources  : lib/src/calendar/calendar.dart:1-135 (DabblerCalendarMonth —
           weekdayOrder, defaultFirstWeekdayFor confirmed directly, not
           assumed), :222-332 (DabblerCalendar's full class dartdoc through
           contrast/touch-target section), :870-883 (the Confirm/Cancel
           action row — re-read 2026-09-20 after KAN-279; Cancel now passes
           DabblerButtonTone.text and DabblerCalendarTextAction is gone)
           lib/src/calendar/calendar_gallery.dart:15 (specimen title:
           "Calendar — month grid")
           DECISIONS.md D-023 (read in full, prior session — the action-row
           sizing correction and the `text` tone, since shipped), D-030 (read in
           full this session), D-032 (read in full this session — the
           date-cell pitch correction, not yet shipped)

RESOLVED 2026-09-20. This page carried a FINDING that DabblerCalendarTextAction
still existed, deleted only once D-023's Button `text` tone shipped — which was
blocked on KAN-261 having no assignable executor. KAN-279 (`a90a784`) shipped
the tone and deleted the stand-in. Re-measured for this correction rather than
taken from the commit: `calendar.dart:880` passes DabblerButtonTone.text for
Cancel, Confirm takes the default `primary` (`button.dart:193`), and
DabblerCalendarTextAction appears nowhere in lib/ or test/. Both tones are now
pinned in `test/calendar/calendar_test.dart`.

Direction: DabblerCalendarMonth.defaultFirstWeekdayFor(TextDirection) is a
real nuance worth getting right — it is NOT the same as "the caller must
always supply the locale's week start." It's a fallback the widget applies
when the caller passes nothing (Monday under LTR, Saturday under RTL),
explicitly documented as extension beyond the source and explicitly NOT a
locale lookup — direction and locale aren't the same thing, and a caller
serving a real locale should still pass firstWeekday explicitly. Stated
carefully below rather than repeating the flattened "week start is a locale
fact the caller passes" framing from earlier in this project.
-->

# Calendar
### `DabblerCalendar`

Calendar is the month grid — header, weekday labels, selectable dates, and an optional Confirm/
Cancel footer — used as-is by every date-picking surface in this system.

It raises no overlay of its own; `DateField` and `PickerField` each attach it through their own
open/close seam, and a chosen date reports back through the same path typing does. Selection is a
plain set of dates rather than the design source's list of day numbers, specifically because a day
number alone can't tell a selected day in the shown month from the same day number in a neighbouring
month the grid also renders — the set is otherwise exactly as arbitrary and non-contiguous as the
source's own list.

## Specimen

A month grid with selection — see `calendar_gallery.dart`'s *Calendar* section.

## Using it

**Never fork Calendar for a field-specific variant.** `DateField`, `PickerField` and any future date
picker all use this same widget as-is — a field that needs different calendar behaviour is a
calendar limitation to raise, not a reason to build a second grid.

**Pass `firstWeekday` explicitly for a real locale rather than relying on the built-in default.**
The widget falls back to Monday under LTR and Saturday under RTL when nothing is passed, but that
fallback is a documented convenience extension beyond the design source, not a locale lookup —
direction and locale aren't the same fact, and a screen serving a specific locale's actual week
start should pass it rather than assume the direction-based guess is correct for that locale.

**Interpret a set of selected dates as exactly that — plain, arbitrary dates — never as an implied
range.** This widget never treats the set as a span; a composer that wants range behaviour (a start
and an end) builds that interpretation on top rather than assuming the widget provides it.

**Build the action row out of `Button`, not a Calendar-specific action widget.** There used to be
one — `DabblerCalendarTextAction`, a stand-in for a `Button` `text` tone that did not exist
yet — and it is gone: the tone shipped and the row now uses it directly. Cancel is `text`,
Confirm is the default `primary`. Reaching for a component-local button here would re-create
exactly the scaffolding that was just removed.

## Axes

### Selection
A set of selected dates, or none.

### Footer
Confirm/Cancel action row, or none.

## Direction

**Four separate facts, only one of which is this widget's own addition rather than inherited
`Directionality` behaviour.** (1) The seven weekday columns run right-to-left under Arabic because
they're an ordinary row under the ambient direction — nothing reverses a list to achieve this. (2)
The previous/next header controls swap position for free the same way, but their glyphs are
explicitly swapped for different icon names rather than mirrored, the same directional-glyph
pattern this system uses everywhere a glyph would otherwise flip its optical weight incorrectly.
(3) "Next" always moves forward in calendar time regardless of direction — RTL changes where the
control sits and which way its arrow points, never which month it goes to. (4) Numerals stay
Western Arabic in both scripts.

*Confirmed by reading `calendar.dart` directly — all four facts are stated explicitly in its own
class dartdoc, including the same optical-weight reasoning behind the glyph swap. Not yet checked
against the gallery's direction switcher.*

## Tokens used

Day text: `textPrimary` (a corrected deviation from a design value that failed contrast on this
card). Selected day: `onBrand` on `brandPrimary`. Outside-month day: `textSecondary` (also a
corrected deviation). Weekday label: `textPrimary` (corrected from a design value found to fail
contrast).

## Change log

- D-023 (cxo) — rules the Confirm/Cancel action row adopts
  `Button` at its `medium` size, and rules a tenth `Button` tone, `text`, for this widget's action
  row. Shipped by KAN-279 (`a90a784`), which also deleted the `DabblerCalendarTextAction` stand-in.
  This page described it as blocked until 2026-09-20, which was true when written and is not now.
- D-030 (cxo) — confirms no drawn ruler is required on the
  paired `TimePicker`, because the design bundle itself doesn't draw one.
- D-032 (cxo) — rules the date-cell touch target should paint
  at 39 and claim a 42px vertical pitch rather than growing to a full 45, a bounded exception for a
  contiguous grid of peer targets where overlapping hit boxes would select the wrong date. **Not yet
  shipped** — cells currently grow to the full 45px floor.

## Source

`lib/src/calendar/calendar.dart`
