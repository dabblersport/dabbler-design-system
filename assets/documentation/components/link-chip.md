<!--
Component page, D-033 ten-part template, D-038's Actions tier.

Sources  : lib/src/controls/link_chip.dart (class dartdoc in full)
           lib/src/cards/profile_row_gallery.dart (specimen title:
           "LinkChip — copy the profile link")
           Profiles.dc.html:77-82.
-->

# LinkChip
### `DabblerLinkChip`

LinkChip is the small pill beside a profile handle that copies the profile link.

Idle it shows a link glyph; once `copied` it takes the success tint, swaps the glyph for a tick and reads `copiedLabel`. It owns no clipboard and no timer: the caller copies and resets the flag.

## Specimen

Idle and copied — see `profile_row_gallery.dart`'s *LinkChip* section.

@specimen link-chip

## Using it

**Reset `copied` yourself.** The design shows the confirmation for about two seconds; a timer in the caller does that.

**Pass `semanticLabel`.** The idle chip has no text, so the label is its only name.

## Axes

### State
Idle or copied.

## Tokens used

It is a `DabblerBadge`: the neutral tint when idle, the success status when copied.

## Change log

- Added for the Profiles design (KAN-426 fidelity pass).

## Source

`lib/src/controls/link_chip.dart`
