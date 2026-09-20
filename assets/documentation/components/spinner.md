<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/spinner.dart:1-90 (DabblerSpinnerSize,
           DabblerSpinnerTone, class dartdoc through the reduced-motion and
           accessibility sections)
           lib/src/feedback/spinner_gallery.dart:13 (specimen title:
           "Spinner — sizes and tones")
           DECISIONS.md — grepped "Spinner": no ruling touches this
           component.
-->

# Spinner
### `DabblerSpinner`

Spinner is the system's only indeterminate loading indicator — every loader in the product,
buttons included, resolves to this ring.

It's a plain ring: no shadow, no gradient, no tinted circle behind it. Under reduced motion it does
not stop — the rotation becomes a slow opacity pulse instead, never a static frame, because a
spinner that stops reads as hung rather than loading. A skeleton reads the opposite way, which is
why the two behave differently under the same setting.

## Specimen

Every size and tone — see `spinner_gallery.dart`'s *Spinner* section.

## Using it

**Never build a second loading indicator.** This is the one indeterminate loader for the whole
product — a button's `loading` state, a panel load, load-more, pull-to-refresh, all resolve to this
same ring rather than each drawing its own.

**Don't render a still ring under reduced motion expecting that's the accessible behaviour.** It
isn't — a still spinner reads as broken, not as respecting a preference. The built-in reduced-motion
behaviour is a pulse, not a stop; only pass `animate: false` if you genuinely want nothing moving at
all, which is a different request from "respect reduced motion."

**Leave `tone` at its default (`brand`) inside ordinary content; reach for `inherit` only when the
spinner sits inside something already tinted.** `inherit` takes the colour of whatever
`DefaultTextStyle`/`IconTheme` surrounds it, which is what lets it sit correctly inside a tinted
button without being told what colour that button is — using it outside that context can leave the
spinner invisible against its background.

## Axes

### Size
`sm` (18, rows/chips/Button's loading state), `md` (24, the default — buttons and cards), `lg`
(30, a section-level load).

### Tone
`brand` (the default, re-tints with the active section theme), `inherit` (takes the ambient text/
icon colour), `onBrand` (for a solid brand fill).

@figure 18 lib/src/tokens/dabbler_geometry.dart#iconSm
@figure 24 lib/src/tokens/dabbler_geometry.dart#iconMd
@figure 30 lib/src/tokens/dabbler_geometry.dart#iconLg


## Tokens used

Ring colour varies by tone — brand, ambient/inherited, or the ink that sits on a brand fill.

## Source

`lib/src/feedback/spinner.dart`
