import 'package:dabbler_design_system/src/calendar/time_picker.dart';
import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/forms/time_field.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

void main() {
  group('DabblerTimeValues — the value arithmetic (AC2)', () {
    test('the hour column is 1..12 and the minute column is twelve steps', () {
      // `TimePicker.jsx:77-78`.
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
      // `TimePicker.jsx:86`.
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
      // `TimePicker.jsx:91`.
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

  group('DabblerTimePicker — header and value set', () {
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
        '7:30 PM',
      );
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

    testWidgets('the rulers carry 12 hours and 12 five-minute steps, tripled', (
      WidgetTester tester,
    ) async {
      // `TimePicker.jsx:9` — `trackLen = n * 3` cells per ruler.
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      for (int i = 0; i < 36; i++) {
        expect(
          find.byKey(
            DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, i),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            DabblerTimePicker.cellKey(DabblerTimePicker.minuteColumnKey, i),
          ),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(
          DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, 36),
        ),
        findsNothing,
      );
      String textAt(Key column, int i) => tester
          .widget<Text>(find.byKey(DabblerTimePicker.cellKey(column, i)))
          .data!;
      // Zero-padded (`TimePicker.jsx:59` `padStart(2, '0')`).
      expect(textAt(DabblerTimePicker.hourColumnKey, 12), '01');
      expect(textAt(DabblerTimePicker.hourColumnKey, 23), '12');
      expect(textAt(DabblerTimePicker.minuteColumnKey, 12), '00');
      expect(textAt(DabblerTimePicker.minuteColumnKey, 23), '55');
    });
  });

  group('DabblerTimePicker — the ruler against TimePicker.jsx', () {
    test('the transcribed constants equal the live values', () {
      // Live `TimePicker.jsx`: height 64 (:39), pitch 46 (:3), ticks bottom 6 /
      // height 14 (:41), 1.5px (:44), numerals 24 / 18 (:57), opacity
      // max(.2, 1 - dist*.3) (:50), window top/bottom 4, width pitch+14,
      // radius 12, 2px (:65-66), pin bottom 8, 2x16 (:70), glide 200ms
      // cubic-bezier(.2,.8,.2,1) (:16), card radius 18, gap 10, header 20.
      expect(DabblerTimePicker.rulerHeight, 64);
      expect(DabblerTimePicker.rulerPitch, 46);
      expect(DabblerTimePicker.tickBottom, 6);
      expect(DabblerTimePicker.tickHeight, 14);
      expect(DabblerTimePicker.tickWidth, 1.5);
      expect(DabblerTimePicker.selectedFontSize, 24);
      expect(DabblerTimePicker.otherFontSize, 18);
      expect(DabblerTimePicker.minOpacity, 0.2);
      expect(DabblerTimePicker.opacityStep, 0.3);
      expect(DabblerTimePicker.windowInset, 4);
      expect(DabblerTimePicker.windowExtra, 14);
      expect(DabblerTimePicker.windowRadius, 12);
      expect(DabblerTimePicker.windowBorder, 2);
      expect(DabblerTimePicker.pinBottom, 8);
      expect(DabblerTimePicker.pinWidth, 2);
      expect(DabblerTimePicker.pinHeight, 16);
      expect(DabblerTimePicker.glide, const Duration(milliseconds: 200));
      expect(DabblerTimePicker.glideCurve, const Cubic(0.2, 0.8, 0.2, 1));
      expect(DabblerTimePicker.cardRadius, 18);
      expect(DabblerTimePicker.cardGap, 10);
      expect(DabblerTimePicker.headerGap, 10);
      expect(DabblerTimePicker.headerFontSize, 20);
    });

    testWidgets('a ruler is 64 tall and the centre cell sits on the centre', (
      WidgetTester tester,
    ) async {
      // Live `:56` height 64; `:35` track left 50% with the centre cell
      // translated to the middle.
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 7, minute: 0)),
          width: phoneWidth,
        ),
      );
      final Rect ruler = tester.getRect(
        find.byKey(DabblerTimePicker.hourColumnKey),
      );
      expect(ruler.height, 64);
      // Hour 7 is index 6; the centre cell is n + idx = 18.
      final Rect centre = tester.getRect(
        find.byKey(
          DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, 18),
        ),
      );
      expect(centre.center.dx, closeTo(ruler.center.dx, 0.6));
      final Rect next = tester.getRect(
        find.byKey(
          DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, 19),
        ),
      );
      // One pitch (46) to the right.
      expect(next.center.dx - centre.center.dx, closeTo(46, 0.6));
    });

    testWidgets('numerals are 24 centred / 18 other with the live opacity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 7, minute: 0)),
          width: phoneWidth,
        ),
      );
      TextStyle styleAt(int i) => tester
          .widget<Text>(
            find.byKey(
              DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, i),
            ),
          )
          .style!;
      final DabblerColors c = colorsFor();
      expect(styleAt(18).fontSize, 24);
      expect(styleAt(18).color, c.brandPrimary);
      expect(styleAt(19).fontSize, 18);
      // dist 1 -> 0.7, dist 2 -> 0.4, dist 3 -> floor 0.2 (1 - .9 = .1).
      expect(styleAt(19).color!.a, closeTo(0.7, 0.01));
      expect(styleAt(20).color!.a, closeTo(0.4, 0.01));
      expect(styleAt(21).color!.a, closeTo(0.2, 0.01));
      expect(styleAt(25).color!.a, closeTo(0.2, 0.01));
      expect(styleAt(19).color!.withValues(alpha: 1), c.textPrimary);
    });

    testWidgets('the same sizes under RTL are Latin less 0.9', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 7, minute: 0)),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      TextStyle styleAt(int i) => tester
          .widget<Text>(
            find.byKey(
              DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, i),
            ),
          )
          .style!;
      expect(styleAt(18).fontSize, closeTo(23.1, 0.001));
      expect(styleAt(19).fontSize, closeTo(17.1, 0.001));
      expect(
        tester
            .widget<Text>(find.byKey(DabblerTimePicker.valueKey))
            .style!
            .fontSize,
        closeTo(19.1, 0.001),
      );
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

    testWidgets('the header value is 20 / 700 in LTR', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      final TextStyle s = tester
          .widget<Text>(find.byKey(DabblerTimePicker.valueKey))
          .style!;
      expect(s.fontSize, 20);
      expect(s.fontWeight, FontWeight.w700);
    });

    testWidgets('the scale ascends to the right in RTL too', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTimePicker(value: TimeOfDay(hour: 7, minute: 0)),
          direction: TextDirection.rtl,
          width: phoneWidth,
        ),
      );
      final double c = tester
          .getCenter(
            find.byKey(
              DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, 18),
            ),
          )
          .dx;
      final double n = tester
          .getCenter(
            find.byKey(
              DabblerTimePicker.cellKey(DabblerTimePicker.hourColumnKey, 19),
            ),
          )
          .dx;
      expect(n - c, closeTo(46, 0.6));
    });

    testWidgets('the rulers stack hour above minute in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection d in TextDirection.values) {
        await tester.pumpWidget(
          host(const DabblerTimePicker(), direction: d, width: phoneWidth),
        );
        final Rect hour = tester.getRect(
          find.byKey(DabblerTimePicker.hourColumnKey),
        );
        final Rect minute = tester.getRect(
          find.byKey(DabblerTimePicker.minuteColumnKey),
        );
        expect(minute.top - hour.bottom, 10, reason: '$d — gap 10 (:98)');
        expect(hour.left, minute.left);
      }
    });

    testWidgets('the card is padded 15 with radius 18', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTimePicker(), width: phoneWidth),
      );
      final Rect card = tester.getRect(find.byType(DabblerTimePicker));
      final Rect ruler = tester.getRect(
        find.byKey(DabblerTimePicker.hourColumnKey),
      );
      expect(ruler.left - card.left, 15);
      expect(card.right - ruler.right, 15);
    });
  });

  group('DabblerTimePicker — interaction', () {
    Widget stateful({
      required ValueChanged<TimeOfDay> onReport,
      TimeOfDay initial = const TimeOfDay(hour: 7, minute: 0),
      TimeOfDay? minimum,
      TimeOfDay? maximum,
      TextDirection direction = TextDirection.ltr,
    }) {
      TimeOfDay value = initial;
      return host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DabblerTimePicker(
              value: value,
              minimum: minimum,
              maximum: maximum,
              onChanged: (TimeOfDay t) {
                setState(() => value = t);
                onReport(t);
              },
            );
          },
        ),
        direction: direction,
        width: phoneWidth,
      );
    }

    Future<void> dragBy(WidgetTester tester, Finder at, double total) async {
      // Steps of 10 so the recogniser passes its slop and still reports the
      // remainder (`DragStartBehavior.start`).
      final TestGesture g = await tester.startGesture(tester.getCenter(at));
      final double step = total < 0 ? -10 : 10;
      for (int i = 0; i < (total.abs() / 10).round(); i++) {
        await g.moveBy(Offset(step, 0));
      }
      await g.up();
      await tester.pumpAndSettle();
    }

    testWidgets('dragging left by ~two pitches advances two hours', (
      WidgetTester tester,
    ) async {
      // `TimePicker.jsx:26-27` — `shift = round(-dx / pitch)`.
      TimeOfDay? last;
      await tester.pumpWidget(stateful(onReport: (TimeOfDay t) => last = t));
      await dragBy(tester, find.byKey(DabblerTimePicker.hourColumnKey), -120);
      expect(last, const TimeOfDay(hour: 9, minute: 0));
    });

    testWidgets('dragging right moves back and wraps modulo twelve', (
      WidgetTester tester,
    ) async {
      TimeOfDay? last;
      await tester.pumpWidget(
        stateful(
          onReport: (TimeOfDay t) => last = t,
          initial: const TimeOfDay(hour: 1, minute: 0),
        ),
      );
      await dragBy(tester, find.byKey(DabblerTimePicker.hourColumnKey), 70);
      // 1 -> 12 (wrap): `((idx + shift) % n + n) % n` (`:27`); 12 with AM is
      // midnight.
      expect(last, const TimeOfDay(hour: 0, minute: 0));
    });

    testWidgets('dragging the minute ruler changes minutes only', (
      WidgetTester tester,
    ) async {
      TimeOfDay? last;
      await tester.pumpWidget(stateful(onReport: (TimeOfDay t) => last = t));
      await dragBy(tester, find.byKey(DabblerTimePicker.minuteColumnKey), -120);
      expect(last, const TimeOfDay(hour: 7, minute: 10));
    });

    testWidgets('a tap picks the numeral under the finger', (
      WidgetTester tester,
    ) async {
      TimeOfDay? last;
      await tester.pumpWidget(stateful(onReport: (TimeOfDay t) => last = t));
      final Offset c = tester.getCenter(
        find.byKey(DabblerTimePicker.hourColumnKey),
      );
      await tester.tapAt(c + const Offset(46, 0));
      await tester.pumpAndSettle();
      expect(last, const TimeOfDay(hour: 8, minute: 0));
    });

    testWidgets('a tap on the centre cell reports nothing', (
      WidgetTester tester,
    ) async {
      int reports = 0;
      await tester.pumpWidget(stateful(onReport: (TimeOfDay _) => reports++));
      await tester.tap(find.byKey(DabblerTimePicker.hourColumnKey));
      await tester.pumpAndSettle();
      expect(reports, 0);
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

    testWidgets('a value outside the bounds is never committed', (
      WidgetTester tester,
    ) async {
      TimeOfDay? last;
      await tester.pumpWidget(
        stateful(
          onReport: (TimeOfDay t) => last = t,
          initial: const TimeOfDay(hour: 9, minute: 0),
          minimum: const TimeOfDay(hour: 8, minute: 0),
          maximum: const TimeOfDay(hour: 11, minute: 0),
        ),
      );
      // Two hours back would be 7 AM, before the 8 AM minimum.
      await dragBy(tester, find.byKey(DabblerTimePicker.hourColumnKey), 120);
      expect(last, isNull);
    });

    testWidgets('arrow keys step and skip disabled values', (
      WidgetTester tester,
    ) async {
      TimeOfDay value = const TimeOfDay(hour: 9, minute: 0);
      await tester.pumpWidget(
        stateful(
          onReport: (TimeOfDay t) => value = t,
          initial: value,
          minimum: const TimeOfDay(hour: 8, minute: 0),
          maximum: const TimeOfDay(hour: 11, minute: 0),
        ),
      );
      await tester.tap(find.byKey(DabblerTimePicker.hourColumnKey));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 10, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 11, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 11, minute: 0), reason: '12 AM off');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 10, minute: 0));
    });

    testWidgets('Home and End jump to the first and last enabled value', (
      WidgetTester tester,
    ) async {
      TimeOfDay value = const TimeOfDay(hour: 7, minute: 0);
      await tester.pumpWidget(
        stateful(onReport: (TimeOfDay t) => value = t, initial: value),
      );
      await tester.tap(find.byKey(DabblerTimePicker.hourColumnKey));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 0, minute: 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 1, minute: 0));
    });

    testWidgets('a ruler is an adjustable semantics node', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      TimeOfDay value = const TimeOfDay(hour: 7, minute: 0);
      await tester.pumpWidget(
        stateful(onReport: (TimeOfDay t) => value = t, initial: value),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byKey(DabblerTimePicker.hourColumnKey),
      );
      final SemanticsData data = node.getSemanticsData();
      expect(data.label, 'Hour');
      expect(data.value, '07');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);
      tester.semantics.performAction(
        find.semantics.byLabel('Hour'),
        SemanticsAction.increase,
      );
      await tester.pumpAndSettle();
      expect(value, const TimeOfDay(hour: 8, minute: 0));
      handle.dispose();
    });
  });

  group('DabblerTimePicker — RTL and numerals', () {
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
          expect(isArabicIndicDigit(rune), isFalse, reason: '"$s"');
        }
      }
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
    });
  });

  group('DabblerTimePicker — targets and colour', () {
    testWidgets('meridiem segments and Cancel clear the 45 floor', (
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
        expect(rect.height, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
        expect(rect.width, greaterThanOrEqualTo(DabblerSizing.touchTargetMin));
      }
    });

    testWidgets('the unselected meridiem is --muted (textSecondary, D-003a)', (
      WidgetTester tester,
    ) async {
      // Live `TimePicker.jsx:104` — inactive segment colour `var(--muted)`.
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

      // D-023 ruled a chrome-less action beside a filled one. This footer
      // carried the one-off DabblerCalendarTextAction until KAN-279 deleted
      // it and pointed the row at the shipped `text` tone; nothing pinned
      // the result, so the migration was invisible to the suite.
      expect(toneOf(DabblerTimePicker.cancelKey), DabblerButtonTone.text);

      // Confirm takes DabblerButton's default. Asserted explicitly so a
      // change to that default cannot silently repaint this footer.
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
