<!--
Component page, D-033 ten-part template.

Tier     : Structure
Sources  : lib/src/messaging/messaging_atoms.dart (DabblerUnreadDivider)
           lib/src/messaging/messaging_atoms_gallery.dart (entry unread-divider)
           Live Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System),
           files components/messaging/UnreadDivider.jsx and UnreadDivider.prompt.md, read via DesignSync
           get_file on 2026-10-02 and transcribed to a local mirror by the coordinator.
           No browser or side-by-side comparison was made.
-->

# UnreadDivider
### `DabblerUnreadDivider`

UnreadDivider is the "new messages" boundary in a timeline.

It is a labelled divider whose rules and label are both the brand colour, with a caption-2 label at weight 700. It is deliberately not a banner: it marks a position and announces nothing.

## Specimen

The default label and a counted label. See `messaging_atoms_gallery.dart`.

@specimen unread-divider

## Using it

**Pair it with the unread anchor.** Use it with MessageThread anchored at `unread` so the timeline opens at this line.

**Keep the label short.** The label stays on one line and ellipsises, as the Divider label does.

## Direction

The rules flank the label symmetrically, so the divider reads the same in both directions, with 6px padding on every side. Arabic labels use the Arabic caption-2 metrics (10.1 on 13). Every axis is logical, so the whole layout mirrors under right-to-left with no direction-specific parameter and no duplicate component.

## Tokens used

Fills and ink: the brand primary for both rules and the label (the source overrides `--faint` with `--color-brand-primary`). Spacing: 6 around, 12 between label and rules. Size: the 1px default border. Type: caption-2 at weight 700.

## Source

`lib/src/messaging/messaging_atoms.dart`
