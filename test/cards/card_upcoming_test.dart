import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _tile({
  TextDirection direction = TextDirection.ltr,
  String title = 'Tuesday 5-a-side',
  VoidCallback? onTap,
}) => host(
  DabblerCardUpcoming(
    title: title,
    fraction: 0.4,
    countdownValue: '3',
    countdownUnit: 'hours',
    when: 'Sep 2 · 7:30 PM',
    place: 'Dubai Sports City',
    distance: '3.1 km',
    onTap: onTap,
  ),
  direction: direction,
  width: 300,
);

void main() {
  testWidgets('draws ring centre, title, date and place', (tester) async {
    await tester.pumpWidget(_tile());
    expect(find.byType(DabblerRing), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('hours'), findsOneWidget);
    expect(find.text('Tuesday 5-a-side'), findsOneWidget);
    expect(find.text('Sep 2 · 7:30 PM'), findsOneWidget);
    expect(find.text('Dubai Sports City · 3.1 km'), findsOneWidget);
  });

  testWidgets('fills with the tile tone', (tester) async {
    await tester.pumpWidget(_tile());
    final DabblerCard card = tester.widget(find.byType(DabblerCard));
    final DabblerColors colors = testColors();
    expect(
      card.fill,
      DabblerCardUpcoming.fillOf(colors, DabblerCardUpcomingTone.amber),
    );
  });

  testWidgets('tap fires', (tester) async {
    int n = 0;
    await tester.pumpWidget(_tile(onTap: () => n++));
    await tester.tap(find.text('Tuesday 5-a-side'));
    expect(n, 1);
  });

  testWidgets('RTL Arabic: the ring leads at the right', (tester) async {
    await tester.pumpWidget(
      _tile(direction: TextDirection.rtl, title: 'دوري البادل الزوجي'),
    );
    final double ring = tester.getCenter(find.byType(DabblerRing)).dx;
    final double title = tester.getCenter(find.text('دوري البادل الزوجي')).dx;
    expect(ring, greaterThan(title));
  });
}
