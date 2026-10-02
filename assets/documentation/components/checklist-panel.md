<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/checklist_panel.dart (class dartdoc in full)
           lib/src/cards/panel_cards_gallery.dart (specimen title:
           "ChecklistPanel — the task rows")
           Live design project components/cards/rChecklistPanel.jsx, design system
           1.2.0 (read through DesignSync).
-->

# rChecklistPanel
### `DabblerChecklistPanel`

ChecklistPanel is the list of task rows inside a PanelCard, where a checked row goes muted.

Each row is a checkbox beside a one-line label, with a 6px gap between rows. The `dark` flag switches the label to page-coloured text for the ink panel.

## Specimen

See `panel_cards_gallery.dart`'s *ChecklistPanel* section.

@specimen checklist-panel

## Using it

**Pass the done state in and toggle it in the parent.** `onToggle` is called with the row index; the panel holds no state.

**The label is `subheadline` at weight 500.** The ramp has no 15/500, so it is a recorded weight override on a named step.

## Axes

### Row
Open or done; a done row is muted.

### Surface
The card panel, or `dark` for the ink panel.

## Tokens used

Gap: the 6px step between rows, 12px beside the checkbox. Type: subheadline at weight 500. Colour: the primary and secondary text roles, or page paper on ink.

## Change log

- Added from the live design project, design system 1.2.0 (`ChecklistPanel.jsx`).

## Source

`lib/src/cards/checklist_panel.dart`
