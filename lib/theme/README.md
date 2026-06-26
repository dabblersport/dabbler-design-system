# Dabbler color & theming

The first design-system layer: **color only**. Material 3, 7 themes, light + dark.

## Files

| File | What it is | Editable? |
| --- | --- | --- |
| `dabbler_colors.dart` | `DabblerPalette` (primitives), `DabblerColors` (`ThemeExtension`, light + dark), `DabblerTheme` / `DabblerSection` enums, `resolveTheme()`, and the resolver `DabblerColors.of(theme, brightness)`. | **Canonical — do not edit color values.** |
| `dabbler_material_scheme.dart` | `dabblerColorScheme(theme, brightness)` — a Material 3 `ColorScheme` per theme, seeded from the 5 reference palettes. | **Canonical — do not edit color values.** |
| `dabbler_tokens.css` | The same tokens as CSS custom properties, for web surfaces (dabbler.pro / dashboard). | **Canonical — do not edit color values.** |
| `dabbler_theme_data.dart` | `dabblerThemeData(theme, brightness)` → ready `ThemeData` (colorScheme + `DabblerColors` extension + `useMaterial3`). | Yes |
| `dabbler_forui_theme.dart` | `dabblerForuiThemeData(material)` → maps the active Material theme into Forui `FThemeData` so the two libraries match. | Yes |
| `theme_controller.dart` | Riverpod `themeControllerProvider` (section + override + ThemeMode), persistence seam. | Yes |

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
