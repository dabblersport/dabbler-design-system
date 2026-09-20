<!--
Component page, D-033 ten-part template.

Group    : Identity and status
Sources  : lib/src/surfaces/rating.dart (read in full through the class
           dartdoc's colour table, empty-star deviation note, and the
           "rendered inverted while it was being built" section; constructor
           and value/max/onChanged fields)
           lib/src/surfaces/rating_gallery.dart:20 (specimen title: "Rating
           — evaluation")
           DECISIONS.md D-025 (read in full, prior session — origin of the
           bounded non-informational --muted permission), D-027 (read in
           full, prior session — names Rating's empty star by name as one of
           the two glyph-exception cases), D-037 (read in full this
           session — sharpens the same bound; Rating's own shipped colour
           already matches it, so no correction needed here unlike InputRow)

D-037(c) COMPLIANCE NOTE: rating.dart's own dartdoc states the empty star's
deviation from the design drawing using two hex/rgb values. Per D-037(c),
this page does not transcribe them — the deviation is described
qualitatively (colder, darker than the drawing) with a pointer to the
ruling that requires it, not the measured colours themselves.

Direction: NO section. The fractional star-fill clip anchors at the logical
inline start, so it mirrors under RTL the same way any directional-clip
rendering does — uniform mirroring, not an exception or a semantic
consequence (a 60%-filled star means the same thing regardless of which
physical side fills first).
-->

# Rating
### `DabblerRating`

Rating is a score, shown or collected — whole or fractional stars, read-only unless given a
callback.

Passing `onChanged` is the only switch between read-only and interactive — there's no separate flag
to disagree with it. A fractional value is never drawn as a half-star glyph, because no such glyph
exists in this system's icon set; it's produced by clipping a filled star over an empty one at the
exact fraction, so any value works, not only halves.

## Specimen

Whole and fractional values, both sizes, read-only and interactive — see `rating_gallery.dart`'s
*Rating* section.

## Using it

**Don't be surprised the empty star renders a colder, darker grey than the design file's own
drawing.** That's a deliberate, ruled difference, not a bug to "fix" toward the drawing — the
drawing's own empty-star colour fails this system's text-contrast rule, and painting a component to
match a rejected colour would undo an accessibility decision to win a pixel comparison. If the rule
ever changes, the fix lands in the colour role, not in this widget.

**If a weight looks inverted anywhere in this system — a filled glyph where an outline belongs, or
the reverse — check the icon registry before assuming Rating (or whichever component you're
looking at) is wrong.** This exact component shipped with its filled and empty stars swapped early
on, and the cause was the shared icon registry mapping weights to the wrong underlying glyphs, not
anything in this file — the same class of bug is far more likely to recur in the registry than in
any one component that consumes it.

**Give `count` when the number of ratings matters to the reader, not just the average.** `4.2 (128)`
reads differently from a bare `4.2` — pass both when you have both, rather than dropping the count
because the average alone looks cleaner.

## Axes

### Size
`sm` (18, for inside cards), `md` (24, the default), `lg` (30, for a review sheet).

### Mode
Read-only (no `onChanged`) or interactive (`onChanged` set).

### Value display
Stars only, or stars with the numeric value and count.

## Tokens used

Filled star: the warning status tone's bare indicator role. Empty star: `textTertiary`, the
non-informational-glyph exception — see the Colour foundation page. Value and count text:
`textSecondary`.

## Change log

- D-025 (cxo) — establishes the bounded permission for
  `textTertiary` on a non-informational glyph, which the empty star relies on.
- D-027 (cxo) — names Rating's empty star directly as one of
  the two glyph exceptions to the text-colour rule.

## Source

`lib/src/surfaces/rating.dart`
