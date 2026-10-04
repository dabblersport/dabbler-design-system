import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

const List<String> _en = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const List<String> _ar = <String>[
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

Widget _columns({
  List<String> months = _en,
  int? day,
  int? month,
  int? year,
  ValueChanged<int>? onDay,
  ValueChanged<int>? onMonth,
  ValueChanged<int>? onYear,
  String dayLabel = 'Day',
}) => DabblerDateColumns(
  dayLabel: dayLabel,
  monthLabel: 'Month',
  yearLabel: 'Year',
  monthNames: months,
  firstYear: 1950,
  lastYear: 2010,
  day: day,
  month: month,
  year: year,
  onDayChanged: onDay,
  onMonthChanged: onMonth,
  onYearChanged: onYear,
);

void main() {
  group('DabblerDateColumns', () {
    testWidgets('lists days from 1, months from January, years newest first', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_columns()));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('January'), findsOneWidget);
      expect(find.text('2010'), findsOneWidget);
      expect(find.text('DAY'), findsOneWidget);
      expect(find.text('MONTH'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
    });

    testWidgets('tapping an option reports its value', (
      WidgetTester tester,
    ) async {
      final List<int> days = <int>[];
      final List<int> months = <int>[];
      final List<int> years = <int>[];
      await tester.pumpWidget(
        host(_columns(onDay: days.add, onMonth: months.add, onYear: years.add)),
      );
      await tester.tap(find.text('2'));
      await tester.tap(find.text('March'));
      await tester.tap(find.text('2009'));
      expect(days, <int>[2]);
      expect(months, <int>[3]);
      expect(years, <int>[2009]);
    });

    testWidgets('the chosen option is brand-filled with on-brand text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(_columns(day: 2, month: 1, year: 2010)));
      final DabblerColors colors = testColors();
      final Text chosen = tester.widget<Text>(find.text('2010'));
      expect(chosen.style?.color, colors.onBrand);
      expect(chosen.style?.fontWeight, DabblerType.semibold);
      final Text plain = tester.widget<Text>(find.text('2009'));
      expect(plain.style?.color, colors.textPrimary);
      expect(
        find.ancestor(
          of: find.text('2010'),
          matching: find.byWidgetPredicate(
            (Widget w) => w is DabblerSurface && w.fill == colors.brandPrimary,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('semantics: a button with a selected state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(_columns(year: 2010, onYear: (_) {})));
      expect(
        tester.getSemantics(find.text('2010')),
        isSemantics(
          label: '2010',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('columns run in reading order ($dir)', (
        WidgetTester tester,
      ) async {
        final bool rtl = dir == TextDirection.rtl;
        await tester.pumpWidget(
          host(
            _columns(months: rtl ? _ar : _en, dayLabel: rtl ? 'اليوم' : 'Day'),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        final double day = tester.getCenter(find.text('1')).dx;
        final double year = tester.getCenter(find.text('2010')).dx;
        expect(rtl ? day > year : day < year, isTrue);
        if (rtl) expect(find.text('يناير'), findsOneWidget);
      });
    }
  });
}
