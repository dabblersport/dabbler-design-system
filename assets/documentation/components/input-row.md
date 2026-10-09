<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/input_row.dart (read in full — class dartdoc,
           DabblerInputRow and DabblerChevron classes)
           lib/src/forms/forms_gallery.dart:665-684 (specimen contents)
           DECISIONS.md D-003 (full read, prior session), D-027 (full read,
           prior session)

RESOLVED by D-037 (2026-09-18): the open question was right not to guess at.
D-027 is the chevron's authority (D-003 remains the subtitle's — the file's
own citation was stale on the chevron specifically), AND the shipped paint
is a real, ruled DEFECT, not a stricter-but-safe choice: the drawing gives
the subtitle and the chevron two different weights (ink-soft / subtle) and
painting both at textSecondary collapses that hierarchy. Ruled: the chevron
must become textTertiary; the subtitle stays textSecondary. Not yet shipped
(po ticket pending) — this page still describes current code (both
textSecondary) but states the defect plainly rather than as an open
question. `--subtle` itself stays unexposed in Dart either way — see the
Colour foundation page.

Direction section REMOVED 2026-09-18 per D-036 — BORDERLINE CALL, flagged to
team-lead rather than fully confident. DabblerChevron.iconNameFor swaps to a
different icon NAME per direction (arrow-right-3/arrow-left-2) instead of
transforming one glyph, specifically to avoid flipping the glyph's optical
weight. The visual RESULT is still uniform mirroring (the row reverses, the
chevron points the new direction, its meaning — "this discloses/proceeds" —
never changes), which is what D-036 excludes; it doesn't hold an LTR/RTL
order against its surroundings (family 1) and carries no state/value meaning
(family 2). Read strictly, out. But it's not one of D-036's own worked
examples and the *mechanism* (name swap, not transform) is a real,
non-obvious implementation fact a developer might want — arguably more a
dartdoc concern than a reader-facing Direction fact, per this doc's own
distinction between the two. Removed under the strict reading; flagged as
the closest call in this pass.
-->

# InputRow
### `DabblerInputRow`, `DabblerChevron`

InputRow is the settings-list row — a leading slot, a one- or two-line text column, and a trailing
slot, tappable or not.

It lives in the design bundle's layout group but is functionally a forms helper, which is why it's
grouped here rather than there. It does not compose `FieldShell` — the two disagree on nearly every
value the shell owns (fill, radius, padding, row gap), so building InputRow on top of it would mean
overriding almost everything the shell provides. It composes the same surface, press and focus
primitives every other tappable surface in this system does instead.

## Specimen

A title-only row, a row with a subtitle, a row with a trailing chevron, a row with a trailing
toggle, and a disabled row — see `forms_gallery.dart`'s *InputRow* section.

@specimen input-row

## Using it

**Do not compose `FieldShell` under an InputRow.** It was tried and does not fit: the two disagree
on fill, radius, padding and row gap, and the shell's label/helper/error chrome has nothing to do
with what a settings row shows. The one thing InputRow actually needs from `FieldShell` — the 45px
floor — comes from the same shared token directly, not from the shell itself.

**A row with neither `title` nor `subtitle` is a valid bare leading/trailing pair, not a mistake.**
The component allows it deliberately; don't add a placeholder title to satisfy an assumption the
component doesn't have.

**Let `title` and `subtitle` merge into the row's own accessible name; only override it when the
visible text genuinely doesn't describe the action.** Setting `semanticLabel` *replaces* the
announced name rather than adding to it — set it only when you mean to replace, not to supplement.

**Do not rely on the chevron reading lighter than the subtitle today — that hierarchy is a known,
ruled defect, not current behaviour.** The design draws the chevron lighter than the subtitle text
beside it; the shipped component currently paints both the same weight, which is a real fidelity
loss pending a fix. See *Change log*.

**Dense is the Settings rhythm.** Pass `dense: true` for the Settings rows: a 15/20 title over a 12/17 subtitle with a 2-point gap, in a row at least 56 tall. It changes the rhythm only; slots, tone and semantics are unchanged.

**Emoji exception (KAN-478).** `emoji` draws an emoji in the leading position, before the title in reading direction (on the right in Arabic): a 20px glyph on a 25px line in a 26-wide centred box, then the 12 gap — the Create Post sport row (`Home Feed.dc.html:742`). The design system otherwise draws no emoji; this is a documented exception, granted by CEO ruling 2026-10-09 for the Create Post surface only, the same as `DabblerChip.emoji` and `DabblerBadge.emoji`, and not a general permission. With both `leading` and `emoji`, the order is `leading`, emoji, title. The emoji never changes the row's height, is decorative (the title is the accessible name), and defaults to null, so every existing row is unchanged.

