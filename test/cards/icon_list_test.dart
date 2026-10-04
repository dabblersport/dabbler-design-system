import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Finder _ticks() => find.byWidgetPredicate(
  (Widget w) => w is DabblerIcon && w.name == 'tick-circle',
);

void main() {
  group('DabblerIconList', () {
    testWidgets('one glyph per line, in the brand colour, bold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerIconList(items: <String>['One', 'Two', 'Three'])),
      );
      expect(_ticks(), findsNWidgets(3));
      final DabblerIcon icon = tester.widget<DabblerIcon>(_ticks().first);
      expect(icon.color, testColors().brandPrimary);
      expect(icon.weight, DabblerIconWeight.bold);
      expect(icon.size, DabblerSizing.iconSm);
    });

    testWidgets('the title is drawn uppercase above the lines', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerIconList(title: 'Don’t forget', items: <String>['One']),
        ),
      );
      expect(find.text('DON’T FORGET'), findsOneWidget);
      expect(
        tester.getCenter(find.text('DON’T FORGET')).dy,
        lessThan(tester.getCenter(find.text('One')).dy),
      );
    });

    testWidgets('a custom glyph replaces the tick', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerIconList(icon: 'verify', items: <String>['One'])),
      );
      expect(_ticks(), findsNothing);
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name == 'verify',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a long line wraps and the glyph stays on the first line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerIconList(items: <String>['word ' * 40]), width: 200),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(_ticks()).dy,
        lessThan(tester.getCenter(find.byType(Text)).dy),
      );
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('glyph at the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerIconList(
              title: 'لا تنسَ',
              items: <String>['أكّد فقط عندما تعرف أنك تستطيع اللعب.'],
            ),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        final double glyph = tester.getCenter(_ticks()).dx;
        final double line = tester
            .getCenter(find.text('أكّد فقط عندما تعرف أنك تستطيع اللعب.'))
            .dx;
        expect(dir == TextDirection.ltr ? glyph < line : glyph > line, isTrue);
      });
    }
  });
}
