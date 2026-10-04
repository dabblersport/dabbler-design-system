<!--
Component page, D-033 ten-part template.

Group    : Date and time
Sources  : lib/src/forms/date_columns.dart (class dartdoc)
           lib/src/forms/date_columns_gallery.dart (specimen
           "DateColumns — day, month and year in three lists")
           design: Auth and Onboarding.dc.html:569-586, :1815-1824
-->

# DateColumns
### `DabblerDateColumns`

DateColumns is a date picked from three side-by-side scrolling lists: day, month and year.

A birth year is decades back, so a calendar grid is the wrong tool for a date of birth; listing each part lets the reader jump straight to a year.

## Specimen

Nothing chosen, then a full date — see `date_columns_gallery.dart`'s *DateColumns* section.

@specimen date-columns

## Using it

**Give it localised month names.** `monthNames` is January first, twelve entries; the column shows them as given.

**Reconcile the date yourself.** The columns hold no state and never reject 31 February; the caller owns the rule for the field it feeds.

**Years run newest first.** From `lastYear` down to `firstYear`.

**Don't use it for a date range or for a booking.** A booking date is `Calendar`; a typed or picked field date is `DateField`.

## Axes

### Selection
The chosen option is filled with the brand colour and reads in the on-brand colour at semibold; the others are plain.

### Direction
The columns run in reading order, so Day is at the right in right-to-left layouts. Digits are drawn Western.

## Tokens used

Caption: `caption1` semibold, uppercase, `textTertiary`. Option: `subheadline`, radius `sm`, padding `space3` by `space2`. Columns share the width 1 : 1.4 : 1.2 with `space3` between; each list is 192 tall with `space1` between options.

Deviation: the design's lists are 200px tall; the nearest step is 192.

## Change log

- Alpha fidelity rebuild (auth2) — adds this component.

## Source

`lib/src/forms/date_columns.dart`
