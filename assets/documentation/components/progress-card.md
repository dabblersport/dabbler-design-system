<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/progress_card.dart (class dartdoc)
           lib/src/feedback/progress_card_gallery.dart (specimen "ProgressCard — one stage of a multi-stage goal")
           app: early-bird check-in challenge (no design frame)
-->

# ProgressCard
### `DabblerProgressCard`

ProgressCard is one stage of a short multi-stage goal.

It holds a badge naming the stage, a tick when it is done, a count at the inline end, and a progress
bar underneath.

## Specimen

Active, completed and Arabic — see `progress_card_gallery.dart`.

@specimen progress-card

## Using it

**One card per stage.** Stack them with a gap; mark the stage in progress `active`.

**Say the count in words.** `caption` is the string at the inline end ("3/7 days"); the bar shows the
same fraction.

## Axes

### Active
Active sets the card on the brand tint and the count in the brand ink; otherwise the grey surface and
the secondary ink.

### Completed
Adds the bold brand tick after the badge.

## Direction

Badge and tick at the inline start, count at the inline end, bar filling from the inline start.

## Tokens used

`DabblerSurface` brand-tint / grey variants, `DabblerInsets.card`, `DabblerBadge`,
`DabblerProgressBar` small. Type: caption1.

## Change log

- Alpha fidelity (KAN-426) — adds this component for the check-in challenge.

## Source

`lib/src/feedback/progress_card.dart`
