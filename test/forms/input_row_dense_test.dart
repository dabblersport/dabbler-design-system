import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, TextDirection dir) => MaterialApp(
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
    child: Scaffold(body: child),
  ),
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('dense row: 20 + 2 + 17 text in 12-point padding — $dir', (
      t,
    ) async {
      await t.pumpWidget(
        _host(
          const DabblerInputRow(
            flat: true,
            showDivider: false,
            dense: true,
            title: 'Push notifications',
            subtitle: 'Receive push notifications on your device',
          ),
          dir,
        ),
      );
      // 20 + 2 + 17 of text in 24 of padding; the test font rounds a line
      // by a point in one direction.
      expect(t.getSize(find.byType(DabblerInputRow)).height, closeTo(63, 2));
    });

    testWidgets('dense row with one line keeps the 56 floor — $dir', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerInputRow(
            flat: true,
            showDivider: false,
            dense: true,
            title: 'Language',
          ),
          dir,
        ),
      );
      expect(t.getSize(find.byType(DabblerInputRow)).height, 56);
    });
  }
}
