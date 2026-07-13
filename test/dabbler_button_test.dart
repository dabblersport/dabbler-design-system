import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/components/dabbler_button.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';

/// Pump a button inside a real Dabbler theme so `context.dabbler` resolves.
Future<void> _pump(
  WidgetTester tester,
  Widget button, {
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dabblerThemeData(theme, brightness),
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

void main() {
  testWidgets('renders its label', (tester) async {
    await _pump(tester, DabblerButton(label: 'Join game', onPressed: () {}));
    expect(find.text('Join game'), findsOneWidget);
  });

  testWidgets('onPressed fires on tap', (tester) async {
    var taps = 0;
    await _pump(tester, DabblerButton(label: 'Tap', onPressed: () => taps++));
    await tester.tap(find.byType(DabblerButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('onPressed: null renders disabled and does NOT fire',
      (tester) async {
    var taps = 0;
    // onPressed defaults to null → the disabled contract.
    await _pump(tester, const DabblerButton(label: 'Nope'));
    await tester.tap(find.byType(DabblerButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);

    // Disabled draws at half opacity.
    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.text('Nope'),
        matching: find.byType(Opacity),
      ).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('isLoading shows a progress indicator and swallows taps',
      (tester) async {
    var taps = 0;
    await _pump(
      tester,
      DabblerButton(label: 'Loading', isLoading: true, onPressed: () => taps++),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(DabblerButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('height matches the size step (36 / 45 / 54)', (tester) async {
    const expected = {
      DabblerButtonSize.small: 36.0,
      DabblerButtonSize.medium: 45.0,
      DabblerButtonSize.large: 54.0,
    };

    for (final entry in expected.entries) {
      await _pump(
        tester,
        DabblerButton(label: 'Size', size: entry.key, onPressed: () {}),
      );
      final size = tester.getSize(find.byKey(DabblerButton.surfaceKey));
      expect(size.height, entry.value,
          reason: '${entry.key.name} should be ${entry.value}px tall');
    }
  });

  testWidgets('filled label uses onBrand on a light-primary theme (Bright)',
      (tester) async {
    // Bright's primary is light, so onBrand is DARK. The label must read the
    // token, not a hardcoded white — this is the core correctness guarantee.
    await _pump(
      tester,
      DabblerButton(label: 'Go', onPressed: () {}),
      theme: DabblerTheme.bright,
    );

    final text = tester.widget<Text>(find.text('Go'));
    final labelColor = text.style!.color!;

    final ctx = tester.element(find.byType(DabblerButton));
    final onBrand = ctx.dabbler.onBrand;
    expect(labelColor, onBrand);
    // And it is genuinely dark (luminance well below mid), i.e. legible on the
    // light primary — a hardcoded white would fail this.
    expect(labelColor.computeLuminance(), lessThan(0.5));
  });
}
