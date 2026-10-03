import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// A stateful harness so the picked month flows back in.
class _Harness extends StatefulWidget {
  const _Harness({this.minimum, this.maximum, this.onYearPressed});
  final DateTime? minimum;
  final DateTime? maximum;
  final VoidCallback? onYearPressed;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  DateTime month = DateTime(2026, 9);
  @override
  Widget build(BuildContext context) => DabblerCalendar(
    month: month,
    yearPicker: true,
    minimum: widget.minimum,
    maximum: widget.maximum,
    onYearPressed: widget.onYearPressed,
    onMonthChanged: (DateTime m) => setState(() => month = m),
  );
}

DateTime _shown(WidgetTester t) =>
    t.state<_HarnessState>(find.byType(_Harness)).month;

void main() {
  group('DabblerCalendar — built-in year picker', () {
    testWidgets('default: no picker, the chip is inert', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: DateTime(2026, 9), onMonthChanged: (_) {})),
      );
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      expect(find.byType(DabblerCalendarYearGrid), findsNothing);
    });

    for (final TextDirection d in TextDirection.values) {
      testWidgets('opens in place of the days and jumps years (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(), direction: d));
        expect(
          find.byKey(DabblerCalendar.dayKey(DateTime(2026, 9, 15))),
          findsOneWidget,
        );
        await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
        await tester.pump();
        expect(find.byType(DabblerCalendarYearGrid), findsOneWidget);
        expect(
          find.byKey(DabblerCalendar.dayKey(DateTime(2026, 9, 15))),
          findsNothing,
        );

        // Years run with the reading direction.
        final Rect a = tester.getRect(
          find.byKey(DabblerCalendarYearGrid.yearKey(2025)),
        );
        final Rect b = tester.getRect(
          find.byKey(DabblerCalendarYearGrid.yearKey(2026)),
        );
        if (a.top == b.top) {
          expect(
            d == TextDirection.ltr ? a.left < b.left : a.left > b.left,
            isTrue,
          );
        }

        await tester.tap(find.byKey(DabblerCalendarYearGrid.yearKey(2028)));
        await tester.pump();
        expect(_shown(tester), DateTime(2028, 9));
        expect(find.byType(DabblerCalendarYearGrid), findsNothing);
        expect(find.text('2028'), findsOneWidget);
      });
    }

    testWidgets('the selected year is scrolled into view and selected', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(host(const _Harness()));
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      final Finder cell = find.byKey(DabblerCalendarYearGrid.yearKey(2026));
      expect(cell.hitTestable(), findsOneWidget);
      final SemanticsNode node = tester.getSemantics(cell);
      expect(node.flagsCollection.isSelected.toBoolOrNull(), isTrue);
      expect(node.flagsCollection.isButton, isTrue);
      expect(tester.getSize(cell).height, DabblerSizing.touchTargetMin);
      h.dispose();
    });

    testWidgets('bounds limit the list and clamp the month', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          _Harness(
            minimum: DateTime(2024, 11, 3),
            maximum: DateTime(2027, 3, 1),
          ),
        ),
      );
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      expect(find.byKey(DabblerCalendarYearGrid.yearKey(2023)), findsNothing);
      expect(find.byKey(DabblerCalendarYearGrid.yearKey(2028)), findsNothing);
      await tester.tap(find.byKey(DabblerCalendarYearGrid.yearKey(2027)));
      await tester.pump();
      expect(_shown(tester), DateTime(2027, 3));
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      await tester.tap(find.byKey(DabblerCalendarYearGrid.yearKey(2024)));
      await tester.pump();
      expect(_shown(tester), DateTime(2024, 11));
    });

    testWidgets('the chip toggles closed and still notifies onYearPressed', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      await tester.pumpWidget(host(_Harness(onYearPressed: () => calls++)));
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      expect(find.byType(DabblerCalendarYearGrid), findsNothing);
      expect(calls, 2);
    });

    testWidgets('selected year is brand on onBrand', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const _Harness()));
      await tester.tap(find.byKey(DabblerCalendar.yearChipKey));
      await tester.pump();
      final Text t = tester.widget<Text>(
        find.descendant(
          of: find.byKey(DabblerCalendarYearGrid.yearKey(2026)),
          matching: find.byType(Text),
        ),
      );
      expect(t.style!.color, colorsFor().onBrand);
    });
  });
}
