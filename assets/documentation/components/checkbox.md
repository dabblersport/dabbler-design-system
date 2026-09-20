<!--
Pilot page, D-033 ten-part template, the "hard" case: Checkbox.prompt.md is 5
lines (one description sentence + a code sample) and carries almost nothing
to mine. This page is written directly from the component.

Group    : Selection and input
Sources  : lib/src/forms/checkbox.dart (read in full — dartdoc AND
           implementation, since the prompt.md had nothing to check the
           dartdoc's claims against)
           lib/src/forms/forms_gallery.dart:380-387 (specimen contents)
           DECISIONS.md — grepped for "Checkbox": no entry rules this
           component; Change log section omitted per D-033's own rule
           ("omitted where none does, which is itself informative") and
           D-034(a)'s general "omit, never stub" principle.

Direction section REMOVED 2026-09-18 per D-036: checkbox.dart reads
Directionality exactly once (line 132), only to resolve the type face via
resolveForDirection — script selection is a Foundations fact (documented once
on Bidirectionality), never a per-component one. The row's mirroring is
uniform (Directionality's own default), not an exception to mirroring or a
semantic consequence of it, so it does not qualify under either of D-036's
two inclusion families.
-->

# Checkbox
### `DabblerCheckbox`

Checkbox is a flat, independent on/off control for one item in a set where any number of items can
be selected at once.

The box is 24px, filled with the brand colour when checked and outlined and empty when not — flat,
never glass, because content controls stay opaque in this system. Each Checkbox is its own value:
there is no group behaviour and no indeterminate state. The whole row, box plus label, is the tap
target, and the box moves to the other side of the label automatically under Arabic with no
direction-specific code.

## Specimen

Unchecked, checked, disabled unchecked, and disabled checked, each with the label "Recurring" —
see `forms_gallery.dart`'s *Checkbox* section.

## Using it

**Use Checkbox only where selections are independent.** Each box answers one yes/no question on
its own; if the choices in a group are mutually exclusive, that is Radio, not several Checkboxes.

**Do not build a tri-state or indeterminate Checkbox.** The control has two states, on and off, by
design — a "some but not all" state is a different control this system does not currently have,
not a variant of this one.

**Give every Checkbox a visible or accessible label.** The box alone answers "on or off" but not
"of what" — pass `label` for a visible one, or `semanticLabel` where the visible text lives
elsewhere and only the announced name is needed.

**Let the row provide the tap target; do not add your own padding to reach 45px.** The visual box
is smaller than the minimum target on purpose — the row already floors at 45px so the control
stays easy to hit without the box itself growing past what a checkbox should look like.

## Axes

### State
Unchecked, checked, disabled-unchecked, disabled-checked. Disabled drops the whole row to 50%
opacity and takes no input, in either checked state.

@figure 50% lib/src/forms/checkbox.dart#disabledOpacity


## Tokens used

Box fill: `brandPrimary` when checked, transparent when not. Box outline: `brandPrimary` when
checked, `borderDefault` when not. Check mark: `onBrand`. Label: `textPrimary` at the body text
style. Focus ring and the 45px touch-target minimum are the same shared tokens every interactive
control reads.

## Source

`lib/src/forms/checkbox.dart`
