import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// KAN-426 fidelity re-check: the border-outside box on the search field and
/// on the white card, which the Auth frame draws with `box-sizing: border-box`
/// and a content-sized height (the hairline adds to the box).
void main() {
  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String placeholder = rtl ? 'ابحث' : 'Search';

    group('border outside, $dir', () {
      testWidgets('search field: default 45, borderOutside 47', (
        WidgetTester tester,
      ) async {
        Future<double> height({required bool outside}) async {
          await tester.pumpWidget(
            host(
              DabblerSearchField(
                placeholder: placeholder,
                borderOutside: outside,
              ),
              direction: dir,
            ),
          );
          return tester.getSize(find.byType(DabblerSearchField)).height;
        }

        final double inside = await height(outside: false);
        final double outside = await height(outside: true);
        expect(outside, inside + 2 * DabblerSizing.borderDefault);
      });

      testWidgets('white card: borderOutside grows by twice the hairline', (
        WidgetTester tester,
      ) async {
        Future<double> height({required bool outside}) async {
          await tester.pumpWidget(
            host(
              DabblerCard(
                variant: DabblerCardVariant.white,
                borderOutside: outside,
                child: const SizedBox(height: 10),
              ),
              direction: dir,
            ),
          );
          return tester.getSize(find.byType(DabblerCard)).height;
        }

        final double inside = await height(outside: false);
        final double outside = await height(outside: true);
        expect(outside, inside + 2 * DabblerSizing.borderDefault);
      });
    });
  }
}
