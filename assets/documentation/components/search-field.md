<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/search_field.dart (class dartdoc through "The clear
           button")
           lib/src/forms/text_field.dart (DabblerTextField.clearable,
           onCleared, clearLabel; _handleTextChange, _clear)
           lib/src/forms/text_field_parts.dart (_ClearButton)
           lib/src/forms/search_gallery.dart (specimen "SearchField — with
           an inline clear button")
           design: Search.dc.html:162-173 (the results-page header)
-->

# SearchField
### `DabblerSearchField`

SearchField is the text field a person types a query into: the `search` variant of `TextField`,
with the clear button the design puts at the end of the box while there is something to clear.

It adds no paint of its own. The box, the leading search glyph and the states are `TextField`'s;
SearchField turns the clear button on by default and gives it a localisable label.

## Specimen

Empty, holding a query, and disabled — see `search_gallery.dart`'s *SearchField* section.

@specimen search-field

## Using it

**Pass the localised word as `clearLabel`.** The button is an icon with no visible text, so its
semantics label is all a screen reader has. The package ships the English default and no other
strings.

**The button is for emptying the field, not for dismissing the search screen.** Tapping it clears
the text, calls `onChanged('')` and then `onCleared`, and leaves focus where it was so the keyboard
stays up for the next query. Use `onCleared` to reset the results list.

**Give it a `controller` when something else also writes the text.** The controller is the single
source of truth: text set from outside shows the button, and clearing it from outside hides it.
With no controller the field owns one and `initialValue` seeds it.

**Don't build this from `standard` plus a suffix icon.** The target size, the end inset, the
focus handling and the mirroring are the variant's; a hand-built clear icon drifts from them.

## Axes

### Clear button
Shown while the field holds text and is enabled; absent while it is empty or disabled. Turned off
entirely with `clearable: false`.

### Direction
The button sits at the inline end — the right in left-to-right layouts, the left in right-to-left.
The leading search glyph mirrors to the opposite side.

## Tokens used

Clear glyph: `close-circle` at `iconSm` (18), in `textTertiary` — the design's `--muted`. Target:
`touchTargetMin` (45) square. Everything else — box, radius, border states, leading glyph, value
and placeholder — is `TextField`'s.

## Change log

- KAN-412 — adds the inline clear button, `onCleared` and `clearLabel`, and this component.
  `TextField` gains `clearable` (off by default, so existing search fields are unchanged); the
  `select` build and the two trailing buttons moved to `text_field_parts.dart` to hold the
  500-line rule.

## Source

`lib/src/forms/search_field.dart`
