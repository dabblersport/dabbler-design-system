# Dabbler color & theming

Design-system foundation: **color + typography**. Material 3, 7 themes, light +
dark, bilingual EN/AR.

## Files

| File | What it is | Editable? |
| --- | --- | --- |
| `dabbler_colors.dart` | `DabblerPalette` (primitives), `DabblerColors` (`ThemeExtension`, light + dark), `DabblerTheme` / `DabblerSection` enums, `resolveTheme()`, and the resolver `DabblerColors.of(theme, brightness)`. | **Canonical — do not edit color values.** |
| `dabbler_material_scheme.dart` | `dabblerColorScheme(theme, brightness)` — a Material 3 `ColorScheme` per theme, seeded from the 5 reference palettes. | **Canonical — do not edit color values.** |
| `dabbler_tokens.css` | The same color tokens as CSS custom properties, for web surfaces. | **Canonical — do not edit color values.** |
| `dabbler_type.dart` | `DabblerType` (Apple HIG ramp in Readex Pro), `dabblerTextTheme({arabic})`, `dabblerTextThemeFor(locale)`, `DabblerTypeSpecimen`, `kDabblerFontFamily`. | **Canonical — do not edit type values.** |
| `dabbler_type.css` | CSS mirror of the type ramp. | **Canonical — do not edit type values.** |
| `dabbler_spacing.dart` | `DabblerSpacing` / `DabblerRadius` / `DabblerSizing` / `DabblerElevation` — the base-3 geometry tokens. | **Canonical — do not edit values.** |
| `dabbler_spacing.css` | CSS mirror of the geometry tokens. | **Canonical — do not edit values.** |
| `dabbler_theme_data.dart` | `dabblerThemeData(theme, brightness, {locale})` → ready `ThemeData` (colorScheme + `DabblerColors` extension + `textTheme` + `fontFamily` + `useMaterial3`). | Yes |
| `dabbler_forui_theme.dart` | `dabblerForuiThemeData(material)` → maps the active Material theme (colors + Readex Pro type) into Forui `FThemeData`. | Yes |
| `theme_controller.dart` | Riverpod `themeControllerProvider` (section + override + ThemeMode + locale), persistence seam. | Yes |

## The two color systems (and when to use each)

A screen reads color from exactly two places:

1. **Material roles** — `Theme.of(context).colorScheme`
   `primary`, `onPrimary`, `secondary`, `surface`, `onSurface`, `error`, …
   Use these for standard Material widgets and anything that should follow M3.

2. **Dabbler tokens** — `context.dabbler` (getter defined in `dabbler_colors.dart`)
   `brandPrimary`, `onBrand`, `accent`, `onAccent`, `bgPrimary/Secondary/Tertiary`,
   `surfaceCard`, `textPrimary/Secondary/Tertiary`, `borderDefault/Strong`,
   `success/warning/error/info` (+ `…Surface` / `on…`), `spotlight`, `focusRing`.
   Use these for brand surfaces, status chips, custom components, and anything
   not covered by a Material role.

```dart
final colors = Theme.of(context).colorScheme; // Material roles
final tokens = context.dabbler;                // Dabbler tokens

FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: tokens.brandPrimary,
    foregroundColor: tokens.onBrand, // never hardcode white-on-primary
  ),
  onPressed: () {},
  child: const Text('Primary CTA'),
);
```

## How to add a screen color correctly

1. Pick the role: is it a Material role (`colorScheme`) or a Dabbler token
   (`context.dabbler`)? Use one of those — **do not** add a `Color(0x…)`,
   `Colors.*`, or a hex literal in feature/UI code.
