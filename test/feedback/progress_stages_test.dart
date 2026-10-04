import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Finder _icon(String name) =>
    find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == name);

Widget _stages(List<DabblerProgressStage> stages) =>
    DabblerProgressStages(stages: stages);

const List<DabblerProgressStage> _mixed = <DabblerProgressStage>[
  DabblerProgressStage(label: 'One', status: DabblerStageStatus.done),
  DabblerProgressStage(label: 'Two', status: DabblerStageStatus.active),
  DabblerProgressStage(label: 'Three'),
];

void main() {
  group('DabblerProgressStages', () {
    testWidgets('done ticks, running spins, pending is a faded dot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_stages(_mixed)));
      final DabblerColors colors = testColors();
      expect(
        tester.widget<DabblerIcon>(_icon('tick-circle')).color,
        colors.success.strong,
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(find.byType(DabblerSurface), findsOneWidget);
      final List<AnimatedOpacity> fades = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .toList();
      expect(fades.map((AnimatedOpacity o) => o.opacity), <double>[
        1,
        1,
        DabblerProgressStages.pendingOpacity,
      ]);
    });

    testWidgets('the running label is semibold, the done one regular', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_stages(_mixed)));
      expect(
        tester.widget<Text>(find.text('Two')).style?.fontWeight,
        DabblerType.semibold,
      );
      expect(
        tester.widget<Text>(find.text('One')).style?.fontWeight,
        DabblerType.regular,
      );
      expect(
        tester.widget<Text>(find.text('Three')).style?.color,
        testColors().textTertiary,
      );
    });

    testWidgets('a failed stage shows the danger glyph in the error colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          _stages(const <DabblerProgressStage>[
            DabblerProgressStage(
              label: 'Broke',
              status: DabblerStageStatus.failed,
            ),
          ]),
        ),
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(_icon('danger'));
      expect(icon.color, testColors().error.strong);
      expect(icon.weight, DabblerIconWeight.bold);
    });

    testWidgets('semantics: one labelled node per stage', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(_stages(_mixed)));
      expect(find.bySemanticsLabel('Two'), findsOneWidget);
      handle.dispose();
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('glyph at the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            _stages(const <DabblerProgressStage>[
              DabblerProgressStage(
                label: 'إنشاء ملفك الشخصي',
                status: DabblerStageStatus.done,
              ),
            ]),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        final double glyph = tester.getCenter(_icon('tick-circle')).dx;
        final double label = tester
            .getCenter(find.text('إنشاء ملفك الشخصي'))
            .dx;
        expect(
          dir == TextDirection.ltr ? glyph < label : glyph > label,
          isTrue,
        );
      });
    }
  });
}
