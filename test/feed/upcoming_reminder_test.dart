import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

const List<DabblerUpcomingItem> _items = <DabblerUpcomingItem>[
  DabblerUpcomingItem(
    month: 'OCT',
    day: '4',
    title: 'Tuesday 5-a-side',
    detail: 'Dubai Sports City · 7:30 PM',
    ringFraction: 0.9,
    ringBig: '2',
    ringSmall: 'hours',
    short: 'in 2h',
  ),
  DabblerUpcomingItem(
    month: 'OCT',
    day: '6',
    title: 'Padel doubles',
    detail: 'Meydan · 8 PM',
    ringFraction: 0.5,
    ringBig: '2',
    ringSmall: 'days',
    short: 'in 2d',
  ),
  DabblerUpcomingItem(
    month: 'OCT',
    day: '8',
    title: 'Net practice',
    detail: 'Al Maryah · 6 PM',
    ringFraction: 0.2,
    ringBig: '4',
    ringSmall: 'days',
    short: 'in 4d',
  ),
  DabblerUpcomingItem(
    month: 'OCT',
    day: '9',
    title: 'Fourth',
    detail: 'X · 6 PM',
    ringFraction: 0.1,
    ringBig: '5',
    ringSmall: 'days',
    short: 'in 5d',
  ),
];

Widget _reminder({
  List<DabblerUpcomingItem> items = _items,
  bool collapsed = false,
  bool expanded = false,
  VoidCallback? onDismiss,
  VoidCallback? onExpandStrip,
  VoidCallback? onToggle,
}) => DabblerUpcomingReminder(
  items: items,
  title: 'Upcoming · ${items.length}',
  collapsed: collapsed,
  expanded: expanded,
  onDismiss: onDismiss ?? () {},
  onExpandStrip: onExpandStrip ?? () {},
  onToggleExpanded: onToggle ?? () {},
  stripLabel: '${items.length} upcoming',
  moreLabel: '3 more this week',
  showLessLabel: 'Show less',
  dismissLabel: 'Hide',
  seeAllLabel: 'See all',
);

void main() {
  group('DabblerUpcomingReminder', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('stack: first game, ring and more toggle (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(threadHost(_reminder(), direction: d));
        expect(tester.takeException(), isNull);
        expect(find.text('Upcoming · 4'), findsOneWidget);
        expect(find.text('Tuesday 5-a-side'), findsOneWidget);
        expect(find.text('Padel doubles'), findsNothing);
        expect(find.text('3 more this week'), findsOneWidget);
        expect(find.byType(DabblerRing), findsOneWidget);
        final Rect card = tester.getRect(find.byType(DabblerRing));
        final Rect tile = tester.getRect(find.text('OCT'));
        if (d == TextDirection.ltr) {
          expect(tile.left, lessThan(card.left));
        } else {
          expect(tile.left, greaterThan(card.left));
        }
      });
    }

    testWidgets('open list shows the rest, See all above three, Show less', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(threadHost(_reminder(expanded: true)));
      expect(find.text('Padel doubles'), findsOneWidget);
      expect(find.text('Fourth'), findsOneWidget);
      expect(find.text('in 2d'), findsOneWidget);
      expect(find.text('See all'), findsNWidgets(2));
      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('one game is a lone card; callbacks fire', (
      WidgetTester tester,
    ) async {
      int dismissed = 0;
      int toggled = 0;
      await tester.pumpWidget(
        threadHost(
          _reminder(items: _items.sublist(0, 1), onDismiss: () => dismissed++),
        ),
      );
      expect(find.text('Upcoming · 1'), findsOneWidget);
      expect(find.textContaining('more this week'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Hide'));
      expect(dismissed, 1);
      await tester.pumpWidget(threadHost(_reminder(onToggle: () => toggled++)));
      await tester.tap(find.text('3 more this week'));
      expect(toggled, 1);
    });

    testWidgets('collapsed draws the strip and expands on tap', (
      WidgetTester tester,
    ) async {
      int opened = 0;
      await tester.pumpWidget(
        threadHost(_reminder(collapsed: true, onExpandStrip: () => opened++)),
      );
      expect(find.text('4 upcoming'), findsOneWidget);
      expect(find.byType(DabblerRing), findsNothing);
      await tester.tap(find.text('4 upcoming'));
      expect(opened, 1);
    });

    testWidgets('empty draws nothing', (WidgetTester tester) async {
      await tester.pumpWidget(
        threadHost(_reminder(items: const <DabblerUpcomingItem>[])),
      );
      expect(find.byType(DabblerSurface), findsNothing);
    });
  });
}
