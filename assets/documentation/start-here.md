<!--
Global page, not a component or Foundations page — D-033(a)'s "Start here":
one page, not a tutorial track. Exempt from the D-042 heading vocabulary
(D-042(e)) — it's the one page named as an explicit exception, since "a
vocabulary for one page is a list with one member." Still bound by D-042(a)'s
lead-prose rule (exactly two unheaded paragraphs before the first ##, the
first a single sentence) and by @specimen resolution once that syntax
exists. Migrated from docs/component-docs/pilot/start-here.md to
assets/documentation/start-here.md per D-041(a); added the required lead
prose, which the pilot version was missing (it went straight from the
title into "## One import" with no lead at all — a real gap this migration
catches, not something D-042 introduced).

Sources : lib/dabbler_design_system.dart (read in full through the "What is
          deliberately NOT exported" section — the barrel's own contract,
          its self-checking test, and the two explicitly hidden internal
          types: DabblerFieldShell/DabblerFieldAlign and
          DabblerPickerFieldShell)
          lib/main.dart:1-35 (gallery app entry, confirms it imports only
          the barrel)
          lib/src/gallery/gallery_theme_scope.dart:1-75 (GalleryAppearance
          class dartdoc through the ThemeMode.light default rationale —
          confirmed this is gallery-specific chrome, not a pattern a
          consuming app reuses directly)
          lib/src/tokens/dabbler_colors.dart:305-320 (DabblerColors.of and
          DabblerColors.resolve — the actual installation pattern a
          consuming app uses, which GalleryThemeScope is built on top of)

RESOLVED by D-040(a): the "GalleryThemeScope" question this page originally
flagged is settled — D-033(a) named the gallery's switcher where it meant
the DabblerColors.resolve/.of pair underneath it, and this page already
taught the right thing. No change needed. General form, worth carrying
into every other page: the gallery's own chrome is never taught as product
API.
-->

# Start here

Start here is the one page that orients a reader new to this package before they open anything
else in this documentation.

It covers the one import every component and token is reachable through, how to install the colour
set on a real app rather than the gallery's own review chrome, why nothing in this package takes a
direction prop, and the three mistakes a first import tends to make.

## One import

Every token and component this package ships is reachable through one import:

```dart
import 'package:dabbler_design_system/dabbler_design_system.dart';
```

Nothing under `lib/src/` is a supported import path — the barrel is the contract, checked by a
test that fails the build if a public declaration lands in `lib/src/` with no export and no
documented exemption. Two internal types are deliberately not exported at all: `DabblerFieldShell`
and `DabblerPickerFieldShell`, the paint layer every field composes internally. Their pages exist in
this documentation because they're real composition machinery worth understanding, not because a
screen should import them directly.

## Installing the colour set

`DabblerColors` reaches every component as a `ThemeExtension`, not through a widget wrapping the
subtree. Resolve one of the fourteen `(theme, brightness)` instances and install it on your
`MaterialApp`'s `theme`/`darkTheme`:

```dart
MaterialApp(
  theme: ThemeData(extensions: [DabblerColors.resolve(theme: DabblerTheme.main, brightness: Brightness.light)]),
  darkTheme: ThemeData(extensions: [DabblerColors.resolve(theme: DabblerTheme.main, brightness: Brightness.dark)]),
  // ...
)
```

Every component reads it back with `DabblerColors.of(context)`, which throws in debug if nothing is
installed — that's a wiring bug to fix, not a state to handle defensively. Because the extension
lives on `MaterialApp` rather than inside a screen, a theme change made above the `Navigator`
reaches every pushed route, overlay and dialog for free; a switcher built *inside* a screen would
only ever re-wrap that screen's own subtree and leave overlays painting the old palette.

The gallery app in this package (`lib/main.dart`) demonstrates this pattern behind its own
theme/brightness/direction switcher, `GalleryThemeScope` — that switcher is gallery chrome for
reviewing every combination side by side, not a component to import into a real screen. What a
consuming app needs is the `resolve`/`of` pair above, not `GalleryThemeScope` itself.

## Direction is ambient, not a prop

Nothing in this package takes a `rtl` flag or a direction override — several components document
this as a deliberate deviation from the design source, which does carry one. Flutter's
`Directionality` is trusted as the single source of truth; every directional value in this package
resolves against it through `EdgeInsetsDirectional`, `AlignmentDirectional`, and reading
`Directionality.of(context)` directly where a component needs to branch. Wrap a subtree in its own
`Directionality` only if you genuinely need to force a direction independent of the ambient one —
never to work around a component that isn't mirroring the way you expect, since every component in
this package is built to trust the ambient value rather than needing one passed to it.

## The three things a first import gets wrong

**Importing a `lib/src/` path directly instead of the barrel.** It happens to work until the next
release moves a file, at which point the import breaks for no reason visible at the call site. The
barrel is the only path this package's own tests treat as stable.

**Reading `Theme.of(context).colorScheme` instead of `DabblerColors.of(context)`.** Material's own
theme mechanism is used internally for behaviour this package needs, but no colour ever comes from
it — every visible colour in this package is `DabblerColors`, and reaching for Material's own scheme
gets a colour this package never declared and never tested against.

**Assuming a component needs to be told the reading direction.** It doesn't. If something isn't
mirroring the way it should, the fix is almost never a prop on that component — it's either the
correct behaviour (see that component's own Direction section, or the Bidirectionality foundation
page for a system-wide fact like script selection), or a real defect to report against the
component, not a direction override to add at the call site.
