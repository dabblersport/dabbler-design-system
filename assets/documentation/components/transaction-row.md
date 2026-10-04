<!--
Component page, D-033 ten-part template.

Group    : Content containers
Sources  : lib/src/cards/transaction_row.dart (class dartdoc)
           lib/src/cards/transaction_row_gallery.dart (specimen "TransactionRow — one money line in a history list")
           app: Transactions history (no design frame)
-->

# TransactionRow
### `DabblerTransactionRow`

TransactionRow is one money line in a history list, drawn as a tappable card.

It holds a leading icon tile, a title with a status badge beside it, a detail line, a caption, and
the amount with its time at the inline end.

## Specimen

A payment, a refund, and the row in Arabic — see `transaction_row_gallery.dart`.

@specimen transaction-row

## Using it

**Give the amount as it should read.** Sign and currency are part of the string; the component does
no formatting. Set `amountTone` to success for money in.

**Pass the badge and tile as widgets.** A `DabblerBadge` for the status and a `DabblerIconTile` for
the type; the row owns the gaps and every text style.

**Make it tappable with `onTap`.** The whole card is one button with the card's press treatment.

## Axes

### Amount tone
Primary for money out, success for money in.

### Optional lines
Detail (with an optional small glyph) and caption are each omitted when null.

## Direction

The tile sits at the inline start and the amount column at the inline end; in Arabic they swap sides.

## Tokens used

Card shell and padding from `DabblerCard`. Type: subheadline (title), footnote (detail), caption2
(caption and time), headline (amount). Gaps: `space1`, `space3`, `space4`.

## Change log

- Alpha fidelity (KAN-426) — adds this component so history lists are not hand-arranged.

## Source

`lib/src/cards/transaction_row.dart`
