<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/navigation/top_bar.dart:1-135 (DabblerNavigationAction,
           DabblerNavigationTopBar's full class dartdoc through the safe-area
           section, constructor and barHeight/barPadding fields)
           lib/src/navigation/navigation_gallery.dart:25 (specimen title:
           "Navigation — top bar")
           DECISIONS.md D-026 (read in full this session — rules that the
           kit's greeting-stack variant temptation must be refused), D-032
           (read in full this session — rules the touch-target/pitch fix)

Direction confirmed by team-lead reading top_bar.dart directly, and
independently confirmed here: the wordmark is never mirrored because a
wordmark is text, not a mirrored glyph (top_bar.dart's own "RTL" section
states this explicitly).

CORRECTED by team-lead, who read top_bar.dart directly after my report
conflicted with what an implementing agent had told them: the 34x45
trailing-action hit-box half of D-032 IS shipped — confirmed here too,
directly, at top_bar.dart:150-159 (`actionTarget = Size(34,
DabblerSizing.touchTargetMin)`, dartdoc citing D-032 by name). I had
described the whole ruling as "not yet shipped"; only the barHeight half
is.

UPDATED again per D-039: the barHeight "69 > 62" conflict I described
above (from top_bar.dart's own comment) is FALSE, not merely unresolved.
cxo found the bar's interior is 60 (62 minus 1px borders top and bottom),
the padding is border-box, and the 12px gap the file's comment blamed is
horizontal pitch (D-032(a)'s 34), not vertical — a 45-tall hit box centred
in a 60px interior fits with 7.5px to spare on each side; nothing painted
moves. Ruled: barHeight becomes a hard 62 (fixed, not minHeight).
NOT YET SHIPPED — still BoxConstraints(minHeight:) as of this write —
po ticketed as KAN-319, with an explicit requirement that the false
"69 > 62" reasoning at top_bar.dart:80,123-127 be replaced, not softened.
Per team-lead's flag: I had faithfully transcribed that reasoning as real
in my own earlier edit ("45-tall targets plus vertical padding add up to
more than 62") — that sentence was never true, and D-037(c) treats a
dartdoc's stated REASON as a verifiable claim same as a number, not just
the value it explains. Dropped the conflict framing entirely below;
described only what renders (a minimum expanding to fit) plus the ruled,
unshipped fixed-62 outcome.
-->

# TopBar
### `DabblerNavigationTopBar`

TopBar is the app's identity row — the Dabbler wordmark at the inline start, trailing icon actions
and the account avatar at the inline end.

It's a verbatim export with a narrow, fixed anatomy: no title, no back action, no alignment or
surface variants exist because the design draws none. A screen that needs a greeting, a back
action or an overflow menu doesn't extend this component — it composes `Section`, `Button`, `Icon`
and `Avatar` directly, the same way `ConversationHeader` already does.

## Specimen

Default with trailing actions and the account avatar — see `navigation_gallery.dart`'s *Navigation
— top bar* section.

@specimen top-bar

An action with `unread: true` carries the brand unread dot on its glyph's top-end corner — no
count, mirrored under Arabic.

@specimen top-bar/unread

The titled variant — a back button, a title and trailing actions, with an optional bottom rule — is
the inner-screen header of the Settings and Article designs. The back glyph points to the reading
start, so it is `arrow-circle-right` under Arabic.

@specimen top-bar/titled

## Using it

**Use `DabblerNavigationTopBar.titled` for an inner screen, never a hand-built header.** It carries
the back button, the title and trailing actions the Settings and Article designs draw; the wordmark
bar itself still takes no title, alignment or surface variant.

**Pass `avatarImageUrl` when the user has a photo.** The seed portrait stands in while it loads,
when it is empty and when it fails.

**Each trailing action needs its own accessible label; the action is icon-only and has no other
name.** Pass `label` for every `DabblerNavigationAction` — it's the sole source of the announced
name.

**Trust the trailing-action hit boxes as drawn — they're already the corrected 34×45 shape, not
the naive 45×45 a touch-target floor might suggest.** Each action's hit box is 34 wide, matching
the drawn glyph pitch exactly, and 45 tall on the axis the floor actually measures against. Don't
"fix" it toward a square 45×45 box.

**Don't expect the bar height to be a fixed 62 yet, though it's ruled to become one.** It's
currently a minimum that expands to fit its content. See *Change log*.

## Axes

### Content
Wordmark plus zero or more trailing actions plus the account avatar — the avatar is always present;
actions are optional.

Trailing actions are icon-only by default. `DabblerNavigationAction.text(label: 'Save')` draws a
labelled action as a text-tone `Button` in the same slot. Its label is its accessible name unless
you pass `semanticLabel`, and without `onPressed` it is drawn disabled.

### Safe area
Padded for the device status bar by default, or left to the source's literal behaviour when an
ancestor already handles it.

## Direction

**The wordmark never mirrors, even though the rest of the bar does.** The logo and avatar swap
sides under Arabic like any ordinary flow row — but the wordmark itself stays as drawn, because it's
text, and text is not a mirrored glyph.

**The titled bar's back glyph points at the inline start in both directions.** It is drawn as
`arrow-circle-left` with `mirrorInRtl`, so Arabic shows `arrow-circle-right` on the right edge,
pointing outward to where back leads. A test reads the drawn glyph's pixels in both directions. The
design's Arabic Settings frame keeps `arrow-circle-left` (`Settings.dc.html:381`), which would point
toward the content, the forward direction. The bar follows the platform convention and not that
literal.

*Confirmed by reading `top_bar.dart` directly — its own "RTL" section states this explicitly. Not
yet checked against the gallery's direction switcher.*

## Tokens used

Titled variant: back button `surfaceCard` fill with a `borderDefault` hairline, 40px inside a 45px
target, glyph 20; title on the `body` step at semibold in `textPrimary`; the bottom rule is
`bgTertiary`. The design's 40px trailing buttons take the bar's own 34×45 action targets (nearest
existing geometry), and its 6/18/12 padding takes the bar's 62 height and 16 inline padding.


Trailing action glyphs: `linear` weight, sized within their hit box. Account avatar: the shared
`Avatar` component, unmodified. No shadow, no surface fill of its own beyond the screen background.

## Change log

- D-026 (cxo) — confirms the transcription's narrow anatomy is
  correct as built and refuses widening the API for a greeting-stack variant a different part of the
  design kit draws.
- D-032 (cxo) — rules the trailing-action hit-box correction
  above (shipped).
- D-039 (cxo) — rules `barHeight` becomes a hard 62. Not yet
  shipped.

- Alpha plan decision 1 (orchestrator, D-035) — adds the titled variant and the avatar image URL.

## Source

`lib/src/navigation/top_bar.dart`
