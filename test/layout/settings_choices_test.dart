import 'package:dabbler_design_system/src/layout/settings_choices.dart';
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
    testWidgets('preset card selects and reports taps — $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              DabblerPresetCard(
                icon: 'lock',
                title: 'Public',
                description: 'Everyone can see',
                selected: true,
                onTap: () => taps++,
              ),
              DabblerPresetCard(
                icon: 'people',
                title: 'Friends',
                description: 'Friends only',
                onTap: () => taps++,
              ),
            ],
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Friends'));
      expect(taps, 1);
      expect(find.text('Everyone can see'), findsOneWidget);
    });

    testWidgets('option segments report the tapped id — $dir', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(
          DabblerOptionSegments(
            value: 'dark',
            onChanged: (String id) => picked = id,
            items: const <DabblerOptionSegment>[
              DabblerOptionSegment(id: 'light', label: 'Light', icon: 'lock'),
              DabblerOptionSegment(id: 'dark', label: 'Dark', icon: 'lock'),
              DabblerOptionSegment(id: 'system', label: 'System', icon: 'lock'),
            ],
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('System'));
      expect(picked, 'system');
    });

    testWidgets('stacked group draws its heading over loose children — $dir', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerRowGroup.stack(
            header: 'Theme',
            note: 'Pick one',
            children: <Widget>[Text('one'), Text('two')],
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('option row reports taps — $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DabblerOptionRow(
            label: 'Anyone',
            selected: true,
            onTap: () => taps++,
          ),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Anyone'));
      expect(taps, 1);
    });

    testWidgets('hint renders its text — $dir', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerSettingsHint(text: 'Changes save automatically.'),
          dir,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Changes save automatically.'), findsOneWidget);
    });
  }
}
