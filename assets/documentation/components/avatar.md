<!--
Component page, D-033 ten-part template.

Group    : Identity and status
Sources  : lib/src/surfaces/avatar.dart (read in full through
           DabblerAvatarGroup's class dartdoc and constructor — sizes,
           badge tones, seed contract, portrait builder seam, the ring/
           overlap mechanics)
           lib/src/surfaces/avatar_gallery.dart:24 (specimen title: "Avatar
           — sizes, badges and groups")
           DECISIONS.md D-004 (read in full, prior session — the indigo
           badge defect), D-031 (read in full, prior session — the group
           ring is a stroke, not a shadow exception), T-084 (title read
           this session, confirming it rules the portrait generator; not
           re-read in full — the seed/determinism contract in avatar.dart's
           own dartdoc is what this page describes)
-->

# Avatar
### `DabblerAvatar`, `DabblerAvatarGroup`

Avatar is a person's circular portrait — generated deterministically from a seed, never from
initials — at one of five sizes, with an optional corner badge.

A seed (name, handle or user id) is hashed and used only to generate a portrait; it is never
rendered as text anywhere in this component, in the fallback path or the primary one. The same
seed always produces the same portrait and different seeds almost always produce different ones —
that determinism is the whole contract an avatar has with a user. `AvatarGroup` stacks several at a
fixed overlap with an optional `+N` overflow chip.

## Specimen

Every size, every badge tone, and a group — see `avatar_gallery.dart`'s *Avatar* section.

## Using it

**Pass a stable seed — a name, handle or user id — never assume the portrait can be styled to match
a specific look.** The generator is a pure function of the seed; there's no colour or style
parameter to reach for because the whole point is that the same person always renders the same way
without anyone choosing it.

**Never render `seed` as visible text.** It exists only to be hashed. If a screen also needs to
show the person's name, that's a separate label next to the avatar, not a prop this component
exposes.

**Do not treat the `indigo` badge tone as a stable colour yet.** It resolves through the same known
accent-indigo stand-in Button's `accent` tone and Fab's `indigo` tone do — see *Change log*.

**Build `AvatarGroup` from `people`, not by manually stacking individual `Avatar`s.** The −10px
overlap, the inside-drawn ring and the RTL stacking order are all this component's own mechanics —
recreating them by hand risks getting the ring wrong (see *Change log*) or the overlap direction
wrong under Arabic.

## Axes

### Size
Five: `xs` (28), `sm` (36 — the size `AvatarGroup` stacks), `md` (48, the default), `lg` (64),
`xl` (80).

### Badge tone
`primary`, `accent`, `indigo` (known defect — see *Change log*).

### Grouping
Single avatar, or `AvatarGroup` (overlapping row plus an optional `+N` chip).

@figure 28 lib/src/surfaces/avatar.dart#DabblerAvatarSize
@figure 36 lib/src/surfaces/avatar.dart#DabblerAvatarSize
@figure 48 lib/src/surfaces/avatar.dart#DabblerAvatarSize
@figure 64 lib/src/surfaces/avatar.dart#DabblerAvatarSize
@figure 80 lib/src/surfaces/avatar.dart#DabblerAvatarSize


## Direction

**In `AvatarGroup`, which avatar reads as "first" changes side under Arabic, while staying on top
of the stack.** The group is laid out with logical positioning rather than negative margins, so in
Arabic the stack runs from the right instead of the left — but the first person in the `people`
list is always the topmost avatar in the stack, in either direction. A reader assuming "leftmost is
first" is wrong under RTL; "topmost is first" holds in both.

*Confirmed by reading `avatar.dart` directly — the group uses `PositionedDirectional`, and its own
comment states the RTL behaviour explicitly ("the stack runs from the right and the first person
stays on top"). Not yet checked against the gallery's direction switcher.*

## Tokens used

Badge fill varies by tone — brand, accent, or the indigo stand-in. The group's inside-drawn ring
uses the page surface colour, drawn as a real 2px border rather than the source's outside
`box-shadow` spread, since this system paints no shadows.

## Change log

- D-004 (cxo) — the `indigo` badge tone's fill is the same
  known, documented defect as Button's `accent` and Fab's `indigo` tones.
- D-031 (cxo) — confirms `AvatarGroup`'s separating ring is a
  stroke, not a shadow, and needs no flatness exception — build it as a border in the page surface
  colour, which is exactly what this component does.
- T-084 (cto) — adopts `random_avatar` as the portrait
  generator this component's seed contract is built on.

## Source

`lib/src/surfaces/avatar.dart`
