<!--
Component page, D-033 ten-part template.

Sources : lib/src/tokens/dabbler_layout.dart
          lib/src/foundations/text_gallery.dart (specimen "Gap - one spacing step")
-->

# Gap
### `DabblerGap`

Gap is an empty space of one spacing step between two things in a row, a column or a scroll view.

It replaces a numeric spacer box. It accepts only values from the spacing scale and the named layout extents, so a one-off number cannot come back in through it.

## Specimen

Vertical and horizontal gaps between two blocks - see `text_gallery.dart`.

@specimen gap

## Using it

**Use `DabblerGap.v` in a column and `DabblerGap.h` in a row**, passing a `DabblerSpacing` step.

**Use `DabblerGap.sliver` between slivers** in a scroll view.

**For padding, use `DabblerInsets`** rather than a gap: screen, card, list bottom, under the floating bar.

## Direction

A horizontal gap has no side, so it is the same in both directions.

## Tokens used

Spacing: the eleven steps and the floating-bar clearance.

## Source

`lib/src/tokens/dabbler_layout.dart`
