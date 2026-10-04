import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _rail({
  TextDirection direction = TextDirection.ltr,
  List<String> labels = const <String>['Within 5 km', 'Today'],
  List<String>? removed,
  VoidCallback? onClearAll,
}) => host(
  DabblerFilterRail(
    items: <DabblerFilterRailItem>[
      for (final String l in labels)
        DabblerFilterRailItem(label: l, onRemove: () => removed?.add(l)),
    ],
    clearAllLabel: direction == TextDirection.rtl ? 'مسح الكل' : 'Clear all',
    onClearAll: onClearAll,
  ),
  direction: direction,
);

void main() {
  testWidgets('draws a chip per filter and Clear all', (tester) async {
    await tester.pumpWidget(_rail(onClearAll: () {}));
    expect(find.text('Within 5 km'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.byKey(DabblerFilterRail.clearAllKey), findsOneWidget);
  });

  testWidgets('renders nothing when empty', (tester) async {
    await tester.pumpWidget(_rail(labels: const <String>[]));
    expect(find.byType(DabblerChip), findsNothing);
  });

  testWidgets('Clear all fires and is hidden without a handler', (
    tester,
  ) async {
    int n = 0;
    await tester.pumpWidget(_rail(onClearAll: () => n++));
    await tester.ensureVisible(find.byKey(DabblerFilterRail.clearAllKey));
    await tester.pump();
    await tester.tap(find.byKey(DabblerFilterRail.clearAllKey));
    expect(n, 1);
    await tester.pumpWidget(_rail());
    expect(find.byKey(DabblerFilterRail.clearAllKey), findsNothing);
  });

  testWidgets('RTL Arabic: first chip at the right, Clear all at the left', (
    tester,
  ) async {
    await tester.pumpWidget(
      _rail(
        direction: TextDirection.rtl,
        labels: const <String>['ضمن 5 كم', 'اليوم'],
        onClearAll: () {},
      ),
    );
    final double first = tester.getCenter(find.text('ضمن 5 كم')).dx;
    final double clear = tester
        .getCenter(find.byKey(DabblerFilterRail.clearAllKey))
        .dx;
    expect(first, greaterThan(clear));
  });

  testWidgets('FilterGroup shows caption and chips', (tester) async {
    await tester.pumpWidget(
      host(
        const DabblerFilterGroup(
          label: 'التاريخ',
          children: <Widget>[DabblerChip(label: 'اليوم')],
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(find.text('التاريخ'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
  });
}
