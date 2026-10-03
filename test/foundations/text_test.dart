import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Text _text(WidgetTester t) => t.widget<Text>(find.byType(Text).first);

void main() {
  group('DabblerText — single run', () {
    testWidgets('defaults: body, primary tone, body weight, LTR Latin face', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerText('Hello')));
      final TextStyle s = _text(tester).style!;
      final TextStyle expected = DabblerType.body.resolve();
      expect(s.fontFamily, expected.fontFamily);
      expect(s.fontSize, DabblerType.body.fontSize);
      expect(s.height, expected.height);
      expect(s.fontWeight, DabblerType.body.fontWeight);
      expect(s.color, testColors().textPrimary);
      expect(s.fontFeatures, DabblerType.numeralFeatures);
      expect(s.decoration, TextDecoration.none);
    });

    testWidgets('weight and tone roles resolve through the tokens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText(
            'x',
            style: DabblerType.footnote,
            weight: DabblerTextWeight.semibold,
            tone: DabblerTextTone.brand,
          ),
        ),
      );
      final TextStyle s = _text(tester).style!;
      expect(s.fontSize, DabblerType.footnote.fontSize);
      expect(s.fontWeight, DabblerType.semibold);
      expect(s.color, testColors().brandPrimary);
    });

    testWidgets('every tone maps onto its colour role', (
      WidgetTester tester,
    ) async {
      final DabblerColors c = testColors();
      final Map<DabblerTextTone, Color?> expected = <DabblerTextTone, Color?>{
        DabblerTextTone.primary: c.textPrimary,
        DabblerTextTone.secondary: c.textSecondary,
        DabblerTextTone.tertiary: c.textTertiary,
        DabblerTextTone.brand: c.brandPrimary,
        DabblerTextTone.accent: c.accent,
        DabblerTextTone.onBrand: c.onBrand,
        DabblerTextTone.onAccent: c.onAccent,
        DabblerTextTone.success: c.success.strong,
        DabblerTextTone.warning: c.warning.strong,
        DabblerTextTone.error: c.error.strong,
        DabblerTextTone.info: c.info.strong,
        DabblerTextTone.inherit: null,
      };
      expect(expected.keys.toSet(), DabblerTextTone.values.toSet());
      for (final MapEntry<DabblerTextTone, Color?> e in expected.entries) {
        expect(e.key.colorIn(c), e.value, reason: e.key.name);
      }
    });

    testWidgets('inherit takes the ambient DefaultTextStyle colour', (
      WidgetTester tester,
    ) async {
      final Color ambient = testColors().onBrand;
      await tester.pumpWidget(
        host(
          DefaultTextStyle(
            style: TextStyle(color: ambient),
            child: const DabblerText('x', tone: DabblerTextTone.inherit),
          ),
        ),
      );
      expect(_text(tester).style!.color, ambient);
    });

    testWidgets('passes maxLines, overflow, align, softWrap, semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText(
            'x',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            softWrap: false,
            semanticsLabel: 'label',
          ),
        ),
      );
      final Text t = _text(tester);
      expect(t.maxLines, 2);
      expect(t.overflow, TextOverflow.ellipsis);
      expect(t.textAlign, TextAlign.center);
      expect(t.softWrap, false);
      expect(t.semanticsLabel, 'label');
    });
  });

  group('DabblerText — RTL and Arabic script', () {
    testWidgets('RTL resolves the Arabic face, size and leading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText('مرحبا', style: DabblerType.headline),
          direction: TextDirection.rtl,
        ),
      );
      final TextStyle s = _text(tester).style!;
      final TextStyle arabic = DabblerType.headline.resolve(
        DabblerTypeScript.arabic,
      );
      expect(s.fontFamily, arabic.fontFamily);
      expect(s.fontFamily, contains(DabblerType.sansArabicFamily));
      expect(s.fontSize, DabblerType.headline.arabicFontSize);
      expect(s.height, arabic.height);
    });

    testWidgets('Arabic-Indic digits render as Western digits', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerText('عدد ١٢٣'), direction: TextDirection.rtl),
      );
      expect(find.text('عدد 123'), findsOneWidget);
    });

    testWidgets('a display step in RTL takes the Arabic display face', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText('عنوان', style: DabblerType.title2),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        _text(tester).style!.fontFamily,
        contains(DabblerType.displayArabicFamily),
      );
    });
  });

  group('DabblerText.rich', () {
    testWidgets('runs override weight and tone; others inherit the base', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText.rich(
            <DabblerTextSpan>[
              DabblerTextSpan(
                '12 ',
                weight: DabblerTextWeight.heavy,
                tone: DabblerTextTone.primary,
              ),
              DabblerTextSpan('results'),
            ],
            style: DabblerType.footnote,
            tone: DabblerTextTone.secondary,
          ),
        ),
      );
      final TextSpan parent = _text(tester).textSpan! as TextSpan;
      expect(parent.style!.color, testColors().textSecondary);
      final TextSpan first = parent.children![0] as TextSpan;
      final TextSpan second = parent.children![1] as TextSpan;
      expect(first.style!.fontWeight, DabblerType.bold);
      expect(first.style!.color, testColors().textPrimary);
      expect(second.style!.color, testColors().textSecondary);
      expect(second.style!.fontWeight, DabblerType.footnote.fontWeight);
    });

    testWidgets('a run with onTap is an inline DabblerTextLink', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          DabblerText.rich(<DabblerTextSpan>[
            const DabblerTextSpan('Read the '),
            DabblerTextSpan('terms', onTap: () => taps++),
          ]),
        ),
      );
      expect(find.byType(DabblerTextLink), findsOneWidget);
      await tester.tap(find.byType(DabblerTextLink));
      expect(taps, 1);
    });

    testWidgets('rich text in RTL uses the Arabic face and Western digits', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerText.rich(<DabblerTextSpan>[
            DabblerTextSpan('٤ '),
            DabblerTextSpan('نتائج'),
          ]),
          direction: TextDirection.rtl,
        ),
      );
      final TextSpan parent = _text(tester).textSpan! as TextSpan;
      expect(parent.style!.fontFamily, contains(DabblerType.sansArabicFamily));
      expect((parent.children![0] as TextSpan).text, '4 ');
    });
  });

  test('DabblerTextWeight maps onto the --weight-* steps; heavy is bold', () {
    expect(DabblerTextWeight.regular.fontWeight, DabblerType.regular);
    expect(DabblerTextWeight.medium.fontWeight, DabblerType.medium);
    expect(DabblerTextWeight.semibold.fontWeight, DabblerType.semibold);
    expect(DabblerTextWeight.bold.fontWeight, DabblerType.bold);
    expect(DabblerTextWeight.heavy.fontWeight, DabblerType.bold);
  });
}
