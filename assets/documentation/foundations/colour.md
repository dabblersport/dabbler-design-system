<!--
Written to D-033's ten-part template as adapted by D-034, which ruled on the
two frictions this page raised in pilot: Foundations pages use a NINE-part
template (Title/Definition/Intro/Specimen/Using it/Axes/Direction/Change
log/Source) with NO "Tokens used" section at all — not stubbed, omitted, per
D-034(a)'s general "omit, never stub" rule.

UNBLOCKED 2026-09-18 per D-040(c): the colour specimen shipped —
lib/src/tokens/dabbler_colors_gallery.dart, 4 gallery entries, confirmed by
reading the file directly (not just team-lead's report). It resolves every
swatch through DabblerColors.of/resolve, prints the resolved (theme,
brightness) pair and which of the fourteen it is on each entry, and renders
the section-theme band across all seven themes side by side at the current
brightness — satisfying D-034(b)'s all-fourteen-pairs requirement by
construction. Its own dartdoc states it computes contrast live rather than
typing a table, which is D-037(c) satisfied by construction rather than by
a writer's discipline — exactly what that rule was for, per D-040(c). This
page now SHIPS.

Section  : Foundations
Page     : Colour
Sources  : lib/src/tokens/dabbler_colors.dart (read in full to line 254)
           lib/src/tokens/dabbler_colors_gallery.dart (read in full — the
           four entry titles and the dartdoc's own description of what each
           draws against which design-source guideline page)
           dabbler-design-system-design/project/guidelines/FOUNDATIONS.md
           DECISIONS.md D-003, D-004, D-025, D-027, D-028, D-034, D-037,
           D-040

REVISED 2026-09-18 per D-037(c): a documentation page never transcribes a
measured figure (a contrast ratio, a hex value) into prose — it computes at
render or links the source that does. Removed four transcribed ratios
(3.36:1, 2.15:1, 9.13:1, 10.37:1) from Using It, replaced with qualitative
statements (fails/clears AA) plus a pointer to the ruling. Also corrected
the glyph exception per D-037(b): `--subtle` is not exposed as a
DabblerColors role AT ALL — the practical non-informational-glyph role in
Dart is `textTertiary` (`--muted`), bounded to directional/non-meaningful
glyphs only, never a glyph that carries meaning. The previous wording said
"`--subtle` may still colour a glyph," which was correct about the design
source's own token layer (D-027(a)) but wrong for what a Dart consumer can
actually reach.
-->

# Colour

Colour is consumed by **role name**, never by hex — a component asks for `textSecondary` or
`brandPrimary`, and the active theme and brightness decide what that name resolves to.

Every component draws from one shared colour set, resolved for whichever of the seven section
themes (`main`, `sport`, `social`, `active`, `bright`, `simple`, `shade`) and two brightnesses is
active — fourteen pairs in total, all built from the same role names. A theme re-tints the
**brand** layer only; the paper underneath it — backgrounds, surfaces, text, borders — is shared
across all seven. Status colour (`success` / `warning` / `error` / `info`) is a separate,
contrast-audited system from decorative colour (a card tone, a tag), and the two are never
interchangeable — see *Status colour* below and the Badge page for the decorative set.

## Specimen

Four entries — see `dabbler_colors_gallery.dart`'s *Colour* section: brand ladders and all seven
section themes resolved side by side; surfaces, ink and outline; status, tags and decorative tones;
and contrast, measured live rather than typed. Every semantic swatch resolves through
`DabblerColors.of`, and each entry opens with the resolved `(theme, brightness)` pair and which of
the fourteen it's showing — switch theme or brightness in the gallery header and the grid repaints.
The brand primitives are the one deliberate exception: they're the literal-hex layer and don't
resolve, which is itself part of what the specimen shows.

## Using it

**Never draw body text or a placeholder in `textTertiary`.** It fails ordinary text contrast and
clears AA only at large sizes (24px and up, or 18.66px bold and up) — its legitimate uses are large
text, icons, non-informational rules, and a disabled control's text. For the measured ratio, see
the ruling linked in *Change log* rather than a number restated here.

**`textTertiary` may colour disabled text, but contrast is never the only signal that a control is
disabled.** Pair it with a second cue — reduced opacity, a distinct fill, a changed cursor —
because a reader cannot tell "dim because unavailable" from "dim because someone chose a weak
colour" from contrast alone.

**`textTertiary` may also colour a non-informational directional glyph — a chevron, an empty
rating star — but never a glyph that carries meaning on its own, like a status icon or a sport
mark.** This is a narrow, bounded exception, not a general licence for "glyphs are exempt from the
text rule." A glyph that is the only place a fact is stated is text, and follows the text rule
above instead.

**No role in this system's Dart-consumable set is dim enough to draw placeholder or secondary body
text and still pass — reach for `textSecondary` for both, never anything dimmer.** The design
source's own token file declares a still-lighter neutral for surface and divider use, but it is not
exposed as a `DabblerColors` role at all, and no future component should reach for it as if it were
one — a role that light needs a request to `cxo`, not a workaround at the call site.

## Axes

### Paper
Shared by all seven themes at a given brightness: `bgPrimary` (app background), `bgSecondary`
(tonal background), `bgTertiary` (faint fill / divider), `surfaceCard` (elevated card, sheet, tab
bar), `surfaceSunken` (tonal card, list row), `surfaceGrey` (neutral inset panel).

### Text
`textPrimary`, `textSecondary` (the only secondary body-text role), `textTertiary` (large text,
icons and inactive controls only — see *Using it*).

### Border
`borderDefault` (card outline), `borderStrong` (emphasised outline).

### Brand and accent
`brandPrimary` / `brandPrimaryHover`, `onBrand` (the ink that sits on `brandPrimary`), `accent` /
`accentHover`, `onAccent`, `focusRing` — these re-tint per theme; everything above does not.

### Status
Four tones — `success`, `warning`, `error`, `info` — each carrying four roles together as one
value: `base` (the bare indicator), `surface` (tint background), `strong` (status ink, legible on
`surface` and on a neutral card), `solid` (the fill that carries white text). A status is passed as
this set, never as a single `Color` — see the Badge and Banner pages for where it is consumed.

### Other
`spotlight` (the single attention accent — never a status), `scrim` (the wash behind every
overlay).

## Change log

- [D-003 (cxo)](../../../../dabbler-docs/DECISIONS.md) — the six failing colour pairings: the light ramp
  is not reopened, the dark ramp's structure is corrected, and `--muted` / `--subtle` were never
  text roles.
- [D-004 (cxo)](../../../../dabbler-docs/DECISIONS.md) — `--accent-indigo` is an omission from
  `colors.css`, not a value to transcribe from the export file.
- [D-025 (cxo)](../../../../dabbler-docs/DECISIONS.md) — disabled text stays on `textTertiary`, bounded so
  contrast is never the only signal.
- [D-027 (cxo)](../../../../dabbler-docs/DECISIONS.md) — `--subtle` is still not a text role; the
  glyph-vs-text distinction that bounds its permitted use.
- [D-028 (cxo)](../../../../dabbler-docs/DECISIONS.md) — `--accent-indigo` is a transcription gap, not a
  missing value; Badge is the one site that must not simply be re-pointed to it.
- [D-034 (cxo)](../../../../dabbler-docs/DECISIONS.md) — rules the Foundations page template this page
  follows, and that this page does not ship until its own swatch-grid specimen does.
- [D-037 (cxo)](../../../../dabbler-docs/DECISIONS.md) — bounds `textTertiary`'s non-informational-glyph
  exception to directional/meaningless glyphs only, and rules this documentation never transcribes a
  measured figure into prose.
- [D-040 (cxo)](../../../../dabbler-docs/DECISIONS.md) — confirms this page's specimen has shipped and
  ships this page.

## Source

`lib/src/tokens/dabbler_colors.dart`
