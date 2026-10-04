import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/forms/toggle.dart';
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
    testWidgets('toggle in a tappable row lays out at 28 — $dir', (t) async {
      await t.pumpWidget(
        _host(
          DabblerInputRow(
            flat: true,
            showDivider: false,
            title: 'Push',
            subtitle: 'Receive pushes',
            onTap: () {},
            trailing: DabblerToggle(checked: true, onChanged: (_) {}),
          ),
          dir,
        ),
      );
      expect(t.getSize(find.byType(DabblerToggle)).height, 28);
    });

    testWidgets('a bare toggle keeps the 45 target — $dir', (t) async {
      await t.pumpWidget(
        _host(
          Center(child: DabblerToggle(checked: true, onChanged: (_) {})),
          dir,
        ),
      );
      expect(t.getSize(find.byType(DabblerToggle)).height, 45);
    });

    testWidgets('toggle in a non-tappable row keeps 45 — $dir', (t) async {
      await t.pumpWidget(
        _host(
          DabblerInputRow(
            flat: true,
            showDivider: false,
            title: 'Push',
            trailing: DabblerToggle(checked: true, onChanged: (_) {}),
          ),
          dir,
        ),
      );
      expect(t.getSize(find.byType(DabblerToggle)).height, 45);
    });
  }
}
