<!--
Component page, D-033 ten-part template.

Group    : Presentation
Sources  : lib/src/overlays/sheet_list.dart (class dartdoc)
           lib/src/overlays/sort_control_gallery.dart (specimen
           "SheetList — a bounded list inside a sheet")
           design: Listings.dc.html:313-345 (location sheet)
-->

# SheetList
### `DabblerSheetList`

SheetList is a scrolling list with a height of its own, for the body of a sheet: the sheet already
scrolls its content, so a long list inside it needs a bound.

It can pin a search field above the rows, and shows a loading or an empty state in their place.

## Specimen

A searchable list of thirty places, and the empty state — see `sort_control_gallery.dart`'s
*SheetList* section.

@specimen sheet-list

## Using it

**Use it whenever a sheet holds more rows than fit.** A short list shrinks to fit; a long one stops
at half the viewport and scrolls, leaving the sheet's title and the header in view.

**Put the search field in `header`, not in the rows.** It stays pinned while the rows scroll, and
stays usable while `loading`.

**Pass `emptyText` for the no-match case.** Without it, and without `empty`, an empty list draws
nothing.

## Axes

### State
Rows, loading (a centred `Spinner`), and empty.

### Bound
Half the viewport by default; set `maxHeightFraction`, or an absolute `maxHeight`.

## Tokens used

Header gap: `space3`. State padding: `space8`. Empty text: `footnote` in `textTertiary`.

## Change log

- Alpha DS gaps 5 — adds this component.

## Source

`lib/src/overlays/sheet_list.dart`
