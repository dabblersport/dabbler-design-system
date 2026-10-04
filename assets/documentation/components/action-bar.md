<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/navigation/action_bar.dart (class dartdoc)
           lib/src/layout/detail_gallery.dart (specimen "ActionBar")
           design: Details.dc.html:178-190, 354-366, 517-529
-->

# ActionBar
### `DabblerActionBar`

ActionBar is the bar pinned to the bottom of a detail screen: a price on the inline start and the screen's actions beside it.

It sits as a page's bottom bar, pads the home-indicator inset itself, and gives the call to action whatever width the price leaves.

## Specimen

A price with a primary action, and a price with a secondary and a primary one, in both directions — see `detail_gallery.dart`.

@specimen action-bar

## Using it

**Use it as a page's `bottomBar`.** It pads the home-indicator inset itself.

**Give the call to action `fullWidth`.** The primary slot takes the remaining width.

## Axes

### Slots
Price only, price and primary, or price, secondary and primary.

### Direction
The price sits at the inline start and mirrors.

## Tokens used

`bgPrimary`, `bgTertiary` hairline, `headline` and `caption2`, spacing steps 5–8.

## Change log

- KAN-426 fidelity rebuild — adds this component.

## Source

`lib/src/navigation/action_bar.dart`
