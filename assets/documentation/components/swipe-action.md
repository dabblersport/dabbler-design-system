<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/interaction/swipe_action.dart (DabblerSwipeAction)
           lib/src/interaction/swipe_action_item.dart (DabblerSwipeActionItem,
           DabblerSwipeActionTone)
           lib/src/interaction/swipe_action_gallery.dart (specimen
           "SwipeAction — swipe to reveal")
           KAN-410 item a
-->

# SwipeAction
### `DabblerSwipeAction`

SwipeAction wraps a row so dragging it toward the start edge reveals one or more actions behind it.

Tapping an action fires it and closes the row; tapping the open row, or dragging it back, closes it
without firing anything. The row never leaves the list on its own.

## Specimen

One destructive action, and a neutral and brand pair — see `swipe_action_gallery.dart`'s
*SwipeAction* section.

@specimen swipe-action

## Using it

**Use it for secondary actions on a list row**, such as hiding a story in the Home Feed. The primary
action stays a tap on the row.

**Never make a swipe the only way to an action.** Every action is also exposed to screen readers as
a custom action on the row, and anything important should also be reachable from the row's menu.

**Keep labels to one short word.** Each box is 72 wide and the label is one line.

## Direction

The actions sit at the inline end. In English the row is dragged left to reveal them; in Arabic it
is dragged right and they appear on the left.

## Tokens used

Fills and inks: the `Button` tone of the same name — `destructive` is `error.solid` with paper ink,
`neutral` is `surfaceSunken` with `textPrimary`, `brand` is `brandPrimary` with `onBrand`. Label:
`caption1` at medium weight. Box width: `space11` + `space8`; minimum hit box: the 45 touch target.
Settle: `slow` duration on the `easeOut` curve. Row ground: `bgPrimary`.

## Source

`lib/src/interaction/swipe_action.dart`
