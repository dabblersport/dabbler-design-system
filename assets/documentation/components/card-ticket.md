<!--
Component page, D-033 ten-part template, D-038's Composed cards tier.

Tier     : Composed cards
Sources  : lib/src/cards/card_ticket.dart:1-95 (DabblerTicketHeader,
           DabblerTicketStatusTone enums in full, class dartdoc opening)
           lib/src/cards/cards_gallery.dart:36 (specimen title: "Card —
           house, pricing, ticket")
           DECISIONS.md D-015 (read in full this session), D-004 (read in
           full, prior session — CardTicket's indigo header default shares
           the same known defect as Button/Fab/Avatar)
-->

# CardTicket
### `DabblerCardTicket`

CardTicket is a booking as a ticket — a coloured header strip carrying a reference and title, a
status pill, and one or two actions, with its own self-contained type scale.

It's deliberately not a generic card dressed in ticket colours: the design file gives it a complete
type scale of its own, five header colours and eleven status-pill tones — four of them booking-
specific aliases pointing at the same seven workflow tags every status tag in the system already
uses, kept distinct because the product says "upcoming," not "progress."

## Specimen

Alongside CardHouse and CardPricing — see `cards_gallery.dart`'s *Card — house, pricing, ticket*
section.

## Using it

**Never compose `Badge` for the status pill.** It was tried and reversed: `Badge`'s 11px bold with
a hairline doesn't match the ticket's own type scale, and it adds a border the ticket draws nowhere
else. The status pill is built directly at the ticket's own size and weight instead.

**Use the four booking-alias status tones (`upcoming` and its siblings) rather than translating
them to the underlying workflow tag yourself.** They exist specifically so the product's own
vocabulary reaches the component untranslated — a caller doing that translation itself is exactly
the mistranslation risk these aliases were added to prevent.

**Don't treat the `indigo` header tone as a stable colour yet.** It's the source's own default and
carries the same known accent-indigo stand-in as Button's `accent`, Fab's `indigo` and Avatar's
`indigo` badge tone.

## Axes

### Header tone
Five: `brand` (the only one that follows the active theme), `indigo` (the source's default — known
defect, see *Change log*), `amber`, `mint` (the one header reading off the real status API), `pink`.

### Status tone
Eleven: seven workflow tags plus four booking aliases (`upcoming` and siblings), each alias pointing
at one of the seven.

### Actions
One action (a past booking) or two (an active one).

## Tokens used

Header fill and ink vary by tone — four decorative tile roles plus one theme-following brand role
and one true status role (`mint`). Status pill: built at the ticket's own 13px/weight-500 scale, no
border, pill radius — deliberately not composed from `Badge`.

## Change log

- D-004 (cxo) — the `indigo` header tone's fill is the same
  known, documented defect as Button's `accent`, Fab's `indigo` and Avatar's `indigo` badge tone.
- D-015 (cxo) — the status pill is built literal, at the
  ticket's own type scale, rather than composed from `Badge`.

## Source

`lib/src/cards/card_ticket.dart`
