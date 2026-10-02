<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/rooms/mini_player.dart (class dartdoc in full)
           lib/src/rooms/rooms_gallery.dart (specimen title: "MiniPlayer — the collapsed room player")
           Live design project, design system 1.2.0 (read through DesignSync).
-->

# rMiniPlayer
### `DabblerMiniPlayer`

MiniPlayer is the collapsed room player: two speaker avatars, one caption line and a row of trailing glyph actions.

A 16px sunken bar with overlapped 28px avatars, a one-line caption in `caption-1` at weight 600, and icon actions with a 45px touch area. The source's `18/28` spans are icon slots, so they are drawn as icons, not sized from a type step.

## Specimen

See the *MiniPlayer* section of `rooms_gallery.dart`.

@specimen mini-player

## Using it

**Pass the caption, the seeds and the actions.** Each action names its icon, its accessible label and its tone; one without `onTap` is decorative.

**It holds no audio.** Playback and room state belong to the app.

## Axes

### Actions
Accent, muted or brand glyphs, linear or bold.

## Tokens used

Corner: the 16px card radius. Avatars: the 28px extra-small size. Icons: the 18px step. Type: caption-1 at weight 600.

## Change log

- Added from the live design project, design system 1.2.0.

## Source

`lib/src/rooms/mini_player.dart`
