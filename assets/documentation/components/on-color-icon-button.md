<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/on_color_icon_button.dart (class dartdoc)
           lib/src/controls/on_color_icon_button_gallery.dart (specimen
           "OnColorIconButton — translucent buttons on a coloured hero")
           design: Details.dc.html:48-58 (game-details hero: back, favourite,
           share), Profiles.dc.html:887 (the same fill on a brand row)
-->

# OnColorIconButton
### `DabblerOnColorIconButton`

OnColorIconButton is the round icon button that sits on a coloured hero: back, favourite and share
on a game's sport-coloured header, drawn as a soft wash of the hero's own on-colour.

It exists because every `Button` tone is drawn for the page surface. On a solid brand band those
fills either disappear or punch a pale hole in the hero; this one stays part of the band.

## Specimen

A brand band with back, a set favourite and a disabled share, in both directions — see
`on_color_icon_button_gallery.dart`.

@specimen on-color-icon-button

## Using it

**Only on a coloured fill.** On the page surface the wash is nearly invisible; use `Button` in its
icon tone there.

**Always pass `semanticLabel`.** The button has no visible text, so the label is its whole name to
a screen reader. Pass the localised word.

**Set `mirrorInRtl` on directional glyphs.** A back arrow must point the other way in Arabic; a
heart or a share glyph must not.

**Use `selected` for a toggle.** A favourite heart passes `selected` and a bold weight when set;
it is then announced as a toggle, not only by its colour.

## Axes

### State
Enabled, disabled (`onPressed: null`, dimmed and announced as disabled), keyboard-focused (the
shared focus ring), and — for a toggle — selected or not.

### Direction
Placed by its parent row, so it follows the reading direction. Only the glyph mirrors, and only
when asked.

**Deviation (size):** the design circle is a little under the touch-target minimum; it is drawn at
the minimum so the painted circle is the target.

**Deviation (glyph):** the design glyph sits between two icon sizes; the small icon size is used.

**Deviation (fill):** the design's translucency has no token. It is a named constant on the
component, applied to `onBrand`, so a theme whose on-colour is ink gets an ink wash.

## Tokens used

Fill: `onBrand` at the component's `fillAlpha`. Glyph: `onBrand` (or a caller's state colour) at
`iconSm`. Size: `touchTargetMin`. Shape: `pill` radius. Focus ring: the shared ring at the pill
radius.

## Change log

- Alpha DS gaps 6 — adds this component.

## Source

`lib/src/controls/on_color_icon_button.dart`
