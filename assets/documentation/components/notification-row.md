<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/feed/notification_row.dart
           lib/src/feed/feed_gallery.dart (specimen title:
           "NotificationRow — one entry in the notification list")
           Claude Design file "Notifications.dc.html", the row at lines 116-175.
-->

# NotificationRow
### `DabblerNotificationRow`

NotificationRow is one entry in the notification list: who or what, what happened, when, with an optional status pill, an unread dot, a meta line and up to two actions.

The leading widget is yours: an avatar, an avatar group, or a `DabblerActivitySystemTile`. The row sits on a hairline rather than in a card.

## Specimen

A person with a pill, meta and two actions, a system tile, and an Arabic row in right-to-left — see `feed_gallery.dart`.

@specimen notification-row

## Using it

**Pass the leading widget, not a kind.** A small avatar for a person, an avatar group for several, a system tile for anything else.

**Actor and verb read as one sentence.** The actor is in primary ink and the verb in secondary.

**The unread dot follows the time.** Pass `unread` and the brand dot is drawn after it.

**Actions are filled or outlined.** At most two, in small buttons under the row.

## Axes

### Leading
Avatar, avatar group or system tile.

### State
Read or unread; with or without a pill, meta line and actions.

## Direction

Everything mirrors: the leading widget sits at the inline start and the dot and time at the inline end.

## Tokens used

`DabblerColors` text and border roles, `DabblerSpacing`, `DabblerType.subheadline` and `caption1`.

## Change log

- Added for the Notifications fidelity rebuild.

## Source

`lib/src/feed/notification_row.dart`, `Notifications.dc.html`.
