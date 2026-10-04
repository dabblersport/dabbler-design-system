<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/layout/flow_page.dart (class dartdoc)
           lib/src/layout/flow_gallery.dart (specimen
           "FlowPage — the onboarding step template")
           design: Auth and Onboarding.dc.html:287-299 (welcome back),
           :301-326 (new user), :329-452 (steps), :456-492 (setup),
           :494-529 (persona welcome)
-->

# FlowPage
### `DabblerFlowPage`

FlowPage is the screen template of a one-way flow such as onboarding: an optional back button and segmented progress, a title and subtitle, a body, and one full-width primary action.

Every frame of the onboarding design draws the same paddings, so the template owns them and a screen only supplies what is different — its title, its body and its action.

## Specimen

A step with back, progress, a field and the action; and the centred variant with a banner above the action — see `flow_gallery.dart`'s *FlowPage* section.

@specimen flow-page

## Using it

**Give a step its progress and a back button together.** `stepCount` and `stepIndex` go together; `onBack` needs its `backLabel`, already localised.

**Put the body in `content`, not in your own column.** The template scrolls it and spaces the children by `bodyGap`.

**Use `centered` for a screen with no steps.** The title block, the optional `leading` widget and the body then sit in one vertically centred column — the welcome-back and setup frames.

**Use `spreadChildren` and `background` for the persona welcome.** The children spread over the full height with the space between them, and the artwork fills the page behind them.

**Don't put a second primary action in the footer.** The footer holds a `footerBanner`, the one primary action and a `secondary` widget under it.

## Axes

### Layout
Steps: back row, header (progress, title, subtitle), scrolling body, footer. Centred: one centred column. Spread: children distributed over the body with a full-bleed background.

### Footer
The primary action is loading while `primaryLoading`, and disabled while `onPrimary` is null. A banner above it sits `space3` from it.

### Direction
Nothing is directional except the back arrow, which mirrors.

## Tokens used

Sides `space8`; back row top `space2` and start `space4`; header top `space2` (with a back row) or `space6`; body top `bodyTopPadding` (`space6`); footer top `space6` and bottom `footerBottomPadding` (`space8`); gap between body children `bodyGap` (`space6`). Content is at most 480 wide, centred. Type: `title1` title and `subheadline` subtitle by default.

Deviation: the design's step title is 30px, between `title1` (28) and `largeTitle` (34); `title1` is used. The frame's 24px footer bottom and 18px gaps are `space8` and `space6`.

## Change log

- Alpha fidelity rebuild (auth2) — adds this component.
- KAN-426 (close) — adds `titleGap` (default `space2`; the email, log-in, code and welcome-back frames give `space3`, 9px, between title and subtitle).

## Source

`lib/src/layout/flow_page.dart`
