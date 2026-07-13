import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/components/dabbler_text_field.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';

/// Pump a widget inside a real Dabbler theme so `context.dabbler` resolves.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 320,
  DabblerTheme theme = DabblerTheme.main,
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dabblerThemeData(theme, brightness),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(child: SizedBox(width: width, child: child)),
        ),
      ),
    ),
  );
}

OutlineInputBorder _errorBorder(WidgetTester tester) {
  final field = tester.widget<TextField>(find.byType(TextField));
  return field.decoration!.errorBorder! as OutlineInputBorder;
}

void main() {
  testWidgets('typing updates the controller and fires onChanged',
      (tester) async {
    final controller = TextEditingController();
    var last = '';
    await _pump(
      tester,
      DabblerTextField(controller: controller, onChanged: (v) => last = v),
    );

    await tester.enterText(find.byType(TextField), 'Ada');
    expect(controller.text, 'Ada');
    expect(last, 'Ada');
  });

  testWidgets('errorText renders and sets the border to the error colour',
      (tester) async {
    await _pump(
      tester,
      const DabblerTextField(label: 'Email', errorText: 'Required'),
    );

    expect(find.text('Required'), findsOneWidget);

    final expected = tester.element(find.byType(DabblerTextField)).dabbler.error;
    expect(_errorBorder(tester).borderSide.color, expected);
  });

  testWidgets('enabled: false prevents editing', (tester) async {
    await _pump(
      tester,
      const DabblerTextField(label: 'Locked', enabled: false),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('password variant obscures, and the toggle reveals it',
      (tester) async {
    await _pump(tester, const DabblerTextField.password(label: 'Password'));

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
  });

  testWidgets("search variant's clear button empties the field",
      (tester) async {
    final controller = TextEditingController(text: 'hello');
    await _pump(tester, DabblerTextField.search(controller: controller));

    // The clear (×) shows only while non-empty.
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('RTL: the prefix icon sits on the right', (tester) async {
    await _pump(
      tester,
      const DabblerTextField(prefixIcon: Icons.person_outline),
      direction: TextDirection.rtl,
    );

    final iconCenter = tester.getCenter(find.byIcon(Icons.person_outline));
    final fieldCenter = tester.getCenter(find.byType(DabblerTextField));
    // start-of-line in RTL is the right edge, so the prefix is right of centre.
    expect(iconCenter.dx, greaterThan(fieldCenter.dx));
  });
}
