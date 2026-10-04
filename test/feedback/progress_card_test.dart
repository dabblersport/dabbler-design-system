import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

DabblerSurface _surface(WidgetTester tester) =>
    tester.widget<DabblerSurface>(find.byType(DabblerSurface));

void main() {
  group('DabblerProgressCard', () {
    testWidgets('active is the brand tint, settled is grey', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerProgressCard(
            label: 'Week 1',
            caption: '3/7 days',
            value: 3 / 7,
            active: true,
          ),
        ),
      );
      expect(_surface(tester).variant, DabblerSurfaceVariant.brandTint);
      await tester.pumpWidget(
        host(
          const DabblerProgressCard(
            label: 'Week 1',
            caption: '7/7 days',
            value: 1,
          ),
        ),
      );
      expect(_surface(tester).variant, DabblerSurfaceVariant.grey);
    });

    testWidgets('completed adds the bold brand tick', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerProgressCard(
            label: 'Week 1',
            caption: '7/7 days',
            value: 1,
            completed: true,
          ),
        ),
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.byType(DabblerIcon),
      );
      expect(icon.name, 'tick-circle');
      expect(icon.weight, DabblerIconWeight.bold);
      expect(icon.color, testColors().brandPrimary);
    });

    testWidgets('the bar carries the value', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerProgressCard(
            label: 'Week 1',
            caption: '3/7 days',
            value: 0.5,
          ),
        ),
      );
      expect(
        tester
            .widget<DabblerProgressBar>(find.byType(DabblerProgressBar))
            .value,
        0.5,
      );
    });

    testWidgets('badge at the inline start, count at the end, in RTL Arabic', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerProgressCard(
            label: 'الأسبوع ١',
            caption: '٣/٧ أيام',
            value: 3 / 7,
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getTopRight(find.byType(DabblerBadge)).dx,
        greaterThan(tester.getTopRight(find.textContaining('3/7')).dx),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
