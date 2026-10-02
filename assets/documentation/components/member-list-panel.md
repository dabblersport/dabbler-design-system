<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/member_list_panel.dart (class dartdoc in full)
           lib/src/cards/panel_cards_gallery.dart (specimen title:
           "MemberListPanel — the people rows")
           Live design project components/cards/rMemberListPanel.jsx, design system
           1.2.0 (read through DesignSync).
-->

# rMemberListPanel
### `DabblerMemberListPanel`

MemberListPanel is a list of people with a name, a role and a round add or remove button.

Each row has a small avatar seeded from the name, the name and role stacked, and a 32px round button that is drawn outlined when the person is not added and filled with a minus when they are. The button's hit area is the full 45px target.

## Specimen

See `panel_cards_gallery.dart`'s *MemberListPanel* section.

@specimen member-list-panel

## Using it

**Pass `added` per person and toggle it in the parent.** `onToggle` is called with the row index.

**The name is `subheadline` at weight 700 and the role is `footnote`.** The weight is a recorded override on a named step.

## Axes

### Row
Not added (outlined plus) or added (filled minus).

### Surface
The card panel, or `dark` for the ink panel.

## Tokens used

Gap: the 12px step. Avatar: the small size. Type: subheadline at weight 700, footnote. Button: 32px drawn, 45px target. Colour: ink, page paper and the card outline.

## Change log

- Added from the live design project, design system 1.2.0 (`MemberListPanel.jsx`).

## Source

`lib/src/cards/member_list_panel.dart`
