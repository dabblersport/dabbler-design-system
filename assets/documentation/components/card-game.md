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

Full, and title-and-time only — see `card_game_gallery.dart`'s *CardGame* section.

@specimen card-game

## Using it

**Pass tags as `Chip`s.** The tag row wraps; the card does not model sport, format or skill.

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
`headline` bold, day `caption1` in brand ink, place line `footnote`.

Deviation: the time is `headline` bold (17) where the design draws 20/26 sans bold — the ramp's 20 step is the display face. The verified tick is `iconInline` (15) where the design draws 16.

## Change log

- Alpha fidelity rebuild (KAN-426) — adds this component.
- KAN-426 (Seat B) — adds `accent`: tints the card fill with a sport's accent at 12% over the card fill. A derivation of the persona-card recipe, not a Listings frame.

## Source

`lib/src/cards/card_game.dart`
