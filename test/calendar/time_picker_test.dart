import 'package:dabbler_design_system/src/calendar/time_picker.dart';
import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/forms/time_field.dart';
import 'package:dabbler_design_system/src/overlays/menu.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// The row carrying [value] in the column keyed [column].
Finder rowFor(Key column, String value) => find.descendant(
  of: find.byKey(column),
  matching: find.widgetWithText(DabblerMenuItem, value),
);

DabblerMenuList listIn(WidgetTester tester, Key column) =>
    tester.widget<DabblerMenuList>(
      find.descendant(
        of: find.byKey(column),
        matching: find.byType(DabblerMenuList),
      ),
    );

void main() {
  group('DabblerTimeValues — the value arithmetic', () {
    test('the hour column is 1..12 and the minute column is twelve steps', () {
      // Live `TimePicker.jsx:77-78`.
      expect(DabblerTimeValues.hours.length, 12);
      expect(DabblerTimeValues.hours.first, 1);
      expect(DabblerTimeValues.hours.last, 12);
      final List<int> minutes = DabblerTimeValues.minutesFor(
        DabblerTimeValues.defaultMinuteStep,
      );
      expect(minutes.length, 12);
      expect(minutes, <int>[0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]);
    });

    test('the default is 7:00 AM', () {
      // Live `TimePicker.jsx:86`.
      expect(
        DabblerTimeValues.defaultValue,
        const TimeOfDay(hour: 7, minute: 0),
      );
      expect(
        DabblerTimeFormat.format(DabblerTimeValues.defaultValue),
        '7:00 AM',
      );
    });

    test('nearestMinute folds to the closest step', () {
      // Live `TimePicker.jsx:91`.
      expect(DabblerTimeValues.nearestMinute(37, 5), 35);
      expect(DabblerTimeValues.nearestMinute(38, 5), 40);
      expect(DabblerTimeValues.nearestMinute(0, 5), 0);
      expect(DabblerTimeValues.nearestMinute(59, 5), 55);
    });

    test('the 12-hour hour is 12 at both midnight and noon', () {
      expect(
        DabblerTimeValues.hourOfPeriodOf(const TimeOfDay(hour: 0, minute: 0)),
        12,
      );
      expect(
        DabblerTimeValues.hourOfPeriodOf(const TimeOfDay(hour: 12, minute: 0)),
        12,
      );
      expect(
        DabblerTimeValues.hourOfPeriodOf(const TimeOfDay(hour: 18, minute: 30)),
        6,
      );
    });

    test('changing one column leaves the others alone', () {
      const TimeOfDay evening = TimeOfDay(hour: 18, minute: 30);
      expect(
        DabblerTimeValues.withHourOfPeriod(evening, 9),
        const TimeOfDay(hour: 21, minute: 30),
      );
      expect(
        DabblerTimeValues.withMinute(evening, 45),
        const TimeOfDay(hour: 18, minute: 45),
      );
      expect(
        DabblerTimeValues.withPeriod(evening, DayPeriod.am),
        const TimeOfDay(hour: 6, minute: 30),
      );
      expect(DabblerTimeValues.withPeriod(evening, DayPeriod.pm), evening);
    });

    test('hour 12 round-trips through both periods', () {
      const TimeOfDay noon = TimeOfDay(hour: 12, minute: 0);
      expect(
        DabblerTimeValues.withPeriod(noon, DayPeriod.am),
        const TimeOfDay(hour: 0, minute: 0),
      );
      expect(DabblerTimeValues.withHourOfPeriod(noon, 12), noon);
    });
  });

  group('DabblerTimePicker — the D-030 default API', () {
    testWidgets('compiles and builds with visibleRows and minuteStep', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(
            visibleRows: 3,
            minuteStep: 5,
            minimum: TimeOfDay(hour: 6, minute: 0),
            maximum: TimeOfDay(hour: 22, minute: 0),
            showActions: false,
            confirmLabel: 'OK',
            cancelLabel: 'Back',
            hourColumnLabel: 'H',
            minuteColumnLabel: 'M',
            periodLabel: 'P',
          ),
          width: phoneWidth,
        ),
      );
      expect(find.byType(DabblerTimePicker), findsOneWidget);
      expect(DabblerTimePicker.defaultVisibleRows, 3);
      expect(DabblerTimePicker.rowExtent, DabblerSizing.touchTargetMin);
      expect(DabblerTimeValues.defaultMinuteStep, 5);
    });

    testWidgets('minuteStep 15 yields the minutes 00 15 30 45', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(minuteStep: 15), width: phoneWidth),
      );
      expect(
        listIn(
          tester,
          DabblerTimePicker.minuteColumnKey,
        ).items.map((DabblerMenuEntry e) => e.label).toList(),
        <String>['00', '15', '30', '45'],
      );
    });

    testWidgets('visibleRows sizes the column in rows of rowExtent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(visibleRows: 5), width: phoneWidth),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.hourColumnKey)).height,
        DabblerTimePicker.rowExtent * 5,
      );
    });

    testWidgets('the default constructor builds listboxes and no ruler', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      expect(find.byType(DabblerMenuList), findsNWidgets(2));
      expect(find.byType(DabblerTimeRuler), findsNothing);
    });

    testWidgets('semantics: a selectable list whose options are announced', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 15, minute: 20)),
          width: phoneWidth,
        ),
      );
      await tester.pumpAndSettle();
      for (final Key column in <Key>[
        DabblerTimePicker.hourColumnKey,
        DabblerTimePicker.minuteColumnKey,
      ]) {
        final DabblerMenuList list = listIn(tester, column);
        expect(list.role, DabblerMenuRole.listbox);
        // Every option is a selectable item with a label, so each is
        // announced by name; exactly one is selected.
        expect(list.items.where((DabblerMenuEntry e) => e.selected).length, 1);
        expect(
          list.items.every((DabblerMenuEntry e) => e.label.isNotEmpty),
          true,
        );
      }
      // The selected hour (3) is announced as selected, with its own label.
      final SemanticsNode three = tester.getSemantics(
        rowFor(DabblerTimePicker.hourColumnKey, '3'),
      );
      expect(three.label, contains('3'));
      expect(
        three.getSemanticsData().flagsCollection.isSelected.toBoolOrNull(),
        isTrue,
      );
      final SemanticsNode four = tester.getSemantics(
        rowFor(DabblerTimePicker.hourColumnKey, '4'),
      );
      expect(four.label, contains('4'));
      expect(
        four.getSemanticsData().flagsCollection.isSelected.toBoolOrNull(),
        isFalse,
      );
      // The column itself is labelled for the screen reader.
      expect(
        find.bySemanticsLabel('Hour'),
        findsWidgets,
        reason: 'the column carries its accessible name',
      );
      handle.dispose();
    });

    testWidgets('arrow keys move the selection of the default picker', (
      WidgetTester tester,
    ) async {
      TimeOfDay value = const TimeOfDay(hour: 7, minute: 0);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                DabblerTimePicker(
                  value: value,
                  onChanged: (TimeOfDay t) => setState(() => value = t),
                ),
          ),
          width: phoneWidth,
        ),
      );
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '7'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 8, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 7, minute: 0));
    });
  });

  group('DabblerTimePicker — the ruler is opt-in only', () {
    testWidgets('DabblerTimePicker never builds a DabblerTimeRuler', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 9, minute: 30)),
          width: phoneWidth,
        ),
      );
      expect(find.byType(DabblerTimeRuler), findsNothing);
      expect(find.byType(DabblerMenuList), findsNWidgets(2));
    });

    testWidgets('an explicit DabblerTimeRuler builds the ruler, no listbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimeRuler(), width: phoneWidth),
      );
      expect(find.byType(DabblerTimeRuler), findsOneWidget);
      expect(find.byType(DabblerMenuList), findsNothing);
      expect(find.byKey(DabblerTimeRuler.hourColumnKey), findsOneWidget);
    });
  });

  group('DabblerTimePicker — it composes DS-602 and DS-700', () {
    testWidgets('the header prints the field\'s own H:MM AM', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 19, minute: 30)),
          width: phoneWidth,
        ),
      );
      expect(
        tester.widget<Text>(find.byKey(DabblerTimePicker.valueKey)).data,
        DabblerTimeFormat.format(const TimeOfDay(hour: 19, minute: 30)),
      );
      expect(
        tester.widget<Text>(find.byKey(DabblerTimePicker.valueKey)).data,
        '7:30 PM',
      );
    });

    testWidgets('both columns are DS-700 listboxes, not menus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      for (final Key key in <Key>[
        DabblerTimePicker.hourColumnKey,
        DabblerTimePicker.minuteColumnKey,
      ]) {
        final DabblerMenuList list = listIn(tester, key);
        expect(list.role, DabblerMenuRole.listbox);
        expect(list.decorated, isFalse);
        expect(list.autofocus, isFalse);
      }
    });

    testWidgets(
      'the hour column offers 1..12 and the minute column the steps',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const DabblerTimePicker(), width: phoneWidth),
        );
        expect(
          listIn(
            tester,
            DabblerTimePicker.hourColumnKey,
          ).items.map((DabblerMenuEntry e) => e.label).toList(),
          <String>[
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
          ],
        );
        final DabblerMenuList minutes = listIn(
          tester,
          DabblerTimePicker.minuteColumnKey,
        );
        // Live `TimePicker.jsx:59` pads; the hour is deliberately not padded so
        // the column agrees with `DabblerTimeFormat.format`, which prints
        // `7:05 PM`.
        expect(minutes.items.first.label, '00');
        expect(minutes.items.last.label, '55');
      },
    );

    testWidgets('the selected row is the one carrying the value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 15, minute: 20)),
          width: phoneWidth,
        ),
      );
      expect(
        listIn(
          tester,
          DabblerTimePicker.hourColumnKey,
        ).items.where((DabblerMenuEntry e) => e.selected).single.label,
        '3',
      );
      expect(
        listIn(
          tester,
          DabblerTimePicker.minuteColumnKey,
        ).items.where((DabblerMenuEntry e) => e.selected).single.label,
        '20',
      );
    });

    testWidgets('tapping an hour keeps the minute and the period', (
      WidgetTester tester,
    ) async {
      TimeOfDay? reported;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            value: const TimeOfDay(hour: 19, minute: 30),
            onChanged: (TimeOfDay t) => reported = t,
          ),
          width: phoneWidth,
        ),
      );
      await tester.ensureVisible(rowFor(DabblerTimePicker.hourColumnKey, '9'));
      await tester.pump();
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '9'));
      expect(reported, const TimeOfDay(hour: 21, minute: 30));
    });

    testWidgets('tapping a minute keeps the hour and the period', (
      WidgetTester tester,
    ) async {
      TimeOfDay? reported;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            value: const TimeOfDay(hour: 19, minute: 30),
            onChanged: (TimeOfDay t) => reported = t,
          ),
          width: phoneWidth,
        ),
      );
      await tester.ensureVisible(
        rowFor(DabblerTimePicker.minuteColumnKey, '45'),
      );
      await tester.pump();
      await tester.tap(rowFor(DabblerTimePicker.minuteColumnKey, '45'));
      expect(reported, const TimeOfDay(hour: 19, minute: 45));
    });

    testWidgets('the meridiem pill moves the value across noon', (
      WidgetTester tester,
    ) async {
      TimeOfDay? reported;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            value: const TimeOfDay(hour: 19, minute: 30),
            onChanged: (TimeOfDay t) => reported = t,
          ),
          width: phoneWidth,
        ),
      );
      await tester.tap(find.byKey(DabblerTimePicker.amKey));
      expect(reported, const TimeOfDay(hour: 7, minute: 30));

      reported = null;
      await tester.tap(find.byKey(DabblerTimePicker.pmKey));
      expect(reported, isNull, reason: 'already PM — no redundant report');
    });

    testWidgets('an unchanged selection is not reported twice', (
      WidgetTester tester,
    ) async {
      int reports = 0;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            value: const TimeOfDay(hour: 19, minute: 30),
            onChanged: (TimeOfDay _) => reports++,
          ),
          width: phoneWidth,
        ),
      );
      await tester.ensureVisible(rowFor(DabblerTimePicker.hourColumnKey, '7'));
      await tester.pump();
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '7'));
      expect(reports, 0);
    });

    testWidgets('a null value shows the source default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      expect(
        tester.widget<Text>(find.byKey(DabblerTimePicker.valueKey)).data,
        '7:00 AM',
      );
    });
  });

  group('DabblerTimePicker — bounds and keyboard', () {
    testWidgets('a value outside the bounds renders disabled', (
      WidgetTester tester,
    ) async {
      TimeOfDay? reported;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            value: const TimeOfDay(hour: 9, minute: 0),
            minimum: const TimeOfDay(hour: 8, minute: 0),
            maximum: const TimeOfDay(hour: 11, minute: 0),
            onChanged: (TimeOfDay t) => reported = t,
          ),
          width: phoneWidth,
        ),
      );
      final DabblerMenuList hours = listIn(
        tester,
        DabblerTimePicker.hourColumnKey,
      );
      // The value is 9 AM, so an hour of 7 would be 7 AM — before the 8 AM
      // minimum — and an hour of 12 would be 12 AM, before it too.
      expect(
        hours.items.firstWhere((DabblerMenuEntry e) => e.label == '7').disabled,
        isTrue,
      );
      expect(
        hours.items.firstWhere((DabblerMenuEntry e) => e.label == '9').disabled,
        isFalse,
      );
      await tester.tap(
        rowFor(DabblerTimePicker.hourColumnKey, '7'),
        warnIfMissed: false,
      );
      expect(reported, isNull);
    });

    testWidgets('arrow keys move the selection and skip disabled values', (
      WidgetTester tester,
    ) async {
      TimeOfDay value = const TimeOfDay(hour: 9, minute: 0);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DabblerTimePicker(
                value: value,
                minimum: const TimeOfDay(hour: 8, minute: 0),
                maximum: const TimeOfDay(hour: 11, minute: 0),
                onChanged: (TimeOfDay t) => setState(() => value = t),
              );
            },
          ),
          width: phoneWidth,
        ),
      );

      // Tapping into a column focuses it (pointer-down focus); the row tapped
      // is the one already selected, so nothing else changes.
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '9'));
      await tester.pump();
      expect(value, const TimeOfDay(hour: 9, minute: 0));
      // 9 -> 10, both inside 8..11.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 10, minute: 0));
      // 10 -> 11. 12 would be 12 AM and is disabled, so Down stops here.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 11, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 11, minute: 0));
      // Up walks back, skipping nothing inside the range.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 10, minute: 0));
    });

    testWidgets('Home and End jump to the first and last enabled value', (
      WidgetTester tester,
    ) async {
      TimeOfDay value = const TimeOfDay(hour: 7, minute: 0);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DabblerTimePicker(
                value: value,
                onChanged: (TimeOfDay t) => setState(() => value = t),
              );
            },
          ),
          width: phoneWidth,
        ),
      );
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '7'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      // Hour 12 with an AM period is midnight.
      expect(value, const TimeOfDay(hour: 0, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 1, minute: 0));
    });

    testWidgets('the arrow keys do not wrap', (WidgetTester tester) async {
      TimeOfDay value = const TimeOfDay(hour: 1, minute: 0);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DabblerTimePicker(
                value: value,
                onChanged: (TimeOfDay t) => setState(() => value = t),
              );
            },
          ),
          width: phoneWidth,
        ),
      );
      await tester.tap(rowFor(DabblerTimePicker.hourColumnKey, '1'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, const TimeOfDay(hour: 1, minute: 0));
    });
  });

  group('DabblerTimePicker — RTL and numerals', () {
    testWidgets('the hour column leads in both directions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.hourColumnKey)).left,
        lessThan(
          tester.getRect(find.byKey(DabblerTimePicker.minuteColumnKey)).left,
        ),
      );

      await tester.pumpWidget(
        host(
          const DabblerTimePicker(),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.hourColumnKey)).left,
        greaterThan(
          tester.getRect(find.byKey(DabblerTimePicker.minuteColumnKey)).left,
        ),
      );
    });

    testWidgets('AM leads PM in both directions', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.amKey)).left,
        lessThan(tester.getRect(find.byKey(DabblerTimePicker.pmKey)).left),
      );

      await tester.pumpWidget(
        host(
          const DabblerTimePicker(),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.amKey)).left,
        greaterThan(tester.getRect(find.byKey(DabblerTimePicker.pmKey)).left),
      );
    });

    testWidgets('every numeral stays Western in RTL (DS-103a)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 19, minute: 30)),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      final List<String> strings = renderedStrings(
        tester,
        find.byType(DabblerTimePicker),
      );
      expect(strings, contains('7:30 PM'));
      for (final String s in strings) {
        for (final int rune in s.runes) {
          expect(
            isArabicIndicDigit(rune),
            isFalse,
            reason: '"$s" carries an Arabic-Indic digit',
          );
        }
      }
    });

    testWidgets('the header reads H:MM AM left to right even in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 18, minute: 35)),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      expect(
        tester
            .widget<Text>(find.byKey(DabblerTimePicker.valueKey))
            .textDirection,
        TextDirection.ltr,
      );
    });

    testWidgets('the meridiem stays the product\'s literal AM/PM', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      expect(
        renderedStrings(tester, find.byKey(DabblerTimePicker.amKey)),
        contains(DabblerTimeFormat.amLabel),
      );
      expect(
        renderedStrings(tester, find.byKey(DabblerTimePicker.pmKey)),
        contains(DabblerTimeFormat.pmLabel),
      );
    });
  });

  group('DabblerTimePicker — targets and contrast', () {
    testWidgets('a value row is exactly the 45 the scroll maths assumes', (
      WidgetTester tester,
    ) async {
      // `_ValueColumn._revealSelected` computes its offset as
      // `index * rowExtent`; this keeps that arithmetic honest.
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      final Iterable<Element> rows = find
          .descendant(
            of: find.byKey(DabblerTimePicker.hourColumnKey),
            matching: find.byType(DabblerMenuItem),
          )
          .evaluate();
      expect(rows, isNotEmpty);
      for (final Element row in rows) {
        expect(
          (row.renderObject! as RenderBox).size.height,
          DabblerTimePicker.rowExtent,
        );
      }
    });

    testWidgets('every meridiem segment and Cancel clear the 45 floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(onCancel: null), width: phoneWidth),
      );
      for (final Key key in <Key>[
        DabblerTimePicker.amKey,
        DabblerTimePicker.pmKey,
        DabblerTimePicker.cancelKey,
      ]) {
        final Rect rect = tester.getRect(find.byKey(key));
        expect(
          rect.height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
          reason: '$key is under the 45 floor',
        );
        expect(rect.width, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      }
    });

    testWidgets('a column shows visibleRows rows and scrolls past them', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      expect(
        tester.getRect(find.byKey(DabblerTimePicker.hourColumnKey)).height,
        DabblerTimePicker.rowExtent * DabblerTimePicker.defaultVisibleRows,
      );
    });

    testWidgets('the selected value is scrolled into view', (
      WidgetTester tester,
    ) async {
      // Hour 11 is the eleventh row of twelve — off screen in a 3-row window
      // unless the column moved to it.
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 11, minute: 0)),
          width: phoneWidth,
        ),
      );
      await tester.pumpAndSettle();
      final Rect column = tester.getRect(
        find.byKey(DabblerTimePicker.hourColumnKey),
      );
      final Rect row = tester.getRect(
        rowFor(DabblerTimePicker.hourColumnKey, '11'),
      );
      expect(row.top, greaterThanOrEqualTo(column.top - 0.5));
      expect(row.bottom, lessThanOrEqualTo(column.bottom + 0.5));
    });

    test('a value row clears 4.5:1 in every theme and mode', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          final DabblerColors c = colorsFor(
            theme: theme,
            brightness: brightness,
          );
          expect(
            contrastRatio(c.textPrimary, c.surfaceCard),
            greaterThanOrEqualTo(4.5),
            reason: 'a value row in $theme/$brightness',
          );
        }
      }
    });

    testWidgets('the unselected meridiem is textSecondary (D-003(a))', (
      WidgetTester tester,
    ) async {
      // Live `TimePicker.jsx:104` sets it in `--muted`; D-003(a) maps `--muted`
      // text to `textSecondary`, the same mapping `DabblerCalendar` uses.
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      final TextStyle pm = tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(DabblerTimePicker.pmKey),
              matching: find.byType(Text),
            ),
          )
          .style!;
      expect(pm.color, colorsFor().textSecondary);
      expect(pm.fontSize, 12);
      expect(pm.fontWeight, FontWeight.w700);
    });
  });

  group('DabblerTimePicker — the footer', () {
    testWidgets('showActions false drops it', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(showActions: false), width: phoneWidth),
      );
      expect(find.byKey(DabblerTimePicker.confirmKey), findsNothing);
      expect(find.byKey(DabblerTimePicker.cancelKey), findsNothing);
    });

    testWidgets('the footer is Confirm primary, Cancel text (D-023, KAN-279)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      DabblerButtonTone toneOf(Key key) =>
          tester.widget<DabblerButton>(find.byKey(key)).tone;

      expect(toneOf(DabblerTimePicker.cancelKey), DabblerButtonTone.text);
      // Asserted explicitly so a change to DabblerButton's default cannot
      // silently repaint this footer.
      expect(toneOf(DabblerTimePicker.confirmKey), DabblerButtonTone.primary);
    });

    testWidgets('Confirm and Cancel fire', (WidgetTester tester) async {
      int confirmed = 0;
      int cancelled = 0;
      await tester.pumpWidget(
        host(
          DabblerTimePicker(
            onConfirm: () => confirmed++,
            onCancel: () => cancelled++,
          ),
          width: phoneWidth,
        ),
      );
      await tester.tap(find.byKey(DabblerTimePicker.confirmKey));
      await tester.tap(find.byKey(DabblerTimePicker.cancelKey));
      expect(confirmed, 1);
      expect(cancelled, 1);
    });
  });
}
