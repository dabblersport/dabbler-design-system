<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/selectable_card.dart (class dartdoc through "RTL")
           lib/src/forms/selectable_card_gallery.dart (specimen
           "SelectableCard — a card that is chosen or not")
           design: Auth and Onboarding.dc.html:373-389 (persona step),
           :392-406 (sport grid), :1405-1425 (personaCards paint)
-->

# SelectableCard
### `DabblerSelectableCard`

SelectableCard is a tappable card that is either chosen or not: the persona cards and the sport
tiles of onboarding, where a choice needs more room than a radio or a chip gives it.

It holds no state. The caller says whether it is selected and decides what a tap means, so the
same card serves one-of-many and many-of-many.

## Specimen

Persona rows, a sport tile grid, and a disabled card — see `selectable_card_gallery.dart`'s
*SelectableCard* section.

@specimen selectable-card

## Using it

**Use the row layout for a choice that needs a sentence, the tile layout for a grid of short
names.** Rows carry a caption, a title and a subtitle; tiles carry a glyph and one short label, and
are built to sit in a four-column grid.

**`onChanged` receives the toggled value.** A many-of-many grid stores it; a one-of-many list
ignores it and selects that card. A null `onChanged` disables the card.

**Pass the persona's own colour as `tint`.** Without one the card is tinted with the brand.

**Pass a `tone` when the card is tinted by hue.** A `DabblerHueTone` gives the card its own fill, idle border, selected border, glyph and idle radio colours — a sport (`DabblerHueTone.forSportKey`), a gender (`DabblerHueTone.gender`) or a palette ramp (`DabblerHueTone.ramp`).

**Don't use it for a setting that takes effect immediately.** That is a `Toggle`.

## Axes

### Layout
`row` — glyph, caption, title and subtitle, with a radio-style check at the inline end. `tile` —
glyph over a short label, with a small check in the top inline-end corner while selected. `listRow` — a one-line option: glyph, one label and the check, centred in a row with a minimum height (the primary-sport step). `stacked` — a centred glyph over a label with the check after it, with a larger minimum height (the gender step).

### Selected
Idle: a tinted fill with a tinted hairline border and an empty `record` glyph. Selected: a doubled border in
the tint, a bold glyph and a `tick-circle`.

### Direction
The glyph sits at the inline start and the check at the inline end — mirrored in right-to-left
layouts.

## Tokens used

Fill and idle border: the surface tint at 10% and 28%. Selected border: the tint at twice
`borderDefault`. Radius: `lg` for rows, `md` for tiles. Padding `space5` (row), gaps `space4` and
`space2`. Type: `body` semibold caption, `body` medium hook at 16/23 (persona row), `small` subtitle, `rowTitle` list-row title, `copy` medium stacked label, `tagTight` medium tile label.

Row caption and title use the 16px `body` step, as the source sets no size and they inherit it; the caption is tracked 0.06em (not under RTL, where tracking breaks joining).

Deviation: the design mixes the fill at 12% and the idle border at 30%, and draws a 26px tile
glyph and a 14px tile check. The nearest tokens are used: the 10%/28% tint,
`iconLg` and `iconSm`. There is no 2px border token, so the selected border is two
`borderDefault` widths.

## Change log

- KAN-426 (final) — adds `borderOutside` (default false): the persona row and the sport tile grow by twice their border (1px idle, 2px selected, as the frame does); `listRow` and `stacked` keep their outer 63 and 96 minimum, because `min-height` under `border-box` includes the border.
- Alpha DS gaps 5 — adds this component.
- KAN-426 (close) — text roles follow the frames: persona subtitle `small` (14/20) with 3px between the lines and the hook at 16/23, list-row title `rowTitle` (17/23), stacked label `copy` medium (15/21), tile label `tagTight` medium (11/14). Previously `footnote`, `callout`, `subheadline` and `caption2`.
- Alpha fidelity rebuild (auth2) — adds the `listRow` and `stacked` layouts and the `tone` parameter (`DabblerHueTone`: per-sport, per-gender and ramp tints, from the source's `tone()` and `personaCards()`); the row caption and title move to the 16px step the source inherits.

## Source

`lib/src/forms/selectable_card.dart`
