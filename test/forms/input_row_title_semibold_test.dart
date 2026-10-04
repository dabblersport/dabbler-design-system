import 'package:dabbler_design_system/src/forms/input_row.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('titleSemibold sets the title weight — $dir', (tester) async {
      Future<FontWeight?> pump(bool semibold) async {
        await tester.pumpWidget(
          host(
            DabblerInputRow(title: 'Ahmed', titleSemibold: semibold),
            direction: dir,
          ),
        );
        final Text t = tester.widget<Text>(find.text('Ahmed'));
        return t.style?.fontWeight;
      }

      expect(await pump(true), DabblerType.semibold);
      expect(await pump(false), isNot(DabblerType.semibold));
    });
  }
}
