<!--
Component page, D-033 ten-part template.

Group    : Identity and status
Sources  : lib/src/surfaces/hero_icon.dart (class dartdoc)
           lib/src/surfaces/hero_icon_gallery.dart (specimen
           "HeroIcon — the large round glyph on a result screen")
           design: Auth and Onboarding.dc.html:455-520 (confirmation glyphs),
           Listings.dc.html:194 (tinted tile precedent)
-->

# HeroIcon
### `DabblerHeroIcon`

HeroIcon is the large round tile holding one glyph at the top of a success, confirmation or
empty screen, the screen-sized sibling of `IconTile`.

It is decorative by default: the screen's title says what happened.

## Specimen

All six tones — see `hero_icon_gallery.dart`'s *HeroIcon* section.

@specimen hero-icon

## Using it

**Pick the tone from what happened.** `success` for a finished flow, `error` for one that failed,
`brand` for a welcome, `neutral` for an empty screen.

**One per screen, above the title.** It anchors a full-screen message; it is not a list glyph.

**Pass `semanticLabel` only when the glyph says something the text does not.**

## Axes

### Tone
`brand` (brand tint with its hairline), `success`, `warning`, `error`, `info` (each the status
surface with its strong ink), and `neutral` (sunken surface, card hairline, secondary ink).

### Size
`defaultSize` unless a diameter is passed.

## Tokens used

Brand: the surface tint of `brandPrimary` at 10% fill and 28% border. Status tones: the status
`surface` and `strong`. Neutral: `surfaceSunken`, `borderDefault`, `textSecondary`. Radius: `pill`.
Glyph: `iconLg`, bold.

Deviation: the design files draw no circular hero tile and no hero size token exists. The default
diameter is `space11 + space8` (72), and the tint follows the 60px tinted tile in
`Listings.dc.html`.

## Change log

- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/surfaces/hero_icon.dart`
