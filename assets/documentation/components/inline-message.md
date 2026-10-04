<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/inline_message.dart (class dartdoc)
           lib/src/feedback/inline_message_gallery.dart (specimen "InlineMessage —
           a line of status under a control")
           design: Auth and Onboarding.dc.html:230-235 (the OTP error line),
           :885-893 (the states board, code-input group)
-->

# InlineMessage
### `DabblerInlineMessage`

InlineMessage is one line of status text with a bold glyph, set directly under the control it
explains.

It is the small cousin of Banner: no fill, no hairline, no radius — only the glyph and the words in
the tone's strong colour. Use it where a control has no error line of its own, such as the boxes of a
code input.

## Specimen

Every tone, the expired-code glyph, a message that wraps, and the same line in Arabic — see
`inline_message_gallery.dart`.

@specimen inline-message

## Using it

**A field with `errorText` keeps using that.** TextField, DateField and the other fields draw their
own message line. InlineMessage is for a control that has none — the code input, a toggle row, a
group of chips.

**Say what happened and what to do next.** "That code is not right. Check the email and try again."
The glyph and the words carry the state; the colour only reinforces them, so a screen reader and a
reader who cannot tell the tones apart get the same message.

**Change the glyph, not the tone, for a variation of the same status.** An expired code is still an
error: pass `icon: 'clock'`. The glyph is always drawn bold.

**For a message that stays on screen and needs an action, use Banner.** InlineMessage is a line, not
a surface; it has no dismiss and no button.

## Axes

### Tone
Error (the default), success, warning, info. Each takes its status colour's strong step for the glyph
and the text alike, and its own default glyph: `danger`, `tick-circle`, `warning-2`, `info-circle`.

### Announcement
An error or warning is a live region, so a screen reader announces it when it appears. Success and
info are not.

## Direction

A row: the glyph sits at the inline start and the message flows from it, so in Arabic the glyph is at
the right. Nothing is mirrored by hand.

**Deviation (glyph size):** the design draws the glyph at 16; the sizing roles have 15 and 18, and 15
is used.

## Tokens used

Glyph and text colour: the tone's `strong` status role. Type: footnote at medium weight. Glyph size:
`iconInline` (15). Gap: `iconGap` (6).

## Change log

- Alpha fidelity (KAN-426) — adds this component for the OTP frame.

## Source

`lib/src/feedback/inline_message.dart`
