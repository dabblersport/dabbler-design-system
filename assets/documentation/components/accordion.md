<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/layout/accordion.dart (read in full through the state
           class start — DabblerAccordionVariant, DabblerAccordionItem,
           DabblerCollapse and DabblerAccordion's class dartdoc/constructor)
           lib/src/layout/accordion_gallery.dart:20 (specimen title:
           "Accordion — plain, card, and the Collapse under it")
           DECISIONS.md — grepped "Accordion": no ruling touches this
           component.
-->

# Accordion
### `DabblerAccordion`, `DabblerCollapse`

Accordion is collapsible sections for content that's secondary but not hidden — FAQs, venue rules,
refund terms — built on `DabblerCollapse`, the system's one expand/collapse animation.

Single section open at a time by default; `multiple` allows several at once. It can be controlled
(pass `value`, a single id or a list of ids under `multiple`) or left to hold its own state. The
underlying collapse animation never measures a height in code — it reveals a fraction of the
child's own intrinsic size, so content of any length animates correctly with nothing hard-coded.

## Specimen

Both variants, with `DabblerCollapse` shown underneath them — see `accordion_gallery.dart`'s
*Accordion* section.

## Using it

**Compose `DabblerCollapse` for any other expand/collapse animation in the system — never hand-roll
a height transition.** It's the one collapse primitive this system has, specifically so an
animated-height bug only has one place to exist.

**Match `value`'s shape to `multiple`: a single id when it's false, a list of ids when it's
true.** Passing the wrong shape for the mode is a contract mismatch, not a supported configuration.

**Use `card` when each section should read as its own surface, `plain` when they should read as one
continuous column.** `plain` separates items with a faint rule; `card` wraps each in the standard
card surface with a gap between them — reaching for the wrong one changes whether the sections read
as one list or several distinct panels.

## Axes

### Variant
`plain` (inline, faint rules between items), `card` (each item its own card surface, gapped).

### Open mode
Single-open (default) or `multiple`.

### Section content
Title (required), body (revealed by `DabblerCollapse`), optional leading icon.

## Tokens used

Leading icon and title: `brandPrimary` and `textPrimary`. `card` variant items: card surface fill
with a `borderDefault` hairline. `plain` variant items: separated by a `bgTertiary` faint rule
instead of a surface.

## Source

`lib/src/layout/accordion.dart`
