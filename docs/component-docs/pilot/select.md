<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/select.dart (read in full through the "Single and
           multiple" and "RTL" sections, and the constructor pair)
           lib/src/forms/forms_gallery.dart:157-161 (specimen description:
           "Single, multiple, searchable and disabled")
           DECISIONS.md — grepped "Select" (excluding Selected/Selection/
           pricingSelected noise): no ruling touches this component.
-->

# Select
### `DabblerSelect`

## Definition

Select is choosing one or more values from a known list — a `TextField` shell for the closed state,
a `Menu` for the open list, composing both rather than owning either.

## Intro

Nothing about the box geometry, the border states, the list's keyboard handling, its viewport-aware
flipping, or its switch to a `Sheet` below 480px is re-expressed in this file — all of it belongs to
`TextField`'s `select` variant and to `Menu`. Select owns only what neither of those two already
has: the field's own focus stop, and the trip back to the field once the list closes so the next Tab
continues from where the user was.

## Specimen

Single-value, multi-value, searchable and disabled — see `forms_gallery.dart`'s *Select* section.

## Using it

**Compose `TextField` and `Menu` for any picker that isn't exactly this one — never fork either.**
Select's own composition rule doubles as the rule for building a new picker: `Select` is the
`TextField` shell plus `Menu`, and a date, time or duration picker is built the same way rather than
by forking Select or either of its two parts.

**Reach for `DabblerSelect.multiple` when more than one value can be chosen, not for a
single-value select called repeatedly.** The two constructors carry a real behavioural
difference — multiple keeps the list open and toggles membership; single closes and replaces —
which only the `.multiple` constructor implements correctly.

**Let focus return to the field when the list closes; don't manage it yourself.** That return trip
is this component's whole reason for owning a focus node at all — building a custom re-focus
after using Select would fight behaviour it already has.

## Axes

### Selection mode
Single value (closes and replaces on choice) or multiple (`.multiple` constructor — stays open,
toggles membership, chosen rows show a tick).

### Searchable
Present or absent — adds a search field to the open list's header.

### State
The same rest / focused / filled / error / disabled states `TextField`'s `select` variant carries.

## Source

`lib/src/forms/select.dart`
