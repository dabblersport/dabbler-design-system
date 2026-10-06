<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/navigation_activity.dart (class dartdoc in full —
           colours table, the indicator-never-doubled rule, lifecycle,
           accessibility; DabblerNavigationActivityPresentation)
           lib/src/feedback/action_area_gallery.dart (specimen titles:
           "NavigationActivity — spinner", "NavigationActivity — progress")
           Design: components/feedback/status-feedback.card.html, sections
           "Spinner", "ProgressBar", "Action Area · system states"
-->

# NavigationActivity
### `DabblerNavigationActivity`

NavigationActivity reports loading and progress on the bottom navigation's action footprint, composing the same Spinner, ProgressBar and progress ring the content column uses.

Collapsed, the brand action circle keeps its fill and its plus is replaced by an on-brand spinner or
a progress ring — the action button, working. Expanded, the circle grows into a card row, the same
surface the create menu uses, carrying a labelled spinner or a progress bar. Nothing new is painted:
every indicator is the system's own. It is built on `ActionArea`.

## Specimen

The spinner on the footprint — compact on the brand circle, grown into a labelled card row, and in
Arabic — see `action_area_gallery.dart`'s *NavigationActivity — spinner* section.

@specimen navigation-activity/spinner

Progress: the compact bar with its label and value, the expanded card with a status line, the
indeterminate sweep, and the ring on the footprint with and without a value, plus a live value.

@specimen navigation-activity/progress

## Using it

**Use the compact presentations when the bar should stay usable.** `spinner` and `ring` live in the
collapsed circle, so the destinations beside it stay live; the ring reports progress without
expanding at all.

**Expand when the label matters.** `spinnerLabel` names the work; `progress` shows how far along it
is; `progressExpanded` adds a status line for a longer operation.

**Never add an indicator beside the bar.** Once expanded, the bar is the indicator: the spinner or
ring appears only in the collapsed circle the row grows from. Only the labelled spinner keeps its
glyph, turning from on-brand to brand as it lands on the card.

**Resolve into feedback, don't append to it.** When the work finishes, swap this for
`NavigationFeedback` with the result — the circle changes tone, then expands. There is no failure
or paused state here, by design.

## Axes

### Presentation
`spinner` and `ring` (collapsed), `spinnerLabel`, `indeterminate` and `progress` (rows),
`progressExpanded` (grown to content).

### Value
A fraction from zero to one, or none — the ring then spins and the bars sweep.

### Active
Inactive is idle navigation: the bar alone.

## Direction

**The bar fills from the inline start; the ring is never mirrored.** In Arabic the surface
originates on the left and grows rightward, the labelled spinner leads on the right, the progress
fill runs right to left, and the ring still runs clockwise from twelve o'clock.

## Tokens used

Collapsed: the brand fill with the on-brand ink — the action button's own pair. Expanded: the card
surface, card outline and primary ink — the create menu's. The ring on the footprint is the
footprint inset by the twelve-pixel spacing step on every side. Everything else belongs to the
composed Spinner, ProgressBar and Ring.

## Source

`lib/src/feedback/navigation_activity.dart`
