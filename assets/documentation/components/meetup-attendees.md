<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/meetup_attendees.dart (class dartdoc)
           lib/src/cards/meetup_parts_gallery.dart (specimen "MeetupAttendees — who is going and how many fit")
           design: Listings.dc.html:545-553 (the meetup card attendee row)
-->

# MeetupAttendees
### `DabblerMeetupAttendees`

MeetupAttendees shows who is going to a meetup: an avatar stack, the going count and the capacity line beside it.

It composes `AvatarGroup` and the type ramp.

## Specimen

Open, full, and with nobody yet — see `meetup_parts_gallery.dart`.

@specimen meetup-attendees

## Using it

**Put it in a game card's `progress` slot.** A meetup card is `CardGame` with this where the players bar goes.

**Say full in words.** `full` turns the capacity line to the error ink; the text must still read `Full`.

**Pass every attendee.** The stack shows the first three and a `+N` chip for the rest.

## Axes

### State
Open, full, or no attendees yet (no stack).

## Direction

The stack leads at the inline start and overlaps towards the inline end; the text follows it.

## Tokens used

Gap `space3`. Going count `footnote` semibold in primary ink; capacity `caption2` in secondary ink, or the error strong ink when full.

## Change log

- KAN-429 (Meetups) — adds this component.

## Source

`lib/src/cards/meetup_attendees.dart`
