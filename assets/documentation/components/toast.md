<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/toast.dart:1-210 (DabblerToastTone in full —
           including its deliberate mirroring of DabblerBannerTone;
           dabblerToastNoIcon; DabblerToastAction; duration/sticky
           constants; DabblerToastController's queue-capping doc and
           _items management)
           lib/src/feedback/toast_gallery.dart:19 (specimen title: "Toast —
           tones (trigger)")
           DECISIONS.md D-016 (read in full, prior session — removal
           timing)
-->

# Toast
### `DabblerToast`

Toast is a transient, queued notification — auto-dismissing by default, capped at three showing at
once, oldest dropped first.

Its tone model deliberately mirrors `Banner`'s exactly — the same four status roles plus a
non-status `neutral` — because both resolve colour from the same underlying four roles; they're
separate components only because they're separate public APIs with separate defaults (`Banner`
defaults to `info`, Toast to `neutral`). Toast's queue is capped, and a fourth toast while three are
showing pushes the oldest one out rather than growing the stack.

## Specimen

Every tone, triggered — see `toast_gallery.dart`'s *Toast* section.

## Using it

**Removal is immediate, with no exit animation — don't build one around it.** A toast's dismissal
is either user-initiated or timed, so it's expected rather than surprising, and keeping a dismissed
entry alive just to animate it out would change what the queue's `max` actually counts.

**Pass `duration: DabblerToast.sticky` for a toast that must stay until dismissed, not a very long
duration.** `sticky` is `Duration.zero` read as "never auto-dismiss" — a long finite duration still
times out eventually, which isn't the same guarantee.

**Pass the explicit no-icon sentinel to suppress the leading glyph — don't just omit the icon prop
and assume the same thing happens.** Omitting the icon and explicitly asking for none are two
different states in the source, and this package keeps that distinction.

**Don't assume a fourth toast queues indefinitely.** The queue is capped at three by default; a
fourth showing while three are already up silently drops the oldest rather than growing the stack
or blocking the new one.

## Axes

### Tone
`neutral` (the default — no status meaning), `success`, `warning`, `error`, `info`.

### Duration
A finite auto-dismiss duration (4000ms default) or `sticky` (never auto-dismisses).

### Action
Zero or one trailing action.

## Tokens used

Fill, ink and hairline mirror `Banner`'s exactly — the four status tones resolve through the shared
status colour set, `neutral` through the ordinary card surface roles.

## Change log

- [D-016 (cxo)](../../../../dabbler-docs/DECISIONS.md) — confirms removal is immediate with no exit
  animation, correcting the design source's own prompt file to match.

## Source

`lib/src/feedback/toast.dart`
