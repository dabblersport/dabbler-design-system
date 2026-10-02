<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/panel_card.dart (class dartdoc in full)
           lib/src/cards/panel_cards_gallery.dart (specimen title:
           "PanelCard — the framed panel")
           Live design project components/cards/rPanelCard.jsx, design system
           1.2.0 (read through DesignSync).
-->

# rPanelCard
### `DabblerPanelCard`

PanelCard is the framed panel: a coloured outer frame with a header row, an inset content panel and a footer with a text link and prev/next arrows.

The frame is 24px round with a 6px inset around an 18px panel; the body collapses with the system's one collapse animation and the chevron reports whether it is expanded. Everything shown — title, body, footer — is supplied by the caller.

## Specimen

See `panel_cards_gallery.dart`'s *PanelCard* section.

@specimen panel-card

## Using it

**Give it a body and let it frame it.** Put a `DabblerChecklistPanel` or `DabblerMemberListPanel` inside; set `headerInside` to false when the child draws its own header.

**An arrow with no callback is dimmed and inert.** Pass `onPrev` and `onNext` only for the directions that exist.

**The title is `headline` at weight 700 and the footer label is `subheadline` at weight 600.** Both are recorded type overrides on named steps, not new steps.

## Axes

### Tone
`brand`, `amber`, `info`, `sport`, `active`.

### Panel
The card surface, or `dark` for the ink panel.

### State
Expanded or `collapsed`.

## Tokens used

Frame: 24px radius; panel: 18px radius; inset: 6px. Colour: the brand, tile-amber, status-info-solid, sport and active roles, on the surface-card or ink panel. Type: headline and subheadline. Touch targets: the 45px step.

## Change log

- Added from the live design project, design system 1.2.0 (`PanelCard.jsx`).

## Source

`lib/src/cards/panel_card.dart`
