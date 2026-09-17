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

## Definition

Tabs switches between peer views — an underline indicator for content tabs, or a segmented pill
track for two or three views of equal weight.

## Intro

Exactly one signal marks the active tab, not several: the brand colour lives in the underline
alone, not in the label and the underline and a heavier weight all at once. A tab's `icon` and
`badge` are `Widget` slots rather than typed names — pass `DabblerIcon(...)` or `DabblerBadge(...)`
into them directly, which is what those two slots have always been designed to accept.

## Specimen

Both variants — see `tabs_gallery.dart`'s *Tabs* section.

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

## Axes

### Variant
`underline` (2px brand indicator over a faint rail — the default, for content tabs), `segmented`
(sunken pill track, solid brand fill on the selected tab — for two or three peer views).

### Tab content
Label (required), optional leading icon slot, optional badge slot.

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

- [D-026 (cxo)](../../../dabbler-docs/DECISIONS.md) — confirms the underline-only brand signal is
  correct as built and refuses a competing kit treatment that would triple the signal for one state.

## Source

`lib/src/layout/tabs.dart`
