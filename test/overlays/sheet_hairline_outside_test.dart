import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433: `hairlineOutside` starts the content 1 in and 1 down, as the Home
/// Feed frame's content-box sheet does (content x 19, grabber y +1).
Widget _host(bool outside, TextDirection d) => MediaQuery(
  data: const MediaQueryData(
    size: Size(393, 852),
    disableAnimations: true,
  ),
  child: Directionality(
    textDirection: d,
    child: Theme(
      data: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      child: DabblerSheet(
        open: true,
        hairlineOutside: outside,
        child: const SizedBox(key: Key('c'), height: 20),
      ),
    ),
  ),
);

void main() {
  for (final TextDirection d in TextDirection.values) {
    testWidgets('content moves 1 in and 1 down, $d', (tester) async {
      await tester.pumpWidget(_host(false, d));
      await tester.pump(const Duration(seconds: 1));
      final Rect a = tester.getRect(find.byKey(const Key('c')));
      await tester.pumpWidget(_host(true, d));
      await tester.pump(const Duration(seconds: 1));
      final Rect b = tester.getRect(find.byKey(const Key('c')));
      expect(b.width, a.width - 2);
      expect(b.left, a.left + 1);
      // The panel is bottom-anchored: it grows by the 1 above it.
      expect(b.bottom - b.top, a.bottom - a.top);
    });
  }
}
