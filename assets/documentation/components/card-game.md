<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/card_game.dart (class dartdoc)
           lib/src/cards/card_game_gallery.dart (specimen "CardGame — a game
           in a listing")
           design: Listings.dc.html:207-262 (the game card)
-->

# CardGame
### `DabblerCardGame`

CardGame is a game in a listing, drawn without a cover as a title with tags on the start side, the
day and time on the end side, a place line, the player progress beside the price, and the join
action.

It composes `Card`, `Text`, `Icon` and the listing slots of the event cards.

## Specimen

@specimen card-game/social

Full, and title-and-time only — see `card_game_gallery.dart`'s *CardGame* section.

@specimen card-game

As a meetup — badges, attendees, an RSVP action and social counts:

@specimen card-game/meetup

## Using it

**Pass tags as `ListingTag`s.** The tag row wraps; the card does not model sport, format or skill.

**Fill only the slots the screen has.** Every slot except the title is optional; absent progress,
price and action drop their rows with their gaps.

**Use the event cards' listing slots.** `progress`, `price` and `action` are the same
`DabblerCardEventPlayers`, `DabblerCardEventPrice` and `DabblerCardEventListing.joinButton` the
event cards take.

## Axes

### Direction
Title and tags at the inline start, day and time at the inline end; the progress bar fills from the
inline start and the price sits at the inline end.

### Interaction
With `onTap` the whole card is one button; `action` and `trailing` keep their own targets.

## Tokens used

Row gap `space4`, section gap `stackDefault`, tag gap `space2`. Title `headline` semibold, time
`figureLarge` (20/26 bold), day `caption1` in brand ink, place line a `MetaLine`. Shell: the white
card at the listing corner (`DabblerCardEventListing.cardRadius`, 18) and padding.

Deviation: the verified tick is `iconInline` (15) where the design draws 16.

## Change log

- KAN-429 (Meetups) — the card is the white variant (`--surface-card` with the hairline), as the Listings frame draws it; it was the tonal fill.
- Alpha fidelity rebuild (KAN-426) — adds this component.
- KAN-429 (Meetups) — no change to the card: a meetup is this card with badges as `tags`, `MeetupAttendees` as `progress`, an `RsvpCta` as `action` and `FeedAction`s as `trailing`.
- KAN-426 (Seat B) — adds `accent`: tints the card fill with a sport's accent at 12% over the card fill. A derivation of the persona-card recipe, not a Listings frame.
- Listings fidelity pass — the time is `figureLarge` (20/26) as the frame draws it; the corner is the listing card's 18; the place line is a `MetaLine` with 3px dots; tags are `ListingTag`s; with `trailing`, Join takes half of what the social counts leave (`DabblerListingActionRow`).

## Source

`lib/src/cards/card_game.dart`
