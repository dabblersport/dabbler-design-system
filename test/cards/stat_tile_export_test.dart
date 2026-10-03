// KAN-412 item 4: fails to compile if DabblerStatTile / DabblerStatGrid stop
// being exported from the public barrel.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatTile and StatGrid construct through the barrel (RTL)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            DabblerColors.resolve(
              theme: DabblerTheme.main,
              brightness: Brightness.light,
            ),
          ],
        ),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: DabblerStatGrid(
              children: <DabblerStatTile>[
                DabblerStatTile(value: '12', label: 'Games'),
                DabblerStatTile(value: '4', label: 'Wins'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(DabblerStatGrid), findsOneWidget);
    expect(find.byType(DabblerStatTile), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
