import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _card({
  TextDirection direction = TextDirection.ltr,
  String title = 'Tuesday 5-a-side',
  String time = '7:30 PM',
  VoidCallback? onTap,
  VoidCallback? onJoin,
}) => host(
  DabblerCardGame(
    title: title,
    verified: true,
    tags: const <Widget>[DabblerChip(label: 'Football')],
    dayLabel: 'Today',
    timeLabel: time,
    meta: const <String>['Dubai Sports City', '2.1 km'],
    progress: const DabblerCardEventPlayers(
      label: '9 of 10 players in',
      joined: 9,
      capacity: 10,
    ),
    price: const DabblerCardEventPrice(price: 'AED 40', note: 'per player'),
    action: DabblerCardEventListing.joinButton(
      label: 'Join game',
      onPressed: onJoin,
    ),
    onTap: onTap,
  ),
  direction: direction,
  width: 360,
);

void main() {
  testWidgets('draws every slot', (tester) async {
    await tester.pumpWidget(_card());
    for (final String t in <String>[
      'Tuesday 5-a-side',
      'Football',
      'Today',
      '7:30 PM',
      'Dubai Sports City',
      '2.1 km',
      '9 of 10 players in',
      'AED 40',
      'Join game',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('join and card taps are separate', (tester) async {
    int open = 0;
    int join = 0;
    await tester.pumpWidget(_card(onTap: () => open++, onJoin: () => join++));
    await tester.tap(find.text('Join game'));
    expect(join, 1);
    expect(open, 0);
    await tester.tap(find.text('Tuesday 5-a-side'));
    expect(open, 1);
  });

  testWidgets('RTL Arabic: time sits left of the title block', (tester) async {
    await tester.pumpWidget(
      _card(
        direction: TextDirection.rtl,
        title: 'دوري البادل الزوجي',
        time: '9:00 م',
      ),
    );
    final double title = tester.getCenter(find.text('دوري البادل الزوجي')).dx;
    final double time = tester.getCenter(find.text('9:00 م')).dx;
    expect(time, lessThan(title));
  });

  testWidgets('title-only card has no rows', (tester) async {
    await tester.pumpWidget(
      host(const DabblerCardGame(title: 'Solo'), width: 360),
    );
    expect(find.text('Solo'), findsOneWidget);
    expect(find.text('Join game'), findsNothing);
  });
}
