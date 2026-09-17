<!--
The navigational spine, not a generated table of contents. D-033 defines
four global sections and nine purpose groups; this page orders and
characterises both for a reader who does not yet know which group their
problem lives in. The group order and the one-line descriptions are
editorial judgement, not derived from filenames — every description below
is drawn from the page it describes, most of them close to that page's own
Definition sentence, not invented independently of it.

Migrated from docs/component-docs/pilot/index.md to
assets/documentation/_order.md per D-041(a), which names this exact file
("the reader-journey ordering") as the fourth thing under
assets/documentation/, alongside start-here.md and the two content
directories. Per D-042(e), _order.md is not a page and is exempt from the
heading vocabulary entirely — including the lead-prose rule that binds
even start-here.md. All 58 links below were mechanically rewritten to the
new two-level path shape (foundations/<slug>.md, components/<slug>.md,
patterns/<slug>.md) rather than hand-edited, and cross-checked against the
full file list — 45 components + 9 foundations + 3 patterns + start-here.
-->

# Reading order

Start with [Start here](start-here.md) if you haven't installed the colour set or wired up
direction yet — this page assumes that's done and helps you find the component or rule you
actually need.

## How this is ordered

Not alphabetically. The nine component groups below are ordered the way building a screen
actually goes: orient the user, give them somewhere to put things, tell them what those things
are, let them tell you something back, act on it, show them more when the flow needs it, and tell
them what happened along the way. If you arrived here already knowing "I need a `Select`," search
is faster than reading this top to bottom — this ordering is for the more common case, where you
know the problem but not yet which of nine groups answers it.

## Foundations

The rules every component page assumes and never repeats. Read the one that's actually blocking
you; nobody reads all nine in order.

- [Colour](foundations/colour.md) — colour is consumed by role name, never by hex; role names
  resolve per theme and brightness.
- [Type](foundations/type.md) — one twelve-step ramp, two roles, two scripts — and a live freeze on
  adding to it.
- [Spacing and geometry](foundations/spacing-geometry.md) — two base-3 ramps, plus the small fixed
  exceptions (touch target, border widths, icon sizes, the one legal shadow).
- [Motion](foundations/motion.md) — one duration scale, one easing curve, one press transform.
- [Icons](foundations/icons.md) — one font, exactly two weights, a fallback contract for what isn't
  in the vocabulary.
- [Sports](foundations/sports.md) — sport identity is carried by icon and background together;
  neither may be the only carrier.
- [Interaction](foundations/interaction.md) — the one shared focus ring, press scale and overlay
  scrim every interactive thing composes.
- [Themes and brightness](foundations/themes.md) — fourteen resolved palettes; thirteen roles never
  move, three re-tint.
- [Bidirectionality](foundations/bidirectionality.md) — where this system's mirroring deliberately
  stops, and the handful of places direction changes what a position means.

## Components

### 1 · Navigation — orienting the user: where they are, and how they move

The first thing on most screens, and the reason it comes first here.

- [TopBar](components/top-bar.md) — the app's identity row: wordmark, trailing actions, account
  avatar.
- [BottomBar](components/bottom-bar.md) — the primary destination switcher, plus the create action.
- [Tabs](components/tabs.md) — switching between peer views of one screen.

### 2 · Content containers — holding what you show

Two tiers, and the tier is the point, not a filing accident. **Shells** are the generic chrome
every specific card composes — one component, several paint variants, no content opinions of its
own. **Composed cards** are finished, specific things built on those shells that you hand real data
to: a `CardTicket` isn't a variant of `Card`, it's a separate widget with its own API that happens
to be built from `Card`'s shell underneath. That's why it has its own page below `Card` rather than
sitting beside it as another entry in `Card`'s own variant list.

**Shells**
- [Card](components/card.md) — the shared shell, five paint variants, used by every specific card
  below.
- [Surface](components/surface.md) — the flat container primitive everything with a fill and a
  hairline composes, including `Card` itself.
- [Section](components/section.md) — a titled group of content, with an optional trailing action.
- [Accordion](components/accordion.md) — collapsible sections for content that's secondary but not
  hidden.
- [IconTile](components/icon-tile.md) — the tinted square that holds one glyph.

