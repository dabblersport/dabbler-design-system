<!--
Foundations page, D-034's nine-part template. UNBLOCKED per this session —
the bidirectionality comparison specimen shipped (KAN-316), the last of the
two remaining blocked pages.

Like Themes, this page's subject is a DIFFERENCE — where mirroring stops —
which the gallery's single-component direction switcher can't show (that
switcher is correct for a single component's own Direction section, per
code-input.md and D-035(c), but not for a foundation whose subject is the
comparison itself). The specimen renders each of six contracts twice,
LTR and RTL adjacent, under its own explicit Directionality each.

Sources : lib/src/tokens/dabbler_direction_gallery.dart (read in full — the
          "why this page exists although a switcher already does" section
          and the six-contract table with its own file:line citations,
          plus the explicit note that case 2 attributes the LTR pin to
          PickerFieldShell and not to DateField, matching this rollout's
          own prior correction on that exact point)
          _notes-bidirectionality.md (this rollout's own accumulated
          findings, folded in below — chevron/glyph-selection confirmed
          independently on InputRow and Calendar before this page existed,
          now also band 6 of the shipped specimen)
          DECISIONS.md D-035(c), D-036 (both read in full, prior session)

Per team-lead: every one of the six contracts was checked against what
renders, with no disagreement found, including the type-script fork
(measured live in the specimen). Per D-037(c) that measured comparison is
not transcribed here as a number — the specimen computes and shows it live,
which is exactly what this page's Specimen section points to instead.

This page CLOSES OUT _notes-bidirectionality.md — every finding logged
there is folded in below. The notes file should be deleted once this page
is confirmed landed; left in place for this handoff so the fold-in is
checkable against the original notes.
-->

# Bidirectionality

## Definition

Every component in this system mirrors under Arabic by default, through Flutter's own
`Directionality` — this page is about the specific, deliberate places that default doesn't hold.

## Intro

Six contracts across this system deliberately deviate from ordinary mirroring, and each one is a
real fact a reader needs, not a guess: something that doesn't flip when everything around it does,
or a value whose meaning changes with direction even though its layout mirrors normally. Uniform
mirroring itself — the ordinary case, true of nearly every component in this package — isn't
documented per component; it's documented once, here, as the default every unlisted component gets.

## Specimen

One entry, six bands — see `dabbler_direction_gallery.dart`'s *Direction* section. Each band renders
its component twice, LTR and RTL side by side, under its own explicit direction rather than the
gallery's header switcher — the subject is the difference between the two renders, which a switcher
that replaces one state with the other can't show adjacently.

## Using it

**Never assume a component needs a direction prop to behave correctly.** Nothing in this package
takes one — every one of the six contracts below is achieved through `Directionality` itself, either
by trusting it (the ordinary case) or by deliberately pinning against it (the six exceptions). If a
component isn't mirroring the way you expect, the fix is almost never a prop at the call site.

**Attribute the picker fields' LTR-pinned editable to the shell, not to whichever field you're
using.** `DateField`, `TimeField` and any future picker field all inherit this from
`PickerFieldShell` — it's one fact in one place, not something each field implements separately, and
a regression in it would hit every picker field at once.

**Never assume a directional glyph mirrors by flipping.** Where a glyph's direction carries meaning
— a disclosure chevron, a calendar's previous/next arrows — this system selects a different named
icon per direction rather than transforming one glyph. A mirrored arrow's stroke weights land on
the wrong sides; swapping the glyph name is how this system avoids that, confirmed independently on
more than one component before this page existed to name it as a system-wide rule.

**Don't localise the week start into a fixed default and call it done.** `Calendar` falls back to a
direction-based guess when the caller passes nothing, but that fallback is documented as an
extension beyond the design source and explicitly not a locale lookup — direction and locale are
different facts. A screen serving a real locale should pass the actual week start rather than trust
the direction-keyed default.

## Axes

### The six contracts
1. A code's digit boxes do not mirror.
2. A picker field's typed editable is LTR-pinned inside otherwise-mirrored chrome — the shell's
   contract, inherited by every picker field.
3. A calendar's week start is a fact the caller passes, with a direction-keyed fallback that is not
   a locale lookup.
4. A slider's pointer mapping inverts along with its visual axis.
5. The type layer forks by script, not by theme — the same mechanism this system uses to select
   face, leading and numeral rendering. See the Type foundation page for the mechanism itself; this
   page names only the direction-specific consequence.
6. Directional glyphs are selected per direction, never transformed from one glyph.

## Change log

- [D-035 (cxo)](../../../dabbler-docs/DECISIONS.md) — the same "comparison, not a state" test that
  unblocks Themes unblocks this page, and bounds it to the foundation only — per-component Direction
  sections stayed unblocked throughout, verified one at a time by the direction switcher.
- [D-036 (cxo)](../../../dabbler-docs/DECISIONS.md) — the test this page's Axes section is built on:
  a component gets its own Direction section only for an exception to mirroring or a semantic
  consequence of it, never for uniform mirroring or script selection, both of which are foundation
  facts documented here instead.

## Source

Six contracts, six files: `lib/src/forms/code_input.dart`, `lib/src/forms/picker_field_shell.dart`,
`lib/src/calendar/calendar.dart`, `lib/src/forms/slider.dart`, `lib/src/tokens/dabbler_type.dart`,
`lib/src/forms/input_row.dart`.
