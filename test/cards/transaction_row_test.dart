import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

DabblerTransactionRow _row({VoidCallback? onTap, bool arabic = false}) =>
    DabblerTransactionRow(
      leading: const DabblerIconTile.named('calendar'),
      title: arabic ? 'حجز ملعب' : 'Court Booking',
      badge: DabblerBadge(label: arabic ? 'مكتمل' : 'COMPLETED'),
      detail: arabic ? 'مدينة زايد' : 'Zayed Sports City',
      detailIcon: 'building',
      caption: 'Visa •••• 4242',
      amount: arabic ? '-٢٠٠ د.إ' : '-AED 200',
      amountCaption: arabic ? 'منذ ساعة' : '1h ago',
      onTap: onTap,
    );

void main() {
  group('DabblerTransactionRow', () {
    testWidgets('draws every slot and the amount at the inline end (LTR)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_row(), width: 393));
      for (final String s in <String>[
        'Court Booking',
        'COMPLETED',
        'Zayed Sports City',
        'Visa •••• 4242',
        '-AED 200',
        '1h ago',
      ]) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(
        tester.getTopLeft(find.byType(DabblerIconTile)).dx,
        lessThan(tester.getTopLeft(find.text('-AED 200')).dx),
      );
      expect(
        tester.widget<Text>(find.text('-AED 200')).style!.fontWeight,
        DabblerType.headline.fontWeight,
      );
    });

    testWidgets('mirrors in RTL with Arabic text', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(_row(arabic: true), direction: TextDirection.rtl, width: 393),
      );
      expect(
        tester.getTopRight(find.byType(DabblerIconTile)).dx,
        greaterThan(tester.getTopRight(find.textContaining('200')).dx),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('success tone colours the amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerTransactionRow(
            title: 'Refund',
            amount: '+AED 100',
            amountTone: DabblerTextTone.success,
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('+AED 100')).style!.color,
        testColors().success.strong,
      );
    });

    testWidgets('a tap fires onTap', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(host(_row(onTap: () => taps++), width: 393));
      await tester.tap(find.text('Court Booking'));
      expect(taps, 1);
    });

    testWidgets('a long title ellipsises on one line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTransactionRow(
            title:
                'A very long transaction title that cannot possibly fit on one line',
            amount: '-AED 1',
            badge: DabblerBadge(label: 'PENDING'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
