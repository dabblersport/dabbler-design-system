import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

List<Rect> _boxes(WidgetTester tester) => tester
    .widgetList<DabblerSurface>(find.byType(DabblerSurface))
    .map((DabblerSurface s) => tester.getRect(find.byWidget(s)))
    .toList();

void main() {
  group('DabblerCodeInput — fullWidth', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('boxes fill the width, gaps unchanged (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerCodeInput(length: 6, fullWidth: true),
            direction: d,
            width: 330,
          ),
        );
        final List<Rect> boxes = _boxes(tester);
        expect(boxes, hasLength(6));
        final double expected = DabblerCodeInput.fittedBoxWidth(
          330,
          6,
          DabblerCodeInput.defaultMaxBoxWidth,
        );
        expect(expected, greaterThan(DabblerCodeInput.boxWidth));
        for (final Rect b in boxes) {
          expect(b.width, moreOrLessEquals(expected));
          expect(b.height, DabblerCodeInput.boxHeight);
        }
        expect(
          boxes[1].left - boxes[0].right,
          moreOrLessEquals(DabblerCodeInput.boxGap),
        );
        // Digits never mirror: box 0 is leftmost in RTL too.
        expect(boxes.first.left, lessThan(boxes.last.left));
      });
    }

    testWidgets('caps at maxBoxWidth and centres the row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerCodeInput(length: 4, fullWidth: true), width: 600),
      );
      final List<Rect> boxes = _boxes(tester);
      for (final Rect b in boxes) {
        expect(b.width, DabblerCodeInput.defaultMaxBoxWidth);
      }
      final double left = boxes.first.left;
      final double right = 800 - boxes.last.right;
      expect(left, greaterThan(0));
      expect((left - right).abs(), lessThan(1));
    });

    testWidgets('a custom maxBoxWidth is honoured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerCodeInput(
            length: 4,
            fullWidth: true,
            maxBoxWidth: DabblerSizing.touchTargetMin,
          ),
          width: 600,
        ),
      );
      expect(_boxes(tester).first.width, DabblerSizing.touchTargetMin);
    });

    testWidgets('default stays at the fixed 45-wide boxes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerCodeInput(), width: 600));
      expect(_boxes(tester).first.width, DabblerCodeInput.boxWidth);
    });

    testWidgets('typing still advances across widened boxes', (
      WidgetTester tester,
    ) async {
      String? done;
      await tester.pumpWidget(
        host(
          DabblerCodeInput(
            length: 4,
            fullWidth: true,
            onCompleted: (String v) => done = v,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).first, '1234');
      await tester.pump();
      expect(done, '1234');
    });

    testWidgets('keeps the group label', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const DabblerCodeInput(length: 4, fullWidth: true)),
      );
      expect(find.bySemanticsLabel('4-digit code'), findsOneWidget);
      h.dispose();
    });
  });
}
