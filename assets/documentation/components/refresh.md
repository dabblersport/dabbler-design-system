<!--
Component page, D-033 ten-part template.

Group    : Status and feedback
Sources  : lib/src/layout/refresh.dart (DabblerRefresh — gesture from
           RefreshIndicator.noSpinner, every visible pixel a DabblerSpinner)
           lib/src/layout/refresh_gallery.dart (specimen "Refresh — pull to
           refresh")
           KAN-409 item 3
-->

# Refresh
### `DabblerRefresh`

Refresh wraps a vertical scrollable so pulling it down past the top edge reloads its content.

The pull gesture is the framework's own, but nothing the framework would draw reaches the screen:
the only indicator is the system `Spinner` in its brand tone, still while the user drags and turning
once the pull is armed and while the refresh runs.

## Specimen

A pullable list — see `refresh_gallery.dart`'s *Refresh* section.

@specimen refresh

## Using it

**Return the real reload future from `onRefresh`.** The indicator turns exactly as long as that
future is pending; a future that completes early makes the refresh look finished before it is.

**Wrap a scrollable whose physics allow overscroll.** A plain `ListView` or `CustomScrollView` is
enough; a non-scrolling child gives the gesture nothing to pull.

**Never put a second loader inside the list for the same reload.** The pull indicator already says a
refresh is running.

## Direction

The indicator is centred, so it does not move between English and Arabic; only the content beneath
it mirrors.

## Tokens used

Indicator: `Spinner` in the `brand` tone, so `brandPrimary` and re-tinted per section theme. Inset
from the top edge: `space4`. Fade: `base` duration on the `easeOut` curve.

## Source

`lib/src/layout/refresh.dart`
