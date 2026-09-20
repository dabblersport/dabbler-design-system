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
different icon NAME per direction (arrow-right/arrow-left) instead of
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

## Axes

### Content
Title only, title and subtitle, bare leading/trailing (no text at all).

### Interactivity
Tappable (`onTap` set — gets press scale and focus ring) or inert (`onTap` null).

### Trailing slot
A `DabblerChevron` (disclosure), a control like `Toggle`, or a badge — any widget.

## Tokens used

Title: the subheadline type style, unmodified. Subtitle: the footnote type style at `textSecondary`.
Chevron: currently `textSecondary`, overridable per instance — **ruled to become `textTertiary`,
not yet shipped** (see *Change log*). Row minimum height and press/focus behaviour are the same
shared tokens and primitives every other tappable surface reads.

## Change log

- D-003 (cxo) — the subtitle's colour: text under WCAG, so it
  takes `textSecondary`, never a surface-neutral role.
- D-027 (cxo) — the chevron is not text at all, and is
  permitted a lighter, non-informational tint in the design source.
- D-037 (cxo) — settles which of the two rulings governs the
  chevron (D-027) versus the subtitle (D-003), and rules the shipped paint a real defect: the
  chevron must move to `textTertiary` to restore the weight difference the drawing gives it against
  the subtitle. Not yet shipped.

## Source

`lib/src/forms/input_row.dart`
