import 'package:dabbler_design_system/src/forms/picker_field.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

/// KAN-276 — the trailing picker button's keyboard path.
///
/// `PickerField.jsx:59` gives the button `className="dbl-focus"` and the web's
/// `<button>` role gives it Enter/Space activation; the first Dart port had
/// neither. These tests drive the button **by keyboard**, not by asserting a
/// ring is painted: focus it through
/// [DabblerPickerFieldShell.pickerButtonKey], send Enter, send Space, and
/// require the same callback a tap fires.
void main() {
  /// The [FocusNode] the button's [FocusableActionDetector] inserted, reached
  /// through the key the shell already puts on the button.
  FocusNode buttonFocusNode(WidgetTester tester) {
    return Focus.of(
      tester.element(
        find.descendant(
          of: find.byKey(DabblerPickerFieldShell.pickerButtonKey),
          matching: find.byType(DabblerFocusRing),
        ),
      ),
    );
  }

  Widget shell(
    TextEditingController controller, {
    required VoidCallback? onOpenPressed,
    bool enabled = true,
    bool open = false,
    String? placeholder,
  }) {
    return host(
      DabblerPickerFieldShell(
        controller: controller,
        iconName: 'calendar',
        label: 'Date',
        enabled: enabled,
        open: open,
        placeholder: placeholder,
        onOpenPressed: onOpenPressed,
      ),
    );
  }

  group('DabblerPickerFieldShell picker button — keyboard (KAN-276)', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    testWidgets('Enter on the focused button fires onOpenPressed', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      await tester.pumpWidget(shell(controller, onOpenPressed: () => pressed++));

      buttonFocusNode(tester).requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('Space on the focused button fires onOpenPressed', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      await tester.pumpWidget(shell(controller, onOpenPressed: () => pressed++));

      buttonFocusNode(tester).requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('a keyboard-focused button shows the shared focus ring', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(shell(controller, onOpenPressed: () {}));

      final Finder ring = find.descendant(
        of: find.byKey(DabblerPickerFieldShell.pickerButtonKey),
        matching: find.byType(DabblerFocusRing),
      );
      expect(tester.widget<DabblerFocusRing>(ring).visible, isFalse);

      buttonFocusNode(tester).requestFocus();
      // A key press is what puts the focus highlight in `traditional` mode,
      // which is Flutter's `:focus-visible`.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      buttonFocusNode(tester).requestFocus();
      await tester.pumpAndSettle();

      expect(
        tester.widget<DabblerFocusRing>(ring).visible,
        isTrue,
        reason: 'a visible focus indicator — cpo §5.2 Principle 3',
      );
    });

    testWidgets('tap still fires onOpenPressed, unchanged', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      await tester.pumpWidget(shell(controller, onOpenPressed: () => pressed++));

      await tester.tap(find.byKey(DabblerPickerFieldShell.pickerButtonKey));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('disabled takes neither a tap nor a key', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      await tester.pumpWidget(
        shell(controller, enabled: false, onOpenPressed: () => pressed++),
      );

      await tester.tap(
        find.byKey(DabblerPickerFieldShell.pickerButtonKey),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(pressed, 0);
    });

    testWidgets('semantics keep the button role, state and both labels', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(shell(controller, onOpenPressed: () {}));

      expect(
        find.bySemanticsLabel(
          DabblerPickerFieldShell.defaultOpenSemanticsLabel,
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        shell(controller, open: true, onOpenPressed: () {}),
      );
      expect(
        find.bySemanticsLabel(
          DabblerPickerFieldShell.defaultCloseSemanticsLabel,
        ),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  /// KAN-336 — D-025 at the SECOND hint site.
  ///
  /// This shell owns its own `hintStyle`, reached by every picker in the
  /// system, and `DateField`/`TimeField` supply a format placeholder by
  /// default — so a disabled empty picker always paints one. It carried the
  /// identical unconditional-secondary defect [DabblerTextField] did, and
  /// had no placeholder-colour coverage at all until these two.
  group('DabblerPickerFieldShell placeholder colour (KAN-336, D-025)', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    TextField hintField(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField));

    testWidgets('enabled and empty, the hint is textSecondary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        shell(controller, onOpenPressed: () {}, placeholder: 'DD/MM/YYYY'),
      );
      expect(
        hintField(tester).decoration!.hintStyle!.color,
        testColors().textSecondary,
      );
    });

    testWidgets('disabled and empty, the hint falls to textTertiary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        shell(
          controller,
          onOpenPressed: () {},
          enabled: false,
          placeholder: 'DD/MM/YYYY',
        ),
      );
      expect(
        hintField(tester).decoration!.hintStyle!.color,
        testColors().textTertiary,
        reason: 'D-025 applies at this site too — fixing only '
            'text_field.dart would leave the contradiction in place',
      );
    });
  });
}
