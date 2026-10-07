<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/host_card.dart (class dartdoc)
           lib/src/cards/meetup_parts_gallery.dart (specimen "HostCard — who runs the meetup")
           design: Details.dc.html:277-284 (the community host block)
-->

# HostCard
### `DabblerHostCard`

HostCard shows who runs a meetup: the host's avatar, a role caption over the name and, optionally, a pill action such as `Follow`.

It composes `Avatar`, `Surface` and the type ramp.

## Specimen

With a Follow action, and the host alone — see `meetup_parts_gallery.dart`.

@specimen host-card

## Using it

**Omit the action when there is nothing to do.** No `actionLabel` draws the host alone.

**Pass the caption as the role.** `Community host`, `Host`.

## Axes

### Action
With or without the pill.

## Direction

The avatar leads at the inline start and the action sits at the inline end.

## Tokens used

Fill: the accent tile. Radius `lg`, padding `space5`, gap `space4`. Caption `caption2` at 60% ink, name `subheadline` semibold, pill `footnote` semibold on the page colour.

## Change log

- KAN-429 (Meetups) — adds this component.
- Details dark (Details.dc.html 2026-10-08) — the card fills from `tileAccentTone` and its caption from `tileSubInk` in dark; light is unchanged.

## Source

`lib/src/cards/host_card.dart`