**Composed cards**
- [CardEvent](components/card-event.md) — the event card, in three densities.
- [CardHouse](components/card-house.md) — a house (a recurring room series) as one row.
- [CardPricing](components/card-pricing.md) — one subscription plan as a selectable tile.
- [CardTicket](components/card-ticket.md) — a booking as a ticket, with its own type scale.

### 3 · Identity and status — who or what a piece of content is

- [Avatar](components/avatar.md) — a person's circular, deterministically generated portrait.
- [Badge](components/badge.md) — the pill that labels a row, a card or a tab.
- [Rating](components/rating.md) — a score, shown or collected.

### 4 · Selection and input — capturing what the user tells you

The largest group, because a form has the most distinct pieces. `FieldShell` and
`PickerFieldShell` are listed here too, even though neither is something you place directly —
they're the chrome every other field in this list is built from, and understanding one explains a
lot about the rest.

- [TextField](components/text-field.md) — the flat input, in five shapes.
- [Select](components/select.md) — choosing one or more values from a known list.
- [Checkbox](components/checkbox.md) — a flat, independent on/off control.
- [Radio](components/radio.md) — one choice in a mutually exclusive set.
- [Toggle](components/toggle.md) — a switch whose change takes effect immediately.
- [Slider](components/slider.md) — a value, or a bounded range, on a continuous axis.
- [Stepper](components/stepper.md) — a small bounded integer, nudged rather than typed.
- [CodeInput](components/code-input.md) — one-time-code and PIN entry.
- [InputRow](components/input-row.md) — the settings-list row: leading slot, text, trailing slot.
- [FieldShell](components/field-shell.md) — the internal chrome every text-entry field paints from.
- [PickerFieldShell](components/picker-field-shell.md) — the internal chrome every
  typed-or-picked field paints from.
- [PickerField](components/picker-field.md) — the shell plus a ready-made responsive picker
  surface.

### 5 · Date and time — the one input concern too large to fold into the last group

- [DateField](components/date-field.md) — a date, or a date range, typed or picked.
- [TimeField](components/time-field.md) — a time of day, typed or picked.
- [Calendar](components/calendar.md) — the month grid, standalone, used as-is by every date picker.
- [TimePicker](components/time-picker.md) — the hour/minute/meridiem picker that pairs with it.

### 6 · Actions — letting the user act

- [Button](components/button.md) — the one control for a tappable action, nine tones, three sizes.
- [Fab](components/fab.md) — the one floating action button, and the one deliberate exception to
  this system's flatness.
- [Chip](components/chip.md) — filtering and tagging, tappable or static.

### 7 · Presentation — surfacing more than the flow can hold

- [Dialog](components/dialog.md) — the modal that interrupts to get one decision.
- [Sheet](components/sheet.md) — the canonical bottom sheet.
- [Menu](components/menu.md) — the anchored popover for a list of actions or options.
- [Tooltip](components/tooltip.md) — a short label for a control that carries no visible text.

### 8 · Status and feedback — telling the user what happened

- [Banner](components/banner.md) — a persistent, in-flow message about the screen it's on.
- [Toast](components/toast.md) — a transient, queued notification that survives navigation.
- [Spinner](components/spinner.md) — the system's only indeterminate loading indicator.
- [ProgressBar](components/progress-bar.md) — progress with a known end, or a busy bar when there
  isn't one.
- [Skeleton](components/skeleton.md) — placeholder geometry for content that hasn't arrived yet.
- [EmptyState](components/empty-state.md) — the "nothing here yet" state, and the only one this
  system has.

### 9 · Structure — the one thing that separates, and nothing else

- [Divider](components/divider.md) — the only line this system draws between things.

## Patterns

Not components — the rule for choosing **between** components that already answer overlapping
questions. Read a pattern page when you know several components could work and don't yet know
which; read the component page when you already know which one you need.

- [Waiting](patterns/waiting.md) — Skeleton, Spinner, ProgressBar or Button's `loading` state:
  which one, based on what you actually know about what's coming.
- [Nothing to show](patterns/nothing-to-show.md) — EmptyState, Banner, or omitting the section
  entirely.
- [Telling the user something happened](patterns/telling-the-user-something-happened.md) — Toast,
  Banner or Dialog, by interrupt cost.
