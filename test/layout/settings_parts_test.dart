import 'package:dabbler_design_system/src/cards/stat_tile.dart';
import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/layout/settings_parts.dart';
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
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('header and group render — $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              DabblerSettingsHeader(
                versionLabel: 'Version 1.7.8',
                title: 'Settings',
                subtitle: 'Manage everything',
                identity: DabblerInputRow(
                  flat: true,
                  showDivider: false,
                  title: 'me@example.com',
                  onTap: () => taps++,
                ),
              ),
              DabblerRowGroup(
                header: 'Account',
                note: 'Note',
                children: <Widget>[
                  DabblerInputRow(
                    flat: true,
                    showDivider: false,
                    title: 'One',
                    onTap: () => taps++,
                  ),
                  const DabblerInputRow(
                    flat: true,
                    showDivider: false,
                    title: 'Two',
                  ),
                ],
              ),
            ],
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('One'));
      await tester.tap(find.text('me@example.com'));
      expect(taps, 2);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('colour dots render — $dir', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerColorDots(
            colors: <Color>[Color(0xFF111111), Color(0xFF222222)],
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('setting stat tile renders — $dir', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 170,
            height: 100,
            child: DabblerStatTile(
              value: '4/8',
              label: 'Shown on your profile',
              size: DabblerStatTileSize.setting,
            ),
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('4/8'), findsOneWidget);
    });
  }

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('hint and action — $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              const DabblerRowHint(text: 'Nothing here'),
              DabblerRowAction(label: 'Unblock', onPressed: () => taps++),
            ],
          ),
          dir,
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
      await tester.tap(find.text('Unblock'));
      expect(taps, 1);
    });
  }
}