2. For text/icons drawn **on** a brand or accent surface, read the matching
   `on…` token (`onBrand`, `onAccent`, `onSuccess`, …). Some themes use **dark**
   on-brand text (Bright's primary; Sport/Social accents) — reading the token is
   the only correct way; hardcoding white will be illegible.
3. If a genuinely new semantic color is needed, add it to `DabblerColors`
   (all variants) and to `dabbler_tokens.css`, then expose it — don't inline it.
4. Keep it **RTL-safe**: never hardcode `left`/`right`. Use `start`/`end`
   (`EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`,
   `PositionedDirectional`).

## Section → theme map

Theming is section-driven by default and user-overridable. A user override
always wins, but it never changes a theme's semantic meaning.

| Section | Default theme |
| --- | --- |
| `home` | `main` |
| `sport` | `sport` |
| `social` | `social` |
| `active` | `active` |

```dart
DabblerTheme resolveTheme(DabblerSection section, {DabblerTheme? userOverride});
```

The remaining themes — `bright`, `simple`, `shade` — are reachable only through
a user override (or the debug Theme Gallery). Drive the section from navigation:

```dart
ref.read(themeControllerProvider.notifier).setSection(DabblerSection.sport);
```

Set or clear an override (persisted):

```dart
ref.read(themeControllerProvider.notifier).setUserOverride(DabblerTheme.bright);
ref.read(themeControllerProvider.notifier).clearUserOverride();
```

## Neutrals are intentionally tinted — do not "fix" this

Backgrounds, surfaces, text, and borders are **deliberately not** pure white or
pure black. Each is a faint tint of the active theme's own primary:

- **Dart:** computed in `DabblerColors.of` via `Color.lerp` against a per-theme
  `_neutralSeed`.
- **CSS:** `color-mix(in srgb, var(--t-primary) N%, white|black)`.

Leave this as-is. Do **not** replace tinted neutrals with `Colors.white` /
`Colors.black` / `#FFFFFF` / `#000000`. The Material `ColorScheme` neutral roles
(`surface`, `onSurface`, containers, outlines) are re-pointed at these tinted
tokens in `dabbler_theme_data.dart` so Material widgets match too.

## Typography (`dabbler_type.dart`)

The type system is the **Apple Human Interface Guidelines ramp**, rendered in
**Readex Pro** (which carries both Latin and Arabic in the same files — there is
no separate Arabic face). Tracking is near-zero on purpose: Apple's per-size
tracking is hand-tuned for SF Pro and does not transfer to another typeface.

### Reading type in a screen

Material widgets pick it up automatically from `ThemeData.textTheme`. For
explicit styles, read the Material slot:

```dart
Text('Join game', style: Theme.of(context).textTheme.titleMedium); // = Headline
```

…or, when you want the named Apple style directly:

```dart
Text('Join game', style: DabblerType.headline);
```

### The Apple ramp

The ramp runs **lighter** than Apple's SF Pro defaults — titles are **Light
(300)** and Headline is **Medium (500)** — tuned for Readex Pro. Sizes and
leading are unchanged from the Apple ramp.

| Style | Size / Leading | Weight |
| --- | --- | --- |
| Large Title | 34 / 41 | 300 |
| Title 1 | 28 / 34 | 300 |
| Title 2 | 22 / 28 | 300 |
| Title 3 | 20 / 25 | 300 |
| Headline | 17 / 22 | 500 |
| Body | 17 / 22 | 400 |
| Callout | 16 / 21 | 400 |
| Subheadline | 15 / 20 | 400 |
| Footnote | 13 / 18 | 400 |
| Caption 1 | 12 / 16 | 400 |
| Caption 2 | 11 / 13 | 400 |

`leading / size` becomes Flutter's `height` multiplier. `DabblerType.emphasized()`
and `.bold()` bump the weight to 500 / 700.

### Apple → Material 3 slot mapping

`dabblerTextTheme()` maps each Apple style onto the closest M3 slot so Material
widgets inherit the ramp:

| M3 slot | Apple style | | M3 slot | Apple style |
| --- | --- | --- | --- | --- |
| `displayLarge` | Large Title | | `titleLarge` | Title 3 |
| `displayMedium` | Title 1 | | `titleMedium` | **Headline** (17/500) |
| `displaySmall` | Title 2 | | `titleSmall` | Subheadline |
| `headlineLarge` | Title 1 | | `bodyLarge` | Body |
| `headlineMedium` | Title 2 | | `bodyMedium` | Callout |
| `headlineSmall` | Title 3 | | `bodySmall` | Footnote |
| `labelLarge` | Headline (buttons) | | `labelMedium` | Footnote / 500 |
| `labelSmall` | Caption 2 / 500 | | | |

### Arabic leading rule

Arabic keeps the **same sizes** but takes a **taller leading** — `height` is
scaled by `kArabicLeadingScale` (**1.18×**), tracking stays 0. Apply it with
`DabblerType.arabic(style)`, or get a whole themed ramp via
`dabblerTextTheme(arabic: true)` / `dabblerTextThemeFor(const Locale('ar'))`.
The CSS mirror does the same under `[dir="rtl"]`.

The active locale lives in `themeControllerProvider` (`ThemeState.locale`).
`dabblerThemeData(theme, brightness, {locale})` folds it into the text theme, so
changing locale rebuilds the theme. `setLocale()` persists it; `MaterialApp`
also flips direction to RTL for `ar`.

### The font binaries

The family `ReadexPro` is declared in `pubspec.yaml` with five weights
(300/400/500/600/700) under `assets/fonts/`:

```
assets/fonts/ReadexPro-Light.ttf     (300)
assets/fonts/ReadexPro-Regular.ttf   (400)
assets/fonts/ReadexPro-Medium.ttf    (500)
assets/fonts/ReadexPro-SemiBold.ttf  (600)
assets/fonts/ReadexPro-Bold.ttf      (700)
```

The repo ships **real Readex Pro** binaries (SIL OFL 1.1), each containing both
Latin and Arabic glyphs. To swap in the official Google Fonts copies, replace
these files keeping the same filenames — no code or pubspec change needed.

> **Note:** the font files must contain glyphs. Empty/placeholder `.ttf` files
> make CanvasKit (web) render **no text** (it does not fall back), and a
> *declared-but-missing* asset is a hard build error — so don't blank these out.

## Spacing, radius & elevation (`dabbler_spacing.dart`)

Read geometry from `DabblerSpacing` / `DabblerRadius` / `DabblerSizing` /
`DabblerElevation` — never inline raw numbers.

```dart
Padding(padding: const EdgeInsets.all(DabblerSpacing.cardPadding), …);
ClipRRect(borderRadius: DabblerRadius.cardRadius, …);
Container(decoration: BoxDecoration(boxShadow: DabblerElevation.level2), …);
```

### Base-3 grid

The scale is **base 3**: `space1..space11` = 3, 6, 9, 12, 15, 18, 21, 24, 30, 36,
48, with semantic aliases (`cardPadding` 18, `screenGutter` 24, `sectionGap` 30,
`stackTight` 6, `stackDefault` 12, `iconGap` 6). Radii are base-3 too — `sm` 6,
`md` 9, `lg` 12, `xl` 18, `pill` 999.

> **Prefer 12 / 24 / 30 / 36 / 48 for structural values.** These are multiples of
> **both 3 and 4**, so they line up with 24px icons (`iconMd`, the HugeIcons
> native grid) and platform components. Use the other steps for fine tuning.

`touchTargetMin` is **45** (base-3, and clears Apple's 44pt floor) — use it as the
minimum tap size.

### Elevation — the FLAT rule is RETIRED; Liquid Glass is the rule

> **Superseded (glass era).** The system previously mandated *flat* elevation —
> no shadows, separation via borders + tint only. That rule is **retired** and
> replaced by the **Glass elevation rule** below (source of truth:
> `dabbler.pen` · "Search Screen"). Do not follow the old flat guidance.

Surfaces are now **liquid glass** (`dabbler_glass.dart`):

- **Surface** — a translucent fill (white 45% light / ~12% dark) over a
  `BackdropFilter` blur (`DabblerGlass.blurCard/blurField/blurSmall/blurSelected`).
- **Border** — a 1px **gradient hairline** (white → brand-light → brand →
  white, top to bottom) that re-tints from the active theme's `brandPrimary`.
- **Shadow** — a two-part set per scale (`cardShadows` / `raisedShadows` /
  `insetShadows` / `selectedShadows`): a **coloured cast** derived from
  `brandPrimary` plus a 1px **white lip** highlight. Cards and chips DO cast
  these glass shadows now.
- **Background** — glass only reads against `DabblerGlassBackground` (a theme-
  tinted base + four brand/accent radial orbs).
- **Selected / active** — brand fill @ 85% + a top-lit sheen + a white 70%
  stroke; the label reads `onBrand` (dark in Bright/Sport — never white).

Build glass surfaces with `DabblerGlassSurface` — it enforces the performance
rules (one `BackdropFilter` per surface, never nested; `RepaintBoundary`;
`DabblerGlass.enabled` + platform high-contrast / disable-animations degrade it
to a solid tinted surface + border).

`DabblerElevation.level2` remains only as the legacy floating shadow used by
Material dialogs / sheets / menus via `dabblerThemeData`; new surfaces should
use the `DabblerGlass` shadow sets instead.

## Persistence

`theme_controller.dart` persists the user override + `ThemeMode` through the
`ThemePreferences` seam (a `SharedPreferences` implementation by default). To
sync with Supabase, implement `ThemePreferences` against your Supabase client
and swap `themePreferencesProvider` — nothing else changes.

## Web (`dabbler_tokens.css`)

`color-mix()` is supported in Chrome 111+, Safari 16.2+, Firefox 113+. Set
`[data-theme]` and `[data-mode="dark"]` on `<html>`; consume the
`--color-*` semantic variables.

## Debug Theme Gallery

A debug-only screen (`debug/theme_gallery.dart`, route behind `kDebugMode`)
renders an app bar, CTAs, status chips, and nested surfaces across all 7 themes ×
light/dark. It is the visual acceptance check for this layer.
