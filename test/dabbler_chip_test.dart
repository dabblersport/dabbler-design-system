import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/components/dabbler_chip.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  DabblerTheme theme = DabblerTheme.main,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dabblerThemeData(theme, Brightness.light),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('chip renders its label and fires onTap', (tester) async {
    var taps = 0;
    await _pump(tester, DabblerChip(label: 'Near me', onTap: () => taps++));
    expect(find.text('Near me'), findsOneWidget);

    await tester.tap(find.byType(DabblerChip));
    await tester.pump();
    expect(taps, 1);

    // Tap area clears the 45px floor even though the chip is visually smaller.
    expect(
      tester.getSize(find.byType(GestureDetector).first).height,
      greaterThanOrEqualTo(45),
    );
  });

  testWidgets('selected chip label reads onBrand — dark in Bright',
      (tester) async {
    await _pump(
      tester,
      DabblerChip(label: 'Go', selected: true, onTap: () {}),
      theme: DabblerTheme.bright,
    );

    final text = tester.widget<Text>(find.text('Go'));
    final ctx = tester.element(find.byType(DabblerChip));
    expect(text.style!.color, ctx.dabbler.onBrand);
    // Bright has a light primary → the selected label must be dark.
    expect(text.style!.color!.computeLuminance(), lessThan(0.5));
  });

  testWidgets('icon tile is a 45px square with a brand-tinted icon',
      (tester) async {
    await _pump(tester, const DabblerIconTile(icon: Icons.sports_soccer));
    final size = tester.getSize(find.byType(DabblerIconTile));
    expect(size.width, 45);
    expect(size.height, 45);

    final ctx = tester.element(find.byType(DabblerIconTile));
    final icon = tester.widget<Icon>(find.byIcon(Icons.sports_soccer));
    expect(icon.color, ctx.dabbler.brandPrimary);
  });
}
