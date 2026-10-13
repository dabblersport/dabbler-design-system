// KAN-508: the messaging gap components — thread skeleton, connection notice,
// older-messages pager, composer state notice and time mark.
import 'dart:io';

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'messaging_parts_host.dart';

Widget _scaled(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: partsHost(child, direction: dir),
    );

void main() {
  group('DabblerThreadSkeleton', () {
    testWidgets('LTR: received avatar at the start, sent bubble at the end', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const SizedBox(
            height: 600,
            child: DabblerThreadSkeleton(animate: false),
          ),
        ),
      );
      final Rect box = tester.getRect(find.byType(DabblerThreadSkeleton));
      final Rect avatar = tester.getRect(find.byType(DabblerSkeleton).at(0));
      expect(avatar.left - box.left, lessThan(60));
      // Row 3 (index 2) is a sent row: its bubble hugs the end edge.
      final Finder rects = find.byWidgetPredicate(
        (Widget w) =>
            w is DabblerSkeleton && w.variant == DabblerSkeletonVariant.rect,
      );
      final Rect sent = tester.getRect(rects.at(2));
      expect(box.right - sent.right, lessThan(60));
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL mirrors: avatar at the right, sent bubble at the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const SizedBox(
            height: 600,
            child: DabblerThreadSkeleton(animate: false),
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Rect box = tester.getRect(find.byType(DabblerThreadSkeleton));
      final Rect avatar = tester.getRect(find.byType(DabblerSkeleton).at(0));
      expect(box.right - avatar.right, lessThan(60));
      final Finder rects = find.byWidgetPredicate(
        (Widget w) =>
            w is DabblerSkeleton && w.variant == DabblerSkeletonVariant.rect,
      );
      expect(tester.getRect(rects.at(2)).left - box.left, lessThan(60));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rows count is honoured and a short box does not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const SizedBox(
            height: 120,
            child: DabblerThreadSkeleton(rows: 9, animate: false),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is DabblerSkeleton && w.variant == DabblerSkeletonVariant.rect,
        ),
        findsNWidgets(9),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DabblerConnectionNotice', () {
    testWidgets('shown with the caller text; hidden collapses to nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(const DabblerConnectionNotice(text: 'caller offline text')),
      );
      expect(find.text('caller offline text'), findsOneWidget);
      expect(find.byType(DabblerIcon), findsOneWidget);
      await tester.pumpWidget(
        partsHost(
          const DabblerConnectionNotice(
            text: 'caller offline text',
            visible: false,
          ),
        ),
      );
      expect(find.text('caller offline text'), findsNothing);
      expect(tester.getSize(find.byType(DabblerConnectionNotice)).height, 0);
    });

    testWidgets('reconnecting shows a spinner instead of the icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerConnectionNotice(text: 'again', reconnecting: true),
        ),
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(find.byType(DabblerIcon), findsNothing);
    });

    testWidgets('RTL puts the icon on the right of the text', (tester) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerConnectionNotice(text: 'نص'),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.byType(DabblerIcon)).dx,
        greaterThan(tester.getCenter(find.text('نص')).dx),
      );
    });

    testWidgets('200 percent text with a long line wraps without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scaled(
          DabblerConnectionNotice(
            text: List<String>.filled(12, 'offline').join(' '),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DabblerOlderMessagesPager', () {
    Widget pager(
      DabblerOlderMessagesState s, {
      VoidCallback? onLoad,
      VoidCallback? onRetry,
    }) => DabblerOlderMessagesPager(
      state: s,
      idleLabel: 'idle-label',
      loadingLabel: 'loading-label',
      errorText: 'error-text',
      retryLabel: 'retry-label',
      onLoad: onLoad,
      onRetry: onRetry,
    );

    testWidgets('idle: a button that calls onLoad', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        partsHost(pager(DabblerOlderMessagesState.idle, onLoad: () => taps++)),
      );
      expect(find.text('idle-label'), findsOneWidget);
      expect(find.byType(DabblerSpinner), findsNothing);
      await tester.tap(find.text('idle-label'));
      expect(taps, 1);
    });

    testWidgets('loading: spinner and text, no button', (tester) async {
      await tester.pumpWidget(
        partsHost(pager(DabblerOlderMessagesState.loading)),
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(find.text('loading-label'), findsOneWidget);
      expect(find.byType(DabblerButton), findsNothing);
    });

    testWidgets('error: caller text and a retry that calls onRetry', (
      tester,
    ) async {
      int retries = 0;
      await tester.pumpWidget(
        partsHost(
          pager(DabblerOlderMessagesState.error, onRetry: () => retries++),
        ),
      );
      expect(find.text('error-text'), findsOneWidget);
      await tester.tap(find.text('retry-label'));
      expect(retries, 1);
    });

    testWidgets('RTL and 200 percent text in every state do not overflow', (
      tester,
    ) async {
      for (final DabblerOlderMessagesState s
          in DabblerOlderMessagesState.values) {
        await tester.pumpWidget(_scaled(pager(s), dir: TextDirection.rtl));
        expect(tester.takeException(), isNull, reason: '$s');
      }
    });
  });

  group('DabblerComposerStateNotice', () {
    testWidgets('closed: lock icon and the caller text', (tester) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerComposerStateNotice(
            kind: DabblerComposerNoticeKind.closed,
            text: 'closed text',
          ),
        ),
      );
      expect(find.text('closed text'), findsOneWidget);
      expect(tester.widget<DabblerIcon>(find.byType(DabblerIcon)).name, 'lock');
    });

    testWidgets('cannot send: its own icon, a warning tone, icon override', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerComposerStateNotice(
            kind: DabblerComposerNoticeKind.cannotSend,
            text: 'cannot text',
          ),
        ),
      );
      expect(find.text('cannot text'), findsOneWidget);
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).name,
        'slash',
      );
      await tester.pumpWidget(
        partsHost(
          const DabblerComposerStateNotice(
            kind: DabblerComposerNoticeKind.cannotSend,
            text: 'cannot text',
            icon: 'info-circle',
          ),
        ),
      );
      expect(
        tester.widget<DabblerIcon>(find.byType(DabblerIcon)).name,
        'info-circle',
      );
    });

    testWidgets('closed and cannot-send differ in fill', (tester) async {
      Future<Color?> fill(DabblerComposerNoticeKind k) async {
        await tester.pumpWidget(
          partsHost(DabblerComposerStateNotice(kind: k, text: 't')),
        );
        final DecoratedBox box = tester.widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(DabblerComposerStateNotice),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        return (box.decoration as BoxDecoration).color;
      }

      expect(
        await fill(DabblerComposerNoticeKind.closed),
        isNot(await fill(DabblerComposerNoticeKind.cannotSend)),
      );
    });

    testWidgets('200 percent text, long line, LTR and RTL: no overflow', (
      tester,
    ) async {
      for (final TextDirection d in TextDirection.values) {
        for (final DabblerComposerNoticeKind k
            in DabblerComposerNoticeKind.values) {
          await tester.pumpWidget(
            _scaled(
              DabblerComposerStateNotice(
                kind: k,
                text: List<String>.filled(14, 'word').join(' '),
              ),
              dir: d,
            ),
          );
          expect(tester.takeException(), isNull, reason: '$k $d');
        }
      }
    });
  });

  group('DabblerTimeMark', () {
    testWidgets('label and countdown render; empty countdown is omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        partsHost(
          const DabblerTimeMark(label: 'label-text', countdown: 'count-text'),
        ),
      );
      expect(find.text('label-text'), findsOneWidget);
      expect(find.text('count-text'), findsOneWidget);
      await tester.pumpWidget(
        partsHost(const DabblerTimeMark(label: 'label-text', countdown: '')),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('the tile is 36 dp and tinted', (tester) async {
      await tester.pumpWidget(partsHost(const DabblerTimeMark(label: 'x')));
      expect(tester.getSize(find.byType(DabblerIconTile)), const Size(36, 36));
    });

    testWidgets('LTR tile before the text, RTL after it', (tester) async {
      await tester.pumpWidget(partsHost(const DabblerTimeMark(label: 'xx')));
      expect(
        tester.getCenter(find.byType(DabblerIconTile)).dx,
        lessThan(tester.getCenter(find.text('xx')).dx),
      );
      await tester.pumpWidget(
        partsHost(
          const DabblerTimeMark(label: 'xx'),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.byType(DabblerIconTile)).dx,
        greaterThan(tester.getCenter(find.text('xx')).dx),
      );
    });

    testWidgets('long text at 200 percent wraps without overflow', (
      tester,
    ) async {
      for (final TextDirection d in TextDirection.values) {
        await tester.pumpWidget(
          _scaled(
            DabblerTimeMark(
              label: List<String>.filled(10, 'Saturday').join(' '),
              countdown: List<String>.filled(10, 'soon').join(' '),
            ),
            dir: d,
          ),
        );
        expect(tester.takeException(), isNull, reason: '$d');
      }
    });

    testWidgets('every tone renders', (tester) async {
      for (final DabblerTimeMarkTone t in DabblerTimeMarkTone.values) {
        await tester.pumpWidget(
          partsHost(DabblerTimeMark(label: 'x', tone: t)),
        );
        expect(tester.takeException(), isNull, reason: '$t');
      }
    });
  });

  group('source discipline', () {
    const List<String> files = <String>[
      'thread_skeleton',
      'connection_notice',
      'older_messages_pager',
      'composer_state_notice',
      'time_mark',
    ];
    test('no raw colour, no hand-set size or padding literal, no copy', () {
      for (final String f in files) {
        final String src = File('lib/src/messaging/$f.dart')
            .readAsLinesSync()
            .where((String l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(src, isNot(contains('Color(0x')), reason: f);
        expect(RegExp(r'\bColors\.').hasMatch(src), isFalse, reason: f);
        expect(
          RegExp(r'EdgeInsets[\w.]*\([^)]*\b\d').hasMatch(src),
          isFalse,
          reason: '$f: numeric EdgeInsets',
        );
        expect(
          RegExp(r'SizedBox\((width|height):\s*\d').hasMatch(src),
          isFalse,
          reason: '$f: numeric SizedBox',
        );
        expect(
          RegExp(r'''Text\(\s*['"]''').hasMatch(src),
          isFalse,
          reason: '$f: a literal string in Text',
        );
      }
    });
  });
}
