<!--
Component page, D-033 ten-part template.

Group    : Structure
Sources  : lib/src/cards/list_row.dart (class dartdoc)
           lib/src/layout/detail_gallery.dart (specimen "ListRow and ListGroup")
           design: Details.dc.html:101-146, 466-478
-->

# ListRow
### `DabblerListRow`, `DabblerListGroup`

ListRow is one row of a detail screen's list: a leading slot, a title with an overline and a subtitle, and a trailing slot, stacked in a rounded group with hairlines between.

A row is a title with an optional overline and subtitle between two slots; a group stacks rows on a sunken or tinted panel and draws the hairlines.

## Specimen

Squad rows with a tag, and a contact group with chevrons, in both directions — see `detail_gallery.dart`.

@specimen list-row

## Using it

**Slots are widgets.** Avatars, icon tiles, badges and buttons all fit; the row owns padding and text.

**Group tone follows the content.** Sunken for people, info for the host and contacts.

## Axes

### Tone
Sunken, info, accent or amber fill on the group.

### Flat
`flat: true` is the sheet-list form: no inline padding and a hairline under the row (Listings "Change location"); `brand: true` sets the title in the brand colour ("Use current location").

### Interaction
With `onTap` the whole row is a button; `showChevron` adds the mirrored forward arrow.

## Tokens used

`subheadline`, `caption1`, `caption2`, surface and tile fills, `DabblerRadius.lg`, spacing steps 4–5.

## Change log

- KAN-433 (Home fidelity) — adds `metrics`. Drawn is the city sheet's area row: the title at the regular weight and 1 between title and subtitle, so a flat row with a subtitle is 62 with its hairline (61 by default).
- KAN-426 fidelity rebuild — adds these components.
- KAN-426 closing pass — `flat` and `brand` options for the Change-location sheet rows.

## Source

`lib/src/cards/list_row.dart`
