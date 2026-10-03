import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const List<DabblerSortOption<String>> _opts = <DabblerSortOption<String>>[
  DabblerSortOption<String>(value: 'near', label: 'Nearest'),
  DabblerSortOption<String>(value: 'soon', label: 'Starting soonest'),
  DabblerSortOption<String>(value: 'price', label: 'Lowest price'),
];

Widget _control(
  List<String> got, {
  DabblerSortControlVariant variant = DabblerSortControlVariant.sheet,
  TextDirection direction = TextDirection.ltr,
}) => host(
  DabblerSortControl<String>(
    label: 'Sort by',
    options: _opts,
    value: 'near',
    variant: variant,
    onChanged: got.add,
  ),
  direction: direction,
);

void main() {
  group('DabblerSortControl — sheet', () {
    testWidgets('trigger shows label and current value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_control(<String>[]));
      expect(find.text('Sort by: Nearest'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Sort by, Nearest')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('opens a sheet; picking reports and closes ($dir)', (
        WidgetTester tester,
      ) async {
        final List<String> got = <String>[];
        await tester.pumpWidget(_control(got, direction: dir));
        await tester.tap(find.byType(DabblerChip));
        await tester.pumpAndSettle();
        expect(find.byType(DabblerSheet), findsOneWidget);
        expect(find.byType(DabblerMenuList), findsOneWidget);
        // The selected row carries the check.
        expect(
          find.descendant(
            of: find.byType(DabblerMenuList),
            matching: find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'tick-circle',
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Lowest price'));
        await tester.pumpAndSettle();
        expect(got, <String>['price']);
        expect(find.byType(DabblerSheet), findsNothing);
      });
    }

    testWidgets('picking the selected option does not report', (
      WidgetTester tester,
    ) async {
      final List<String> got = <String>[];
      await tester.pumpWidget(_control(got));
      await tester.tap(find.byType(DabblerChip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nearest').last);
      await tester.pumpAndSettle();
      expect(got, isEmpty);
    });
  });

  group('DabblerSortControl — segmented', () {
    testWidgets('one chip per option, the selected one filled', (
      WidgetTester tester,
    ) async {
      final List<String> got = <String>[];
      await tester.pumpWidget(
        _control(got, variant: DabblerSortControlVariant.segmented),
      );
      final List<DabblerChip> chips = tester
          .widgetList<DabblerChip>(find.byType(DabblerChip))
          .toList();
      expect(chips.length, 3);
      expect(chips.map((DabblerChip c) => c.selected), <bool>[
        true,
        false,
        false,
      ]);
      await tester.tap(find.text('Starting soonest'));
      expect(got, <String>['soon']);
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('chips run from the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _control(
            <String>[],
            variant: DabblerSortControlVariant.segmented,
            direction: dir,
          ),
        );
        final double a = tester.getCenter(find.text('Nearest')).dx;
        final double b = tester.getCenter(find.text('Starting soonest')).dx;
        expect(dir == TextDirection.ltr ? a < b : a > b, true);
      });
    }
  });
}
