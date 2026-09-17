<!--
Pattern page, D-042(d)'s four-heading template. Migrated from
docs/component-docs/pilot/pattern-telling-the-user.md, restructured: split
the single-paragraph lead into the required two paragraphs (single-sentence
Definition, then Intro), renamed "The choice, by interrupt cost" to
"## Choosing" and folded "Removal is never staged" beneath it as a `###`
subsection. D-016 stays linked in ## Change log, per D-033(c)'s own framing
of it as this page's spine.

The interrupt-cost ordering (Toast < Banner < Dialog) is synthesised from
each component's own already-documented purpose. The navigation-survival
claim for Toast was independently verified by reading toast.dart directly
(:282-283,333) — the provider is "mounted above the router" — not carried
over from memory. Banner's non-survival follows from its own definition
(in-flow, part of the screen's own widget tree). Dialog's claim is limited
to what's already sourced on its own page (blocking, modal); no
navigation-survival claim is made for it either way.

Sources : toast.md, banner.md, dialog.md (this rollout's own pages);
          lib/src/feedback/toast.dart:282-283,333 (read directly, prior
          session, for the above-the-router claim); DECISIONS.md D-016
          (read in full, prior session)
-->

# Telling the user something happened

Telling the user something happened is the choice among `Toast`, `Banner` and `Dialog` — three
components that all say "this happened," at three different interrupt costs.

This page is the rule for which one costs the right amount for what you're telling the user.

## Choosing

**`Toast` — least interrupting.** Transient, queued, capped at three showing at once, and
auto-dismissing by default. It's mounted above the app's own router, not inside any one screen, so
a toast queued on one screen keeps showing (or keeps its place in the queue) across a navigation —
it belongs to the app, not to the screen that triggered it. Reach for it when the user doesn't need
to act on the message and doesn't need it to persist once they've moved on.

**`Banner` — moderate.** Persistent and in-flow, part of the screen it's declared on — it doesn't
survive a navigation away from that screen, because it's literally in that screen's own widget
tree. Reach for it when the message is about *this screen's* state specifically and should stay
visible (optionally dismissible) for as long as the user is looking at it, but shouldn't block
interaction with the rest of the screen.

**`Dialog` — most interrupting.** Fully modal: it captures focus, traps Tab inside the panel, and
blocks interaction with everything beneath it until it's dismissed. Reach for it only when the
message genuinely requires a decision before the user can do anything else — everything Banner or
Toast could express is a message; Dialog is for a message that's actually a question.

### Removal is never staged

`Toast`'s dismissal is immediate, with no exit animation, by explicit ruling — a toast's removal is
either user-initiated or timed, so it's expected rather than surprising, and animating it out would
change what the queue's cap actually counts. The same discipline applies across all three: none of
them should be built to linger past its own dismissal to finish an animation. If a message needs to
be seen and acknowledged rather than just shown, that need is itself a sign the right component is
`Dialog`, not a longer `Toast` duration.

## Related

[Toast](../components/toast.md) · [Banner](../components/banner.md) · [Dialog](../components/dialog.md)

## Change log

- [D-016 (cxo)](../../../../dabbler-docs/DECISIONS.md) — rules Toast's removal is immediate with no
  exit animation, which is this page's own "Removal is never staged" section applied to all three.
