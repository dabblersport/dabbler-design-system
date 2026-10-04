import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feed/thread_host.dart';

void main() {
  group('DabblerActionRow', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('label, note and glyph; glyph leads (${d.name})', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await tester.pumpWidget(
          threadHost(
            DabblerActionRow(
              icon: 'eye-slash',
              label: 'Hide post',
              note: 'Fewer posts like this',
              onTap: () => taps++,
            ),
            direction: d,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Hide post'), findsOneWidget);
        expect(find.text('Fewer posts like this'), findsOneWidget);
        final Rect icon = tester.getRect(find.byType(DabblerIcon));
        final Rect label = tester.getRect(find.text('Hide post'));
        if (d == TextDirection.ltr) {
          expect(icon.right, lessThanOrEqualTo(label.left));
        } else {
          expect(icon.left, greaterThanOrEqualTo(label.right));
        }
        await tester.tap(find.text('Hide post'));
        expect(taps, 1);
      });
    }

    testWidgets('no note draws one line; destructive uses the error ink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        threadHost(
          const DabblerActionRow(
            icon: 'danger',
            label: 'Report',
            destructive: true,
          ),
        ),
      );
      final Text label = tester.widget<Text>(find.text('Report'));
      expect(label.style!.color, threadColors.error.strong);
    });
  });
}
