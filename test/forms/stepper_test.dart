import 'package:dabbler_design_system/src/forms/field_shell.dart';
import 'package:dabbler_design_system/src/forms/stepper.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _button(String icon) => find.ancestor(
      of: find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == icon,
      ),
      matching: find.byType(SizedBox),
    );

void main() {
  group('Stepper composes the FieldShell rather than forking it', () {
    testWidgets('the chrome is DabblerFieldShell at --radius-xxl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerStepper(value: 10, label: 'players', helperText: '4–22'),
        ),
      );

      expect(find.byType(DabblerFieldShell), findsOneWidget);
      final DabblerFieldShell shell =
          tester.widget<DabblerFieldShell>(find.byType(DabblerFieldShell));
      expect(shell.radius, DabblerRadius.xxl);
      expect(
        shell.innerPadding,
        EdgeInsetsDirectional.zero,
        reason: "Stepper.jsx:73 — innerStyle {padding: 0, gap: 0}",
      );
      expect(find.text('players'), findsOneWidget);
      expect(find.text('4–22'), findsOneWidget);
      // The box is the shell's surface, not one this file paints.
      expect(
        find.descendant(
          of: find.byType(DabblerFieldShell),
          matching: find.byType(DabblerSurface),
        ),
        findsWidgets,
      );
    });

    testWidgets('the error state is the shell\'s, on the shell\'s border', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerStepper(value: 1, errorText: 'too few')),
      );

      final DabblerSurface box = tester.widget<DabblerSurface>(
        find
            .descendant(
              of: find.byType(DabblerFieldShell),
              matching: find.byType(DabblerSurface),
            )
            .first,
      );
      expect(box.borderColor, testColors().error.base);
      expect(find.text('too few'), findsOneWidget);
    });
  });

  group('Stepper geometry is the design source', () {
    testWidgets('md controls are 45 square, sm are 39', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerStepper(value: 5)));
      expect(
        tester.getSize(_button(DabblerStepper.decreaseIcon).first),
        const Size(45, 45),
      );
      expect(
        DabblerStepper.boxSizeFor(DabblerStepperSize.md),
        DabblerSizing.touchTargetMin,
      );

      await tester.pumpWidget(
        host(const DabblerStepper(value: 5, size: DabblerStepperSize.sm)),
      );
      expect(
        tester.getSize(_button(DabblerStepper.increaseIcon).first),
        const Size(39, 39),
      );
    });

    testWidgets('the glyphs are the source\'s minus and add at --icon-md', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerStepper(value: 5)));

      final List<DabblerIcon> icons = tester
          .widgetList<DabblerIcon>(find.byType(DabblerIcon))
          .toList();
      expect(icons.map((DabblerIcon i) => i.name), <String>['minus', 'add']);
      expect(icons.every((DabblerIcon i) => i.size == DabblerSizing.iconMd),
          isTrue);
    });
  });

  group('Stepper clamps, and never reports out of range', () {
    testWidgets('the buttons step and clamp', (WidgetTester tester) async {
      final List<int> reported = <int>[];
      await tester.pumpWidget(
        host(
          DabblerStepper(
            value: 5,
            min: 4,
            max: 22,
            step: 2,
            onChanged: reported.add,
          ),
        ),
      );

      await tester.tap(_button(DabblerStepper.increaseIcon).first);
      await tester.pump();
      await tester.tap(_button(DabblerStepper.decreaseIcon).first);
      await tester.pump();
      expect(reported, <int>[7, 4], reason: '5−2 = 3 is clamped to min');
    });

    testWidgets('a button at a bound is disabled and drops to tertiary', (
      WidgetTester tester,
    ) async {
      final List<int> reported = <int>[];
      await tester.pumpWidget(
        host(
          DabblerStepper(value: 4, min: 4, max: 22, onChanged: reported.add),
        ),
      );

      final DabblerColors colors = testColors();
      final DabblerIcon minus = tester.widget<DabblerIcon>(
        find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == 'minus'),
      );
      expect(minus.color, colors.textTertiary);
      final DabblerIcon add = tester.widget<DabblerIcon>(
        find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == 'add'),
      );
      expect(add.color, colors.textPrimary);

      await tester.tap(_button(DabblerStepper.decreaseIcon).first);
      await tester.pump();
      expect(reported, isEmpty);
    });

    testWidgets('typing is filtered to digits and clamped', (
      WidgetTester tester,
    ) async {
      final List<int> reported = <int>[];
      await tester.pumpWidget(
        host(
          DabblerStepper(value: 5, min: 4, max: 22, onChanged: reported.add),
        ),
      );

      await tester.enterText(find.byType(TextField), '19');
      await tester.pump();
      expect(reported.last, 19);

      await tester.enterText(find.byType(TextField), '99');
      await tester.pump();
      expect(reported.last, 22, reason: 'clamped to max');
    });
  });

  group('Stepper keyboard', () {
    testWidgets('arrow up and down step the value from the numeral', (
      WidgetTester tester,
    ) async {
      final List<int> reported = <int>[];
      await tester.pumpWidget(
        host(
          DabblerStepper(
            value: 10,
            min: 4,
            max: 22,
            onChanged: reported.add,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(reported.last, 11);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(reported.last, 9);
    });
  });

  group('Stepper is RTL-correct', () {
    testWidgets('minus and plus swap sides, and the numeral does not reorder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerStepper(value: 12), direction: TextDirection.ltr),
      );
      final double minusLtr =
          tester.getRect(_button(DabblerStepper.decreaseIcon).first).left;
      final double addLtr =
          tester.getRect(_button(DabblerStepper.increaseIcon).first).left;
      expect(minusLtr, lessThan(addLtr));

      await tester.pumpWidget(
        host(const DabblerStepper(value: 12), direction: TextDirection.rtl),
      );
      final double minusRtl =
          tester.getRect(_button(DabblerStepper.decreaseIcon).first).left;
      final double addRtl =
          tester.getRect(_button(DabblerStepper.increaseIcon).first).left;
      expect(minusRtl, greaterThan(addRtl), reason: 'flow order, mirrored');

      // The numeral itself is pinned to ltr so the digits never reorder.
      final Directionality pinned = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(DabblerStepper),
              matching: find.byType(Directionality),
            )
            .last,
      );
      expect(pinned.textDirection, TextDirection.ltr);
    });
  });

  group('Stepper semantics', () {
    testWidgets('both buttons are named and enabled-stated', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(DabblerStepper(value: 4, min: 4, max: 22, onChanged: (_) {})),
      );

      expect(find.bySemanticsLabel('Decrease'), findsOneWidget);
      expect(find.bySemanticsLabel('Increase'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Decrease')),
        matchesSemantics(
          label: 'Decrease',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
        reason: 'at min, the decrement button is genuinely disabled',
      );
      handle.dispose();
    });
  });
}
