/// Gallery entries for the messaging gap components (KAN-508): the thread
/// skeleton, the connection notice, the older-messages pager, the composer
/// state notice and the time mark. Each shows left to right and right to left.
///
/// The strings are demo text for the specimens; the components carry none.
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import 'composer_state_notice.dart';
import 'connection_notice.dart';
import 'older_messages_pager.dart';
import 'thread_skeleton.dart';
import 'time_mark.dart';

/// The messaging gap specimens.
const List<GalleryEntry> messagingGapsGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'thread-skeleton',
    page: 'components/messaging-thread-parts',
    group: GalleryPurpose.presentation,
    title: 'ThreadSkeleton — a thread while it loads',
    description: 'Message-row placeholders, left to right and right to left.',
    builder: _skeleton,
  ),
  GalleryEntry(
    id: 'connection-notice',
    page: 'components/messaging-thread-parts',
    group: GalleryPurpose.presentation,
    title: 'ConnectionNotice — offline and reconnecting',
    description: 'The caller supplies the text; shown, reconnecting, RTL.',
    builder: _connection,
  ),
  GalleryEntry(
    id: 'older-messages-pager',
    page: 'components/messaging-thread-parts',
    group: GalleryPurpose.presentation,
    title: 'OlderMessagesPager — load earlier messages',
    description: 'Idle, loading and error with retry, and right to left.',
    builder: _pager,
  ),
  GalleryEntry(
    id: 'composer-state-notice',
    page: 'components/messaging-thread-parts',
    group: GalleryPurpose.presentation,
    title: 'ComposerStateNotice — closed and cannot send',
    description: 'Read-only closed and cannot-send, and right to left.',
    builder: _composerNotice,
  ),
  GalleryEntry(
    id: 'time-mark',
    page: 'components/messaging-thread-parts',
    group: GalleryPurpose.presentation,
    title: 'TimeMark — a date and time tile',
    description: 'A tinted tile with a date label and an optional countdown.',
    builder: _timeMark,
  ),
];

void _noop() {}

Widget _both(String label, Widget child) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: '$label — LTR',
      child: SizedBox(width: 360, child: child),
    ),
    GallerySpecimen(
      label: '$label — RTL',
      child: SizedBox(
        width: 360,
        child: Directionality(textDirection: TextDirection.rtl, child: child),
      ),
    ),
  ],
);

Widget _skeleton(BuildContext context) => _both(
  'thread skeleton',
  const SizedBox(height: 320, child: DabblerThreadSkeleton(animate: false)),
);

Widget _connection(BuildContext context) => GalleryStack(
  children: <Widget>[
    _both(
      'offline',
      const DabblerConnectionNotice(
        text: 'You are offline. Messages will wait.',
      ),
    ),
    _both(
      'reconnecting',
      const DabblerConnectionNotice(
        text: 'Reconnecting...',
        reconnecting: true,
      ),
    ),
    _both(
      'Arabic text',
      const DabblerConnectionNotice(text: 'لا يوجد اتصال. ستنتظر الرسائل.'),
    ),
  ],
);

Widget _pager(BuildContext context) => GalleryStack(
  children: <Widget>[
    _both(
      'idle',
      const DabblerOlderMessagesPager(
        idleLabel: 'Earlier messages',
        loadingLabel: 'Loading',
        errorText: 'Could not load',
        retryLabel: 'Retry',
        onLoad: _noop,
      ),
    ),
    _both(
      'loading',
      const DabblerOlderMessagesPager(
        state: DabblerOlderMessagesState.loading,
        idleLabel: 'Earlier messages',
        loadingLabel: 'Loading',
        errorText: 'Could not load',
        retryLabel: 'Retry',
      ),
    ),
    _both(
      'error',
      const DabblerOlderMessagesPager(
        state: DabblerOlderMessagesState.error,
        idleLabel: 'Earlier messages',
        loadingLabel: 'Loading',
        errorText: 'Could not load',
        retryLabel: 'Retry',
        onRetry: _noop,
      ),
    ),
  ],
);

Widget _composerNotice(BuildContext context) => GalleryStack(
  children: <Widget>[
    _both(
      'closed',
      const DabblerComposerStateNotice(
        kind: DabblerComposerNoticeKind.closed,
        text: 'This game chat is closed.',
      ),
    ),
    _both(
      'cannot send',
      const DabblerComposerStateNotice(
        kind: DabblerComposerNoticeKind.cannotSend,
        text: 'You cannot send messages here.',
      ),
    ),
  ],
);

Widget _timeMark(BuildContext context) => GalleryStack(
  children: <Widget>[
    _both(
      'label and countdown',
      const DabblerTimeMark(
        label: 'Sat 14 Oct, 7:30 PM',
        countdown: 'In 2 hours',
      ),
    ),
    _both('label only', const DabblerTimeMark(label: 'Sat 14 Oct, 7:30 PM')),
    _both(
      'Arabic',
      const DabblerTimeMark(
        label: 'السبت 14 أكتوبر، 7:30 م',
        countdown: 'بعد ساعتين',
      ),
    ),
  ],
);
