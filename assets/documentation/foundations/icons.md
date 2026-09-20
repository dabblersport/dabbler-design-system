<!--
Foundations page, D-034's nine-part Foundations template (Title/Definition/
Intro/Specimen/Using it/Axes/Direction/Change log/Source — no "Tokens used").
UNBLOCKED: specimen already ships as 'Icon — the app vocabulary' in
foundations_gallery.dart:25.

Sources : lib/src/foundations/icon.dart (read in full: DabblerIconWeight,
          DabblerIconOutcome, DabblerIconResolution, DabblerIconRegistry
          including the vocabulary and webProGatedNames lists, DabblerIcon
          widget)
          lib/src/foundations/foundations_gallery.dart:25-29,60-105
          DECISIONS.md — grepped "Icon" (excluding SportIcon/CardIcon/
          IconTile/iconLabel): T-083 (cto)

RESOLVED by D-035: T- entries belong in the Change log, prefix and seat
shown — added below. D-035(b) also confirms this page's handling of the
weight-mapping fix was already correct under D-034(c) and rules that no note
about the T-083/code discrepancy belongs in the body — the escalation to cto
is the mechanism, not this page. Nothing further changed here.
-->

# Icons
### `DabblerIcon`

Icons are drawn from one font, `iconsax_flutter`, in exactly two weights — the app has no third
icon source and no third weight.

Every icon is requested by a kebab-case name (`search-normal`, `home-2`) at `linear` (the default,
outlined) or `bold` (filled, reserved for active tabs and primary actions) — never by a raw
`IconData`, so a call site reads the way the design source names it rather than the way the font
package does. A name that does not resolve at the requested weight falls back to the other weight
before it falls back to a placeholder, and a name the font does not carry at all renders a visible
neutral placeholder rather than empty space, because a silently collapsed icon is a harder defect
to catch in review than a wrong one.

## Specimen

The full 40-name vocabulary at both weights, plus the fallback and placeholder states — see
`foundations_gallery.dart`'s *Icon* section.

## Using it

**Request an icon by its kebab-case design-source name, not by an `Iconsax` constant.** The name is
what the design specifies and what a reviewer can check against it; which underlying font constant
it maps to is this component's problem, not the caller's.

**Reserve `bold` for an active tab or a primary action.** `linear` is the default weight for every
other case — using `bold` more broadly than that makes the one thing `bold` is supposed to signal
stop meaning anything.

**Do not build a substitution table for a name that looks unavailable.** Every name in this
package's 40-name vocabulary ships in both weights; a name outside the vocabulary that fails to
resolve should be treated as a real gap to report, not silently swapped for a similar-looking icon.

**Never treat an unresolved icon as an empty box.** If a name fails to resolve at all, the
component renders a visible placeholder and asserts in debug — that behaviour exists so a missing
glyph is caught in review, and building around it (catching the assert, hiding the placeholder)
defeats the reason it's there.

## Axes

### Weight
`linear` (outline, the default), `bold` (filled — active tabs and primary actions only).

### Size
`iconSm` (18), `iconMd` (24, the default and the font's own native grid), `iconLg` (30).

### Resolution outcome
`resolved` (the requested name and weight both exist), `weightFallback` (the name exists but not
at the requested weight — bold asks fall back to linear, never the reverse), `missing` (the name
does not exist in the font at all — renders the placeholder).

## Change log

- T-083 (cto) — adopts `iconsax_flutter` as the single icon
  source and rules the weight-fallback contract this page describes.
- D-034 (cxo) — rules the Foundations page template this page
  follows.

## Source

`lib/src/foundations/icon.dart`
