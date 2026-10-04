<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/cards/headcount.dart (class dartdoc)
           lib/src/layout/detail_gallery.dart (specimen "Headcount")
           design: Details.dc.html:79-91, 246-253
-->

# Headcount
### `DabblerHeadcount`

Headcount shows who is going: avatars beside a headline figure and a caption, with an optional fill bar.

The avatar cluster is a slot, the headline is the design's large bold figure, and a bar under the row shows how full the game is.

## Specimen

A filling game and a full one, in both directions — see `detail_gallery.dart`.

@specimen headcount

## Using it

**Pass the avatar cluster in.** Normally a `DabblerAvatarGroup`.

**Use `critical` for a full game.** The caption and bar turn to the error tone.

## Axes

### Bar
`progress` null draws no bar.

### Direction
Avatars at the inline start; the bar fills from the start.

## Tokens used

`headline` at the design's 20/25 bold, `caption1`, `ProgressBar`.

## Change log

- KAN-426 fidelity rebuild — adds this component.

## Source

`lib/src/cards/headcount.dart`
