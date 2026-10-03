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

**Don't use it for a setting that takes effect immediately.** That is a `Toggle`.

## Axes

### Layout
`row` — glyph, caption, title and subtitle, with a radio-style check at the inline end. `tile` —
glyph over a short label, with a small check in the top inline-end corner while selected.

### Selected
Idle: a tinted fill with a tinted hairline border and an empty `record` glyph. Selected: a doubled border in
the tint, a bold glyph and a `tick-circle`.

### Direction
The glyph sits at the inline start and the check at the inline end — mirrored in right-to-left
layouts.

## Tokens used

Fill and idle border: the surface tint at 10% and 28%. Selected border: the tint at twice
`borderDefault`. Radius: `lg` for rows, `md` for tiles. Padding `space5` (row), gaps `space4` and
`space2`. Type: `caption1` semibold caption, `callout` title, `footnote` subtitle, `caption2`
medium tile label.

Deviation: the design mixes the fill at 12% and the idle border at 30%, and draws a 26px tile
glyph, a 14px tile check and a 14px body. The nearest tokens are used: the 10%/28% tint,
`iconLg`, `iconSm` and `footnote`. There is no 2px border token, so the selected border is two
`borderDefault` widths.

## Change log

- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/forms/selectable_card.dart`
