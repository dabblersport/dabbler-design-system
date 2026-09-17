<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/menu.dart:1-300 (DabblerMenuPlacement,
           DabblerMenuIconTone, DabblerMenuItemTone, DabblerMenuRole,
           DabblerMenuEntry, DabblerMenu's full class dartdoc and constructor
           start — sheetBreakpoint/popover-sizing constants through RTL
           section). DabblerMenuList (line 714) and DabblerMenuItem (line
           1028) confirmed to exist by class declaration; their own dartdoc
           bodies not read in full this session — this page describes only
           what DabblerMenu's own dartdoc states about them (the composition
           relationship, the role difference), not their internal mechanics.
           lib/src/overlays/menu_gallery.dart:29 (specimen title: "Menu —
           placements, and the list on its own")
           DECISIONS.md — grepped "Menu": no ruling touches this
           component's own behaviour.

Direction: NO section. Popover placement and text alignment mirror via
Directionality/EdgeInsetsDirectional and a direction-aware flip function —
uniform mirroring (the file's own "RTL" note says explicitly "nothing in
this file names left or right as a design decision"), not an exception or a
semantic consequence.
-->

# Menu
### `DabblerMenu`, `DabblerMenuList`

## Definition

Menu is the anchored popover for a list of actions or options — a `Sheet` below phone width, an
anchored popover above it, with the same item list either way.

## Intro

`DabblerMenu` owns the trigger, the overlay, viewport-aware placement and the responsive switch to
a sheet below its breakpoint; `DabblerMenuList` is the reusable list body underneath, for a
composer that wants the roving-focus, type-ahead and keyboard behaviour without the popover
machinery around it — which is exactly what `Select` does, at `listbox` role instead of the default
`menu` role.

## Specimen

Every placement, plus the list shown on its own — see `menu_gallery.dart`'s *Menu* section.

## Using it

**Compose `DabblerMenuList` directly only when you're building your own popover surface — reach for
`DabblerMenu` for an ordinary trigger-and-list menu.** `Select` is the worked example: it needs the
list's keyboard and selection behaviour but owns its own popover-vs-sheet decision already through
`PickerFieldShell`, so it composes the list alone rather than nesting one menu inside another.

**Use `role: listbox` only when building a picker whose semantics are "choosing a value," never for
an actions menu.** The default `menu` role is for actions; `listbox` is reserved for the one case
this system actually needs it — a value picker like `Select` — and reaching for it elsewhere
mislabels an actions list as a value picker to assistive technology.

**Put a destructive action last, after a separator — never first or unmarked.** That ordering is
this system's own composition rule for the destructive item tone, not a per-screen style choice.

**Never build a second popover or a second sheet fallback around `DabblerMenuList`.** The
breakpoint switch, the viewport-aware flip and the sheet fallback all live in `DabblerMenu` — a
second implementation of any of them is exactly the fork this split is designed to prevent.

## Axes

### Placement
Four: `bottomStart` (the default), `bottomEnd`, `topStart`, `topEnd` — all inline edges, all subject
to a viewport-aware flip that overrides the requested placement when it would overflow.

### Role
`menu` (the default — actions) or `listbox` (value selection, as `Select` composes it).

### Presentation
Anchored popover above the shared breakpoint, `Sheet` below it — chosen automatically, with no
change at the call site.

### Entry tone
Six icon tones (five status-mapped plus a neutral) and two item text tones (default, destructive).

## Tokens used

Popover: card surface fill, a hairline border, the large radius step. No shadow — the hairline does
the separating, and the one reserved elevation shadow belongs to Dialog alone. Item icon tones map
to the status colours or the neutral secondary-text role; destructive item text uses the error
status's strong ink.

## Source

`lib/src/overlays/menu.dart`
