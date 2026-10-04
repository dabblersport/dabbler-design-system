<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/navigation/step_progress.dart (class dartdoc)
           lib/src/navigation/step_progress_gallery.dart (specimen
           "StepProgress — where a multi-step flow is")
           design: Auth and Onboarding.dc.html:333-339, :1386-1388
-->

# StepProgress
### `DabblerStepProgress`

StepProgress is the segmented bar at the top of a multi-step flow: one segment per step, filled up
to the step on screen, with an optional "Step 3 of 5" label under it.

It only shows where the flow is. Moving between steps is the screen's job.

## Specimen

The first, middle and last of five steps — see `step_progress_gallery.dart`'s *StepProgress*
section.

@specimen step-progress

## Using it

**`current` is zero-based.** The segment at `current` and every one before it are filled.

**Pass the localised label.** The bar reads it to assistive technology; without one it reads
"Step N of M" in English.

**Don't use it for loading.** Progress toward a known end inside one screen is `ProgressBar`.

## Axes

### Step
Completed and current segments carry the brand fill; upcoming segments carry the faint fill. The
fill crossfades as the step changes, and snaps under reduced motion.

### Direction
Step one sits at the inline start — the right edge in right-to-left layouts.

## Tokens used

Filled: `brandPrimary`. Upcoming: `bgTertiary` (`--faint`). Radius: `pill`. Label: `caption1`
semibold, uppercase, in `textTertiary`. Motion: `base` with `easeOut`.

Deviation: the design draws 4px segments with a 5px gap; no such tokens exist, so the segment is
`space1` (3) tall and the gap is `space2` (6).

## Change log

- KAN-426 (round 2) — the segments are now 4 high with a 5 gap, as the frame draws them (were 3 and 6, the nearest grid steps). No 4 or 5 token exists on the 3pt grid, so they are named literals `defaultSegmentHeight` and `defaultSegmentGap`; `segmentHeight` and `segmentGap` override them (pass `DabblerSpacing.space1` and `space2` for the old look). No other frame draws a `DabblerStepProgress`.
- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/navigation/step_progress.dart`
