<!--
Component page, D-033 ten-part template.

Tier     : Content containers (composed cards)
Sources  : lib/src/layout/settings_parts.dart
           lib/src/layout/settings_choices.dart
           lib/src/layout/settings_parts_gallery.dart (specimen title:
           "SettingsHeader and RowGroup — the Settings page parts";
           "PresetCard, OptionSegments and OptionRow — Settings choices")
           Claude Design file "Settings.dc.html", the hero at lines 77-95 and
           the group at lines 131-240.
-->

# SettingsParts
### `DabblerSettingsHeader`, `DabblerRowGroup`, `DabblerColorDots`, `DabblerPresetCard`, `DabblerOptionSegments`, `DabblerOptionRow`

The parts a Settings page is built from: a tinted hero, a titled card of rows, a row of palette dots, and the choice parts of the sub-pages.

SettingsHeader is the tinted hero at the top of the root page; RowGroup is a titled card of rows divided by hairlines; ColorDots is a row of small round dots for previewing a palette.

## Specimen

The hero with its version pill, title and identity row, and a group with a toggle row and a destructive row — see `settings_parts_gallery.dart`.

@specimen settings-parts

PresetCard is one option in a stack of described choices, the chosen one filled with the brand colour; OptionSegments is a card of equal icon-over-label options; 

@specimen settings-choices

## Using it

**PresetCard is one of a stack, chosen by the caller.** Give each card its `icon`, `title` and `description`; mark the chosen one `selected`. The card holds no state, and a null `onTap` disables it.

**OptionSegments is a controlled choice.** Pass `items`, the chosen `value` and `onChanged`; a `value` matching no item highlights none.

**OptionRow is a choice in a sheet.** One bordered card row per option, with a brand check on the chosen one; the caller closes the sheet.

**The hero carries its own top bar.** Pass a titled top bar as `topBar` so the bar sits on the tint.

**The identity row is a flat input row.** Pass a `DabblerInputRow` with `flat: true` and `showDivider: false`; the hero draws the translucent card behind it.

**ColorDots previews a palette.** Pass the colours of another theme's roles; it draws small round dots and is decorative.

**A group of choices uses `DabblerRowGroup.stack`.** It draws the heading and note over loose children — preset cards or option segments — with a 9px gap and no card.

**RowGroup separates, it does not style.** Give it flat input rows with `showDivider: false`; it draws the card and the hairlines between them. `header` and `note` sit above the card.

**RowHint and RowAction.** A hint is a muted one-line note with an information glyph, used where a group has nothing to list; a row action is a destructive text action at a row's end, such as Unblock.

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
- Added OptionRow for sheet choice lists.
- Added PresetCard and OptionSegments for the Settings sub-pages (privacy presets, appearance).
- Added RowHint and RowAction for the blocked-accounts list.

## Source

`lib/src/layout/settings_parts.dart`, `lib/src/layout/settings_choices.dart`, `Settings.dc.html`.
