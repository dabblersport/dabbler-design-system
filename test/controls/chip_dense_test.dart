import 'package:dabbler_design_system/dabbler_design_system.dart';
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
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('dense chip is shorter than the default — $dir', (tester) async {
      Future<double> height(bool dense) async {
        await tester.pumpWidget(
          _host(
            DabblerChip(label: 'padel', dense: dense),
            dir,
          ),
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
