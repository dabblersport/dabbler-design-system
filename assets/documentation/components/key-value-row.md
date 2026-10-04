<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/layout/key_value_row.dart (class dartdoc)
           lib/src/layout/key_value_row_gallery.dart (specimen "KeyValueRow — a read-only label and its value")
           app: transaction details, admin report details, venue submission details (no design frame)
-->

# KeyValueRow
### `DabblerKeyValueRow`

KeyValueRow is a label and its value on one line of a detail sheet or summary card: "Status —
Completed", "Address — Plot 12, Marina Walk".

It is not an input row. It has no tap, no chevron and no control; use InputRow when the reader acts
on the row.

## Specimen

Inline, a long value wrapping, stacked, a badge in place of text, and Arabic — see
`key_value_row_gallery.dart`.

@specimen key-value-row

## Using it

**Pass the value as a string.** It is set at weight 600 and wraps; nothing is ellipsised.

**Use the stacked layout for a sentence.** A description or an admin note reads better with the label
above and the value under it, full width.

**Pass a widget for a status.** A badge goes in `trailing` in place of the value text.

## Axes

### Layout
Inline (label at the inline start, value at the inline end, the value taking up to two thirds of the
row and wrapping) or stacked (label above value).

### Value tone
The ink of the value text; primary by default, brand or success where the value is meaningful.

## Direction

Everything is directional. In Arabic the label sits at the right and the value at the left, with no
conditional in the call site.

## Tokens used

Type: subheadline, secondary ink for the label, weight 600 for the value. Gap: `space4` between label
and value, `space1` between stacked lines. Padding: `space3` above and below.

## Change log

- Alpha fidelity (KAN-426) — adds this component so label/value lines are not hand-arranged.

## Source

`lib/src/layout/key_value_row.dart`
