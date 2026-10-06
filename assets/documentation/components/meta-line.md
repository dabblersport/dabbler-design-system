<!--
Component page, D-033 ten-part template.

Tier     : Composed cards
Sources  : lib/src/cards/meta_line.dart (class dartdoc, read in full)
           lib/src/cards/listing_cards_gallery.dart (specimen "MetaLine —
           place, distance, duration")
           design: Listings.dc.html:231-240 (card), :440-447 (upcoming)
-->

# MetaLine
### `DabblerMetaLine`

MetaLine is a glyph followed by short facts separated by small dots — where a game is, how far, how long.

The first fact is the place, set a step stronger; the facts after it are figures, each after a 3px round dot. Every child sits 5 apart on a card and 4 apart on the upcoming card.

## Specimen

The card size and the compact size.

@specimen meta-line

## Using it

**Pass formatted, localised facts.** Empty facts are skipped, so an optional distance can be passed as an empty string.

**Keep it to one line of short facts.** At a large text scale every fact may ellipsise rather than overflow.

**It reads as one sentence.** Screen readers hear the facts joined by commas; the glyph and dots are decorative.

## Axes

### Size
`card` (the footnote step, the first fact at medium weight) or `compact` (the caption-1 step).

@figure 5 lib/src/cards/meta_line.dart#gap
@figure 4 lib/src/cards/meta_line.dart#compactGap

## Direction

A row under the ambient direction: under Arabic the glyph sits at the right and the facts run leftwards.

## Tokens used

Facts: footnote or caption-1 in `textSecondary` — the frame's `--muted` is the demoted tertiary role under D-003(a), so the text takes the secondary role. Glyph and dots: `textTertiary`.

## Change log

- Listings fidelity pass — adds this component, from `Listings.dc.html:231-240`; `CardGame` and `CardUpcoming` draw their place rows with it.

## Source

`lib/src/cards/meta_line.dart`
