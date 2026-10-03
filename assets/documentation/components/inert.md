<!--
Component page, D-033 ten-part template.

Sources : lib/src/interaction/inert.dart
          lib/src/foundations/text_gallery.dart (specimen "Inert - a disabled block")
-->

# Inert
### `DabblerInert`

Inert dims a block of content and stops it taking input while a condition holds.

It replaces the app's hand-rolled pairing of an opacity with a pointer blocker. The dimming is the same opacity every disabled control in the system already draws, so a disabled section reads as disabled in the system's own terms.

## Specimen

The same block live and inert - see `text_gallery.dart`.

@specimen inert

## Using it

**Use it for a section that is temporarily unavailable**, such as settings that only apply while another setting is on.

**Do not use it to fade content for decoration.** It means "not available now", and it removes the block from focus traversal.

**It keeps semantics**, so the content is still announced while it cannot be used.

## Tokens used

Opacity: the system disabled opacity, 0.45.

## Source

`lib/src/interaction/inert.dart`
