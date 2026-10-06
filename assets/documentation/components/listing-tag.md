<!--
Component page, D-033 ten-part template.

Tier     : Surfaces
Sources  : lib/src/surfaces/listing_tag.dart (class dartdoc, read in full)
           lib/src/cards/listing_cards_gallery.dart (specimen "ListingTag —
           the listing card pills")
           design: Listings.dc.html:221, 527, 779-791, 798 and the TONES
           table at :1781-1790
-->

# ListingTag
### `DabblerListingTag`

ListingTag is the small pill a listing card labels itself with — sport, format, skill, a status, a distance — in the Listings frame's own recipe.

It is not `Badge`. `Badge` is the system badge (11 bold at 1.5 leading inside a 20% hairline); the listing frame draws its tags 11/15 at weight 600 with no hairline, 23 tall, and the venue card's sport chips outlined at 12/16 weight 500, 28 tall.

## Specimen

Every tone, the solid distance chip and the outlined sport chip.

@specimen listing-tag

## Using it

**Pick the tone by meaning, not by colour.** `info` is the sport or activity, `brandTint` the format or setting ("Futsal 5s", "Outdoor"), `success` / `warning` / `error` the skill (Beginner / Intermediate / Advanced) or a status, `neutral` a requirement note, `brand` a quiet brand label.

**The distance chip is `solid` with a pin.** `DabblerCardVenue.distanceTag` builds it.

**Use `.outlined` for a venue's sports.** It is the only outlined form.

**Pass localised words.** The tag draws what it is given; the colour only reinforces the words.

## Axes

### Tone
Eight fill and ink pairs: the four status pairs, `brand`, `brandTint`, `neutral` and `solid`.

@figure 4 lib/src/surfaces/listing_tag.dart#paddingBlock
@figure 10 lib/src/surfaces/listing_tag.dart#paddingInline

### Outlined
The venue sport chip: card surface, card hairline, a little more padding than the filled tag.

@figure 5 lib/src/surfaces/listing_tag.dart#outlinedPaddingBlock

## Direction

The optional glyph leads at the inline start, so under Arabic it sits at the right of the label.

## Tokens used

Label: the tag step (11/15, 600) or caption-1 at medium for the outlined chip. Fills: the status `surface` roles, `surfaceSunken`, `surfaceCard`, `brandPrimary`, and brand at 12% over the card. Inks: the status `strong` roles, `brandPrimary`, `textSecondary`, `onBrand`. Corner: the pill radius.

## Change log

- Listings fidelity pass — adds this component, from `Listings.dc.html`; the listing cards move to it from `Badge`.

## Source

`lib/src/surfaces/listing_tag.dart`
