/// Gallery entries for the message receipts (KAN-580): the six delivery states,
/// the group receipt count in each tier, and the Message info drawer body. Each
/// shows left to right and right to left, English and Arabic.
///
/// Every value is an injected view-model; nothing is sent anywhere.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'message.dart';
import 'message_receipts.dart';
import 'messaging_foundations.dart';

/// The receipt specimens.
const List<GalleryEntry> messageReceiptsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'message-delivery',
    page: 'components/message',
    group: GalleryPurpose.contentContainers,
    title: 'Message delivery — sending to seen',
    description:
        'Sending, retrying, sent, delivered, seen and not sent, with the word '
        'spelled, left to right and right to left.',
    builder: _delivery,
  ),
  GalleryEntry(
    id: 'message-group-receipt',
    page: 'components/message',
    group: GalleryPurpose.contentContainers,
    title: 'Message group receipt — Seen by N of M',
    description:
        'One compact count per outgoing group message in each tier, opening '
        'the Message info drawer.',
    builder: _groupReceipt,
  ),
  GalleryEntry(
    id: 'receipts-sheet',
    page: 'components/message',
    group: GalleryPurpose.contentContainers,
    title: 'ReceiptsSheet — Message info',
    description:
        'The message, three summary tiles and a list per state, in English '
        'and Arabic.',
    builder: _sheet,
  ),
];

void _noop() {}

Widget _both(String label, Widget Function(String lang) build) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: '$label — LTR',
      child: SizedBox(width: 360, child: build('en')),
    ),
    GallerySpecimen(
      label: '$label — RTL',
      child: SizedBox(
        width: 360,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: build('ar'),
        ),
      ),
    ),
  ],
);

Widget _delivery(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerDeliveryState d in DabblerDeliveryState.values)
      _both(
        d.name,
        (String lang) => DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: lang == 'ar' ? 'أنا في الطريق' : 'On my way',
          timestamp: '17:12',
          deliveryState: d,
          showDeliveryLabel: true,
          lang: lang,
          onRetry: d == DabblerDeliveryState.failed ? _noop : null,
        ),
      ),
  ],
);

Widget _groupReceipt(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerReceipt r in const <DabblerReceipt>[
      DabblerReceipt(seen: 9, delivered: 9, total: 9),
      DabblerReceipt(seen: 4, delivered: 7, total: 9),
      DabblerReceipt(delivered: 7, total: 9),
      DabblerReceipt(total: 9),
    ])
      _both(
        r.text(),
        (String lang) => DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          context: DabblerMessageContext.group,
          content: lang == 'ar' ? 'الملعب الثالث الليلة' : 'Pitch 3 tonight',
          timestamp: '20:40',
          deliveryState: DabblerDeliveryState.sent,
          receipt: r,
          onReceipts: _noop,
          lang: lang,
        ),
      ),
  ],
);

Widget _sheet(BuildContext context) => _both('Message info', (String lang) {
  final bool ar = lang == 'ar';
  return DabblerReceiptsSheet(
    lang: lang,
    preview: ar ? 'الملعب الثالث الليلة' : 'Pitch 3 tonight',
    groups: <DabblerReceiptGroup>[
      DabblerReceiptGroup(
        state: DabblerDeliveryState.seen,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(
            name: ar ? 'أحمد' : 'Ahmed',
            time: ar ? '8:43 م' : '8:43 PM',
          ),
          DabblerReceiptPerson(
            name: ar ? 'سارة' : 'Sara',
            time: ar ? '8:44 م' : '8:44 PM',
          ),
        ],
      ),
      DabblerReceiptGroup(
        state: DabblerDeliveryState.delivered,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(
            name: ar ? 'يوسف' : 'Yousef',
            time: ar ? '8:41 م' : '8:41 PM',
          ),
        ],
      ),
      DabblerReceiptGroup(
        state: DabblerDeliveryState.sent,
        people: <DabblerReceiptPerson>[
          DabblerReceiptPerson(name: ar ? 'بريا' : 'Priya'),
        ],
      ),
    ],
  );
});
