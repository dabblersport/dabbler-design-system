<!--
Component page, D-033 ten-part template.

Tier     : Structure
Sources  : lib/src/messaging/messaging_atoms.dart (DabblerDateSeparator)
           lib/src/messaging/messaging_atoms_gallery.dart (entry date-separator)
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
           files components/messaging/DateSeparator.jsx and DateSeparator.prompt.md, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
           No browser or side-by-side comparison was made.
-->

# DateSeparator
### `DabblerDateSeparator`

DateSeparator is the day boundary in a conversation timeline.

It is a centred sunken pill carrying a label the screen has already formatted; the component never formats a date itself, so locale and calendar handling stay with the screen. It breaks message grouping.

## Specimen

Two day pills, a short label and a full date. See `messaging_atoms_gallery.dart`.

@specimen date-separator

## Using it

**Format the date before you pass it.** `label` is shown as given; use the screen's locale and calendar to produce `Today`, `أمس` or `Saturday, 14 September`.

**Place it between groups.** A separator ends the current message group; MessageThread renders it from a date item.

## Direction

The pill stays centred in both directions and its 9px inline padding is symmetric. Arabic labels use the Arabic caption-1 metrics (11.1 on 16). Every axis is logical, so the whole layout mirrors under right-to-left with no direction-specific parameter and no duplicate component.

## Tokens used

Fills and ink: the sunken surface and the secondary ink (the source's `--muted`, D-003(a)). Corner: the pill radius. Spacing: 3 block and 9 inline inside the pill, 6 above and below. Type: caption-1 at weight 600.

## Source

`lib/src/messaging/messaging_atoms.dart`
