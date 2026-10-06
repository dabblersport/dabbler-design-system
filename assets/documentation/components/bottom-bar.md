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

BottomBar is the primary destination switcher — a pill of icon-only destinations with one active
label showing, plus a detached brand action that opens a create menu.

Exactly one destination's label is ever visible — the active one — so the bar never shows two
labels at once, the same one-signal-per-state discipline `Tabs` follows. The create action is a
`Fab`-sized round button standing apart from the pill; opening its menu replaces the pill in flow
rather than overlaying it, so the row grows upward from the action's own baseline.

## Specimen

Destinations with an active state and the create menu open — see `navigation_gallery.dart`'s
*Navigation — bottom bar* section.

@specimen bottom-bar

Each create tile can tint its glyph plate with `iconTone` (`neutral` by default, or `info`,
`success`, `accent`, `amber`), and `rotateActionOnOpen: false` holds the action glyph upright while
the menu is open — the Home Feed treatment. `actionOpenIcon` names a second glyph the action shows
while the menu is open (the Home Feed passes `close-circle`: a light disc carrying a brand ✕); the
two cross-fade on the slow motion step and swap instantly under reduced motion. Leave it unset and the
action keeps one glyph in both states.

@specimen bottom-bar/icon-tones

A destination can carry an unread dot (`unread: true`) or a count (`count: 3`, capped at `99+`, and
winning over the dot) on its icon's top-inline-end corner. Both are the badge component, with a
card-coloured ring so they read on the brand pill. Pass `badgeLabel` ("3 unread") and it is appended
to the destination's accessible name — "Inbox, 3 unread" — since the package ships no strings of its
own. With neither set the bar is unchanged.

@specimen bottom-bar/badges

`mirrorInRtl` (default `true`) controls whether the layout follows an ambient RTL. Pass `false` to
keep the pill on the physical left and the action on the physical right while the labels and the
create-menu captions still read right to left: the Home Feed frame draws its Arabic bar exactly
that way (its component's own auto-direction probe cannot flip). Callers that do not pass it are
unchanged.

@specimen bottom-bar/pinned-rtl

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

**The bar is also the Action Area.** Loading, progress, toasts and banners can take over the
action button's footprint and grow along the bar, with the bar inert underneath while they are
expanded. Wrap the bar in `NavigationActivity` or `NavigationFeedback` rather than drawing over it;
see the `ActionArea` page.

## Axes

### Destination state
Inactive (icon only, muted) or active (a card chip with icon and label together, both brand-tinted).

### Create menu
Closed (the pill shows) or open (a card of tiles replaces the pill in flow).

### Indicator
None (default), an unread dot, or a count pill.

## Direction

**The keyboard's arrow-key mapping swaps under Arabic, the same semantic-consequence fact `Tabs`
carries.** `ArrowLeft` advances rather than retreats under RTL, so the key that moves "forward"
through destinations is always the one pointing the direction the selection visually travels.

*Confirmed by reading `bottom_bar.dart` directly — its own dartdoc states the arrow-key swap
explicitly and ties it to the same keyboard family as `Tabs`. Not yet checked against the gallery's
direction switcher.*

## Tokens used

The Home Feed frame, measured at 393 wide: the bar is 56 high, the pill's destinations are 44 circles
with 24 icons (`DabblerSizing.navItem`), the action is a 56 circle with a 26 glyph
(`DabblerSizing.navBarHeight`, `navGlyphLarge`), the margins are 18 and the bottom inset 24. Inside
`DabblerPage(bottomOverlay:)` the fade behind it is 80 high (`navFadeHeight`). The open create menu is
289 wide (393 - 2 x 18 - 12 - 56) with three 83 x 62 tiles (`navCreateTile`) and 12.5 / 15.625
captions. Every one of these off-grid values is a named token in `sizingOffGridRulings`, with its
source line.

**The pill hugs its content; it never stretches.** The active chip is exactly its padding, icon,
gap and label wide, the inactive destinations stay 44 squares, the pill ends one pill-padding after
its last destination, and all the free width sits between the pill and the action. With three
destinations the gap to the action is wide, and that is the drawing, not slack to fill. On a column
too narrow for the natural width the pill degrades without overflowing: the active label ellipsizes
first, so the inactive squares keep the 44 touch floor, and only once the chip is down to its icon
do the inactive squares give way, never below their icon.


Nav pill: brand fill, pill radius. Inactive destination: the default border-tone icon colour.
Active destination: card surface chip, brand-tinted icon and label, `bold` icon weight. Create
action: the same size and shadow as `Fab` — see *Change log*.

## Change log

- D-026 (cxo) — confirms this component, its RTL contract and
  its create menu all stay as built; no change from the greeting-stack question that touched TopBar.
- D-031 (cxo) — the detached create action's shadow inherits
  Fab's existing flatness exception rather than needing one of its own.
- KAN-412 W1 — per-destination unread dot and count badge (`unread`, `count`, `badgeLabel`).
  Placement and the ring are this system's: the readable designs draw no bar indicator (the Home
  Feed file is truncated), so the offsets are not transcribed.

- KAN-433 — the frame's geometry pinned (`DabblerSizing.nav*` off-grid tokens, tested in
  `test/navigation/bottom_bar_frame_test.dart` in LTR, RTL mirrored and RTL pinned with the Arabic
  frame's strings) and the `mirrorInRtl` option, default unchanged.
- `actionOpenIcon` — an optional open-state glyph for the action, default unset (unchanged). The Home
  Feed design's open menu shows `close-circle` on the action; tested in
  `test/navigation/bottom_bar_open_glyph_test.dart` in LTR and RTL, light and dark.
- KAN-437 — the active chip hugs its content at every destination count (three, four, five), in
  LTR and pinned Arabic RTL, at 393, 320 and in a wide window's phone column; a narrow column
  ellipsizes and then narrows rather than overflowing. Tested in
  `test/navigation/bottom_bar_hug_test.dart`.

## Source

`lib/src/navigation/bottom_bar.dart`, `lib/src/navigation/bottom_bar_badge.dart`
