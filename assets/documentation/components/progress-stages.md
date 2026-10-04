<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/progress_stages.dart (class dartdoc)
           lib/src/feedback/progress_stages_gallery.dart (specimen
           "ProgressStages — the steps of a setup")
           design: Auth and Onboarding.dc.html:463-486, :2076-2093
-->

# ProgressStages
### `DabblerProgressStages`

ProgressStages is the list of named stages under a progress bar while something with several writes, such as account setup, is being done.

Each stage is pending, running, done or failed, and says so with its glyph, its weight and its fade.

## Specimen

A running setup and a failed one — see `progress_stages_gallery.dart`'s *ProgressStages* section.

@specimen progress-stages

## Using it

**Set one stage running at a time.** The running stage has the spinner and the semibold label; stages after it stay pending.

**Show a failure on the stage that broke.** The failed stage carries the danger glyph; a `Banner` below says what happened and a button offers the retry.

**Don't use it for the bar itself.** The bar is `ProgressBar`.

## Axes

### Status
Pending: a small grey dot and a faded label. Running: a small spinner and a semibold label. Done: a bold success tick. Failed: a bold danger glyph in the error colour and a semibold label.

### Direction
The glyph sits at the inline start.

## Tokens used

Row gap `space5`, glyph to label `space4`. Glyph box `iconMd`; tick and danger `iconRow`; dot `dot`. Label `body`. Motion: `base` for the fade, snapped under reduced motion.

Deviation: the design's 22px glyph is `iconRow` (21).

## Change log

- Alpha fidelity rebuild (auth2) — adds this component.

## Source

`lib/src/feedback/progress_stages.dart`
