<!--
Pattern page, D-042(d)'s four-heading template. Migrated from
docs/component-docs/pilot/pattern-nothing-to-show.md, restructured:
added the required two-paragraph unheaded lead, folded "EmptyState versus
Banner" and "Three outcomes, not two" under one "## Choosing" as two `###`
subsections. No ## Specimen. ## Change log added — D-040 is this page's
real ruling, not a synthesis.

The EmptyState-vs-Banner boundary is synthesised from each component's own
already-documented purpose (empty-state.md, banner.md) — legitimate
cross-referencing, not invention. The three-outcome rule is D-040(b)
close to verbatim, per cxo's own instruction that the reasoning be carried
that closely rather than paraphrased thin.

Sources : empty-state.md, banner.md (this rollout's own pages), DECISIONS.md
          D-040 (read in full, prior session)
-->

# Nothing to show

Nothing to show is the choice among `EmptyState`, `Banner`, and omitting a section entirely, for
the moment a screen or a part of one has nothing to display.

Three outcomes exist and the system doesn't collapse them into one obvious default — this page is
the rule for telling them apart.

## Choosing

### EmptyState versus Banner

**If there is no content to replace, use `EmptyState`. If there is a message about the screen's
state that exists alongside content — or alongside no content, but isn't itself the content — use
`Banner`.** EmptyState is a full replacement for an absent list, section or screen: it's the only
thing on screen where content would otherwise be, carries at most one action, and deliberately has
no illustration slot to reach for something more elaborate. Banner is a persistent, dismissible or
undismissible message that sits *in addition to* whatever else is on the screen — it never replaces
content, and using it to announce "nothing here" where `EmptyState` belongs skips the one-action
constraint and the composition rule that this is the system's only empty state.

**Never build a screen-specific empty state.** This is stated directly on `EmptyState`'s own page
and repeated here because it's exactly the kind of thing this Patterns page exists to reinforce: a
bespoke "nothing here yet" layout for one screen is precisely the drift a single canonical component
is meant to prevent.

### Three outcomes, not two

**The test: is this empty region the answer to what the user came here for?**

| The empty region is… | Outcome |
|---|---|
| the answer to the question the user just asked — they navigated here to see this | `EmptyState.page` |
| one section of a screen that answers the user elsewhere, and it holds the **only** way to create the first item | `EmptyState.inline` |
| one section of a screen that answers the user elsewhere, offering no affordance they can't reach another way | **omitted entirely, heading and all** |

If the answer to the test is yes, it's a page empty state. If not, the section earns its place only
by carrying an action the user can't reach elsewhere — otherwise it goes.

**Why omitting is correct, not just permitted.** A screen with three sections where one is empty
reads better with that section absent than with three lines of apology. An inline empty state
spends vertical space and a reader's attention to say "nothing here," which the section's absence
already says for free. A screen that apologises in three places has taught the user the product is
mostly empty — a claim about the product, and usually a false one.

**Two bounds, so this never becomes a licence to hide things.** Never omit where absence could be
mistaken for failure — a section missing because a request errored must not look like a section
missing because it's genuinely empty; that's *Telling the user something happened*'s territory, not
this one. And never omit the only path to the first item — if the section's inline empty state
carries the sole affordance for creating what would fill it, it stays, which is exactly what
`.inline` exists for.

## Related

[EmptyState](../components/empty-state.md) · [Banner](../components/banner.md)

## Change log

- D-040 (cxo) — rules the three-outcome table above and the
  two bounds on when a section may be omitted.
