<!--
Component page, D-033 ten-part template.

Group    : Identity and status
Sources  : lib/src/surfaces/badge.dart (read in full through the flat/RTL/
           accessibility sections of the class dartdoc and the constructor)
           lib/src/surfaces/badge_gallery.dart:23 (specimen title: "Badge —
           tones and statuses")
           DECISIONS.md D-020, D-028 (both full read), D-029 (full read this
           session)

Direction: NO section. Badge's icon moves to the trailing side in RTL, which
is uniform flow mirroring (family excluded by D-036), and its numeral
handling is a Foundations fact per D-036(b), not a per-component one.
-->

# Badge
### `DabblerBadge`

Badge is the pill that labels a row, a card or a tab — decorative by default, or semantic when
given a real status.

Two separate APIs live on one component. `tone` is decorative and keeps the design file's own
symbol names verbatim, which do **not** describe what they mean — `error` paints purple, `success`
paints black. `status` is semantic: it takes a real status colour set, not a bare colour, and wins
outright whenever both are passed. Reach for `tone` for a purely decorative label and `status` for
one that actually means something.

## Specimen

Every decorative tone and every semantic status — see `badge_gallery.dart`'s *Badge* section.

## Using it

**Never read `tone="error"` as meaning something went wrong, or any other tone name as its literal
meaning.** These names are the design file's own symbol vocabulary, kept verbatim on purpose so
design and engineering say the same word — they are documented as non-semantic, not a bug to
correct. A badge that means something takes `status`, never a tone chosen because its name sounds
right.

**If a badge is the only place a state is shown, name that state somewhere else on the row too.**
A badge is read as plain text with no semantics wrapper — colour and a short pill alone aren't
enough for a state a screen actually depends on the user noticing.

**Do not add a fill override or a size/padding variant to this component.** Both have been asked
for and both were refused — an escape hatch on a shared component is how a system component stops
being one. A badge that needs to look different belongs in a design conversation before it becomes
a new prop.

**Pass `status` as the real status colour set, never a bare `Color`.** This isn't a style
preference — a plain colour can't say which ink goes on it or what hairline it carries, so the type
system refuses one outright.

## Axes

### Decorative tone
Eight: `defaultTone`, `primary`, `success` (black, not green), `warning` (neutral tint, not amber),
`error` (purple, not red), `info` (indigo), `pill`, `withIcon` — several intentionally repaint
identically, kept as separate values because the design file ships them as separate symbols.

### Semantic status
`success`, `warning`, `error`, `info`, plus a `neutral` status built from the paper ramp rather than
the status API, since the design source's fifth status has no declared role there.

### Leading icon
Present or absent.

## Tokens used

Decorative fill/ink vary by tone, with no border on any of them. Semantic fill is the status
surface, ink is the status strong role, and the hairline is that same strong colour at reduced
opacity — the one badge configuration that carries a border at all.

## Change log

- [D-020 (cxo)](../../../../dabbler-docs/DECISIONS.md) — a one-step colour drift in a pricing screen's
  trial pill is not grounds for a fill override on this component; the source is corrected instead.
- [D-028 (cxo)](../../../../dabbler-docs/DECISIONS.md) — Badge is the one site that must not simply be
  re-pointed to the export-only `--accent-indigo` value once it's declared properly.
- [D-029 (cxo)](../../../../dabbler-docs/DECISIONS.md) — reaffirms D-020 after re-checking the premise;
  confirms decorative tones genuinely carry no border, so there was nothing else to reconcile.

## Source

`lib/src/surfaces/badge.dart`
