<!--
Foundations page, D-034's nine-part template. UNBLOCKED per this session —
the theme/brightness comparison specimen shipped (KAN-315).

This is the page D-035(c) named a genuine exception for: its subject is a
DIFFERENCE (which roles move across themes, which don't), which a
single-state switcher can't show. The specimen therefore does not use the
gallery's own theme switcher — every cell installs its own resolved
(theme, brightness) pair, all fourteen rendered adjacent at once.

Sources : lib/src/tokens/dabbler_themes_gallery.dart (read in full — the
          "why this page exists although a switcher already does" section,
          the exact role split cited from test/tokens/dabbler_colors_test.dart's
          own assertions: 13 paper roles pinned identical across all 21
          unordered theme pairs, 3 brand roles pinned different; the
          "how a cell renders in a theme that is not the page's" mechanism)
          lib/src/tokens/dabbler_colors.dart (role names cross-checked
          against foundations-colour.md, already written this session)
          DECISIONS.md D-033(d) (read in full, prior session — rejects a
          per-page theme rail, which is the ruling this whole page exists
          to satisfy instead), D-035 (read in full, prior session — the
          "control that changes state is not a specimen of that axis"
          principle this page is the worked exception to)
-->

# Themes and brightness

There are fourteen resolved palettes — seven section themes at two brightnesses each — and exactly
one fact distinguishes them: the paper stays fixed, only the brand re-tints.

Thirteen roles are identical across every one of the seven themes at a given brightness — every
background, surface, text and border role, plus scrim and spotlight. Three roles differ: the two
brand fills and the focus ring. A theme is therefore not a full repaint; it's a re-tint of a small,
fixed set of roles over paper that never moves. This is the one Foundations page where showing all
fourteen palettes at once is the actual subject, not a convenience — a reviewer flipping through
them one at a time can't see "the card surface never moved," because that's a claim about
comparison, not about any single state.

## Specimen

Two entries — see `dabbler_themes_gallery.dart`'s *Themes* section: one control shown across all
fourteen palettes simultaneously, so the invariant is visible as a single glance rather than a
claim to take on faith; and the same split as live hex values, thirteen paper roles repeating
across all seven themes and three brand roles never repeating. Neither entry follows the gallery's
own theme switcher — each cell installs its own resolved pair independently, which is the whole
point of the page.

## Using it

**Never assume a component needs theme-specific styling for anything except brand-tinted fill,
ink or the focus ring.** Thirteen of the sixteen semantic roles this system exposes are identical
across every theme — a component that reads any of them paints correctly under all seven without
knowing which one is active.

**Don't treat the gallery's theme switcher as a pattern to reuse in a real screen.** It's review
chrome for looking at all fourteen combinations, not a component — a screen changes theme by
installing a different resolved `DabblerColors` extension on `MaterialApp`, the pattern `Start
here` describes, never by wrapping a subtree in switcher logic borrowed from the gallery.

**Never hardcode a brand colour expecting it to be correct across themes.** The three roles that
actually vary — `brandPrimary`, `accent`, `focusRing` — are exactly the ones a hardcoded value would
get wrong the moment the active theme changes; everything else is safe to treat as effectively
constant, but these three are the entire reason token roles exist instead of literals.

## Axes

### Section theme
Seven: `main`, `sport`, `social`, `active`, `bright`, `simple`, `shade` — see the Colour foundation
page for what each one is.

### Brightness
Light or dark — fourteen combinations total with the seven themes.

### What moves versus what doesn't
Thirteen paper/text/border/status-adjacent roles identical across all seven themes at a given
brightness; three brand-adjacent roles (`brandPrimary`, `accent`, `focusRing`) re-tint per theme.

## Change log

- D-033 (cxo) — rejects a per-page theme rail across the rest
  of this documentation precisely so theme could mean something on the one page where it's the
  actual subject.
- D-035 (cxo) — rules that a state-changing switcher is not a
  specimen of an axis whose subject is comparison, which is why this page's specimen renders all
  fourteen palettes adjacently instead of following the gallery's own switcher.

## Source

`lib/src/tokens/dabbler_colors.dart`
