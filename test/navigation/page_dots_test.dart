import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Finder _dot(int i) => find.byKey(ValueKey<int>(i));

void main() {
  group('DabblerPageDots', () {
    testWidgets('active dot is wide and brand, others small and strong', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerPageDots(count: 4, index: 1)));
      expect(tester.getSize(_dot(1)).width, DabblerPageDots.activeWidth);
      expect(tester.getSize(_dot(0)).width, DabblerPageDots.dotSize);
      expect(tester.getSize(_dot(0)).height, DabblerSpacing.space2);
      final AnimatedContainer active = tester.widget(_dot(1));
      final AnimatedContainer idle = tester.widget(_dot(0));
      expect(
        (active.decoration! as BoxDecoration).color,
        testColors().brandPrimary,
      );
      expect(
        (idle.decoration! as BoxDecoration).color,
        testColors().borderStrong,
      );
    });

    testWidgets('static row is one read-only node', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerPageDots(count: 4, index: 1)));
      expect(find.bySemanticsLabel('Page 2 of 4'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 2 of 4')),
        isNot(isSemantics(isButton: true)),
      );
      handle.dispose();
    });

    testWidgets('tappable dots report their index and are buttons', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<int> got = <int>[];
      await tester.pumpWidget(
        host(DabblerPageDots(count: 3, index: 0, onSelected: got.add)),
      );
      await tester.tap(_dot(2));
      expect(got, <int>[2]);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 1 of 3')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 3 of 3')),
        isSemantics(isButton: true, isSelected: false),
      );
      expect(
        tester.getSize(find.bySemanticsLabel('Page 3 of 3')).height,
        DabblerSizing.touchTargetMin,
      );
      handle.dispose();
    });

    testWidgets('custom labels', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerPageDots(
            count: 2,
            index: 0,
            semanticLabelBuilder: (int i, int n) => 'صفحة ${i + 1}',
          ),
        ),
      );
      expect(find.bySemanticsLabel('صفحة 1'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('reduced motion snaps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(const DabblerPageDots(count: 2, index: 0)),
        ),
      );
      expect(tester.widget<AnimatedContainer>(_dot(0)).duration, Duration.zero);
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('page one is at the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerPageDots(count: 3, index: 0), direction: dir),
        );
        final double a = tester.getCenter(_dot(0)).dx;
        final double b = tester.getCenter(_dot(2)).dx;
        expect(dir == TextDirection.ltr ? a < b : a > b, true);
      });
    }
  });
}
