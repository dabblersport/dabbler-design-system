import 'dart:io';

import 'package:dabbler_design_system/src/layout/fade.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: ThemeData(
    brightness: brightness,
    extensions: <ThemeExtension<dynamic>>[
      DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness),
    ],
  ),
  home: Directionality(
    textDirection: direction,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(width: 320, child: child),
    ),
  ),
);

LinearGradient _gradient(WidgetTester tester) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(DabblerFade),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).gradient! as LinearGradient;
}

void main() {
  test('tokens come from existing spacing', () {
    expect(DabblerFadeTokens.opaqueStop, 0.62);
    expect(DabblerFadeTokens.bottomInset, DabblerSpacing.space8);
  });

  for (final Brightness b in Brightness.values) {
    testWidgets('is page colour to transparent page colour in $b', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerFade(child: SizedBox(height: 56)), brightness: b),
      );
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: b,
      );
      final LinearGradient g = _gradient(tester);
      expect(g.begin, Alignment.bottomCenter);
      expect(g.end, Alignment.topCenter);
      expect(g.colors.first, c.bgPrimary);
      expect(g.colors[1], c.bgPrimary);
      expect(g.colors.last, c.bgPrimary.withValues(alpha: 0));
      expect(g.stops, <double>[0, 0.62, 1]);
    });
  }

  testWidgets('adds the 24px inset under its child', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerFade(child: SizedBox(height: 56))),
    );
    expect(
      tester.getSize(find.byType(DabblerFade)).height,
      56 + DabblerSpacing.space8,
    );
  });

  testWidgets('is identical and mirrored-safe under RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerFade(child: SizedBox(height: 56))),
    );
    final LinearGradient ltr = _gradient(tester);
    await tester.pumpWidget(
      _host(
        const DabblerFade(child: SizedBox(height: 56)),
        direction: TextDirection.rtl,
      ),
    );
    final LinearGradient rtl = _gradient(tester);
    expect(rtl.begin, ltr.begin);
    expect(rtl.end, ltr.end);
    expect(rtl.colors, ltr.colors);
    expect(tester.takeException(), isNull);
  });

  test('fade.dart declares no colour literal', () {
    final String code = File('lib/src/layout/fade.dart')
        .readAsLinesSync()
        .where((String l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(code.contains('Color(0x'), isFalse);
    expect(RegExp(r'(?<![A-Za-z])Colors\.').hasMatch(code), isFalse);
  });
}
