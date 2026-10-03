import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/interaction/scrim.dart';
import 'package:dabbler_design_system/src/overlays/dialog.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData get _theme => ThemeData(
  extensions: <ThemeExtension<dynamic>>[
    DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    ),
  ],
);

DabblerDialog _dialog({
  required bool loading,
  required VoidCallback onClose,
  VoidCallback? onConfirm,
}) => DabblerDialog(
  title: 'Delete game?',
  onClose: onClose,
  primaryAction: DabblerDialogAction(
    label: 'Delete',
    onPressed: onConfirm ?? () {},
    loading: loading,
  ),
  secondaryAction: const DabblerDialogAction(label: 'Cancel'),
);

DabblerButton _button(WidgetTester t, Key k) =>
    t.widget<DabblerButton>(find.byKey(k));

void main() {
  for (final TextDirection dir in TextDirection.values) {
    group('inline host, ${dir.name}', () {
      Future<int> pump(WidgetTester t, {required bool loading}) async {
        int closes = 0;
        await t.pumpWidget(
          MaterialApp(
            theme: _theme,
            home: Directionality(
              textDirection: dir,
              child: StatefulBuilder(
                builder: (BuildContext c, StateSetter s) =>
                    _dialog(loading: loading, onClose: () => closes++),
              ),
            ),
          ),
        );
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        return closes;
      }

      testWidgets('loading: spinner in primary, both buttons inert', (t) async {
        await pump(t, loading: true);
        expect(
          find.descendant(
            of: find.byKey(DabblerDialog.primaryActionKey),
            matching: find.byType(DabblerSpinner),
          ),
          findsOneWidget,
        );
        expect(_button(t, DabblerDialog.primaryActionKey).loading, isTrue);
        expect(_button(t, DabblerDialog.secondaryActionKey).disabled, isTrue);
      });

      testWidgets('not loading: unchanged defaults', (t) async {
        await pump(t, loading: false);
        expect(find.byType(DabblerSpinner), findsNothing);
        expect(_button(t, DabblerDialog.primaryActionKey).loading, isFalse);
        expect(_button(t, DabblerDialog.secondaryActionKey).disabled, isFalse);
        expect(
          t.widget<DabblerScrim>(find.byType(DabblerScrim)).onDismiss,
          isNotNull,
        );
      });

      testWidgets('loading blocks scrim, Escape, Enter and Cancel', (t) async {
        int closes = 0, confirms = 0;
        await t.pumpWidget(
          MaterialApp(
            theme: _theme,
            home: Directionality(
              textDirection: dir,
              child: _dialog(
                loading: true,
                onClose: () => closes++,
                onConfirm: () => confirms++,
              ),
            ),
          ),
        );
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(
          t.widget<DabblerScrim>(find.byType(DabblerScrim)).onDismiss,
          isNull,
        );
        await t.tapAt(const Offset(4, 4));
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.tap(
          find.byKey(DabblerDialog.secondaryActionKey),
          warnIfMissed: false,
        );
        await t.pump();
        expect(closes, 0);
        expect(confirms, 0);
      });

      testWidgets('loading blocks back via PopScope', (t) async {
        await pump(t, loading: true);
        expect(
          t
              .widget<PopScope<Object?>>(
                find.byWidgetPredicate((Widget w) => w is PopScope),
              )
              .canPop,
          isFalse,
        );
      });
    });
  }

  group('showDabblerDialog route', () {
    Future<void> open(
      WidgetTester t,
      ValueNotifier<bool> loading,
      TextDirection dir,
    ) async {
      late BuildContext page;
      await t.pumpWidget(
        MaterialApp(
          theme: _theme,
          builder: (BuildContext c, Widget? child) =>
              Directionality(textDirection: dir, child: child!),
          home: Builder(
            builder: (BuildContext c) {
              page = c;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      showDabblerDialog<void>(
        context: page,
        builder: (BuildContext c) => ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (BuildContext c, bool l, Widget? _) =>
              _dialog(loading: l, onClose: () => Navigator.of(c).pop()),
        ),
      );
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
    }

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('${dir.name}: back and Escape refused while loading, '
          'allowed after', (t) async {
        final ValueNotifier<bool> loading = ValueNotifier<bool>(true);
        await open(t, loading, dir);
        // System back (Android back button / predictive back).
        await t.binding.handlePopRoute();
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(find.byKey(DabblerDialog.panelKey), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(find.byKey(DabblerDialog.panelKey), findsOneWidget);
        await t.tapAt(const Offset(4, 4));
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(find.byKey(DabblerDialog.panelKey), findsOneWidget);

        loading.value = false;
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        await t.binding.handlePopRoute();
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(find.byKey(DabblerDialog.panelKey), findsNothing);
      });
    }

    testWidgets('Escape and scrim close again once loading ends', (t) async {
      final ValueNotifier<bool> loading = ValueNotifier<bool>(true);
      await open(t, loading, TextDirection.ltr);
      loading.value = false;
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byKey(DabblerDialog.panelKey), findsNothing);
    });
  });
}
