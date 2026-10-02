<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/rooms/speaker_grid.dart (class dartdoc in full)
           lib/src/rooms/rooms_gallery.dart (specimen title: "SpeakerGrid — the room speakers")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rSpeakerGrid
### `DabblerSpeakerGrid`

SpeakerGrid shows a room's speakers in three columns: a 64px avatar with an optional corner badge and a name under each.

Cells are 96 by 88 with a 16px gap; the badge is a 24px circle with a 2px ring, either a bold microphone on the brand fill for a speaker or a plus on the accent fill for an invite. The source draws six fixed cells; the grid takes any number and adds rows.

## Specimen

See the *SpeakerGrid* section of `rooms_gallery.dart`.

@specimen speaker-grid

## Using it

**Pass the speakers row-major.** Seeds default to the name; the badge is `none`, `speaking` or `invite`.

**Each cell is announced as one item**, with ', speaking' added for an active speaker.

## Axes

### Badge
None, speaking or invite.

## Tokens used

Cells: 96 by 88 with a 16px gap. Avatar: the 64px large size. Badge: 24px with a 2px ring. Type: caption-1 at weight 600 and caption-2 for the plus.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/rooms/speaker_grid.dart`
