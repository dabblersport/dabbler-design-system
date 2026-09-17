<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/radio.dart (read in full through the class dartdoc
           and constructor)
           lib/src/forms/forms_gallery.dart:395-399 (specimen contents)
           DECISIONS.md — grepped "Radio": no entry rules this component.

Direction section REMOVED 2026-09-18 per D-036, same reasoning as Checkbox:
radio.dart reads direction only to resolve the type face, and its mirroring
is uniform — not an exception to mirroring, not a semantic consequence.
-->

# Radio
### `DabblerRadio`

## Definition

Radio is a single-choice control for one option in a mutually exclusive set — there is no group
component, because the exclusivity lives in the state the caller already holds.

## Intro

A visual group of radios is just several `DabblerRadio`s reading and writing one shared value; a
tapped radio fires its change as `true` and is never told to fire `false`, because a radio is only
ever deselected by another one being selected. The ring thickens rather than just changing colour
on selection, and everything about the row — target size, gap, RTL — matches Checkbox exactly.

## Specimen

Three mutually exclusive options with one selected, plus a disabled unselected and a disabled
selected option — see `forms_gallery.dart`'s *Selection* section.

## Using it

**Do not build a `RadioGroup` component.** Mutual exclusivity is state the caller already owns —
one variable, several radios reading it, each `onChanged` writing the new value back. A wrapper
component would duplicate state the app already has.

**Never call `onChanged` with `false`.** A radio only ever reports being selected; deselection is
what happens to the *other* radios in the set when one of them is selected instead.

**Give every Radio a visible or accessible label**, the same rule as Checkbox and for the same
reason: the circle alone answers "selected or not," not "of what."

## Axes

### State
Unselected, selected, disabled — unselected and selected variants of each.

## Tokens used

Ring: `brandPrimary` when selected, `borderDefault` when not. Dot: `brandPrimary`. Label:
`textPrimary`. Focus ring and the 45px touch-target minimum are the same shared tokens every
interactive control reads.

## Source

`lib/src/forms/radio.dart`
