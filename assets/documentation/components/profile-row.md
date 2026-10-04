<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/profile_row.dart (class dartdoc in full)
           lib/src/cards/profile_row_gallery.dart (specimen title:
           "ProfileRow — the profile list row")
           Profiles.dc.html:208-222 and :254-264.
-->

# ProfileRow
### `DabblerProfileRow`

ProfileRow is the list row the profile screens use for games, hosted games, courts and a user's own sports.

It has an optional lead block (a figure over a caption, or a weekday over a day), a title, a sub-line and a tag pill, on a card or on a status-tinted surface. With `onTap` it is a button with the shared focus ring and press scale; without it the row is inert.

## Specimen

Games rows and every tint — see `profile_row_gallery.dart`'s *ProfileRow* section.

@specimen profile-row

## Using it

**Pick the tint from the row's meaning.** `success`, `warning`, `info` and `error` take the status surface; `neutral` is the card.

**Use `captionFirst` for dates.** The games rows put the weekday above the day; the other rows put the figure above its caption.

**Pass `onTap` only when the row navigates.** The accessible name is the title, sub-line and tag read together unless you pass `semanticLabel`.

## Axes

### Tone
`neutral`, `success`, `warning`, `info`, `error`.

### Interactivity
Inert or a button.

## Tokens used

Corner: the 12px large radius, 9px for the lead block. Fill: the card and status surfaces. Type: title-3 for the figure, subheadline at weight 600 for the title, footnote for the sub-line, caption-2 at weight 600 for the caption.

## Change log

- Added for the Profiles design (KAN-426 fidelity pass).

## Source

`lib/src/cards/profile_row.dart`
