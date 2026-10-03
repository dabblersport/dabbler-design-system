import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  group('DabblerHeroIcon', () {
    testWidgets('is a 72 circle with a 30 bold glyph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const Center(child: DabblerHeroIcon('cup'))),
      );
      expect(tester.getSize(find.byType(DabblerSurface)), const Size(72, 72));
      final DabblerSurface s = tester.widget(find.byType(DabblerSurface));
      expect(s.radius, DabblerRadius.pill);
      final DabblerIcon i = tester.widget(find.byType(DabblerIcon));
      expect(i.size, DabblerSizing.iconLg);
      expect(i.weight, DabblerIconWeight.bold);
    });

    testWidgets('tones resolve from existing tokens', (
      WidgetTester tester,
    ) async {
      final DabblerColors c = testColors();
      expect(
        DabblerHeroIcon.fillFor(c, DabblerHeroIconTone.brand),
        DabblerSurface.tintedFillOf(c, c.brandPrimary),
      );
      expect(
        DabblerHeroIcon.inkFor(c, DabblerHeroIconTone.brand),
        c.brandPrimary,
      );
      for (final (DabblerHeroIconTone t, DabblerStatusTone s)
          in <(DabblerHeroIconTone, DabblerStatusTone)>[
            (DabblerHeroIconTone.success, DabblerStatusTone.success),
            (DabblerHeroIconTone.warning, DabblerStatusTone.warning),
            (DabblerHeroIconTone.error, DabblerStatusTone.error),
            (DabblerHeroIconTone.info, DabblerStatusTone.info),
          ]) {
        expect(DabblerHeroIcon.fillFor(c, t), c.status(s).surface);
        expect(DabblerHeroIcon.inkFor(c, t), c.status(s).strong);
      }
      expect(
        DabblerHeroIcon.fillFor(c, DabblerHeroIconTone.neutral),
        c.surfaceSunken,
      );

      await tester.pumpWidget(
        host(
          const DabblerHeroIcon(
            'tick-circle',
            tone: DabblerHeroIconTone.success,
          ),
        ),
      );
      final DabblerIcon i = tester.widget(find.byType(DabblerIcon));
      expect(i.color, c.status(DabblerStatusTone.success).strong);
    });

    testWidgets('decorative by default, an image when labelled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerHeroIcon('cup')));
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      await tester.pumpWidget(
        host(const DabblerHeroIcon('cup', semanticLabel: 'Done')),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Done')),
        isSemantics(isImage: true),
      );
      handle.dispose();
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('centres its glyph ($dir)', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const Center(child: DabblerHeroIcon('cup')), direction: dir),
        );
        expect(
          tester.getCenter(find.byType(DabblerIcon)),
          tester.getCenter(find.byType(DabblerSurface)),
        );
      });
    }
  });
}
