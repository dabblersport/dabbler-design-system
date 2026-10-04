import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _header({
  TextDirection direction = TextDirection.ltr,
  String title = 'Games',
  String? location = 'Dubai Marina',
  VoidCallback? onLocation,
  VoidCallback? onFilter,
  int count = 3,
}) => host(
  DabblerPageHeader(
    title: title,
    locationLabel: location,
    onLocationPressed: onLocation,
    safeArea: false,
    actions: <DabblerPageHeaderAction>[
      const DabblerPageHeaderAction(
        icon: 'search-normal',
        semanticLabel: 'Search',
      ),
      DabblerPageHeaderAction(
        icon: 'filter',
        semanticLabel: 'Filters',
        onPressed: onFilter,
        count: count,
      ),
    ],
  ),
  direction: direction,
);

void main() {
  testWidgets('shows title, location and the count badge', (tester) async {
    await tester.pumpWidget(_header());
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Dubai Marina'), findsOneWidget);
    expect(find.byKey(DabblerPageHeader.badgeKey), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('no badge at zero, no location row when null', (tester) async {
    await tester.pumpWidget(_header(count: 0, location: null));
    expect(find.byKey(DabblerPageHeader.badgeKey), findsNothing);
    expect(find.text('Dubai Marina'), findsNothing);
  });

  testWidgets('location tap fires', (tester) async {
    int loc = 0;
    await tester.pumpWidget(_header(onLocation: () => loc++));
    await tester.tap(find.text('Dubai Marina'));
    expect(loc, 1);
  });

  testWidgets('filter action is named with its count and fires', (
    tester,
  ) async {
    int filter = 0;
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(_header(onFilter: () => filter++));
    await tester.tap(find.bySemanticsLabel('Filters, 3'));
    expect(filter, 1);
    handle.dispose();
  });

  testWidgets('RTL Arabic: title at the inline start (right)', (tester) async {
    await tester.pumpWidget(
      _header(
        direction: TextDirection.rtl,
        title: 'المباريات',
        location: 'مرسى دبي',
      ),
    );
    final double title = tester.getCenter(find.text('المباريات')).dx;
    final double badge = tester
        .getCenter(find.byKey(DabblerPageHeader.badgeKey))
        .dx;
    expect(title, greaterThan(badge));
    expect(find.text('مرسى دبي'), findsOneWidget);
  });
}
