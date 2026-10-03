import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

const DabblerPostRow _original = DabblerPostRow(
  name: 'Moataz Mustapha',
  time: '2h',
  place: 'Al Quoz Pond Park',
  body: 'Football night this Sunday.',
  likes: 24,
  replies: 6,
  divider: false,
);

void main() {
  group('DabblerRepostRow', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('header, quote and embedded original (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            const DabblerRepostRow(
              name: 'Karim Hassan',
              repostedLabel: 'Reposted · 1h',
              quote: 'Who is in?',
              original: _original,
            ),
            direction: d,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Karim Hassan'), findsOneWidget);
        expect(find.text('Reposted · 1h'), findsOneWidget);
        expect(find.text('Who is in?'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(DabblerCard),
            matching: find.byType(DabblerPostRow),
          ),
          findsOneWidget,
        );
        // The reposter avatar leads in reading order.
        final Rect row = tester.getRect(find.byType(DabblerRepostRow));
        final Rect avatar = tester.getRect(find.byType(DabblerAvatar).first);
        if (d == TextDirection.ltr) {
          expect(avatar.left, row.left);
        } else {
          expect(avatar.right, row.right);
        }
        final Rect card = tester.getRect(find.byType(DabblerCard));
        expect(card.top, greaterThan(tester.getRect(find.text('Who is in?')).bottom));
      });
    }

    testWidgets('blank quote draws nothing; unavailable note without original', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        threadHost(
          const DabblerRepostRow(
            name: 'Karim',
            repostedLabel: 'Reposted',
            quote: '   ',
            unavailableLabel: 'Unavailable',
          ),
        ),
      );
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.byType(DabblerPostRow), findsNothing);
      expect(find.text('   '), findsNothing);
    });

    testWidgets('author target is one named button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(
        threadHost(
          DabblerRepostRow(
            name: 'Karim',
            authorLabel: 'Open Karim',
            repostedLabel: 'Reposted',
            unavailableLabel: 'Unavailable',
            onAuthorTap: () => taps++,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Open Karim'),
        findsNWidgets(2),
      );
      await tester.tap(find.text('Karim'));
      await tester.tap(find.byType(DabblerAvatar));
      expect(taps, 2);
      h.dispose();
    });

    testWidgets('detail line and actions slot render under the card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        threadHost(
          const DabblerRepostRow(
            name: 'Karim',
            repostedLabel: 'Reposted',
            original: _original,
            detail: DabblerPostDetail(timestamp: '8:00 PM'),
            actions: Text('acts'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      final double cardBottom = tester.getRect(find.byType(DabblerCard)).bottom;
      expect(find.byType(DabblerPostDetailLine), findsOneWidget);
      expect(tester.getRect(find.text('acts')).top, greaterThan(cardBottom));
    });
  });
}
