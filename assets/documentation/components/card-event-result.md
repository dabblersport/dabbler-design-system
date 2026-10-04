<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/cards/card_event_result.dart
           lib/src/cards/card_event_result_gallery.dart
           design: Search.dc.html (View_all_events)
-->

# CardEventResult
### `DabblerCardEventResult`

CardEventResult is one game or meet-up as a search result: a brand-tinted date tile, a kind badge
with the time, the title with the typed query picked out, the place and a trailing meta line, and
an optional pill action.

It draws the card, the tile and the text column itself, so the result list needs only the data.

## Specimen

A game with a Join action, and a meet-up with none.

@specimen card-event-result

## Using it

**Use it for search results only.** Event listings elsewhere use the `CardEvent` family.

**Pass `query` so the match is highlighted.** Leave it empty for no highlight.

**Give `actionLabel` only where the action does something.** With no label the card has no button.

## Axes

### Action
Present (`actionLabel`) or absent.

### Direction
The tile leads and the action trails in both directions.

## Tokens used

White card variant, `lg` radius, 12 padding; tile: brand tint, `md` radius; month in `caption2`
semibold and day in `headline` bold, both brand ink; badge, `caption1` secondary text, and the
`location` glyph in the tertiary ink.

## Change log

- Alpha fidelity (Search) — adds the component.

## Source

`lib/src/cards/card_event_result.dart`
