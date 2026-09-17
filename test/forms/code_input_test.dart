import 'dart:io';

import 'package:dabbler_design_system/src/forms/code_input.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/surfaces/surface.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors({Brightness brightness = Brightness.light}) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: brightness);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[_colors(brightness: brightness)],
    ),
    home: Directionality(
      textDirection: direction,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// The box surfaces, in the order they are laid out in the widget tree, which
/// under the pinned LTR direction is also digit order.
List<DabblerSurface> _boxes(WidgetTester tester) => tester
    .widgetList<DabblerSurface>(
      find.descendant(
        of: find.byType(DabblerCodeInput),
        matching: find.byType(DabblerSurface),
      ),
    )
    .toList();

Finder _field(int index) => find
    .descendant(
      of: find.byType(DabblerCodeInput),
      matching: find.byType(EditableText),
    )
    .at(index);

void main() {
  group('KAN-247 AC1 — a fixed-length array of boxes', () {
    testWidgets('renders one box per digit, six by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput()));
      expect(_boxes(tester), hasLength(DabblerCodeInput.defaultLength));
      expect(DabblerCodeInput.defaultLength, 6);
    });

    testWidgets('length drives the box count', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      expect(_boxes(tester), hasLength(4));
      expect(
        find.descendant(
          of: find.byType(DabblerCodeInput),
          matching: find.byType(EditableText),
        ),
        findsNWidgets(4),
      );
    });

    testWidgets('every box is 45×54 with --radius-lg and a 1px hairline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      for (final DabblerSurface box in _boxes(tester)) {
        expect(box.width, DabblerSizing.touchTargetMin);
        expect(box.width, 45);
        expect(box.height, 54);
        expect(box.radius, DabblerRadius.lg);
        expect(box.borderWidth, DabblerSizing.borderDefault);
      }
      for (int i = 0; i < 4; i++) {
        final Size size = tester.getSize(
          find
              .descendant(
                of: find.byType(DabblerCodeInput),
                matching: find.byType(DabblerSurface),
              )
              .at(i),
        );
        expect(size, const Size(45, 54));
      }
    });

    testWidgets('the gap between boxes is --space-2 (6)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 3)));
      final Finder boxes = find.descendant(
        of: find.byType(DabblerCodeInput),
        matching: find.byType(DabblerSurface),
      );
      final Rect first = tester.getRect(boxes.at(0));
      final Rect second = tester.getRect(boxes.at(1));
      expect(second.left - first.right, DabblerSpacing.space2);
      expect(DabblerCodeInput.boxGap, 6);
    });

    testWidgets('digits render at .t-title-3 with lining numerals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(value: '12')));
      final EditableText first = tester.widget<EditableText>(_field(0));
      expect(first.style.fontSize, DabblerType.title3.fontSize);
      expect(first.style.fontSize, 20);
      expect(first.style.height! * first.style.fontSize!, closeTo(25, 0.01));
      expect(first.style.fontFeatures, DabblerType.numeralFeatures);
    });
  });

  group('the value is a string and the boxes are a view of it', () {
    testWidgets('a supplied value fills the boxes in order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '4207')),
      );
      for (int i = 0; i < 4; i++) {
        expect(tester.widget<EditableText>(_field(i)).controller.text, '4207'[i]);
      }
    });

    test('sanitize strips non-digits and caps at length', () {
      expect(DabblerCodeInput.sanitize('12-34', 4), '1234');
      expect(DabblerCodeInput.sanitize('a1b2c3', 6), '123');
      expect(DabblerCodeInput.sanitize('1234567', 4), '1234');
      expect(DabblerCodeInput.sanitize(null, 6), '');
    });

    testWidgets('non-digits are ignored on entry', (WidgetTester tester) async {
      String? seen;
      await tester.pumpWidget(
        _host(DabblerCodeInput(length: 4, onChanged: (String v) => seen = v)),
      );
      await tester.enterText(_field(0), 'x');
      await tester.pump();
      expect(seen, isNull);
    });
  });

  group('input behaviour — the four behaviours the ticket names', () {
    testWidgets('typing a digit advances focus to the next box', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(DabblerCodeInput(length: 4, onChanged: changes.add)),
      );
      await tester.tap(_field(0));
      await tester.pump();

      await tester.enterText(_field(0), '7');
      await tester.pumpAndSettle();

      expect(changes, <String>['7']);
      expect(
        tester.widget<EditableText>(_field(1)).focusNode.hasFocus,
        isTrue,
        reason: 'entry must move to the next box',
      );
    });

    testWidgets('the last box does not advance past the end', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 3, value: '12')),
      );
      await tester.enterText(_field(2), '3');
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(2)).focusNode.hasFocus, isTrue);
    });

    testWidgets('backspace clears the current box', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(length: 4, value: '1234', onChanged: changes.add),
        ),
      );
      await tester.tap(_field(3));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(changes.last, '123');
      expect(tester.widget<EditableText>(_field(3)).controller.text, '');
    });

    testWidgets('backspace on an empty box retreats and clears the previous', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(DabblerCodeInput(length: 4, value: '12', onChanged: changes.add)),
      );
      await tester.tap(_field(2));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(2)).controller.text, '');

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(changes.last, '1', reason: 'the previous digit is cleared');
      expect(
        tester.widget<EditableText>(_field(1)).focusNode.hasFocus,
        isTrue,
        reason: 'focus steps back to the box it cleared',
      );
    });

    testWidgets('backspace on the first, empty box does nothing', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(DabblerCodeInput(length: 4, onChanged: changes.add)),
      );
      await tester.tap(_field(0));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('pasting a whole code distributes it across the boxes', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(DabblerCodeInput(onChanged: changes.add)),
      );
      await tester.tap(_field(0));
      await tester.pump();

      // A paste into one box arrives as a multi-character edit, which is
      // exactly why the source sets maxLength to `length` and not to 1.
      await tester.enterText(_field(0), '481516');
      await tester.pumpAndSettle();

      expect(changes.last, '481516');
      for (int i = 0; i < 6; i++) {
        expect(
          tester.widget<EditableText>(_field(i)).controller.text,
          '481516'[i],
        );
      }
    });

    testWidgets('a paste from the middle fills forward and stops at the end', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(length: 4, value: '9', onChanged: changes.add),
        ),
      );
      await tester.enterText(_field(1), '12345');
      await tester.pumpAndSettle();
      expect(changes.last, '9123');
    });

    testWidgets('a full code fires onCompleted after onChanged', (
      WidgetTester tester,
    ) async {
      final List<String> order = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(
            length: 4,
            value: '123',
            onChanged: (String v) => order.add('changed:$v'),
            onCompleted: (String v) => order.add('completed:$v'),
          ),
        ),
      );
      await tester.enterText(_field(3), '4');
      await tester.pumpAndSettle();
      expect(order, <String>['changed:1234', 'completed:1234']);
    });

    testWidgets('an incomplete code never fires onCompleted', (
      WidgetTester tester,
    ) async {
      bool completed = false;
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(length: 4, onCompleted: (_) => completed = true),
        ),
      );
      await tester.enterText(_field(0), '1');
      await tester.pumpAndSettle();
      expect(completed, isFalse);
    });

    testWidgets('arrow keys move between boxes', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      await tester.tap(_field(2));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(1)).focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(3)).focusNode.hasFocus, isTrue);

      // Clamped at both ends, as `focusBox` is.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(3)).focusNode.hasFocus, isTrue);
    });
  });

  group('the RTL exception — the boxes do not mirror', () {
    testWidgets('digit 1 is leftmost under Directionality.rtl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCodeInput(length: 4, value: '1234'),
          direction: TextDirection.rtl,
        ),
      );

      final Finder boxes = find.descendant(
        of: find.byType(DabblerCodeInput),
        matching: find.byType(DabblerSurface),
      );
      double previousLeft = -1;
      for (int i = 0; i < 4; i++) {
        final Rect rect = tester.getRect(boxes.at(i));
        expect(
          rect.left,
          greaterThan(previousLeft),
          reason: 'box ${i + 1} must sit to the right of box $i, in RTL too',
        );
        previousLeft = rect.left;
        expect(
          tester.widget<EditableText>(_field(i)).controller.text,
          '1234'[i],
          reason: 'the digit order is the value order',
        );
      }
    });

    testWidgets('the row is pinned to LTR, not merely laid out that way', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCodeInput(length: 3),
          direction: TextDirection.rtl,
        ),
      );
      final Directionality pinned = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(DabblerCodeInput),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(pinned.textDirection, TextDirection.ltr);
    });

    testWidgets('entry and backspace keep their order under RTL', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(length: 4, onChanged: changes.add),
          direction: TextDirection.rtl,
        ),
      );
      await tester.enterText(_field(0), '5');
      await tester.pumpAndSettle();
      expect(changes.last, '5');
      expect(tester.widget<EditableText>(_field(1)).focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(changes.last, '');
      expect(
        tester.widget<EditableText>(_field(0)).focusNode.hasFocus,
        isTrue,
        reason: 'ArrowLeft/Backspace mean "previous digit" in both scripts',
      );
    });
  });

  group('states', () {
    testWidgets('error swaps every hairline for --color-status-error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '9182', error: true)),
      );
      final Color expected =
          _colors().status(DabblerStatusTone.error).base;
      for (final DabblerSurface box in _boxes(tester)) {
        expect(box.borderColor, expected);
      }
    });

    testWidgets('at rest the hairline is the card surface outline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      final Color? expected = DabblerSurface.borderOf(
        _colors(),
        DabblerSurfaceVariant.card,
      );
      for (final DabblerSurface box in _boxes(tester)) {
        expect(box.borderColor, expected);
      }
    });

    testWidgets('disabled takes --color-bg-secondary and tertiary ink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCodeInput(length: 4, value: '4207', enabled: false),
        ),
      );
      for (final DabblerSurface box in _boxes(tester)) {
        expect(box.fill, _colors().bgSecondary);
      }
      expect(
        tester.widget<EditableText>(_field(0)).style.color,
        _colors().textTertiary,
      );
    });

    testWidgets('a disabled box accepts neither text nor keys', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(
            length: 4,
            value: '12',
            enabled: false,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.tap(_field(1), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('masked obscures with the dot, and still holds the digit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '4207', masked: true)),
      );
      final EditableText first = tester.widget<EditableText>(_field(0));
      expect(first.obscureText, isTrue);
      expect(first.obscuringCharacter, DabblerCodeInput.maskCharacter);
      expect(first.controller.text, '4');
    });

    testWidgets('unmasked by default', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(value: '1')));
      expect(tester.widget<EditableText>(_field(0)).obscureText, isFalse);
    });

    testWidgets('a changed value re-seeds the boxes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '11')),
      );
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '2222')),
      );
      await tester.pump();
      for (int i = 0; i < 4; i++) {
        expect(tester.widget<EditableText>(_field(i)).controller.text, '2');
      }
    });

    testWidgets('a changed length rebuilds the boxes without leaking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 6, value: '123456')),
      );
      await tester.pumpWidget(
        _host(const DabblerCodeInput(length: 4, value: '1234')),
      );
      await tester.pump();
      expect(_boxes(tester), hasLength(4));
    });
  });

  group('accessibility', () {
    testWidgets('the group is labelled "N-digit code"', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      expect(find.bySemanticsLabel('4-digit code'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('each box is labelled "Digit n"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 3)));
      for (int i = 1; i <= 3; i++) {
        expect(find.bySemanticsLabel(RegExp('Digit $i')), findsWidgets);
      }
      handle.dispose();
    });

    test('the two label builders are the source strings', () {
      expect(DabblerCodeInput.groupLabel(6), '6-digit code');
      expect(DabblerCodeInput.boxLabel(0), 'Digit 1');
      expect(DabblerCodeInput.boxLabel(5), 'Digit 6');
    });

    testWidgets('every box is a real text input, keyboard reachable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      for (int i = 0; i < 4; i++) {
        final EditableText box = tester.widget<EditableText>(_field(i));
        expect(box.keyboardType, TextInputType.number);
        expect(box.autofillHints, <String>[AutofillHints.oneTimeCode]);
        expect(box.focusNode.canRequestFocus, isTrue);
      }
    });

    testWidgets('a keyboard user can fill the whole code without a pointer', (
      WidgetTester tester,
    ) async {
      String? completed;
      await tester.pumpWidget(
        _host(
          DabblerCodeInput(
            length: 4,
            autofocus: true,
            onCompleted: (String v) => completed = v,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(_field(0)).focusNode.hasFocus, isTrue);

      for (int i = 0; i < 4; i++) {
        await tester.enterText(_field(i), '${i + 1}');
        await tester.pumpAndSettle();
      }
      expect(completed, '1234');
    });

    testWidgets('the focused box takes the system focus ring', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerCodeInput(length: 4)));
      await tester.tap(_field(1));
      await tester.pumpAndSettle();

      final List<DabblerFocusRing> rings = tester
          .widgetList<DabblerFocusRing>(
            find.descendant(
              of: find.byType(DabblerCodeInput),
              matching: find.byType(DabblerFocusRing),
            ),
          )
          .toList();
      expect(rings, hasLength(4));
      expect(rings[1].visible, isTrue);
      expect(rings.where((DabblerFocusRing r) => r.visible), hasLength(1));
      expect(rings[1].width, DabblerFocusRing.ringWidth);
      expect(rings[1].offset, DabblerFocusRing.ringOffset);
    });
  });

  group('composed, not restated', () {
    test('the box geometry reads from the tokens, not from local numbers', () {
      expect(DabblerCodeInput.boxWidth, DabblerSizing.touchTargetMin);
      expect(DabblerCodeInput.boxGap, DabblerSpacing.space2);
      expect(DabblerCodeInput.boxRadius, DabblerRadius.lg);
    });

    test('code_input.dart restates no colour, ring or press constant', () {
      const String path = 'lib/src/forms/code_input.dart';
      final String code = File(path)
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('///'))
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');

      expect(
        RegExp(r'Color\(0x').hasMatch(code),
        isFalse,
        reason: '$path must take every colour from the tokens',
      );
      expect(
        RegExp(r'ringWidth\s*=|ringOffset\s*=|pressScale\s*=|outlineOffset')
            .hasMatch(code),
        isFalse,
        reason: '$path must not restate an interaction constant',
      );
      expect(
        RegExp(r'Duration\(').hasMatch(code),
        isFalse,
        reason: '$path has no animation, so it declares no duration',
      );
      expect(
        RegExp(r'BoxShadow|LinearGradient|ImageFilter|BackdropFilter')
            .hasMatch(code),
        isFalse,
        reason: 'the system is flat',
      );
    });

    test('the box geometry literals are never restated in the file', () {
      const String path = 'lib/src/forms/code_input.dart';
      final String code = File(path)
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('///'))
          .where((String l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      // 45 (the box width and touch floor), 12 (--radius-lg) and 6 (the gap)
      // are all tokens and must be read as tokens. `defaultLength = 6` is not
      // in scope: it is a count of boxes, not a measurement.
      expect(
        RegExp(r'=\s*45(\.0)?\s*;|=\s*12(\.0)?\s*;').hasMatch(code),
        isFalse,
        reason: '45 and 12 are tokens and must be read as tokens',
      );
      expect(
        RegExp(r'boxGap\s*=\s*6\s*;').hasMatch(code),
        isFalse,
        reason: 'the 6px gap is --space-2, not a local 6',
      );
    });
  });
}
