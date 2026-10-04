import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  group('DabblerKeyValueRow', () {
    testWidgets('the label takes at most half the row, the value the rest', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerKeyValueRow(label: 'Active Enforcements', value: '4'),
          width: 290,
        ),
      );
      expect(
        tester.getSize(find.text('Active Enforcements')).width,
        lessThanOrEqualTo(145),
      );
      // A one-character value is not squeezed.
      expect(tester.getSize(find.text('4')).height, lessThan(24));
    });

    testWidgets('label at the inline start, value at the inline end (LTR)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerKeyValueRow(label: 'Status', value: 'Paid')),
      );
      final double labelX = tester.getTopLeft(find.text('Status')).dx;
      final double valueX = tester.getTopRight(find.text('Paid')).dx;
      expect(labelX, lessThan(valueX));
      expect(
        valueX,
        closeTo(tester.getTopRight(find.byType(DabblerKeyValueRow)).dx, 24),
      );
      expect(
        tester.widget<Text>(find.text('Paid')).style!.fontWeight,
        DabblerType.semibold,
      );
    });

    testWidgets('swaps sides in RTL with Arabic text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerKeyValueRow(label: 'الحالة', value: 'مدفوع'),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getTopRight(find.text('الحالة')).dx,
        greaterThan(tester.getTopLeft(find.text('مدفوع')).dx),
      );
      expect(
        tester.getTopLeft(find.text('مدفوع')).dx,
        closeTo(tester.getTopLeft(find.byType(DabblerKeyValueRow)).dx, 24),
      );
    });

    testWidgets('a long value wraps instead of ellipsising', (
      WidgetTester tester,
    ) async {
      const String long =
          'Plot 12, Marina Walk, Dubai Marina, United Arab Emirates, near the tram';
      await tester.pumpWidget(
        host(const DabblerKeyValueRow(label: 'Address', value: long)),
      );
      final Text t = tester.widget<Text>(find.text(long));
      expect(t.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.getSize(find.text(long)).height, greaterThan(40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacked puts the value under the label, full width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerKeyValueRow(
            label: 'Description',
            value: 'Four covered courts.',
            layout: DabblerKeyValueLayout.stacked,
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Four covered courts.')).dy,
        greaterThan(tester.getBottomLeft(find.text('Description')).dy - 1),
      );
      expect(
        tester.getTopLeft(find.text('Four covered courts.')).dx,
        tester.getTopLeft(find.text('Description')).dx,
      );
    });

    testWidgets('a trailing widget replaces the value text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerKeyValueRow(
            label: 'Status',
            trailing: DabblerBadge(label: 'PAID'),
          ),
        ),
      );
      expect(find.byType(DabblerBadge), findsOneWidget);
    });
  });
}
