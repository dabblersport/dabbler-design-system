import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

List<Color?> _fills(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
    .map((AnimatedContainer c) => (c.decoration! as BoxDecoration).color)
    .toList();

void main() {
  group('DabblerStepProgress', () {
    testWidgets('fills completed and current, faint after', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerStepProgress(count: 5, current: 2)),
      );
      final DabblerColors c = testColors();
      expect(_fills(tester), <Color>[
        c.brandPrimary,
        c.brandPrimary,
        c.brandPrimary,
        c.bgTertiary,
        c.bgTertiary,
      ]);
      const DabblerStepProgress p = DabblerStepProgress(count: 5, current: 2);
      expect(p.isCompleted(1), true);
      expect(p.isCurrent(2), true);
      expect(p.isCompleted(2), false);
    });

    testWidgets('label is uppercased and segments share the width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerStepProgress(count: 3, current: 0, label: 'Step 1 of 3'),
        ),
      );
      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      final List<Size> sizes = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((Widget w) => tester.getSize(find.byWidget(w)))
          .toList();
      expect(sizes.map((Size s) => s.width).toSet().length, 1);
      expect(sizes.first.height, DabblerSpacing.space1);
    });

    testWidgets('semantics reads the label and value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const DabblerStepProgress(count: 5, current: 1)),
      );
      expect(
        tester.getSemantics(find.byType(DabblerStepProgress)),
        isSemantics(label: 'Step 2 of 5', value: '2/5'),
      );
      handle.dispose();
    });

    testWidgets('animates normally, snaps under reduced motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerStepProgress(count: 2, current: 0)),
      );
      expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
            .duration,
        DabblerMotion.base,
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(const DabblerStepProgress(count: 2, current: 0)),
        ),
      );
      expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
            .duration,
        Duration.zero,
      );
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('step one is at the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerStepProgress(count: 3, current: 0), direction: dir),
        );
        final double first = tester
            .getCenter(find.byKey(const ValueKey<int>(0)))
            .dx;
        final double last = tester
            .getCenter(find.byKey(const ValueKey<int>(2)))
            .dx;
        expect(dir == TextDirection.ltr ? first < last : first > last, true);
      });
    }
  });
}
