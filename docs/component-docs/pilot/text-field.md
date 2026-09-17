<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/text_field.dart (read in full through line ~174 —
           class dartdoc, DabblerTextFieldVariant enum, constructor and
           field declarations; colour-resolution call sites read directly
           at lines 269, 345-348, 399-405)
           lib/src/forms/forms_gallery.dart:147-151 (specimen description)
           DECISIONS.md D-003 (read in full, prior session)

REAL FINDING, not something I fix (I don't write code) but worth reporting:
text_field.dart's own class-level dartdoc says TWICE, at two different
comments (the class doc's "## Colours" section and the `placeholder` field's
own doc), that the placeholder renders in `--color-text-tertiary`. Checked
the actual colour-resolution code at the real call sites (lines 345-348,
399-405) — both are `colors.textSecondary`, each with an inline comment
citing D-003(a) directly ("a placeholder is text under WCAG"). The
IMPLEMENTATION is correct and matches D-003(a)/D-027; the SUMMARY COMMENTS
are stale and were not updated when the fix landed at the call sites. This
page describes what the code does (textSecondary), not what the summary
comment says (textTertiary) — but the stale comment is a real defect in
`dabbler-design-system` worth a ticket, separate from anything I can fix.
-->

# TextField
### `DabblerTextField`

## Definition

TextField is the flat input for a single line, a search box, a password, a multi-line note, or a
picker's closed shell — five shapes, one component.

## Intro

Every visible part — the label, the bordered box, the four border states, the helper or error
line — belongs to `FieldShell`. TextField contributes the input itself, each variant's own
affordance, and the two pieces of state the shell can't know on its own: whether it has focus, and
whether a password is currently revealed.

## Specimen

All five variants, each closed and — for `select` — open — see `forms_gallery.dart`'s *TextField*
section.

## Using it

**Reach for the variant, not a manually composed field.** `search` supplies its own leading glyph,
`password` its own trailing reveal toggle, `select` its own trailing arrow — building one of these
by hand out of `standard` plus a prefix/suffix icon duplicates behaviour the variant already owns
and will drift from it.

**A placeholder is text, and reads at the same secondary-text colour as anything else a person is
meant to read.** It is not decoration and it is not de-emphasised past body-text contrast — this
matters because at least one other doc comment in this codebase still states the older, incorrect
rule; don't repeat it.

**Do not fire `onSubmitted` from a multiline field expecting an Enter-to-submit behaviour.** Enter
inserts a newline in `multiline`; the callback is never called from that variant.

**Give `initialValue` or a `controller`, never both.** They're mutually exclusive ways of seeding
the same text — passing both is a contract violation the widget asserts against.

## Axes

### Variant
`standard` (plain single line), `search` (leading search glyph), `password` (obscured, trailing
reveal toggle), `multiline` (top-aligned, the one variant on a smaller corner radius), `select` (not
an input at all — the same shell rendered as a button with a rotating trailing arrow; every picker
in the system reuses this as its closed shape).

### State
Rest, focused, filled, error, disabled — the same five `FieldShell` states, inherited rather than
redefined.

## Tokens used

Leading icon: `brandPrimary`. Trailing icon and the password toggle: `textSecondary`. Value:
`textPrimary`, or `textTertiary` while disabled. Placeholder: `textSecondary` (see the note in
*Using it*). Everything else — label, border states, helper/error line — comes from `FieldShell`.

## Change log

- [D-003 (cxo)](../../../dabbler-docs/DECISIONS.md) — rules the placeholder-is-text finding this page's
  *Using it* section states; the two call sites in this file already carry it correctly, though the
  file's own class-level comments have not been updated to match.

## Source

`lib/src/forms/text_field.dart`
