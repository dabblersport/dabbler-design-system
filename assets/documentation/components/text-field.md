<!--
Component page, D-033 ten-part template.

Group    : Selection and input
Sources  : lib/src/forms/text_field.dart (DabblerTextFieldVariant enum
           :13-36, class dartdoc :38-94, constructor and field declarations
           through :173 — the placeholder field's own doc is :159-173;
           colour-resolution call sites read directly — the value at :297,
           the editable variants' hint at :381-382, the select stand-in at
           :428-440)
           lib/src/forms/forms_gallery.dart:150-157 (specimen description)
           DECISIONS.md D-003 (read in full, prior session), D-025 (read in
           full this session, including its bound)

RESOLVED, and the history is kept rather than deleted: this page used to
carry an open finding that text_field.dart's class dartdoc contradicted its
own call sites on placeholder colour. Two tickets closed it, and the answer
turned out to be neither of the two colours originally argued over.

* KAN-317 corrected the stale dartdoc — but its first attempt replaced a
  wholly wrong claim with a partly wrong one, because the disabled
  behaviour was variant-dependent and nothing measured it.
* A cxo ruling on D-025 then held that the variant split was an unintended
  asymmetry, not a design position: a disabled field whose text is
  indistinguishable from an enabled one is the outcome D-025's own
  reasoning rejects.
* KAN-336 (c1172d1) made the rule uniform in code, at BOTH hint sites —
  text_field.dart:381-382 and picker_field_shell.dart:281-282.

This page now documents the settled rule. It is no longer an open question
and must not be written as one.
-->

# TextField
### `DabblerTextField`

TextField is the flat input for a single line, a search box, a password, a multi-line note, or a
picker's closed shell — five shapes, one component.

Every visible part — the label, the bordered box, the four border states, the helper or error
line — belongs to `FieldShell`. TextField contributes the input itself, each variant's own
affordance, and the two pieces of state the shell can't know on its own: whether it has focus, and
whether a password is currently revealed.

## Specimen

All five variants, each closed and — for `select` — open — see `forms_gallery.dart`'s *TextField*
section.

@specimen text-field/variants

Inside a `Form` with a validator, and with a unit as suffix text — see `form_extras_gallery.dart`.

@specimen text-field/form

The post editor: `DabblerComposerBox`, a card with a multi-line field, a counter and a toolbar of glyphs, and `DabblerSelectPill`, the status-tinted pill that opens a choice — without a tint it is the neutral card pill that shows a value and a trailing arrow. `DabblerStepperPill` is the compact minus, value and plus pill for a small bounded count.

@specimen text-field/composer-box

## Using it

**Reach for the variant, not a manually composed field.** `search` supplies its own leading glyph,
`password` its own trailing reveal toggle, `select` its own trailing arrow — building one of these
by hand out of `standard` plus a prefix/suffix icon duplicates behaviour the variant already owns
and will drift from it.

**A placeholder is text while the field is live, and reads at the same secondary-text colour as
anything else a person is meant to read.** It is not decoration and it is not de-emphasised past
body-text contrast — reaching for a dimmer neutral to make an empty field look quieter is the
mistake this rule exists to stop.

**Once the field is disabled, the placeholder follows the value down to the tertiary role.** That
is not an exception smuggled in against the rule above, it is the rule the ruling actually made:
leaving a disabled field's text at the enabled colour would make it indistinguishable from a live
one, and a control a person cannot tell is unavailable is the worse outcome, not the better one.
The dimmer text is never the only thing saying "disabled" — the shell's disabled fill and the
control's own accessibility state carry it too, and that pairing is the condition the permission
depends on. It holds in every variant: the editable variants' hint and the `select` stand-in
behave identically.

**Do not fire `onSubmitted` from a multiline field expecting an Enter-to-submit behaviour.** Enter
inserts a newline in `multiline`; the callback is never called from that variant.

**Give it a `validator` to put it in a `Form`.** With a `validator`, an `onSaved` or an
`autovalidateMode`, the field registers with the enclosing `Form` exactly as Flutter's own form
field does: `validate()` shows the message in the error slot (error border included), `save()`
hands `onSaved` the text, and `reset()` puts back the text the field started with.
`AutovalidateMode.onUserInteraction` re-checks on every edit after the first. A validator's message
wins over `errorText`; `errorText` shows again once the validator passes. The message is announced
to screen readers when it appears. Without any of the three, the field is the plain widget it
always was. `select` is not a text input and ignores all three.

**Use `suffixText` for a unit, not `suffixIcon` with a hand-styled `Text`.** It sits at the trailing
edge inside the box in the secondary text role (tertiary once disabled), before the password
toggle, the clear button or a suffix icon, in every editable variant.

**Give `initialValue` or a `controller`, never both.** They're mutually exclusive ways of seeding
the same text — passing both is a contract violation the widget asserts against.

## Axes

### Variant
`standard` (plain single line), `search` (leading search glyph), `password` (obscured, trailing
reveal toggle), `multiline` (top-aligned, the one variant on a smaller corner radius), `select` (not
an input at all — the same shell rendered as a button with a rotating trailing arrow; every picker
in the system reuses this as its closed shape).

### State
Rest, focused, filled, error, disabled — the same five `FieldShell` states, inherited rather than
redefined.

## Tokens used

Leading icon: `brandPrimary`. Trailing icon and the password toggle: `textSecondary`. Value:
`textPrimary`, or `textTertiary` while disabled. Placeholder: `textSecondary` while enabled and
`textTertiary` while disabled — the same in both mechanisms that draw it, the editable variants'
hint and the `select` stand-in (see the note in *Using it*). Everything else — label, border
states, helper/error line — comes from `FieldShell`.

## Change log

- KAN-433 (Home fidelity) — adds `metrics` (search variant only): the 42 high city-sheet field. `DabblerFieldShell` gains `minHeight` and `gap`; defaults 45 and the icon gap.
- KAN-426 (round 2) — adds `mutedPasswordToggle` (default false): the password visibility glyph in the tertiary role at 20 (`mutedPasswordToggleGlyphSize`) instead of secondary at 24, as the Auth frames draw it; the 45x45 target is unchanged. The frame's CSS states 24 and secondary, so this is an option, not the default.
- KAN-426 (final) — adds `borderOutside` (47px box, default false) and, for the select variant, `circledSelectArrow`: the trailing glyph is `arrow-circle-down` (`arrow-circle-up` while open, no rotation) instead of the plain `arrow-down-1` chevron, as the Auth date-of-birth field draws it. The frames' other selects were not found, so both stay options.
- KAN-426 (cxo ruling) — the muted field ink introduced earlier in KAN-426 is reverted: label and placeholder stay on the secondary text role (see *Known ruled deviation*). Helper text is unchanged.

- Alpha DS gaps 5 — adds `validator`, `onSaved`, `autovalidateMode` (Form integration) and
  `suffixText`. The editable build moved to `text_field_editable.dart` to hold the 500-line rule.

- D-003 (cxo) — rules the placeholder-is-text finding this page's
  *Using it* section states. The call sites carried it correctly from the start; the file's own
  class-level comments lagged behind them until KAN-317.
- D-025 (cxo) — disabled text stays on `textTertiary`, bounded so
  contrast is never the only signal. Applied to this component's placeholder by KAN-336, which
  settled the variant question this page previously reported as open.

- Alpha fidelity (KAN-426) — the password field is no taller than a standard one: its 45px toggle
  fills the box instead of adding block padding (`Auth and Onboarding.dc.html:28-30`).

## Source

`lib/src/forms/text_field.dart`
