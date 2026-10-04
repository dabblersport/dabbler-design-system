import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

double _boxHeight(WidgetTester tester) =>
    tester.getSize(find.byType(DabblerTextField)).height;

void main() {
  group('DabblerTextField password height', () {
    testWidgets(
      'the toggle keeps its 45px target without stretching the box past 45',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const DabblerTextField(placeholder: 'Email')),
        );
        final double standard = _boxHeight(tester);

        await tester.pumpWidget(
          host(
            const DabblerTextField(
              variant: DabblerTextFieldVariant.password,
              placeholder: 'Password',
            ),
          ),
        );
        expect(_boxHeight(tester), standard);
        expect(
          tester.getSize(find.bySemanticsLabel('Show password')).height,
          DabblerSizing.touchTargetMin,
        );
      },
    );

    testWidgets('the same in right-to-left and with a label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTextField(label: 'الإيميل', placeholder: 'x'),
          direction: TextDirection.rtl,
        ),
      );
      final double standard = tester
          .getSize(find.byType(DabblerTextField))
          .height;
      await tester.pumpWidget(
        host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.password,
            label: 'كلمة السر',
            placeholder: 'x',
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.getSize(find.byType(DabblerTextField)).height, standard);
    });
  });
}
