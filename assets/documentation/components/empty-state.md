<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/cards/empty_state.dart:1-70 (DabblerEmptyStateSize in
           full, class dartdoc through the "which shell each size composes"
           section — composition rules, the no-illustration constraint and
           its reasoning)
           lib/src/cards/cards_gallery.dart:42 (specimen title: "EmptyState
           — inline and page")
           DECISIONS.md — grepped "EmptyState": no D-numbered ruling on this
           component's own behaviour (one incidental mention inside D-013,
           listing EmptyState among components that correctly reach title3
           through the shared class).
-->

# EmptyState
### `DabblerEmptyState`

EmptyState is the "nothing here yet" state for a section, a list, or a whole screen — the only one
this system has.

There's no illustration slot, deliberately. The design source has one and it isn't ported at
all — not as a widget slot, not as an asset hook — because an escape hatch would make "no elaborate
hero illustration" an advisory constraint rather than a real one, and the first screen to use it
would be exactly the illustration this component exists to refuse. What remains is an icon inside
the card shell, which is the whole of its visual vocabulary on purpose.

## Specimen

Both sizes — see `cards_gallery.dart`'s *EmptyState* section.

## Using it

**This is the only empty state in the system — never build a screen-specific one.** A screen that
needs to say "nothing here yet" composes this component; inventing a bespoke empty-state layout
for one screen is exactly the drift this component exists to prevent.

**Give at most one action.** Two actions means the screen is really presenting a decision, not an
empty state — if a caller finds itself wanting a second button here, that's a sign the screen needs
a different component, not a second action slot on this one.

**Don't reach past the icon well for anything more elaborate.** There's no illustration prop and no
asset slot to work around that — an icon inside the card shell is the entire visual language this
component is allowed, and that's an intentional constraint, not an unfinished feature.

**Use `page` for a whole empty screen, `inline` for an empty section or list.** `page` drops the
card frame entirely and centres in the viewport; `inline` keeps the bordered card shell so it reads
as one empty section among others rather than taking over the screen.

## Axes

### Size
`inline` (bordered card shell, 45×45 icon well — the default, for a section or list), `page`
(no frame, centred in the viewport, for a whole empty screen).

### Action
Zero or one.

@figure 45 lib/src/cards/empty_state.dart#wellSide


## Tokens used

`inline` composes `Card` at the `white` variant. `page` composes no card at all — transparent
background, no border, no radius, matching the source exactly.

## Source

`lib/src/cards/empty_state.dart`
