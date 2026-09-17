<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/banner.dart:1-115 (DabblerBannerTone,
           DabblerBannerAction in full — including the `interrupts` getter
           and the neutral-tone rationale)
           lib/src/feedback/banner_gallery.dart:13 (specimen title: "Banner
           — tones")
           DECISIONS.md — grepped "Banner": no ruling touches this
           component's own behaviour (one incidental mention inside T-083's
           icon-adoption list).
-->

# Banner
### `DabblerBanner`

Banner is a persistent, in-flow message about the screen it sits on — one of five tones, optionally
dismissible, optionally carrying one inline action.

Four of its five tones map onto this system's real status set; the fifth, `neutral`, carries no
status meaning at all and resolves to the same ordinary card roles a plain surface would. Whether a
banner interrupts a screen reader or merely announces itself follows directly from tone: `error` and
`warning` interrupt, everything else is a calmer status announcement.

## Specimen

Every tone — see `banner_gallery.dart`'s *Banner* section.

## Using it

**Reach for `neutral` only when the message genuinely carries no status.** It isn't a fifth status
colour — it's the absence of one, painted in the same roles a plain card uses. A neutral banner
announcing something that actually succeeded or failed is the wrong tone regardless of how calm the
message reads.

**Let `error` and `warning` interrupt, and let the other three stay a calm status announcement.**
That split isn't a styling choice — it's what tells a screen reader whether this message needs
immediate attention or can be read whenever it's convenient, and reaching for `error` to make a
message "feel more visible" changes that behaviour along with the colour.

**Give a dismissible banner `onDismiss`, not a bare close icon with your own handler.** The
dismiss affordance and its layout only appear when `onDismiss` is set — building a visually similar
close control outside that prop duplicates behaviour the component already owns.

## Axes

### Tone
`neutral` (no status meaning), `success`, `warning`, `error`, `info` — each with its own default
glyph.

### Dismissibility
Dismissible (`onDismiss` set) or persistent.

### Action
Zero or one inline action.

## Tokens used

Fill, ink and hairline vary by tone — the four status tones resolve through the shared status
colour set; `neutral` resolves through the ordinary card surface roles instead, never a fifth status
entry.

## Source

`lib/src/feedback/banner.dart`
