// KAN-622: the sport pill is a button only when `onSportTap` is set; the rest
// of the row / post never fires it, and with no callback nothing is tappable.
import 'package:dabbler_design_system/src/feed/open_post.dart';
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

DabblerPostRow _row({VoidCallback? onSportTap, VoidCallback? onAuthorTap}) =>
    DabblerPostRow(
      name: 'Suraj Mehta',
      time: '2h',
      place: 'Dubai',
      segments: const <DabblerPostSegment>[
        DabblerPostSegment('Anyone playing?'),
      ],
      sportLabel: 'Football',
      onSportTap: onSportTap,
      onAuthorTap: onAuthorTap,
    );

DabblerOpenPost _open({VoidCallback? onSportTap}) => DabblerOpenPost(
  name: 'Moataz',
  roleLabel: 'Player',
  badgeLabel: 'Dab',
  handle: '@moataz',
  followLabel: 'Follow',
  segments: const <DabblerPostSegment>[DabblerPostSegment('Football')],
  sportLabel: 'Football',
  onSportTap: onSportTap,
  placeLabel: 'Al Quoz',
  timeLabel: '8:00 PM',
  dateLabel: 'Aug 16',
  viewsLabel: '1,204 views',
  audienceLabel: 'EN',
  likes: 0,
  onShare: () {},
);

void main() {
  group('sport pill tap (KAN-622)', () {
    testWidgets('post row: tapping the pill fires onSportTap only', (
      tester,
    ) async {
      int sport = 0;
      int author = 0;
      await tester.pumpWidget(
        threadHost(
          _row(onSportTap: () => sport++, onAuthorTap: () => author++),
        ),
      );
      await tester.tap(find.text('Football'));
      expect(sport, 1);
      expect(author, 0);
      await tester.tap(find.text('Suraj Mehta'));
      expect(sport, 1);
      expect(author, 1);
    });

    testWidgets('post row: pill is a button for a11y only when set', (
      tester,
    ) async {
      await tester.pumpWidget(threadHost(_row(onSportTap: () {})));
      expect(
        find.ancestor(
          of: find.text('Football'),
          matching: find.byWidgetPredicate(
            (Widget w) => w is Semantics && w.properties.button == true,
          ),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(threadHost(_row()));
      expect(
        find.ancestor(
          of: find.text('Football'),
          matching: find.byWidgetPredicate(
            (Widget w) => w is Semantics && w.properties.button == true,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('post row: without onSportTap the pill takes no taps', (
      tester,
    ) async {
      await tester.pumpWidget(threadHost(_row()));
      expect(
        find.ancestor(
          of: find.text('Football'),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('open post: tapping the pill fires onSportTap', (tester) async {
      int sport = 0;
      await tester.pumpWidget(threadHost(_open(onSportTap: () => sport++)));
      await tester.tap(find.text('Football').last);
      expect(sport, 1);
    });

    testWidgets('open post: without onSportTap the pill is not a button', (
      tester,
    ) async {
      await tester.pumpWidget(threadHost(_open()));
      expect(
        find.ancestor(
          of: find.text('Football').last,
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });
  });
}
