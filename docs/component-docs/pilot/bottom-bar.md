<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/navigation/bottom_bar.dart:1-145 (DabblerNavigationItem,
           DabblerNavigationCreateItem, DabblerNavigationBottomBar's class
           dartdoc through the safe-area section — anatomy table,
           controlled/uncontrolled, keyboard, RTL)
           lib/src/navigation/navigation_gallery.dart:32 (specimen title:
           "Navigation — bottom bar")
           DECISIONS.md D-026 (read in full this session), D-031 (read in
           full, prior session — the detached action's shadow inherits
           Fab's exception rather than needing its own)
-->

# BottomBar
### `DabblerNavigationBottomBar`

## Definition

BottomBar is the primary destination switcher — a pill of icon-only destinations with one active
label showing, plus a detached brand action that opens a create menu.

## Intro

Exactly one destination's label is ever visible — the active one — so the bar never shows two
labels at once, the same one-signal-per-state discipline `Tabs` follows. The create action is a
`Fab`-sized round button standing apart from the pill; opening its menu replaces the pill in flow
rather than overlaying it, so the row grows upward from the action's own baseline.

## Specimen

Destinations with an active state and the create menu open — see `navigation_gallery.dart`'s
*Navigation — bottom bar* section.

## Using it

**Drive `active` and `menuOpen` together or not at all — don't control one and leave the other
uncontrolled.** Both follow the same controlled-or-uncontrolled pair rule; mixing controlled and
uncontrolled state between them is the one configuration this component's own contract doesn't
anticipate.

**Rely on `Directionality` for mirroring — never pass a direction override expecting an `rtl`
flag.** There isn't one, deliberately: the web source needs its own flag because a browser can't
always trust the ambient direction, but Flutter's `Directionality` doesn't have that failure mode,
so adding a flag here would just let a caller contradict the ambient direction by mistake. Wrap the
whole bar in a `Directionality` if you genuinely need to force one.

**Expect the same keyboard contract as `Tabs`, not a bar-specific one.** Only the active destination
sits in the tab order, arrows move and select with wraparound, Home/End jump to the ends — this is
deliberately identical to `Tabs` because both are the same interaction family, and two different
keyboard contracts for one gesture pattern would be the actual defect.

## Axes

### Destination state
Inactive (icon only, muted) or active (a card chip with icon and label together, both brand-tinted).

### Create menu
Closed (the pill shows) or open (a card of tiles replaces the pill in flow).

## Direction

**The keyboard's arrow-key mapping swaps under Arabic, the same semantic-consequence fact `Tabs`
carries.** `ArrowLeft` advances rather than retreats under RTL, so the key that moves "forward"
through destinations is always the one pointing the direction the selection visually travels.

*Confirmed by reading `bottom_bar.dart` directly — its own dartdoc states the arrow-key swap
explicitly and ties it to the same keyboard family as `Tabs`. Not yet checked against the gallery's
direction switcher.*

## Tokens used

Nav pill: brand fill, pill radius. Inactive destination: the default border-tone icon colour.
Active destination: card surface chip, brand-tinted icon and label, `bold` icon weight. Create
action: the same size and shadow as `Fab` — see *Change log*.

## Change log

- [D-026 (cxo)](../../../dabbler-docs/DECISIONS.md) — confirms this component, its RTL contract and
  its create menu all stay as built; no change from the greeting-stack question that touched TopBar.
- [D-031 (cxo)](../../../dabbler-docs/DECISIONS.md) — the detached create action's shadow inherits
  Fab's existing flatness exception rather than needing one of its own.

## Source

`lib/src/navigation/bottom_bar.dart`
