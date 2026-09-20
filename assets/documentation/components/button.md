<!--
Pilot page, D-033 ten-part template — the "argued history" case: multiple
DECISIONS.md entries touch this component, testing whether "link, never
summarise" holds up against a real change log.

Group    : Actions
Sources  : Button.prompt.md (design source)
           lib/src/controls/button.dart (read in full through line ~310;
           enum DabblerButtonTone and DabblerButtonSize read complete)
           DECISIONS.md — read D-011, D-012, D-023, D-024 in full; D-004 and
           D-005 confirmed touching Button by direct citation inside
           button.dart itself, not by a keyword grep alone.

CORRECTION TO THE BRIEF: team-lead's message named D-019 as one of the five
rulings on Button. D-019 is about DabblerCardVariant.pricingSelected /
pricingUnselected (card.dart) — it never mentions Button. Verified by reading
D-019 in full. Not included below. The rulings that do touch Button, verified
either by their own text or by direct citation inside button.dart, are D-004,
D-005, D-011, D-012, D-023 and D-024 — six, not five.

FINDING, confirmed as a blocked chain rather than drift (team-lead, 2026-09-18):
D-023 rules that Button gains a tenth tone, `text`, and names the exact code
change (`DabblerButtonTone` gains `text`; `DabblerCalendarTextAction` is
deleted). Checked `lib/src/controls/button.dart`'s `DabblerButtonTone` enum
directly — it has nine values, not ten. `text` has not shipped. Team-lead
traced why: D-023's step 1 is a design-source change gated on KAN-261, which
has no possible executor — the `product-designer` capability has zero seats,
since the CEO supplies design. The Dart step, KAN-279, is parked in To Do
behind it. `DabblerCalendarTextAction` (in `calendar.dart`/`time_picker.dart`)
is likewise still present, for the same reason. This page lists nine tones,
matching what the code does today, links D-023 in the Change log so the
ruling stays visible, and now states the blocked-chain reason plainly in the
Change log entry itself — this is `po`'s known-defect-disclosure acceptance
criterion, not just an audit note for internal review.
-->

# Button
### `DabblerButton`

Button is the one control for a tappable action, merging what used to be thirteen separate button
symbols into a single widget with tone, size and state modifiers.

There is no separate `PrimaryButton`, `SmallButton` or icon-only button widget — one component
carries nine paint tones across three sizes, plus loading, disabled and full-width. Tone names
describe what the button paints, not what it means: `primary` is not "the important one," it is
"filled with the brand colour." Press and focus are the system's shared primitives, not anything
private to this component, and the loading state renders the shared spinner rather than a button-
specific one.

## Specimen

Every tone at every size, plus the icon-only form, loading and disabled — see the *Button* section
of `controls`'s gallery entries.

## Using it

**Reach for a tone by what it should paint, not by habit from another system's names.** This
system does not use `outline`, `ghost` or `dark` — those names were retired because they described
nothing about what they actually painted (`ghost`, for instance, painted a filled neutral pill).
Reaching for a retired name will not compile; that is intentional; the nine current tones are named
for their paint instead.

**Give an icon-only button an accessible name.** `DabblerButton.icon` requires one because there is
nothing else on screen for a screen reader to read — a tooltip does not substitute for it.

**Render the loading state through the `loading` flag, not by swapping in your own spinner.** The
button already draws the shared spinner in the right size and position; a second one nested inside
it duplicates work the component already does.

**Do not treat the 21px corner on the `full` size as a mistake to round off to the pill radius used
everywhere else.** It is a deliberate, documented exception for this one size — see *Change log*.

## Axes

### Tone
Nine: `primary` (brand fill), `secondary` (accent fill), `accent` (indigo fill — see *Change log*
for a known defect in what it currently resolves to), `neutral` (sunken fill), `filled` (ink fill),
`outlined` (the only tone that actually draws an outline), `destructive` (solid error fill),
`iconLabel` and `icon` (the compact and icon-only forms — paint identical to `neutral` and
`filled` respectively, kept as separate names because the design source keeps them separate).

### Size
`full` (320×52, fixed), `medium` (the default), `small`.

### State
Enabled, disabled, loading, full-width.

## Direction

**The icon moves to the other side of the label under Arabic, with nothing in the component naming
a side.** Icon and label sit in ordinary flow inside a row with a logical gap, so the layout
mirrors the same way any unlisted component's does — this is the default, not something Button
does specially.

*Confirmed by reading `button.dart` directly — no `left`/`right` literal anywhere in the file, and
padding is direction-aware throughout. Not rendered in Arabic; no direction switcher exists in the
gallery yet.*

## Tokens used

Fill and label ink vary by tone — brand, accent, surface-sunken or ink, resolved through the shared
colour set (see the *Colour* foundation page for the role names). Corner radius is `--radius-pill`
on `medium` and `small`, and an explicit 21px on `full` (see *Change log*). Press and focus draw
from the shared press-scale and focus-ring primitives; nothing here defines its own.

## Change log

- D-004 (cxo) — `accent`'s fill is a known, documented defect: it
  currently stands in with the nearest declared indigo, pending the missing token being declared
  in the design source's own colour file.
- D-005 (cxo) — confirms the 21px explicit corner on `full` as this
  system's correct corner for a large primary action, the same exception `Fab` takes.
- D-011 (cxo) — the 8px icon gap and the off-grid paddings on every
  size are a deliberate, documented exception, not drift to be corrected.
- D-012 (cxo) — `iconLabel` and `neutral` stay as separate tones
  despite painting identically today.
- D-023 (cxo) — rules a tenth tone, `text`, for a chrome-less
  action alongside a filled one (Cancel beside Confirm, a "See all" trailing action). **Known
  defect: not shipped, and blocked rather than merely pending** — the design-source change this
  needs first has no assignable executor today, so there is currently no path to it landing. Do
  not reach for `tone: 'text'`; it does not compile.
- D-024 (cxo) — Button's tone-size label scale stays a private
  scale, not three new steps in the shared type ramp.

## Source

`lib/src/controls/button.dart`
