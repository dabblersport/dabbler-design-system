import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433: the Home city sheet's search field (42) and area row (62), drawn.
/// Arabic strings are the Arabic frame's own (`Home Feed.dc.html`).
final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, TextDirection d) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  home: Directionality(
    textDirection: d,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 355, child: child),
      ),
    ),
  ),
);

void main() {
  for (final TextDirection d in TextDirection.values) {
    final bool rtl = d == TextDirection.rtl;
    testWidgets('search field drawn is 42 high with a 16 glyph, $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerSearchField(
            metrics: DabblerFeedMetrics.drawn,
            placeholder: 'Search area, street or city',
          ),
          d,
        ),
      );
      expect(tester.getSize(find.byType(DabblerSurface).first).height, 42);
      expect(tester.getSize(find.byType(DabblerIcon)), const Size(16, 16));
      final Rect box = tester.getRect(find.byType(DabblerSurface).first);
      final Rect glyph = tester.getRect(find.byType(DabblerIcon));
      // 15 of padding inside the 1px hairline.
      expect(rtl ? box.right - glyph.right : glyph.left - box.left, 16);
    });

    testWidgets('search field default stays 45, $d', (tester) async {
      await tester.pumpWidget(
        _host(const DabblerSearchField(placeholder: 'x'), d),
      );
      expect(tester.getSize(find.byType(DabblerSurface).first).height, 45);
    });

    testWidgets('flat list row with a subtitle is 1 taller drawn, $d', (
      tester,
    ) async {
      Widget row(DabblerFeedMetrics m) => DabblerListRow(
        flat: true,
        metrics: m,
        title: rtl ? 'ند الشبا' : 'Nad Al Sheba',
        subtitle: 'Dubai',
        leading: const DabblerIcon('location', size: 20),
      );
      await tester.pumpWidget(_host(row(DabblerFeedMetrics.touch), d));
      final double touch = tester.getSize(find.byType(DabblerListRow)).height;
      await tester.pumpWidget(_host(row(DabblerFeedMetrics.drawn), d));
      final double drawn = tester.getSize(find.byType(DabblerListRow)).height;
      expect(drawn, touch + 1);
      expect(touch, rtl ? 64 : 61);
    });
  }
}
