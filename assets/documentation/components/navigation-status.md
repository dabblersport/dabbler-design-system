<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/feedback/navigation_status.dart (class dartdoc in full —
           transitions table, ending and onDone, suspended, accessibility;
           DabblerNavigationStatusPayload and its two forms;
           DabblerNavigationStatusEndReason)
           lib/src/feedback/action_area_gallery.dart (specimen title:
           "NavigationStatus — sequences")
           Origin: the app architecture audit's gap G1 (one persistent
           morphing surface for Processing -> Result), with G2 (an action on
           activity rows), G3 (why it ended) and G4 (the create menu).
-->

# NavigationStatus
### `DabblerNavigationStatus`

NavigationStatus is one persistent Action Area surface that carries an operation from loading or progress to its result, so the result grows out of the same circle the work was shown on.

It owns a single `ActionArea` for its whole life and takes one payload at a time: an activity —
the same spinner, progress bar and ring as `NavigationActivity` — or a message — the same toast and
banner as `NavigationFeedback` — or nothing, which is the bar alone. Changing the payload never
replaces the surface: the working circle takes the result's tone, holds, then grows into the
message. Swapping a `NavigationActivity` for a `NavigationFeedback` cannot do this, because two
different widgets mean two different surfaces; both of those are now thin wrappers over this one.

## Specimen

Four sequences, each on one surface, each playing once and replayable: processing to success;
processing to an error with a retry, back to processing, then success; progress from zero to one
hundred with a cancel, then success; and a sticky information banner the user dismisses, in Arabic.
Under each, the reason the last payload ended.

@specimen navigation-status/sequences

## Using it

**Place this, not the two components above it, when the bar reports an operation.** Hand it the
activity while the work runs and the result when it lands; the surface does the rest. Reach for
`NavigationActivity` or `NavigationFeedback` alone only when the bar shows one or the other and
never both.

**Update progress in place.** A new value, label or presentation of the same activity changes the
surface without restarting anything — a progress tick never shrinks the row. Only a different kind
of payload, or a new message, passes through the circle.

**A new message is a new data object.** The same message re-wrapped in a new payload is the one
already showing; nothing restarts. Hand in a new message object to run the sequence again.

**Clear or advance from `onDone`, and use its reason.** It fires once per payload, the moment the
payload ends, while the close still plays: `timeout`, `dismissed`, `action` (the message's action,
or the activity's cancel, after its own callback ran), or `replaced` (a message that had not ended
was superseded). A null handed in during the close does not cut it short, and a next payload morphs
straight out of it. A payload the host withdraws before it ends is not reported. `onClosed` fires
when a close has finished and the bar is idle again.

**Give a long activity a cancel.** An expanded activity row takes one action, drawn exactly like the
toast's text action and kept to the touch-target minimum. Pressing it runs its callback, contracts
the row back to the bar and reports `action`. The compact circle has no room for one.

**Never present over the open create menu.** The widget cannot see the menu. Set `suspended` while
it is open: the surface stays idle, no timer runs and the payload is kept; when it clears, the
payload is presented from the start. The same holds for a `Dialog` or `Sheet` over the screen, and
for a screen without the bar — use the standard `Toast` there.

## Axes

### Payload
An activity (`spinner`, `ring`, `spinnerLabel`, `indeterminate`, `progress`, `progressExpanded`,
with a label, a value, a status line, an icon and an optional action), a message (`toast` or
`banner`, with a tone, title, message, icon, action, dismissible and duration), or none.

### Transition
In place for the same activity; through the tone circle and the hold for a message; through the
brand circle from a message back to an activity.

### End reason
`timeout`, `dismissed`, `action`, `replaced`.

### Suspended
Idle and timer-free while true; presented from the start when it clears.

## Direction

**The surface follows the bar, as `ActionArea` does.** In Arabic it originates on the left and grows
rightward, the glyph leads on the right and an action or cancel sits at the inline end on the left;
the progress fill runs right to left and the ring still runs clockwise. A bar pinned unmirrored
pins the surface with it.

## Tokens used

Nothing of its own. An activity takes `NavigationActivity`'s colours — the brand fill and on-brand
ink in the circle, the card surface, card outline and primary ink once grown; a message takes the
status tones `NavigationFeedback` reads. Timing is the Action Area's: the action-area hold before a
message grows, the slow step for the size change and the base step for colour and the content fade,
with the fast step for the content leaving first. Under reduced motion only the size step is
dropped. Action and dismiss targets keep the touch-target minimum.

## Source

`lib/src/feedback/navigation_status.dart`
