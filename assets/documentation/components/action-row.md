<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/action_row.dart (class dartdoc, incl. the
           design-to-Dart table)
           lib/src/overlays/sheet_gallery.dart (specimen title:
           "ActionRow — one action in a sheet")
           Claude Design file "Home Feed.dc.html", the Post options sheet
           (lines 444-465).
-->

# ActionRow
### `DabblerActionRow`

ActionRow is one action in a bottom sheet: a leading glyph, the action's name and a one-line note under it, on a sunken tile.

A destructive action draws the glyph and name in the error ink.

## Specimen

A default action with a note, a destructive one, one with no note and an Arabic row in right-to-left — see `sheet_gallery.dart`.

@specimen action-row

## Using it

**Stack rows in a sheet body with a gap between them.** Each row is its own tile; the sheet's title says what the actions are for.

**Give every row a name and, when it helps, a note.** The note says what the action does or what happens next.

**Mark risky actions destructive.** Reporting or blocking take the error ink; the row's shape does not change.

## Axes

### Tone
Default or destructive.

### Note
With or without the second line.

## Direction

The glyph leads and the text follows it; both mirror under right-to-left, and type resolves to the Arabic metrics.

## Tokens used

Surface: sunken, with the 12px large radius. Ink: primary, secondary for the note, error for a destructive row. Spacing: 12, 15 and 12. Type: subheadline and caption-1. Size: a 20px glyph.

## Change log

- KAN-433 (Home fidelity) — adds `metrics`. Drawn is the post-options sheet's row: 14 above and below, a 1 gap between label and note, and a flat sunken fill with no hairline — 65 high with a note (68 under the Arabic leading). Default unchanged.
- Added from the Home Feed design file.
- KAN-429 (Meetups) — adds `selected`: the brand fill, on-brand ink and a bold glyph, the meetup RSVP sheet's chosen answer.

## Source

`lib/src/overlays/action_row.dart`
