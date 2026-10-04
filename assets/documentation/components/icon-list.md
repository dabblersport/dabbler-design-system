<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/cards/icon_list.dart (class dartdoc)
           lib/src/cards/icon_list_gallery.dart (specimen
           "IconList — a titled list with one glyph per line")
           design: Auth and Onboarding.dc.html:511-525
-->

# IconList
### `DabblerIconList`

IconList is a short list of lines, each led by the same small glyph, with an optional uppercase title.

It is the "Don't forget" panel of the persona welcome: three things to remember, each ticked.

## Specimen

Titled inside a white card, and untitled — see `icon_list_gallery.dart`'s *IconList* section.

@specimen icon-list

## Using it

**Put it in a `Card` for a panel.** It paints no surface of its own.

**Keep the lines short.** A line wraps under its own text, with the glyph centred on the first line.

**Don't use it for tasks that can be ticked.** That is `ChecklistPanel`.

## Axes

### Title
Optional: uppercase `footnote`, semibold, in the tertiary text colour.

### Glyph
`tick-circle` by default, bold, in the brand colour.

### Direction
The glyph is at the inline start and the lines align to the reading direction.

## Tokens used

Title `footnote`; line `subheadline`; glyph `iconSm` in `brandPrimary`; gaps `space4` between rows and under the title, `space3` glyph to line.

## Change log

- Alpha fidelity rebuild (auth2) — adds this component.

## Source

`lib/src/cards/icon_list.dart`
