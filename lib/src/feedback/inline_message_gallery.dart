/// Gallery entries for [DabblerInlineMessage] (Alpha fidelity, KAN-426).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'inline_message.dart';

/// InlineMessage's specimens.
const List<GalleryEntry> inlineMessageGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'inline-message',
    page: 'components/inline-message',
    group: GalleryPurpose.statusAndFeedback,
    title: 'InlineMessage — a line of status under a control',
    description:
        'Every tone, the expired-code glyph, and a long message wrapping, in '
        'English and Arabic.',
    builder: _messages,
  ),
];

Widget _messages(BuildContext context) => GalleryStack(
  children: <Widget>[
    for (final DabblerInlineMessageTone tone in DabblerInlineMessageTone.values)
      GallerySpecimen(
        label: tone.name,
        child: DabblerInlineMessage(
          'That code is not right. Check the email and try again.',
          tone: tone,
        ),
      ),
    const GallerySpecimen(
      label: 'custom glyph — expired',
      child: DabblerInlineMessage(
        'This code has expired. Send a new one.',
        icon: 'clock',
      ),
    ),
    const GallerySpecimen(
      label: 'wrapping',
      child: SizedBox(
        width: 220,
        child: DabblerInlineMessage(
          'Your password does not match. Try again, or email yourself a code.',
        ),
      ),
    ),
    GallerySpecimen(
      label: 'Arabic',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: const DabblerInlineMessage(
          'الرمز غير صحيح. تحقق من بريدك وحاول مرة أخرى.',
        ),
      ),
    ),
  ],
);
