<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/action_area.dart (class dartdoc in full — phases,
           sequence, motion, colours, direction, safe area, accessibility)
           lib/src/feedback/action_area_gallery.dart (specimen titles:
           "Action Area — system states", "Action Area — completion")
           Design: components/feedback/status-feedback.card.html, sections
           "Navigation interaction preview" and "Action Area · system states"
           (the card was the readable source this session; ActionArea.jsx
           itself was not mirrored)
-->

# ActionArea
### `DabblerActionArea`

ActionArea is the bottom navigation acting as one surface for loading, progress and status: the real bottom bar, with one morphing surface over its action footprint.

The bar moves from navigation, to loading, to progress, to status, and every one of those states is
the same container. In the collapsed phase the action button's circle becomes the surface — a
brand circle with a spinner while something is working, a tone circle with a glyph once there is a
result. In the expanded phase that circle grows along the bar to the bar's full width, carrying a
toast, a banner, a labelled spinner or a progress row. Two components are built on it and are what
an app normally places: `NavigationFeedback` for toasts and banners, `NavigationActivity` for
loading and progress.

## Specimen

Every reusable state — idle navigation, loading compact and labelled, progress determinate,
indeterminate and on the ring, and the four status tones — see `action_area_gallery.dart`'s
*Action Area — system states* section.

@specimen action-area/system-states

How activity resolves into feedback: the brand circle changes tone, then expands; or the ring
closes, then becomes the tone glyph. The application composes these steps; nothing here runs them
in sequence for you.

@specimen action-area/completion

## Using it

**Reach for `NavigationFeedback` or `NavigationActivity`, not this widget.** ActionArea is the
shared base: it takes a phase, a fit, three colours, a glyph and the expanded content, and nothing
else. The two components above it know which colours, glyphs and content each state draws.

**The bar is hidden only while expanded.** Collapsed, the destinations beside the circle stay live;
expanded, the bar fades out and takes no input, focus or announcement until the phase changes.

**Drive the phase; don't animate it yourself.** `idle`, `collapsed` and `expanded` are the only
states. The widget owns the order of the two steps inside a change — growth before the content
fades in, the content fading out before the shrink — and nothing else.

**Pass the real bar, and let the area own the safe area.** The bar is rendered verbatim beneath the
surface. The device's bottom inset is applied once, below both; the bar's own inset is removed so
the two cannot stack.

**Don't put it over a create menu, a dialog or a sheet.** The bar must be in its ordinary state,
and the screen must have one.

## Axes

### Phase
`idle` (the bar alone), `collapsed` (a circle exactly over the action, glyph centred), `expanded`
(grown to the bar's width).

### Fit
`row` keeps one action-footprint row and the pill radius; `content` grows up to the content's own
height, never shorter than a row, with the radius easing to the create menu's.

### Role
`status` (polite) or `alert` (interrupting — error and warning banners only).

## Direction

**The surface is anchored at the inline end, like the action it replaces.** In Arabic it
originates on the left and grows rightward, and the glyph leads on the right. The glyph is placed
from the surface's leading edge, inset so that it is centred in the collapsed circle (the border
counted), so it rides the growth instead of staying behind on the action; it is bottom-anchored,
or held at the top of a content-fitted surface once expanded. If the bar is pinned unmirrored, the surface pins with it so it is always over
the action.

## Tokens used

Two new structural tokens and no new colours: the action-area size (the footprint — the circle's
diameter and every row's height, defined as the bar's own height) and the action-area hold (how
long the circle shows before it expands and before it returns to idle). Size and radius move on the
slow motion step with the system easing; background, border and ink on the base step; the content
fades in on the base step after the growth, and out on the fast step before the shrink; the bar
fades on the base step. Content sits after the glyph with the small spacing step between, on the
medium gap, with the fifteen-pixel step at the inline end (and top and bottom for a content fit).
Content surfaces end on the extra-large radius; rows stay a pill. Colours are always the caller's.

## Source

`lib/src/feedback/action_area.dart`
