<!--
Foundations page, D-034's nine-part template. UNBLOCKED: specimens already
ship as 'SportIcon — every sport' and 'SportBackground — every variant'
(foundations_gallery.dart:31,37).

Covers both DabblerSportIcon and DabblerSportBackground as one Foundations
topic (they are two axes of the same "how a sport identifies itself" system,
and D-033(b) groups "sports" as one Foundations line item, not two).

Sources : lib/src/foundations/sport_icon.dart (read in full)
          lib/src/foundations/sport_background.dart (read through the
          DabblerSportBackgroundVariant enum and the artwork-reference
          rationale)
          lib/src/foundations/sports.dart (DabblerSport enum, confirmed 13
          values starting 'football'/'basketball')
          DECISIONS.md D-008, D-009 (read in full), D-010 (read in full)

D-006/D-022 (the sport-overlay-on-a-card-cover geometry) are NOT linked here
— they rule where the overlay sits on an event card's cover image, which is
a Card/event-card concern, not a SportIcon/SportBackground one. They belong
on that component's own page when it's written, not here.
-->

# Sports
### `DabblerSportIcon`, `DabblerSportBackground`

Sport identity is carried two ways — a small icon and a full illustrated background — and neither
one is allowed to be the only thing on screen saying which sport it is.

Thirteen sports are named in this system. Every one of them can be asked for as an icon, at
`linear` or `bold`; only eleven currently have illustrated background artwork, and none has a
commissioned icon glyph of its own yet — see *Using it* for what that means for how you build a
screen today.

## Specimen

All thirteen sports at both icon weights, and every sport with shipped background artwork in its
`main` variant — see `foundations_gallery.dart`'s *SportIcon* and *SportBackground* sections.

## Using it

**Never let a sport icon be the only thing on screen that says which sport it is.** No commissioned
sport-glyph set exists yet — every sport icon today falls back to one of three generic Iconsax
glyphs (`game`, `activity`, `ticket-2`), and four different sports collapsing onto the same picture
cannot do the one job a sport icon exists for. Pair it with a label, or let the sport background
carry the identity instead, wherever which sport it is matters to the screen.

**Never let a sport background be the only carrier of meaning either.** It's decorative artwork,
not a labelled illustration — the same constraint as the icon rule, from the other direction. Give
every screen that uses one a text or icon-based way to know which sport it's looking at without the
image.

**Never render a background with no fallback paint underneath it.** Backgrounds are typed
references the consuming app resolves, not bundled assets — a missing, slow or undeclared asset
must show a token-derived solid colour, never an empty or white area.

**Do not treat `matchDay` as a softer version of `main` today.** It's structurally present but
entirely unpopulated — requesting it returns nothing. If a screen needs match-day-specific artwork
now, that's a real gap to raise, not a case for quietly substituting `main`.

## Axes

### Sport
Thirteen: football, basketball, and eleven more — see `lib/src/foundations/sports.dart` for the
full enum.

### Icon weight
`linear`, `bold` — same two weights as the general icon system, since every sport icon falls back
through the same registry.

### Background variant
`main` (general sport identity — populated for eleven of the thirteen sports), `matchDay`
(match/game-day context — anticipated in the type, unpopulated in every sport today).

## Change log

- [D-008 (cxo)](../../../../dabbler-docs/DECISIONS.md) — this system draws thirteen sports, not twelve; a
  drift in the design source's own written description, corrected against what it actually draws.
- [D-009 (cxo)](../../../../dabbler-docs/DECISIONS.md) — no sport glyph set exists yet; rules the
  icon-alone prohibition above and specifies what a real set needs to be before it ships.
- [D-010 (cxo)](../../../../dabbler-docs/DECISIONS.md) — sport background artwork is never bundled into this
  package, and rules the fallback-paint and never-sole-carrier requirements above.
- [D-034 (cxo)](../../../../dabbler-docs/DECISIONS.md) — rules the Foundations page template this page
  follows.

## Source

`lib/src/foundations/sport_icon.dart`, `lib/src/foundations/sport_background.dart`,
`lib/src/foundations/sports.dart`
