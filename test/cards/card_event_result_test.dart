import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('event result: tile, kind, action (${dir.name})', (t) async {
      int taps = 0;
      await t.pumpWidget(host(
        DabblerCardEventResult(
          month: 'Aug', day: '18', kind: 'Game', kindIcon: 'game',
          time: 'Today', title: 'Dabbler Night', query: 'dabbler',
          place: 'Marina', meta: '0/10 spots', actionLabel: 'Join',
          onAction: () => taps++,
        ),
        direction: dir,
      ));
      expect(find.text('AUG'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      final double tileX = t.getCenter(find.text('18')).dx;
      final double btnX = t.getCenter(find.text('Join')).dx;
      expect(dir == TextDirection.ltr ? tileX < btnX : tileX > btnX, isTrue);
      await t.tap(find.text('Join'));
      expect(taps, 1);
    });
  }
  testWidgets('no action label draws no button', (t) async {
    await t.pumpWidget(host(const DabblerCardEventResult(
        month: 'Aug', day: '2', kind: 'Meet-up', time: 'x', title: 'y')));
    expect(find.byType(DabblerButton), findsNothing);
  });
}
