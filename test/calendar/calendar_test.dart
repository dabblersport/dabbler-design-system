import 'package:dabbler_design_system/src/calendar/calendar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// The specimen's month — `calendar.card.html:21` renders
/// `<Calendar month={1} year={2078} …>`, and `month` is 0-indexed
/// (`Calendar.d.ts:5`), so it is February 2078.
final DateTime specimenMonth = DateTime(2078, DateTime.february);

void main() {
  group('DabblerCalendarMonth — the grid arithmetic (AC1)', () {
    test('a month fills whole weeks, opening on the first weekday', () {
      final List<DabblerCalendarCell> cells =
          DabblerCalendarMonth.cellsFor(specimenMonth);
      expect(cells.length % DabblerCalendarMonth.daysInWeek, 0);
      expect(cells.first.date.weekday, DateTime.monday);
      expect(cells.last.date.weekday, DateTime.sunday);
    });

    test('the body is exactly the month, and the padding is its neighbours', () {
      final List<DabblerCalendarCell> cells =
          DabblerCalendarMonth.cellsFor(specimenMonth);
      final List<DabblerCalendarCell> inside =
          cells.where((DabblerCalendarCell c) => !c.outside).toList();
      // 2078 is not a leap year; February has 28 days.
      expect(DabblerCalendarMonth.daysIn(specimenMonth), 28);
      expect(inside.length, 28);
      expect(inside.first.date, DateTime(2078, 2, 1));
      expect(inside.last.date, DateTime(2078, 2, 28));
      for (final DabblerCalendarCell c in cells) {
        expect(c.outside, c.date.month != DateTime.february);
      }
    });

    test('the trailing cells are the next month opening at 1', () {
      // `Calendar.jsx:25` spells this `cells.length - lead - days + 1`, which
      // evaluates to 1, 2, 3 …
      final List<DabblerCalendarCell> cells =
          DabblerCalendarMonth.cellsFor(DateTime(2026, DateTime.september));
      final List<DabblerCalendarCell> trailing = cells
          .skipWhile((DabblerCalendarCell c) => c.outside)
          .skipWhile((DabblerCalendarCell c) => !c.outside)
          .toList();
      if (trailing.isNotEmpty) {
        expect(trailing.first.date.day, 1);
        expect(trailing.first.date.month, DateTime.october);
      }
    });

    test('a leap February is 29 days', () {
      expect(DabblerCalendarMonth.daysIn(DateTime(2028, DateTime.february)), 29);
    });

    test('leadingFor matches the source for a Monday-first week', () {
      // `Calendar.jsx:19` — `(first.getDay() + 6) % 7`, i.e. Monday-first.
      final DateTime first = DateTime(2078, 2, 1);
      expect(
        DabblerCalendarMonth.leadingFor(specimenMonth),
        (first.weekday - DateTime.monday + 7) % 7,
      );
    });

    test('a Saturday-first week shifts the leading count, not the month', () {
      final List<DabblerCalendarCell> saturdayFirst =
          DabblerCalendarMonth.cellsFor(
        specimenMonth,
        firstWeekday: DateTime.saturday,
      );
      expect(saturdayFirst.first.date.weekday, DateTime.saturday);
      expect(
        saturdayFirst.where((DabblerCalendarCell c) => !c.outside).length,
        28,
      );
      expect(
        DabblerCalendarMonth.leadingFor(
          specimenMonth,
          firstWeekday: DateTime.saturday,
        ),
        (DateTime(2078, 2, 1).weekday - DateTime.saturday + 7) % 7,
      );
    });

    test('weekdayOrder starts where it is told and stays logical', () {
      expect(
        DabblerCalendarMonth.weekdayOrder(DateTime.monday),
        <int>[1, 2, 3, 4, 5, 6, 7],
      );
      expect(
        DabblerCalendarMonth.weekdayOrder(DateTime.saturday),
        <int>[
          DateTime.saturday,
          DateTime.sunday,
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
      );
    });

    test('the week-start default is Monday in LTR and Saturday in RTL (AC3)', () {
      expect(
        DabblerCalendarMonth.defaultFirstWeekdayFor(TextDirection.ltr),
        DateTime.monday,
      );
      expect(
        DabblerCalendarMonth.defaultFirstWeekdayFor(TextDirection.rtl),
        DateTime.saturday,
      );
    });

    test('monthAdd rolls the year in both directions', () {
      expect(
        DabblerCalendarMonth.monthAdd(DateTime(2026, 12), 1),
        DateTime(2027, 1),
      );
      expect(
        DabblerCalendarMonth.monthAdd(DateTime(2026, 1), -1),
        DateTime(2025, 12),
      );
    });

    test('weeksFor is cellsFor in rows of seven', () {
      final List<List<DabblerCalendarCell>> weeks =
          DabblerCalendarMonth.weeksFor(specimenMonth);
      expect(
        weeks.every((List<DabblerCalendarCell> w) => w.length == 7),
        isTrue,
      );
      expect(
        weeks.expand((List<DabblerCalendarCell> w) => w).toList(),
        DabblerCalendarMonth.cellsFor(specimenMonth),
      );
    });
  });

  group('DabblerCalendar — the grid renders and selects (AC1)', () {
    testWidgets('every day of the month is on screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(DabblerCalendar(month: specimenMonth)));
      for (int d = 1; d <= 28; d++) {
        expect(
          find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, d))),
          findsOneWidget,
          reason: 'February $d is missing',
        );
      }
    });

    testWidgets('tapping a day reports that date', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            onSelect: (DateTime d) => picked = d,
          ),
        ),
      );
      await tester.tap(find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 14))));
      expect(picked, DateTime(2078, 2, 14));
    });

    testWidgets('an outside day is inert', (WidgetTester tester) async {
      DateTime? picked;
      final DabblerCalendarCell outside = DabblerCalendarMonth.cellsFor(
        specimenMonth,
      ).firstWhere((DabblerCalendarCell c) => c.outside);
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            onSelect: (DateTime d) => picked = d,
          ),
        ),
      );
      await tester.tap(
        find.byKey(DabblerCalendar.dayKey(outside.date)),
        warnIfMissed: false,
      );
      expect(picked, isNull);
    });

    testWidgets('a day before minimum is inert', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            minimum: DateTime(2078, 2, 10),
            onSelect: (DateTime d) => picked = d,
          ),
        ),
      );
      await tester.tap(
        find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 9))),
        warnIfMissed: false,
      );
      expect(picked, isNull);
      await tester.tap(find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 10))));
      expect(picked, DateTime(2078, 2, 10));
    });

    testWidgets('a day after maximum is inert', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            maximum: DateTime(2078, 2, 20),
            onSelect: (DateTime d) => picked = d,
          ),
        ),
      );
      await tester.tap(
        find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 21))),
        warnIfMissed: false,
      );
      expect(picked, isNull);
    });

    testWidgets('selection is a plain non-contiguous set', (
      WidgetTester tester,
    ) async {
      // `Calendar.prompt.md` — *"`range` is a plain list of day numbers, so
      // non-contiguous selections work"*.
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            selected: <DateTime>{DateTime(2078, 2, 3), DateTime(2078, 2, 19)},
          ),
        ),
      );
      final DabblerCalendar widget =
          tester.widget<DabblerCalendar>(find.byType(DabblerCalendar));
      expect(
        widget.isSelected(
          DabblerCalendarCell(date: DateTime(2078, 2, 3), outside: false),
        ),
        isTrue,
      );
      expect(
        widget.isSelected(
          DabblerCalendarCell(date: DateTime(2078, 2, 4), outside: false),
        ),
        isFalse,
      );
      expect(
        widget.isSelected(
          DabblerCalendarCell(date: DateTime(2078, 2, 19), outside: false),
        ),
        isTrue,
      );
    });

    testWidgets('the selected cell paints the brand fill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            selected: <DateTime>{DateTime(2078, 2, 14)},
          ),
        ),
      );
      final Container square = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 14))),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (square.decoration! as BoxDecoration).color,
        colorsFor().brandPrimary,
      );
    });

    testWidgets('showActions false drops the footer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: specimenMonth, showActions: false)),
      );
      expect(find.byKey(DabblerCalendar.confirmKey), findsNothing);
      expect(find.byKey(DabblerCalendar.cancelKey), findsNothing);

      await tester.pumpWidget(host(DabblerCalendar(month: specimenMonth)));
      expect(find.byKey(DabblerCalendar.confirmKey), findsOneWidget);
      expect(find.byKey(DabblerCalendar.cancelKey), findsOneWidget);
    });
  });

  group('DabblerCalendar — RTL, by measured geometry (AC3)', () {
    /// The left edge of each column label, in the order the columns are laid
    /// out logically (first day of the week first).
    Future<List<double>> columnLefts(
      WidgetTester tester,
      TextDirection direction,
      int firstWeekday,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerCalendar(month: specimenMonth, firstWeekday: firstWeekday),
          direction: direction,
        ),
      );
      return <double>[
        for (final int weekday
            in DabblerCalendarMonth.weekdayOrder(firstWeekday))
          tester.getRect(find.byKey(DabblerCalendar.weekdayKey(weekday))).left,
      ];
    }

    testWidgets('LTR runs the week left to right', (WidgetTester tester) async {
      final List<double> lefts =
          await columnLefts(tester, TextDirection.ltr, DateTime.monday);
      for (int i = 1; i < lefts.length; i++) {
        expect(
          lefts[i],
          greaterThan(lefts[i - 1]),
          reason: 'column $i should be further right than ${i - 1}',
        );
      }
    });

    testWidgets('RTL runs the week right to left', (WidgetTester tester) async {
      final List<double> lefts =
          await columnLefts(tester, TextDirection.rtl, DateTime.saturday);
      for (int i = 1; i < lefts.length; i++) {
        expect(
          lefts[i],
          lessThan(lefts[i - 1]),
          reason: 'column $i should be further left than ${i - 1}',
        );
      }
    });

    testWidgets('the first day of the week is the outermost leading column', (
      WidgetTester tester,
    ) async {
      final List<double> ltr =
          await columnLefts(tester, TextDirection.ltr, DateTime.monday);
      expect(ltr.first, lessThan(ltr.last));

      final List<double> rtl =
          await columnLefts(tester, TextDirection.rtl, DateTime.saturday);
      expect(rtl.first, greaterThan(rtl.last));
    });

    testWidgets('a date sits under its own weekday column in both directions', (
      WidgetTester tester,
    ) async {
      for (final (TextDirection direction, int start) in <(TextDirection, int)>[
        (TextDirection.ltr, DateTime.monday),
        (TextDirection.rtl, DateTime.saturday),
      ]) {
        await tester.pumpWidget(
          host(
            DabblerCalendar(month: specimenMonth, firstWeekday: start),
            direction: direction,
          ),
        );
        for (int d = 1; d <= 28; d++) {
          final DateTime date = DateTime(2078, 2, d);
          expect(
            tester.getRect(find.byKey(DabblerCalendar.dayKey(date))).left,
            moreOrLessEquals(
              tester
                  .getRect(find.byKey(DabblerCalendar.weekdayKey(date.weekday)))
                  .left,
              epsilon: 0.5,
            ),
            reason: '$date is not under its weekday column in $direction',
          );
        }
      }
    });

    testWidgets('the next control mirrors its position with direction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: specimenMonth, onMonthChanged: (_) {})),
      );
      expect(
        tester.getRect(find.byKey(DabblerCalendar.nextMonthKey)).left,
        greaterThan(
          tester.getRect(find.byKey(DabblerCalendar.previousMonthKey)).left,
        ),
      );

      await tester.pumpWidget(
        host(
          DabblerCalendar(month: specimenMonth, onMonthChanged: (_) {}),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getRect(find.byKey(DabblerCalendar.nextMonthKey)).left,
        lessThan(
          tester.getRect(find.byKey(DabblerCalendar.previousMonthKey)).left,
        ),
      );
    });

    test('the arrow glyphs swap with direction, because an icon never does', () {
      expect(
        DabblerCalendar.previousIconFor(TextDirection.ltr),
        'arrow-left-2',
      );
      expect(DabblerCalendar.nextIconFor(TextDirection.ltr), 'arrow-right-3');
      expect(
        DabblerCalendar.previousIconFor(TextDirection.rtl),
        'arrow-right-3',
      );
      expect(DabblerCalendar.nextIconFor(TextDirection.rtl), 'arrow-left-2');
    });

    testWidgets('"next" advances calendar time in both directions', (
      WidgetTester tester,
    ) async {
      for (final TextDirection direction in TextDirection.values) {
        DateTime? asked;
        await tester.pumpWidget(
          host(
            DabblerCalendar(
              month: specimenMonth,
              onMonthChanged: (DateTime m) => asked = m,
            ),
            direction: direction,
          ),
        );
        await tester.tap(find.byKey(DabblerCalendar.nextMonthKey));
        expect(
          asked,
          DateTime(2078, DateTime.march),
          reason: 'next must go forward in $direction',
        );
        await tester.tap(find.byKey(DabblerCalendar.previousMonthKey));
        expect(
          asked,
          DateTime(2078, DateTime.january),
          reason: 'previous must go back in $direction',
        );
      }
    });

    testWidgets('numerals stay Western in RTL (DS-103a)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerCalendar(month: specimenMonth, firstWeekday: DateTime.saturday),
          direction: TextDirection.rtl,
        ),
      );
      final List<String> strings =
          renderedStrings(tester, find.byType(DabblerCalendar));
      expect(strings, contains('2078'));
      expect(strings, contains('28'));
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

    testWidgets('the month grid does not reverse its own lists', (
      WidgetTester tester,
    ) async {
      // The logical model is direction-free: only the Row mirrors.
      expect(
        DabblerCalendarMonth.cellsFor(specimenMonth),
        DabblerCalendarMonth.cellsFor(specimenMonth),
      );
      await tester.pumpWidget(
        host(
          DabblerCalendar(month: specimenMonth, firstWeekday: DateTime.monday),
          direction: TextDirection.rtl,
        ),
      );
      // Day 1 is still day 1, drawn wherever its column lands.
      expect(
        find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 1))),
        findsOneWidget,
      );
    });
  });

  group('DabblerCalendar — targets and contrast (AC4)', () {
    testWidgets('every date cell is at least 45 tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(DabblerCalendar(month: specimenMonth)));
      for (final DabblerCalendarCell cell
          in DabblerCalendarMonth.cellsFor(specimenMonth)) {
        expect(
          tester.getRect(find.byKey(DabblerCalendar.dayKey(cell.date))).height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
          reason: '${cell.date} is under the 45 floor',
        );
      }
    });

    testWidgets('cells clear SC 2.5.8 (24) at the specimen width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: specimenMonth), width: specimenWidth),
      );
      final double width = tester
          .getRect(find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 14))))
          .width;
      expect(width, greaterThanOrEqualTo(24));
      // The card's own arithmetic, stated in the class doc.
      expect(width, moreOrLessEquals((specimenWidth - 48) / 7, epsilon: 0.5));
    });

    testWidgets('cells clear 44 at a phone width', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: specimenMonth), width: phoneWidth),
      );
      expect(
        tester
            .getRect(find.byKey(DabblerCalendar.dayKey(DateTime(2078, 2, 14))))
            .width,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets('the header controls are 45×45 targets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            onMonthChanged: (_) {},
            onMonthPressed: () {},
            onYearPressed: () {},
          ),
        ),
      );
      for (final Key key in <Key>[
        DabblerCalendar.previousMonthKey,
        DabblerCalendar.nextMonthKey,
        DabblerCalendar.monthChipKey,
        DabblerCalendar.yearChipKey,
      ]) {
        final Rect rect = tester.getRect(find.byKey(key));
        expect(
          rect.height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
          reason: '$key is under the 45 floor',
        );
        expect(rect.width, greaterThanOrEqualTo(24));
      }
    });

    testWidgets('the Cancel action clears the 45 floor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(DabblerCalendar(month: specimenMonth, onCancel: () {})),
      );
      expect(
        tester.getRect(find.byKey(DabblerCalendar.cancelKey)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
    });

    test('a day number clears 4.5:1 on the card in every theme and mode', () {
      for (final DabblerTheme theme in DabblerTheme.values) {
        for (final Brightness brightness in Brightness.values) {
          expect(
            contrastRatio(
              colorsFor(theme: theme, brightness: brightness).textPrimary,
              colorsFor(theme: theme, brightness: brightness).surfaceCard,
            ),
            greaterThanOrEqualTo(4.5),
            reason: 'a day number in $theme/$brightness',
          );
        }
      }
    });

    test('a selected day clears 4.5:1 in six of seven light themes', () {
      // Measured, not asserted from the source. `shade` is the exception and
      // it is a **token-layer finding this ticket reports and does not
      // patch**: `--color-on-brand` on `--color-brand-primary` is 3.95:1 under
      // `[data-theme="shade"]`, so a selected date in a shade-themed surface
      // fails SC 1.4.3. Nothing inside this widget can fix that — the pair is
      // declared in `tokens/colors.css` and resolved by DabblerColors.
      const Set<DabblerTheme> knownFailingInLight = <DabblerTheme>{
        DabblerTheme.shade,
      };
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors c = colorsFor(theme: theme);
        final double ratio = contrastRatio(c.onBrand, c.brandPrimary);
        if (knownFailingInLight.contains(theme)) {
          expect(
            ratio,
            lessThan(4.5),
            reason: '$theme is recorded as failing; if it now passes, the '
                'token changed and this ticket\'s reported finding is stale',
          );
        } else {
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'a selected day in $theme',
          );
        }
      }
    });

    test('the provisional dark ramp does not yet carry a selected day', () {
      // `DabblerProvisionalDark` is inferred, not signed off, and its brand
      // pairs say so: four of the seven measure under 4.5:1 for
      // `onBrand`-on-`brandPrimary`. Recorded here so the day this ramp is
      // ratified, this test fails and the record is updated rather than the
      // claim quietly going stale.
      const Set<DabblerTheme> failingInDark = <DabblerTheme>{
        DabblerTheme.main,
        DabblerTheme.sport,
        DabblerTheme.social,
        DabblerTheme.active,
      };
      for (final DabblerTheme theme in DabblerTheme.values) {
        final DabblerColors c =
            colorsFor(theme: theme, brightness: Brightness.dark);
        final double ratio = contrastRatio(c.onBrand, c.brandPrimary);
        expect(
          ratio < 4.5,
          failingInDark.contains(theme),
          reason: '$theme in dark measured $ratio',
        );
      }
    });

    test('the weekday label deviates from --muted because --muted fails AA', () {
      final DabblerColors c = colorsFor();
      // The finding this deviation is reported for: `Calendar.jsx:50` sets the
      // column labels in `--muted`, which cannot carry AA body text on a card.
      // Measured against the token itself: since D-003(a) (KAN-260)
      // `textSecondary` no longer resolves to `--muted`, so reading the source
      // token through that field would have stopped measuring the source.
      expect(
        contrastRatio(DabblerPalette.muted, c.surfaceCard),
        lessThan(4.5),
      );
      // What is drawn instead.
      expect(
        contrastRatio(c.textPrimary, c.surfaceCard),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('an outside day is the only sub-4.5 foreground, and is inert', (
      WidgetTester tester,
    ) async {
      // WCAG 1.4.3 exempts inactive user-interface components. The exemption
      // only holds while the cell really is inert, which is what is asserted.
      DateTime? picked;
      final DabblerCalendarCell outside = DabblerCalendarMonth.cellsFor(
        specimenMonth,
      ).firstWhere((DabblerCalendarCell c) => c.outside);
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            onSelect: (DateTime d) => picked = d,
          ),
        ),
      );
      final Text text = tester.widget<Text>(
        find.descendant(
          of: find.byKey(DabblerCalendar.dayKey(outside.date)),
          matching: find.byType(Text),
        ),
      );
      expect(text.style!.color, colorsFor().textSecondary);
      await tester.tap(
        find.byKey(DabblerCalendar.dayKey(outside.date)),
        warnIfMissed: false,
      );
      expect(picked, isNull);
    });

    test('--subtle is never a text colour here (D-003)', () {
      // `Calendar.jsx:58` uses `var(--subtle)` for an outside day. Since
      // D-003(a) no light text role resolves to `--subtle` at all; what this
      // still guards is that the outside day is not painted in the tertiary
      // de-emphasis role either.
      final DabblerColors c = colorsFor();
      expect(c.textSecondary, isNot(c.textTertiary));
    });
  });

  group('DabblerCalendar — the DS-602 seam and the labels', () {
    testWidgets('a chip with no handler claims no affordance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(DabblerCalendar(month: specimenMonth)));
      expect(find.byKey(DabblerCalendar.monthChipKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(DabblerCalendar.monthChipKey),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('the chips carry the month and the year', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(DabblerCalendar(month: specimenMonth)));
      expect(
        renderedStrings(tester, find.byKey(DabblerCalendar.monthChipKey)),
        contains('Feb'),
      );
      expect(
        renderedStrings(tester, find.byKey(DabblerCalendar.yearChipKey)),
        contains('2078'),
      );
    });

    testWidgets('supplied labels replace the Latin defaults', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            firstWeekday: DateTime.saturday,
            weekdayLabels: const <int, String>{
              DateTime.saturday: 'س',
              DateTime.sunday: 'ح',
              DateTime.monday: 'ن',
              DateTime.tuesday: 'ث',
              DateTime.wednesday: 'ر',
              DateTime.thursday: 'خ',
              DateTime.friday: 'ج',
            },
            monthLabels: const <String>[
              '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
              'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
            ],
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        renderedStrings(tester, find.byType(DabblerCalendar)),
        containsAll(<String>['س', 'فبراير']),
      );
    });

    testWidgets('Confirm and Cancel fire', (WidgetTester tester) async {
      int confirmed = 0;
      int cancelled = 0;
      await tester.pumpWidget(
        host(
          DabblerCalendar(
            month: specimenMonth,
            onConfirm: () => confirmed++,
            onCancel: () => cancelled++,
          ),
        ),
      );
      await tester.tap(find.byKey(DabblerCalendar.confirmKey));
      await tester.tap(find.byKey(DabblerCalendar.cancelKey));
      expect(confirmed, 1);
      expect(cancelled, 1);
    });
  });
}
