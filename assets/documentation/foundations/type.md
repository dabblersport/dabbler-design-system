<!--
Foundations page, D-034's nine-part template. UNBLOCKED per D-040(c) — the
type specimen shipped (KAN-299).

Sources : lib/src/tokens/dabbler_type.dart:1-65 (class dartdoc in full —
          two roles/two scripts table, the active FREEZE section in full,
          "Structure only" section), :117-235 (the twelve named
          DabblerTypeStyle constants, confirmed by name), :270-290,456
          (numeral feature / toWesternDigits / resolveForDirection —
          confirmed these exist, not assumed)
          lib/src/tokens/dabbler_type_gallery.dart (read in full — the
          three entry titles, the "what is compared against what" table,
          and the D-024 section explaining the outside-the-ramp band and
          the .t-label usage-claim correction)
          DECISIONS.md D-013 (read in full, prior session), D-024 (read in
          full, prior session), D-040 (read in full this session)

NOTE for whenever Bidirectionality unblocks: the four-face/two-role table
and the numeral/script-fork mechanism (numeralFeatures, toWesternDigits,
resolveForDirection) are described here since they're fundamentally Type's
own content, not repeated on Bidirectionality — that page should link here
for the mechanism rather than restate it, per _notes-bidirectionality.md.
-->

# Type

Type is one twelve-step ramp, each step a role rather than a size — and, separately, a live freeze
on adding to it until a three-way split in the design source is resolved.

Every style is a plain compile-time constant, not something that varies by theme — the seven
section themes differ in colour only, never in type. Two roles cover the whole ramp: **display**
(large titles and titles 1–3) and **sans** (everything else), and each role swaps face by script
rather than by theme — Gloock/Wingx for display, Glory/Meral Sans for sans. The two display faces
each ship a single weight, so every title in this system is weight 400 in both scripts; titles
never run light and never run bold.

## Specimen

Three entries — see `dabbler_type_gallery.dart`'s *Type* section: the four faces each set in
themselves, the complete ramp in Latin and Arabic side by side, and weights including the values
drawn outside the ramp entirely.

## Using it

**No new ramp constant may be added to this class right now — there is a standing freeze.** The
design source specifies type three different ways across its components, and which one is actually
the product's type is escalated to the CEO, unresolved. Until it's answered: new work uses the
existing twelve `.t-*` steps; where it genuinely can't, it transcribes the source's literal value
with a comment naming the freeze, the same way `DabblerButton.labelStyle` already does for
its 16/14/12-at-600 — never promote a private, component-specific value into a new ramp step in
the meantime.

**Never transcribe a value from the design's Figma export file.** It's a diagnostic artefact, not
a source of truth — the export and the declared type ramp are two genuinely different scales, not
two spellings of the same one, and the export's numbers have no claim on this class regardless of
how convenient reaching for one would be.

**Treat Button's 16/14/12-at-600 label scale as outside this ramp, not a missing set of three
steps.** It's real, shipped behaviour, and it's shown that way deliberately — labelled as outside
the ramp rather than folded in as though it were three more named styles, because presenting it as
ramp steps would both invent entries the freeze explicitly refuses and hide the very split that's
still unresolved.

**Numerals are always Western Arabic, in both scripts, in every style.** Every resolved style
carries the font feature that stops an Arabic-aware face substituting Indic digit forms at render
time, and any code formatting a number for display runs it through the same digit-folding utility
this ramp provides rather than reaching for a locale-aware formatter.

## Axes

### Role
`display` (large title, titles 1–3 — Gloock/Wingx, weight 400 only), `sans` (everything else —
Glory/Meral Sans, the full weight range).

### The twelve steps
`largeTitle`, `title1`, `title2`, `title3`, `headline`, `body`, `callout`, `subheadline`,
`footnote`, `caption1`, `caption2`, `label` — each a fixed size, leading (with a separate Arabic
leading override where the two scripts diverge) and weight.

### Outside the ramp
Button's own 16/14/12-at-600 label scale — real, shipped, and explicitly not a set of ramp steps.

@figure 400 D-013


## Change log

- D-013 (cxo) — confirms `title3` at weight 400 is correct
  system-wide, correcting a one-off inline style in the design source that no other title-bearing
  component followed.
- D-024 (cxo) — measures the three-way type-specification
  split across the design source, rules `typography.css` the sole ramp, and imposes the freeze this
  page describes above.
- D-040 (cxo) — confirms this page's specimen has shipped and
  ships this page.

## Source

`lib/src/tokens/dabbler_type.dart`
