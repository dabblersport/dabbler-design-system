<!--
Pattern page, D-042(d)'s four-heading template (## Choosing · ## Specimen
[optional] · ## Related · ## Change log [optional]). Migrated from
docs/component-docs/pilot/pattern-waiting.md, restructured to the new
vocabulary: added the required two-paragraph unheaded lead (D-042(a) binds
Patterns pages too, not just components), renamed "The choice, in order"
to "## Choosing" and folded "What doesn't change the answer" beneath it as
a `###` subheading (### is free per D-042(f)). No ## Specimen — nothing to
point at yet. No ## Change log — no DECISIONS.md entry rules the Waiting
pattern itself; the components it arbitrates carry their own rulings on
their own pages, not repeated here.

The rule below is synthesised from each component's own already-documented,
already-sourced purpose (spinner.md, progress-bar.md, skeleton.md,
button.md's `loading` state) — cross-referencing what each component
already states about itself, not inventing a new fact about any of them.

Sources : spinner.md, progress-bar.md, skeleton.md, button.md (this
          rollout's own pages — the synthesis is between them, not against
          a new source)
-->

# Waiting

Waiting is the choice among four components that all say "not yet" — `Skeleton`, `Spinner`,
`ProgressBar` and `Button`'s own `loading` state — with nothing elsewhere in this system saying
which to reach for.

This page is that rule, stated once so a screen doesn't end up with four different loading
treatments answering the same question four different ways.

## Choosing

**Do you know the shape of what's coming?** Use `Skeleton`. A list of cards, a profile layout, a
row of stats — if the final content's geometry is knowable in advance, show that geometry now so
nothing jumps when the real content lands. Skeleton is never for "something is happening" alone; it
specifically preserves layout.

**Do you know how much is left?** Use `ProgressBar`, determinate. A file upload with byte counts, a
multi-step form — anything with a real, reportable fraction gets the determinate form, never a
guessed one.

**Is it a long operation with no knowable fraction and no content shape to preserve?** Use
`ProgressBar.indeterminate` — a busy strip, for something screen- or section-level that isn't tied
to one control.

**Is it one discrete action — a button, a small inline area — with nothing else on screen waiting
on it?** Use `Spinner` directly, or `Button`'s own `loading` state if the action is a button press.
`Button.loading` already renders `Spinner` internally; never build a second loading indicator inside
a button expecting it to look different; there's only one indeterminate indicator in this system,
and Button already uses it.

### What doesn't change the answer

Which of these you reach for is about what you *know*, not about how long the wait is expected to
take. A "long" wait with a real fraction is still `ProgressBar`, determinate; a "short" wait with no
knowable content shape is still `Spinner`. Duration doesn't enter the decision — only what
information you actually have to show.

## Related

[Spinner](../components/spinner.md) · [ProgressBar](../components/progress-bar.md) ·
[Skeleton](../components/skeleton.md) · [Button](../components/button.md)'s `loading` axis
