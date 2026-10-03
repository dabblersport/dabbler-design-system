<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/highlighted_text.dart (class dartdoc through
           "Deliberate deviation"; matchRanges)
           lib/src/forms/search_gallery.dart (specimen "HighlightedText — the
           matched part of a result")
           design: Search.dc.html:205, 247, 282, 392, 505 (the pre / match /
           rest spans)
-->

# HighlightedText
### `DabblerHighlightedText`

HighlightedText is a line of search-result text with the part that matched the query picked out —
brand colour, semibold, on a light brand tint.

It is plain `Text.rich` set in a ramp step, so it wraps, truncates and mirrors like any other
text in the system.

## Specimen

A title row, a body row with two matches, Arabic, and a Latin match inside an Arabic sentence —
see `search_gallery.dart`'s *HighlightedText* section.

@specimen highlighted-text

## Using it

**Pass the query exactly as typed.** Matching is case-insensitive and finds every occurrence,
left to right. An empty query, a query that does not occur, or one longer than the text all render
the plain string. Accents are not folded: `e` does not match `é`.

**A match never cuts a letter from its vowel sign.** The highlight is widened to take adjoining
combining marks with it, so a match on an Arabic base letter highlights the letter with its
tashkeel. Western digits are matched like any other character and are never rewritten.

**Set the weight for the row, not the match.** The match is always semibold; the design sets
result titles at 600 and body copy at 400, so pass `fontWeight` for the unmatched text.

**The highlight is not announced.** A screen reader reads the whole string as plain text.

**Don't use it for emphasis outside search.** The tint means "this is what you searched for".

## Axes

### Ramp step
Any `DabblerTypeStyle`, default `subheadline`. The design's result rows sit between two ramp steps and
have none of their own; choose the nearest.

### Line limit
Unbounded by default; `maxLines` with the default ellipsis for single-line rows.

## Tokens used

Matched run: `brandPrimary` text, `semibold` weight, on `brandPrimary` at 14% over `surfaceCard`.
Unmatched text: `textPrimary` unless `color` is given. The highlight is a square rectangle, not
the design's 3px rounding: 3 is not a radius token, and a rounded span would break wrapping and
ellipsis.

## Change log

- KAN-412 — new component.

## Source

`lib/src/forms/highlighted_text.dart`
