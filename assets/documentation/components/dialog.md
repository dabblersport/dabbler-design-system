<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/dialog.dart (read in full through the
           "Behaviour" section of the class dartdoc; `actions` field type
           confirmed directly at three call sites, still List<Widget>)
           lib/src/overlays/dialog_gallery.dart:18 (specimen title: "Dialog
           — sizes (trigger)")
           DECISIONS.md D-031 (read in full, prior session — the flatness/
           shadow ruling this component's one exception sits inside)

FINDING, resolved by team-lead: dialog.dart's own class dartdoc states
"Button (DS-400) does not exist yet in this package" as the reason `actions`
is an untyped List<Widget> rather than a typed primary/secondary pair.
Button has since shipped and `actions` is still List<Widget>, confirmed
directly at all three current call sites. This is NOT an unnoticed gap —
it's already KAN-267, "type Dialog's actions slot (primaryAction/
secondaryAction + destructive) once Button lands," created while Button was
still in flight, correctly parked in To Do behind KAN-243, and since moved
to Ready once po verified Button and DabblerButtonTone.destructive both
exist. Worded below as a scheduled, known gap — not as though nobody has
noticed — per team-lead's exact framing: the dartdoc's "because Button does
not exist yet" is true history and false present tense, and a reader who
doesn't know Button now exists would draw the wrong conclusion about
whether to pass a real DabblerButton.

MINOR FIX per team-lead's checkpoint read: dropped "and checked by a test
rather than merely documented" from the Intro's shadow-reservation
sentence. True today, but it's an enforcement claim that ages if the test
is ever renamed or removed — the reader-facing fact is the reservation
itself, not how it's enforced. Team-lead leaned toward dropping rather
than treating it as a D-037(c)-style verifiable claim to compute/link;
took that lean.
-->

# Dialog
### `DabblerDialog`

Dialog is the modal that interrupts to get one decision — the wide-viewport counterpart of Sheet,
the same job in a different presentation.

It's the only component in this system permitted to cast a shadow — the one legal exception to an
otherwise universally flat surface set, reserved for this component alone. Everything else about
the panel — fill, hairline, radius, padding, type — is the same flat treatment every other surface
gets.

## Specimen

Both sizes, opened from a trigger — see `dialog_gallery.dart`'s *Dialog* section.

## Using it

**Never build a separate modal wrapper, scrim or focus trap for a screen's own confirmation
dialog.** The wash, the panel, the fade, the focus trap and the key handling are all this
component's shared plumbing — a screen composing its own version of any of them duplicates work
this component already does correctly, including a focus trap that's easy to get wrong by hand.

**Pass real `Button`s in `actions`, not raw tappable widgets.** The slot is untyped today — a plain
list of widgets rather than a typed primary/secondary pair — because it was built before `Button`
existed in this package. `Button` has since shipped and typing this slot is scheduled work
(`KAN-267`, Ready), not a forgotten follow-up. Until it lands, the convention holds by documentation
and nothing else: every entry in `actions` should be a `Button`, and a destructive primary action
should use `Button`'s `destructive` tone.

**Don't route the primary action's Enter-key behaviour through the untyped `actions` list.** There's
no reliable way to find "the primary action" inside an arbitrary widget list, so Enter is wired to a
separate `onConfirm` callback instead — pass it explicitly rather than assuming the first action in
the list will fire.

**Below a 360px viewport, expect the action row to stack and each action to stretch full width.**
That's built in, not something to lay out defensively around.

## Axes

### Size
`sm` (340px max width), `md` (420px max width, the default).

### Dismissibility
Dismissible (Escape and a scrim press both close it) or not.

## Tokens used

Panel: the flat fill/hairline/radius/type treatment every surface uses, plus the one reserved
elevation shadow this component alone is permitted. Scrim: the shared overlay wash, never a colour
of Dialog's own.

## Change log

- [D-031 (cxo)](../../../../dabbler-docs/DECISIONS.md) — confirms Dialog's shadow as the system's one
  deliberate exception to flatness.

## Source

`lib/src/overlays/dialog.dart`
