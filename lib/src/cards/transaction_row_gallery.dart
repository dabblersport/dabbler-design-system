/// Gallery entries for [DabblerTransactionRow] (Alpha fidelity, KAN-426).
library;

import 'package:flutter/widgets.dart';

import '../foundations/text.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../surfaces/badge.dart';
import '../surfaces/icon_tile.dart';
import 'transaction_row.dart';

/// TransactionRow's specimens.
const List<GalleryEntry> transactionRowGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'transaction-row',
    page: 'components/transaction-row',
    group: GalleryPurpose.contentContainers,
    title: 'TransactionRow — one money line in a history list',
    description:
        'A payment, a refund (money in), a long title ellipsising, and the '
        'row in Arabic.',
    builder: _rows,
  ),
];

Widget _rows(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'payment',
      child: DabblerTransactionRow(
        leading: DabblerIconTile.named('calendar'),
        title: 'Court Booking',
        badge: DabblerBadge(label: 'COMPLETED'),
        detail: 'Zayed Sports City',
        detailIcon: 'building',
        caption: 'Visa •••• 4242',
        amount: '-AED 200',
        amountCaption: '2h ago',
      ),
    ),
    GallerySpecimen(
      label: 'refund — money in',
      child: DabblerTransactionRow(
        leading: DabblerIconTile.named('card'),
        title: 'Booking Cancellation Refund',
        badge: DabblerBadge(label: 'COMPLETED'),
        detail: 'System Refund',
        amount: '+AED 100',
        amountTone: DabblerTextTone.success,
        amountCaption: 'Yesterday',
      ),
    ),
    GallerySpecimen(
      label: 'Arabic',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DabblerTransactionRow(
          leading: DabblerIconTile.named('calendar'),
          title: 'حجز ملعب',
          badge: DabblerBadge(label: 'مكتمل'),
          detail: 'مدينة زايد الرياضية',
          detailIcon: 'building',
          caption: 'فيزا •••• ٤٢٤٢',
          amount: '-٢٠٠ د.إ',
          amountCaption: 'منذ ساعتين',
        ),
      ),
    ),
  ],
);
