import 'package:dabbler_design_system/src/controls/chip.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    for (final bool selected in <bool>[true, false]) {
      testWidgets('count pill draws — $dir selected=$selected', (tester) async {
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
            home: Directionality(
              textDirection: dir,
              child: Scaffold(
                body: DabblerChip(
                  label: 'Games',
                  count: '5',
                  selected: selected,
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('5'), findsOneWidget);
      });
    }
  }
}
