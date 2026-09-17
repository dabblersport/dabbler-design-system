import 'package:dabbler_design_system/src/forms/slider.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// Each thumb's hit area — the [FocusableActionDetector] inside its positioned
/// slot. Measured, not assumed: this is what AC2 is about.
Finder _thumbHits() => find.descendant(
      of: find.byType(DabblerSlider),
      matching: find.byType(FocusableActionDetector),
    );

/// The brand-filled bar, distinguished from the tertiary track by its colour.
Rect _fillRect(WidgetTester tester, DabblerColors colors) {
  final Finder fill = find.byWidgetPredicate(
    (Widget w) =>
        w is DecoratedBox &&
        (w.decoration as BoxDecoration).color == colors.brandPrimary,
  );
  return tester.getRect(fill.first);
}

Rect _trackRowRect(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(DabblerSlider),
            matching: find.byType(GestureDetector),
          )
          .first,
    );

void main() {
  group('Slider anatomy is the design source', () {
    testWidgets('6px track, 24px thumb, 45px row, no shadow', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = testColors();
      await tester.pumpWidget(
        host(const DabblerSlider(value: 50, label: 'distance')),
      );

      expect(_trackRowRect(tester).height, DabblerSizing.touchTargetMin);
      expect(DabblerSlider.trackHeight, DabblerSpacing.space2);
      expect(_fillRect(tester, colors).height, DabblerSlider.trackHeight);

      final Container thumb = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DabblerSlider),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = thumb.decoration! as BoxDecoration;
      expect(decoration.color, colors.surfaceCard);
      expect(decoration.border!.top.color, colors.borderStrong);
      expect(decoration.border!.top.width, DabblerSizing.borderDefault);
      expect(
        decoration.boxShadow,
        isNull,
        reason: 'the flat system: no lift, no shadow',
      );
      expect(DabblerSlider.thumbSize, DabblerSizing.iconMd);
    });

    testWidgets('AC2 — the thumb target is at least 44×44, measured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerSlider(value: 50, onChanged: (_) {})),
      );

      final Size hit = tester.getSize(_thumbHits().first);
      expect(hit.width, greaterThanOrEqualTo(44));
      expect(hit.height, greaterThanOrEqualTo(44));
      expect(hit, const Size(45, 45));
    });

    testWidgets('marks are tick positions in value space and are decorative', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = testColors();
      await tester.pumpWidget(
        host(
          const DabblerSlider(
            value: 50,
            max: 200,
            marks: <double>[0, 50, 100, 150, 200],
          ),
        ),
      );

      final Iterable<Element> ticks = find
          .byWidgetPredicate(
            (Widget w) => w is ColoredBox && w.color == colors.borderDefault,
          )
          .evaluate();
      expect(ticks.length, 5);
      expect(
        tester.getSize(find.byWidgetPredicate(
          (Widget w) => w is ColoredBox && w.color == colors.borderDefault,
        ).first),
        const Size(1, 12),
      );
    });
  });

  group('Slider value and readout', () {
    testWidgets('the readout is the formatted value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerSlider(
            value: 8,
            max: 25,
            label: 'distance',
            formatValue: (num v) => '$v km',
          ),
        ),
      );

      expect(find.text('distance'), findsOneWidget);
      expect(find.text('8 km'), findsOneWidget);
    });

    testWidgets('a range reads as low – high', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          DabblerSlider.range(
            values: const DabblerSliderRange(20, 60),
            max: 200,
            label: 'price',
            formatValue: (num v) => 'AED $v',
          ),
        ),
      );

      expect(find.text('AED 20 – AED 60'), findsOneWidget);
    });

    testWidgets('values snap to step and clamp to the bounds', (
      WidgetTester tester,
    ) async {
      expect(
        DabblerSlider.snap(23, min: 0, max: 200, step: 5),
        25,
        reason: 'Math.round(v / step) * step',
      );
      expect(DabblerSlider.snap(-4, min: 0, max: 200, step: 5), 0);
      expect(DabblerSlider.snap(999, min: 0, max: 200, step: 5), 200);
      expect(
        DabblerSlider.fractionOf(5, min: 5, max: 5),
        0,
        reason: 'a zero-width axis must not produce NaN',
      );
    });
  });

  group('Slider pointer', () {
    testWidgets('a tap on the track jumps to that value', (
      WidgetTester tester,
    ) async {
      double value = 0;
      await tester.pumpWidget(
        host(
          DabblerSlider(value: value, onChanged: (double v) => value = v),
        ),
      );

      final Rect row = _trackRowRect(tester);
      await tester.tapAt(Offset(row.left + row.width / 2, row.center.dy));
      await tester.pump();
      expect(value, closeTo(50, 1));
    });

    testWidgets('a drag moves the value continuously', (
      WidgetTester tester,
    ) async {
      double value = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                DabblerSlider(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        ),
      );

      final Rect row = _trackRowRect(tester);
      final TestGesture gesture =
          await tester.startGesture(Offset(row.left, row.center.dy));
      await gesture.moveTo(Offset(row.left + row.width * 0.75, row.center.dy));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(value, closeTo(75, 1));
    });

    testWidgets('in range mode the nearer thumb moves', (
      WidgetTester tester,
    ) async {
      DabblerSliderRange values = const DabblerSliderRange(20, 60);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                DabblerSlider.range(
              values: values,
              onChanged: (DabblerSliderRange v) => setState(() => values = v),
            ),
          ),
        ),
      );

      final Rect row = _trackRowRect(tester);
      // 90% of the axis is nearer the high thumb.
      await tester.tapAt(Offset(row.left + row.width * 0.9, row.center.dy));
      await tester.pump();
      expect(values.low, 20);
      expect(values.high, closeTo(90, 1));

      // 10% is nearer the low one.
      await tester.tapAt(Offset(row.left + row.width * 0.1, row.center.dy));
      await tester.pump();
      expect(values.low, closeTo(10, 1));
      expect(values.high, closeTo(90, 1));
    });

    testWidgets('disabled takes no pointer and is 45% opaque', (
      WidgetTester tester,
    ) async {
      double value = 10;
      await tester.pumpWidget(
        host(
          DabblerSlider(
            value: value,
            disabled: true,
            onChanged: (double v) => value = v,
          ),
        ),
      );

      final Rect row = _trackRowRect(tester);
      await tester.tapAt(Offset(row.center.dx, row.center.dy));
      await tester.pump();
      expect(value, 10);
      expect(
        tester
            .widget<Opacity>(
              find
                  .descendant(
                    of: find.byType(DabblerSlider),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        DabblerSlider.disabledOpacity,
      );
    });
  });

  group('Slider keyboard', () {
    testWidgets('arrows, Page keys, Home and End', (WidgetTester tester) async {
      double value = 50;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                DabblerSlider(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DabblerFocusRing>(find.byType(DabblerFocusRing).first)
            .visible,
        isTrue,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 51);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 50);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(value, 60, reason: '±10 steps');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 100);
    });
  });

  group('Slider is RTL-correct — the axis inverts', () {
    testWidgets('the fill grows from the inline start in both directions', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = testColors();

      await tester.pumpWidget(host(const DabblerSlider(value: 25)));
      Rect row = _trackRowRect(tester);
      Rect fill = _fillRect(tester, colors);
      expect(fill.left, row.left, reason: 'ltr: the fill starts on the left');
      expect(fill.width, closeTo(row.width * 0.25, 0.5));

      await tester.pumpWidget(
        host(const DabblerSlider(value: 25), direction: TextDirection.rtl),
      );
      row = _trackRowRect(tester);
      fill = _fillRect(tester, colors);
      expect(
        fill.right,
        row.right,
        reason: 'rtl: the minimum is on the right, so the fill starts there',
      );
      expect(fill.width, closeTo(row.width * 0.25, 0.5));
    });

    testWidgets('pointer maths inverts with the axis', (
      WidgetTester tester,
    ) async {
      double value = 0;
      await tester.pumpWidget(
        host(
          DabblerSlider(value: value, onChanged: (double v) => value = v),
          direction: TextDirection.rtl,
        ),
      );

      final Rect row = _trackRowRect(tester);
      await tester.tapAt(Offset(row.left + row.width * 0.25, row.center.dy));
      await tester.pump();
      expect(
        value,
        closeTo(75, 1),
        reason: 'a quarter from the physical left is three quarters along',
      );
    });

    testWidgets('the arrow keys swap so increase always grows the fill', (
      WidgetTester tester,
    ) async {
      double value = 50;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                DabblerSlider(
              value: value,
              onChanged: (double v) => setState(() => value = v),
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(value, 51, reason: 'left points the way the fill grows in rtl');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 50);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, 51, reason: 'up is not directional and never inverts');
    });
  });

  group('Slider semantics', () {
    testWidgets('each thumb is a slider node with its formatted value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerSlider(
            value: 8,
            max: 25,
            label: 'distance',
            formatValue: (num v) => '$v km',
            onChanged: (_) {},
          ),
        ),
      );

      final SemanticsNode node =
          tester.getSemantics(_thumbHits().first.first);
      expect(node.value, '8 km');
      expect(node.label, 'distance');
      expect(node.increasedValue, '9 km');
      expect(node.decreasedValue, '7 km');
      handle.dispose();
    });

    testWidgets('range thumbs are named and bound each other', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerSlider.range(
            values: const DabblerSliderRange(20, 60),
            max: 200,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Minimum'), findsOneWidget);
      expect(find.bySemanticsLabel('Maximum'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Minimum')).increasedValue,
        '21',
      );
      handle.dispose();
    });
  });
}
