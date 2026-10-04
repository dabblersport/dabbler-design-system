<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/layout/settings_parts.dart
           lib/src/layout/settings_parts_gallery.dart (specimen title:
           "SettingsHeader and RowGroup — the Settings page parts")
           Claude Design file "Settings.dc.html", the hero at lines 77-95 and
           the group at lines 131-240.
-->

# SettingsParts
### `DabblerSettingsHeader`, `DabblerRowGroup`, `DabblerColorDots`

The parts a Settings page is built from: a tinted hero, a titled card of rows, and a row of palette dots.

SettingsHeader is the tinted hero at the top of the root page; RowGroup is a titled card of rows divided by hairlines; ColorDots is a row of small round dots for previewing a palette.

## Specimen

The hero with its version pill, title and identity row, and a group with a toggle row and a destructive row — see `settings_parts_gallery.dart`.

@specimen settings-parts

## Using it

**The hero carries its own top bar.** Pass a titled top bar as `topBar` so the bar sits on the tint.

**The identity row is a flat input row.** Pass a `DabblerInputRow` with `flat: true` and `showDivider: false`; the hero draws the translucent card behind it.

**ColorDots previews a palette.** Pass the colours of another theme's roles; it draws small round dots and is decorative.

**RowGroup separates, it does not style.** Give it flat input rows with `showDivider: false`; it draws the card and the hairlines between them. `header` and `note` sit above the card.

## Axes

### Hero
With or without a version pill, subtitle and identity row.

### Group
With or without a header and note.

## Direction

The pill, title and rows start at the inline start; the identity row's chevron mirrors.

## Tokens used

The brand colour at 14% over the card surface for the tint, the card surface and default border for the group, text primary, secondary and tertiary, `largeTitle`, `footnote` and `caption1`, and the 12, 15, 18 and 21 spacing steps.

## Change log

- Added for the Settings fidelity rebuild.

## Source

`lib/src/layout/settings_parts.dart`, `Settings.dc.html`.
