<!--
Foundations page, D-034's nine-part template. UNBLOCKED per D-040(c) — the
spacing & geometry specimen shipped (KAN-300).

Covers four token classes as one Foundations topic, matching the specimen's
own four-entry structure: DabblerSpacing, DabblerRadius, DabblerSizing,
DabblerElevation.

Sources : lib/src/tokens/dabbler_geometry.dart (read in full for the
          numeric steps: 29-182 spacing/radius/sizing constants;
          200-251 DabblerElevation class through dialogFor)
          lib/src/tokens/dabbler_geometry_gallery.dart (read in full — the
          four entry titles/descriptions, the "what is compared against
          what" table, and the D-018/KAN-261 section explaining why this
          specimen draws a step the live design-source page doesn't yet)
          DECISIONS.md D-011 (read in full, prior session), D-018 (read in
          full, prior session), D-031 (read in full, prior session — the
          one legal shadow), D-040 (read in full this session)

Per team-lead's caution, carried through directly: measurements.html is
the LIVE design-source page (spacing-scale.html and radius-scale.html
mark themselves consolidated into it, source-only). The 16px card-corner
step is real, shipped Dart (D-018) but is not yet drawn in
measurements.html itself — KAN-261 is the unrun design-source half. This
page states that gap using the specimen's own exact label rather than
presenting 16 as though the source already declares it.
-->

# Spacing and geometry

Spacing and geometry are two base-3 numeric ramps and two small sets of fixed exceptions — nothing
in this system is sized off a value that isn't one of these steps.

Spacing is eleven steps on a strict base-3 grid, each usable directly or through one of six named
semantic aliases (a card's own padding, the screen gutter, the gap between sections). Radius is
seven steps, most of them base-3, plus one dedicated card-corner step that sits outside the grid on
purpose. Touch targets, border widths and icon sizes are each a small fixed set rather than a
scale. Elevation is almost entirely absent: this is a flat system, and the one shadow it permits is
reserved for a single component.

## Specimen

Four entries — see `dabbler_geometry_gallery.dart`'s *Spacing*, *Radius*, *Sizing* and *Elevation*
sections. The radius entry draws a nested figure specifically to make the 16-versus-12 corner
distinction visible: a card at 16 with a tile inside it at 12, side by side with what it looks like
when both share one corner — which is the actual bug the dedicated card step exists to prevent.

## Using it

**Never use the 12px radius step for a card's own corner.** It's the corner of a tile *nested
inside* a card, not the card itself — nine of nine card shells in the design source draw 16 for the
outer shell, and using 12 for both makes a nested well read as the same surface as the card
containing it.

**The 16px card-corner step is real and shipped, even though the live design-source page doesn't
draw it yet.** `measurements.html` still shows a six-step radius ramp annotating its 12px step as
"cards, icon tiles" — the exact conflation the dedicated step exists to fix — because the matching
design-source amendment hasn't landed. Use the 16px step in Dart regardless; the gap is in the
source page, not in what this system builds against.

**Never add a shadow anywhere except Dialog.** This is a flat system by construction — one legal
shadow exists, it's reserved for one component by name, and every other surface in this system is
opaque fill plus a hairline, never a shadow standing in for depth.

**Don't snap a drawn literal to the nearest grid step when the specimen itself renders the
literal.** Several components keep off-grid values deliberately — Button's icon gap, its
paddings — because the design specimen draws that literal value and snapping it to the nearest
step would be a visible, uncalled-for change.

## Axes

### Spacing steps
Eleven, `--space-1` through `--space-11`, each a multiple of 3 from 3 to 48.

### Spacing aliases
Six named roles, each a specific step: card padding, screen gutter, section gap, tight stack gap,
default stack gap, icon gap.

### Radius steps
Seven: `sm` (6), `md` (9), `lg` (12 — nested-tile corner), `card` (16 — card corner, off-grid by
design), `xl` (18), `xxl` (24), `pill` (999).

### Sizing
Touch-target minimum (45), two border widths (hairline 0.5, default 1), three icon sizes (18/24/30).

### Elevation
None, except the one reserved Dialog shadow.

@figure 3 lib/src/tokens/dabbler_geometry.dart#space1
@figure 6 lib/src/tokens/dabbler_geometry.dart#space2
@figure 9 lib/src/tokens/dabbler_geometry.dart#space3
@figure 12 lib/src/tokens/dabbler_geometry.dart#space4
@figure 16 lib/src/tokens/dabbler_geometry.dart#card
@figure 18 lib/src/tokens/dabbler_geometry.dart#space6
@figure 24 lib/src/tokens/dabbler_geometry.dart#space8
@figure 999 lib/src/tokens/dabbler_geometry.dart#pill
@figure 45 lib/src/tokens/dabbler_geometry.dart#touchTargetMin
@figure 0.5 lib/src/tokens/dabbler_geometry.dart#borderHairline
@figure 1 lib/src/tokens/dabbler_geometry.dart#borderDefault
@figure 30 lib/src/tokens/dabbler_geometry.dart#space9
@figure 48 lib/src/tokens/dabbler_geometry.dart#space11


## Change log

- D-011 (cxo) — confirms Button's own off-grid icon gap and
  paddings as deliberate, documented exceptions rather than drift to snap to the nearest step.
- D-018 (cxo) — adds the dedicated 16px card-corner step and
  rules 12px is the corner of a tile nested inside a card, never the card's own.
- D-031 (cxo) — confirms Dialog's shadow as the one legal
  exception to this system's flatness.
- D-040 (cxo) — confirms this page's specimen has shipped and
  ships this page.

## Source

`lib/src/tokens/dabbler_geometry.dart`
