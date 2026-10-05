import 'package:dabbler_design_system/dabbler_design_system.dart';
    show DabblerColors, DabblerTheme;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, TextDirection dir) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: dir,
      child: Theme(
        data: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

void main() {
  tagTests();
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('dense chip is shorter than the default — $dir', (
      tester,
    ) async {
      Future<double> height(bool dense) async {
        await tester.pumpWidget(
          _host(DabblerChip(label: 'padel', dense: dense), dir),
        );
        return tester
            .getSize(
              find.descendant(
                of: find.byType(DabblerChip),
                matching: find.byType(DabblerSurface),
              ),
            )
            .height;
      }

      final double normal = await height(false);
      final double dense = await height(true);
      expect(dense, lessThan(normal));
      expect(dense, lessThan(34));
    });
  }
}

void tagTests() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('tag chip is shorter than dense — $dir', (tester) async {
      Future<double> height({required bool tag}) async {
        await tester.pumpWidget(
          _host(DabblerChip(label: 'Dubai', dense: !tag, tag: tag), dir),
        );
        return tester
            .getSize(
              find.descendant(
                of: find.byType(DabblerChip),
                matching: find.byType(DabblerSurface),
              ),
            )
            .height;
      }

      expect(await height(tag: true), lessThan(await height(tag: false)));
    });
  }

  testWidgets('a selected dense chip draws its label in the on-brand ink', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerChip(label: 'Today', dense: true, selected: true),
        TextDirection.ltr,
      ),
    );
    final Text t = tester.widget(find.text('Today'));
    expect(
      t.style!.color,
      DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      ).onBrand,
    );
  });
}
