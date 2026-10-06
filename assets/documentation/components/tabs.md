<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/layout/tabs.dart:1-70 (DabblerTabsVariant, DabblerTabItem
           class dartdoc and fields — icon/badge slot rationale confirmed
           directly, and confirmed CURRENT: both are still Widget slots even
           though Icon and Badge have since shipped, which matches the
           dartdoc's own stated prediction — "nothing in this file changes"
           — rather than being a stale-premise defect like Dialog's actions
           slot. Not flagged as a gap.)
           lib/src/layout/tabs.dart:136-142,366-368 (RTL arrow-key swap)
           lib/src/layout/tabs_gallery.dart:19 (specimen title: "Tabs —
           variants")
           DECISIONS.md D-026 (read in full this session — confirms no
           change to Tabs; the kit's three-signal brand treatment is
           refused in favour of the source's one-signal indicator)
-->

# Tabs
### `DabblerTabs`, `DabblerTabPanel`

Tabs switches between peer views — an underline indicator for content tabs, or a segmented pill
track for two or three views of equal weight.

Exactly one signal marks the active tab, not several: the brand colour lives in the underline
alone, not in the label and the underline and a heavier weight all at once. A tab's `icon` and
`badge` are `Widget` slots rather than typed names — pass `DabblerIcon(...)` or `DabblerBadge(...)`
into them directly, which is what those two slots have always been designed to accept.

## Specimen

@specimen tabs/listing

Both variants — see `tabs_gallery.dart`'s *Tabs* section.

@specimen tabs/variants

## Using it

**Let the underline alone carry the active signal — never brand-colour the label as well, and
never raise its weight to compensate.** One state gets one primary signal plus ordinary emphasis;
adding two more signals for the same state was tried elsewhere and refused precisely because it's
redundant, not because it looks wrong.

**Use `segmented` only for two or three peer views of equal weight, always full width.** It's a
distinct visual language from `underline`, not a size variant of it — reaching for it outside that
case draws content tabs as though they were mutually exclusive settings.

**Match a `DabblerTabPanel`'s `id` to its tab's `id` exactly — position doesn't decide which panel
shows.** The panel that renders is whichever one's `id` equals the current value, not whichever one
sits in the matching list position.

**To show no tab as selected, set `allowNoSelection: true` and pass a null `value`.** Every tab
then draws inactive with no indicator, and the first tab is the keyboard entry point. When the
flag is off, a null value still selects the first tab, the same as any value that matches no tab.

**Set `labelFit: DabblerTabsLabelFit.fit` on a segmented strip whose labels can run long.** The
default still shortens a label that does not fit with an ellipsis. With `fit` nothing is cut off:
every label shrinks together, no smaller than the footnote size, and if they still do not fit the
track scrolls sideways and keeps the selected segment in view. This matters most in Arabic, where
labels often run longer than the English.

## Axes

### Variant
`underline` (2px brand indicator over a faint rail — the default, for content tabs), `segmented`
(sunken pill track, solid brand fill on the selected tab — for two or three peer views).

### Tab content
Label (required), optional leading icon slot, optional badge slot.

@figure 2px lib/src/layout/tabs.dart#_indicatorHeight


## Direction

**The keyboard's arrow-key mapping swaps under Arabic — the same semantic-consequence fact
`BottomBar` shares, deliberately.** `ArrowLeft` advances rather than retreats under RTL, so the key
that moves "forward" through tabs always points the direction the indicator visually travels.

*Confirmed by reading `tabs.dart` directly — the arrow-key branch is explicit about the swap. Not
yet checked against the gallery's direction switcher.*

## Tokens used

Underline: `brandPrimary` indicator over a faint rail. Segmented: sunken track, brand-filled
selected pill. Active label: `textPrimary` at medium weight — brand lives in the indicator, not the
label.

## Change log

- KAN-433 (Home fidelity) — adds `DabblerTabsVariant.feed` and `padding`: the Home Feed's tab rail. Label-wide tabs 21 apart, every label at the regular weight (active differs by ink and the underline only, as the frame's markup draws it), 10 under the label, a 3px brand underline over the 1px faint rail, 33 high (36 under Arabic leading 23), each tab's 45 target kept as a hit-test-only area around it. `padding` insets the tabs while the rail still runs edge to edge. Underline and segmented are unchanged.
- D-026 (cxo) — confirms the underline-only brand signal is
  correct as built and refuses a competing kit treatment that would triple the signal for one state.
- DS gaps 6 — `labelFit` (`DabblerTabsLabelFit.ellipsis` default, `.fit`). Additive.
- Listings fidelity pass — adds the `listing` variant: label-width tabs 21 apart, 600 active and 500 otherwise, 9 above the 2px underline, a 31 tall strip with 45 hit-test-only targets.

## Source

`lib/src/layout/tabs.dart`
