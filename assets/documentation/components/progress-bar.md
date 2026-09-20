<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/progress_bar.dart:1-77 (DabblerProgressBarSize,
           DabblerProgressBarTone in full, class dartdoc through the RTL and
           reduced-motion sections)
           lib/src/feedback/progress_bar_gallery.dart:13 (specimen title:
           "ProgressBar — tones, sizes, indeterminate")
           DECISIONS.md — grepped "ProgressBar": no ruling touches this
           component.
-->

# ProgressBar
### `DabblerProgressBar`

ProgressBar is progress with a known end — a determinate fraction — or a busy bar when the end
isn't known yet.

The value is a fraction from 0 to 1, clamped, never a percentage — `showValue` is what turns it
into a rounded percentage for display, and the accessibility layer reports 0–100 on its own,
separately from the stored value. The fill takes the bare status indicator role rather than the
solid one, because a bar carries no text and so never hits the white-on-indicator contrast problem
that forces the solid role everywhere else.

## Specimen

Every tone, both sizes, and the indeterminate form — see `progress_bar_gallery.dart`'s *ProgressBar*
section.

## Using it

**Pass `value` as a 0–1 fraction, never a 0–100 number.** The component clamps into that range but
doesn't rescale a percentage down to it — passing `65` instead of `0.65` renders a bar that's stuck
at full.

**Use `.indeterminate` for a busy state with no known end, rather than animating a determinate bar
toward a guessed value.** A determinate bar that never actually reaches its guess reads as broken
progress; the indeterminate constructor exists specifically so a caller doesn't have to invent a
fraction it can't know.

**Don't reach for the solid status role on this component.** The fill deliberately uses the bare
indicator, not the white-safe solid fill other components need — matching a solid role here would
just be a colour that doesn't match the token this component actually reads.

## Axes

### Size
`sm` (3px — inline, inside a card or row), `md` (6px, the default — section or screen level).

### Tone
`brand` (the default, re-tints per section theme), `success`, `warning`, `error`, `info` — each the
bare status indicator colour.

### Mode
Determinate (a known fraction) or `.indeterminate` (a busy sweep).

@figure 3px lib/src/tokens/dabbler_geometry.dart#space1
@figure 6px lib/src/tokens/dabbler_geometry.dart#space2


## Direction

**A determinate bar fills from the start edge, and an indeterminate sweep travels start to end —
so which physical side represents "more progress" flips under Arabic.** In RTL the fill grows
leftward from the right rather than rightward from the left; the meaning ("this much is done")
doesn't change, but a reader assuming progress always grows rightward is wrong under RTL.

*Confirmed by reading `progress_bar.dart` directly — the fill anchors on
`AlignmentDirectional.centerStart`, and the indeterminate sweep's physical direction is explicitly
flipped for RTL since its translation is a physical transform where the logical anchor isn't. Not
yet checked against the gallery's direction switcher.*

## Tokens used

Track: `bgTertiary`. Fill: the brand colour, or a status tone's bare indicator role — never the
solid, text-safe variant of a status colour.

## Source

`lib/src/feedback/progress_bar.dart`