## Axes

### Content
Title only, title and subtitle, bare leading/trailing (no text at all).

### Interactivity
Tappable (`onTap` set — gets press scale and focus ring) or inert (`onTap` null).

### Trailing slot
A `DabblerChevron` (disclosure), a control like `Toggle`, or a badge — any widget.

### Rich title and badge
`titleSpan` is the alternative to `title` for a highlighted search match;
`DabblerInputRow.highlightSpan` builds the same treatment `DabblerHighlightedText` draws, and the
row announces the span's plain text. `titleBadge` (any widget) or `verified` (the bold `verify`
mark in the brand colour, labelled for assistive technology) sits right after the title.

### Value
`value` is the summarised destination from Settings: a single line in the secondary text colour,
capped in width and ellipsised, drawn before the chevron. A tappable row with a value and no
`trailing` gets the chevron for free.

@figure 150 lib/src/forms/input_row.dart#valueMaxWidth

### Tone
`DabblerInputRowTone.destructive` puts the title (semibold), the leading glyph and the chevron in the
error role's strong step — Sign out and Delete account. The subtitle stays in the secondary text role.

### Selection
`selected` null is an ordinary row. `true` draws the bold `tick-circle` in the brand colour and
marks the node selected; `false` marks it unselected with no tick — for option lists.

### Info and toggle
`DabblerInputRow.toggle` composes an optional info button and a `DabblerToggle` in the trailing
slot. They stay two separate controls, each with its own accessible name; the row itself is not
tappable.

### Trailing chips
`trailingChips` lays chips on one line that never wraps. When the row is too narrow, the strip
scrolls inside its share of the row instead of overflowing, and under right-to-left it starts at
the right edge.

### Flat
`flat: true` drops the card: no sunken fill, no corner and no inline padding, so the row runs to
its parent's gutter. It is the row for picker lists inside sheets and pages — the location
picker in the Listings design. A hairline in the faint divider colour runs under each flat row;
`showDivider: false` drops it on the last row or where the list draws its own separators. Type,
slots, tone, selection and the minimum height are the boxed row's.

### Chevron direction
The chevron is the design's bare open chevron. Under right-to-left it swaps to the glyph that is
its exact pixel mirror rather than flipping, and a test re-renders the pair so the two cannot
drift apart.

## Tokens used

Destructive tone: the error role's strong step. Value: the footnote style at `textSecondary`
(Deviation: the design's value is one step larger than any ramp entry, so it takes the nearest).
Verified mark: the small icon step (Deviation: the design draws it smaller than any icon step).

Title: the subheadline type style, unmodified. Subtitle: the footnote type style at `textSecondary`.
Chevron: currently `textSecondary`, overridable per instance — **ruled to become `textTertiary`,
not yet shipped** (see *Change log*). Row minimum height and press/focus behaviour are the same
shared tokens and primitives every other tappable surface reads.

## Change log

- KAN-478 — adds `emoji`: an optional leading emoji slot (20px glyph, 25px line, 26 wide) for the Create Post sport rows, a documented Create-Post-only exception to the no-emoji rule (CEO ruling 2026-10-09). Default null; existing rows unchanged.
- Alpha fidelity (Search) — adds `titleSemibold`: the title in semibold, as the View all people row draws it.
- KAN-426 (final) — adds `DabblerInputRow.option(title:, selected:, onTap:, textDirection:)`: the sheet option row of the Language and Region lists. `bodyRelaxed` title (400, 600 selected), 9x3 padding around a 52px content box and the 1px hairline, 71 tall, with a bold 22px `tick-circle` while selected. `textDirection` sets the title's own direction so a native-script name sits flush to its own end inside a left-to-right list.
- Alpha fidelity (Settings) — `DabblerChevron.circled`: the disclosure glyph inside its ring, which the Settings frames draw (`Settings.dc.html:97, 134, 269`).
- D-003 (cxo) — the subtitle's colour: text under WCAG, so it
  takes `textSecondary`, never a surface-neutral role.
- D-027 (cxo) — the chevron is not text at all, and is
  permitted a lighter, non-informational tint in the design source.
- D-037 (cxo) — settles which of the two rulings governs the
  chevron (D-027) versus the subtitle (D-003), and rules the shipped paint a real defect: the
  chevron must move to `textTertiary` to restore the weight difference the drawing gives it against
  the subtitle. Not yet shipped.

- DS gaps 6 — `flat` and `showDivider` added. The chevron's glyphs corrected to the bare
  chevron and its measured mirror; the previous pair drew a boxed chevron in one direction and a
  shafted arrow in the other.
- Added `dense`, the Settings row rhythm.

## Source

`lib/src/forms/input_row.dart`
