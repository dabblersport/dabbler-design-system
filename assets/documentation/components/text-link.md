<!--
Component page, D-033 ten-part template.

Group    : Actions
Sources  : lib/src/controls/text_link.dart (class dartdoc)
           lib/src/controls/text_link_gallery.dart (specimen "TextLink —
           standalone and inside a sentence")
           design: Auth and Onboarding.dc.html:22 (link rule), :129, :170,
           :201 (standalone links), :131, :172 (inline legal links)
-->

# TextLink
### `DabblerTextLink`

TextLink is a word or phrase that takes a person somewhere: brand-coloured and underlined, on a
line of its own or inside a sentence.

It is not a button. Use it where the design writes a link — "Log in" under a form, "Terms of
Service" inside the legal line — and use `Button` for anything that acts.

## Specimen

Standalone, disabled, and inline in the legal line in English and Arabic — see
`text_link_gallery.dart`.

@specimen text-link

## Using it

**On its own line, use the widget; inside a sentence, use `DabblerTextLink.span`.** The standalone
link sits in a target at least 45 square, padded around text that stays its drawn size. The inline
span is laid out on the sentence's baseline and is not padded, so the paragraph's lines stay where
they are.

**Pass the sentence's style to `span`.** A link inside rich text does not inherit the surrounding
span's style on its own; give it the same style and only its colour and underline change.

**Keep inline labels short.** An inline link is one unbreakable piece and does not wrap across a
line end.

**A section-header link ("Manage", "See all") is the standalone shape without the underline.**
Pass `underline: false` and the footnote step at the weight the design draws. `trailingIcon` adds an
optional glyph after the label in the link's colour, mirrored in right-to-left; it is decorative and
adds nothing to the link's name.

**Pass `onPressed: null` to disable it, not a no-op.** It then reads in the tertiary text role and
is announced as disabled.

## Axes

### Shape
Standalone (padded to the touch-target minimum) or inline (inside a sentence, no padding).

### State
Enabled, disabled, keyboard-focused (the shared focus ring). Enter and Space activate it, and it is
announced as a link.

### Direction
Inline, it flows with the paragraph — in Arabic the link sits where the sentence puts it. The text
resolves the Arabic face and leading under right-to-left.

**Deviation (inline target size):** an inline link is smaller than the touch-target minimum.
Padding a word inside a line would push the paragraph's lines apart; the WCAG target-size rule
exempts targets inside a sentence. Use the standalone shape whenever the link is alone on its line.

**Deviation (standalone leading):** the design's line height is one step taller than the
subheadline's; the subheadline is the nearest type step and is used as is.

## Tokens used

Text and underline: `brandPrimary`, or `textTertiary` while disabled. Standalone type: subheadline
at medium weight. Target: `touchTargetMin` (45). Focus ring: the shared ring at the small radius.

## Change log

- Alpha DS gaps 5 — adds this component.
- Alpha DS gaps 6 — adds `underline` (on by default) and `trailingIcon` for the lone section link.

## Source

`lib/src/controls/text_link.dart`
