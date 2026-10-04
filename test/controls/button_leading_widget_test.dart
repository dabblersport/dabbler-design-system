import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  group('DabblerButton.leadingWidget', () {
    testWidgets('sits before the label with the icon gap, in LTR and RTL', (
      WidgetTester tester,
    ) async {
      for (final TextDirection d in TextDirection.values) {
        await tester.pumpWidget(
          host(
            DabblerButton(
              label: d == TextDirection.ltr ? 'Continue' : 'المتابعة',
              leadingWidget: const SizedBox(key: Key('mark'), width: 30, height: 30),
              onPressed: () {},
            ),
            direction: d,
          ),
        );
        final Rect mark = tester.getRect(find.byKey(const Key('mark')));
        final Rect label = tester.getRect(find.byType(Text));
        if (d == TextDirection.ltr) {
          expect(mark.right, lessThan(label.left));
        } else {
          expect(mark.left, greaterThan(label.right));
        }
      }
    });

    testWidgets('loading replaces it and an icon wins over it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerButton(
            label: 'x',
            loading: true,
            leadingWidget: SizedBox(key: Key('mark')),
          ),
        ),
      );
      expect(find.byKey(const Key('mark')), findsNothing);
      await tester.pumpWidget(
        host(
          const DabblerButton(
            label: 'x',
            icon: 'sms',
            leadingWidget: SizedBox(key: Key('mark')),
          ),
        ),
      );
      expect(find.byKey(const Key('mark')), findsNothing);
    });
  });
}
