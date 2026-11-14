// KAN-946: a long group label ellipsizes instead of overflowing a narrow row.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  ),
);

void main() {
  const String en =
      'Yesterday · Fri 13 Nov · 4 events and many more after that';
  const String ar =
      'أمس · الجمعة ١٣ نوفمبر · ٤ فعاليات وغيرها الكثير بعد ذلك أيضاً';

  for (final (String label, TextDirection dir) in <(String, TextDirection)>[
    (en, TextDirection.ltr),
    (ar, TextDirection.rtl),
  ]) {
    testWidgets('a long ${dir.name} label ellipsizes at 320px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(DabblerActivityGroupHeader(label, count: '4 items'), dir),
      );
      expect(tester.takeException(), isNull);

      final RenderParagraph p = tester.renderObject<RenderParagraph>(
        find.text(label),
      );
      expect(p.overflow, TextOverflow.ellipsis);
      expect(p.didExceedMaxLines, isTrue);
      expect(find.text('4 items'), findsOneWidget);
      expect(
        tester.getSize(find.byType(DabblerActivityGroupHeader)).width,
        320,
      );
    });
  }

  testWidgets('a short label keeps its width and the hairline fills the rest', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerActivityGroupHeader('Today'), TextDirection.ltr),
    );
    expect(tester.takeException(), isNull);
    final RenderParagraph p = tester.renderObject<RenderParagraph>(
      find.text('Today'),
    );
    expect(p.didExceedMaxLines, isFalse);
    final double hairline = tester
        .getSize(
          find
              .descendant(
                of: find.byType(DabblerActivityGroupHeader),
                matching: find.byType(ColoredBox),
              )
              .last,
        )
        .width;
    expect(hairline, 320 - p.size.width - DabblerSpacing.space3);
  });
}
