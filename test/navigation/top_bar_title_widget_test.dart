import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(TextDirection dir) => Directionality(
  textDirection: dir,
  child: Theme(
    data: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        DabblerColors.resolve(
          theme: DabblerTheme.main,
          brightness: Brightness.light,
        ),
      ],
    ),
    child: MediaQuery(
      data: const MediaQueryData(),
      child: DabblerNavigationTopBar.titled(
        onBack: () {},
        safeArea: false,
        titleWidget: const SizedBox(key: Key('slot'), height: 45),
      ),
    ),
  ),
);

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('titleWidget takes the title slot beside back ($dir)', (
      tester,
    ) async {
      await tester.pumpWidget(_host(dir));
      final Rect slot = tester.getRect(find.byKey(const Key('slot')));
      final Rect back = tester.getRect(find.bySemanticsLabel('Back'));
      expect(slot.width, greaterThan(100));
      if (dir == TextDirection.ltr) {
        expect(slot.left, greaterThanOrEqualTo(back.right));
      } else {
        expect(slot.right, lessThanOrEqualTo(back.left));
      }
    });
  }
}
