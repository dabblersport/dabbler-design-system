<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/sheet.dart (read in full through the "Route
           integration" section of the class dartdoc — presentation enum,
           flat/detents/dragging/dismissal sections)
           lib/src/overlays/sheet_gallery.dart:18 (specimen title: "Sheet —
           detents and footer (trigger)")
           DECISIONS.md — grepped "Sheet": no ruling touches this
           component's own behaviour (one incidental mention inside D-013,
           listing Sheet among components that correctly reach title3
           through the shared class rather than an inline style).
-->

# Sheet
### `DabblerSheet`

Sheet is the canonical bottom sheet — the phone-width presentation of a modal, and the container
Menu falls back to below its own breakpoint.

The wash is the shared scrim primitive and nothing here redeclares its colour or fade; everything
the scrim doesn't own — the panel, positioning, the entry/exit transition, drag-to-dismiss, Escape
and focus capture — belongs to Sheet. It's flat like every other surface: no shadow, because the
scrim is what separates it from the page beneath.

## Specimen

Multiple detents with a footer, opened from a trigger — see `sheet_gallery.dart`'s *Sheet* section.

@specimen sheet/detents

Pass `detent: DabblerSheetDetent.content` to size the sheet to its content instead: a short body
gives a short sheet, and a long one stops at `contentMaxFraction` of the screen (0.8 by default;
the design's sheets cap at 80% and 78%) and scrolls, with the footer still pinned. The `detents`
list is ignored in this mode. Dragging the handle down past the dismiss threshold closes it; a
shorter drag springs back.

@specimen sheet/content

## Using it

**Reserve `inline` presentation for documentation cards and embedded previews — never for a live
modal.** `modal` is what owns the viewport (scrim, bottom alignment, Escape, focus capture);
`inline` is the panel alone, and using it where a real modal is needed leaves out the scrim, the
positioning and the dismissal handling a modal needs.

**Drag the handle by transform only — never by changing height, top or margin.** That's how this
component's own drag gesture works, and it's the reason dragging never triggers a relayout: any
composition on top of Sheet that tries to animate the panel by resizing it is working against how
the panel actually moves.

**Give a dismissible sheet a visible close affordance, not just the drag-to-dismiss gesture.** The
close button here is a deliberate addition beyond the source, which relies on the pointer alone on
the web — this system doesn't assume every user will discover an edge-drag gesture.

## Axes

### Presentation
`modal` (owns the viewport — scrim, positioning, Escape, focus capture) or `inline` (panel only, for
embedded contexts, never a live modal).

### Detents
One or more viewport-height fractions, sorted ascending; the panel snaps to the nearest one on
release.

### Sizing
Fixed fractions (`fractions`, the default) or sized to the content up to a cap (`content`).

### Dismissibility
Dismissible (Escape, a scrim press, and the close affordance all work) or not.

## Tokens used

Panel: opaque card surface fill, a hairline border, top corners at the extra-large radius step. No
shadow — the one reserved elevation shadow belongs to Dialog alone and is deliberately never
referenced here.

## Change log

- KAN-412 W1 — `DabblerSheetDetent.content` and `contentMaxFraction`. Additive; the default sizing
  is unchanged.

## Source

`lib/src/overlays/sheet.dart`, `lib/src/overlays/sheet_detent.dart`
