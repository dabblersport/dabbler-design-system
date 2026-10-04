import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  for (final TextDirection d in TextDirection.values) {
    final bool rtl = d == TextDirection.rtl;
    final String title = rtl ? 'مارينا دبي' : 'Dubai Marina';
    group('DabblerListRow flat/brand $d', () {
      testWidgets('flat drops the inline padding and adds a hairline', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(
            DabblerListRow(title: title, subtitle: 'sub'),
            direction: d,
          ),
        );
        final Rect padded = t.getRect(find.text(title));
        await t.pumpWidget(
          host(
            DabblerListRow(title: title, subtitle: 'sub', flat: true),
            direction: d,
          ),
        );
        expect(find.byType(DabblerDivider), findsOneWidget);
        final Rect flat = t.getRect(find.text(title));
        if (rtl) {
          expect(flat.right, greaterThan(padded.right));
        } else {
          expect(flat.left, lessThan(padded.left));
        }
      });

      testWidgets('brand paints the title in the brand colour', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          host(DabblerListRow(title: title, brand: true), direction: d),
        );
        final Text text = t.widget<Text>(find.text(title));
        expect(text.style!.color, testColors().brandPrimary);
        expect(find.byType(DabblerDivider), findsNothing);
      });
    });
  }
}
