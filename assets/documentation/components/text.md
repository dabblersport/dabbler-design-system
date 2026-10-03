<!--
Component page, D-033 ten-part template.

Sources : lib/src/foundations/text.dart
          lib/src/foundations/text_gallery.dart (specimen "Text - ramp, weight and tone roles")
          Added in the zero-literal pass: the app writes no TextStyle, FontWeight or colour.
-->

# Text
### `DabblerText`

Text is a run of words set in one step of the type ramp, with its weight and colour chosen by role.

It is the replacement for a plain `Text` and for every hand-built `TextStyle` in the app. It runs the same pipeline the components use, so a string in Arabic picks the Arabic face, size and leading from the ambient direction, and digits are always Western.

## Specimen

Ramp steps with weight and tone roles, a rich run with a link, and the same text in Arabic - see `text_gallery.dart`.

@specimen text

## Using it

**Pick a ramp step, not a size.** `style` takes a `DabblerType` step. A size the ramp does not have cannot be written here, by design; report it rather than overriding.

**Pick a weight role, not a weight.** `weight` takes `DabblerTextWeight`. `heavy` is the role for the app's old extra-bold emphasis and renders at bold, because the type source stops there.

**Pick a tone, not a colour.** `tone` takes `DabblerTextTone`, resolved from the active theme. Use `inherit` inside something that already sets the colour, such as a button.

**Mixed runs use `DabblerText.rich`.** Each `DabblerTextSpan` may override weight and tone; giving one an `onTap` makes it an inline link.

## Direction

The script follows the ambient direction: right to left resolves the Arabic face, the Arabic size and the Arabic leading of the chosen step. Alignment is directional.

## Tokens used

Type: every ramp step and the five weight steps. Colour: the three text roles, brand, accent, the two on-fill inks and the four status inks.

## Change log

- Added in the zero-literal pass, so the app writes no text style of its own.

## Source

`lib/src/foundations/text.dart`
