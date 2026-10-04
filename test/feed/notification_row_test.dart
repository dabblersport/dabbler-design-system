import 'package:dabbler_design_system/src/feed/activity_row.dart';
import 'package:dabbler_design_system/src/feed/notification_row.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: Directionality(
        textDirection: dir,
        child: Scaffold(body: SizedBox(width: 360, child: child)),
      ),
    );

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('renders, taps and acts — $dir', (WidgetTester tester) async {
      int taps = 0;
      int acts = 0;
      await tester.pumpWidget(
        _host(
          DabblerNotificationRow(
            leading: const DabblerActivitySystemTile('wallet'),
            actor: 'Aisha',
            verb: 'requested your share',
            subject: 'AED 45',
            pillLabel: 'Unpaid',
            time: '1h',
            unread: true,
            meta: const <DabblerNotificationMeta>[
              DabblerNotificationMeta('clock', 'Due in 6h', strong: true),
            ],
            actions: <DabblerNotificationAction>[
              DabblerNotificationAction(
                'Pay',
                filled: true,
                onPressed: () => acts++,
              ),
            ],
            onTap: () => taps++,
          ),
          dir: dir,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Unpaid'), findsOneWidget);
      await tester.tap(find.text('Pay'));
      expect(acts, 1);
      await tester.tap(find.text('AED 45'));
      expect(taps, 1);
    });
  }

  testWidgets('read row without optional parts', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        const DabblerNotificationRow(
          leading: DabblerAvatar(seed: 'x', size: DabblerAvatarSize.sm),
          actor: 'Rahul',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
