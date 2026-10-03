import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _clearIcon() => find.byWidgetPredicate(
  (Widget w) => w is DabblerIcon && w.name == DabblerTextField.clearIconName,
);

void main() {
  group('DabblerSearchField — autofocus', () {
    testWidgets('takes focus on first build when autofocus is true', (
      WidgetTester tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(DabblerSearchField(focusNode: node, autofocus: true)),
      );
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('does not take focus by default', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(host(DabblerSearchField(focusNode: node)));
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });
  });

  group('DabblerSearchField — loading', () {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('spinner replaces clear at the inline end (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSearchField(initialValue: 'dab', loading: true),
            direction: d,
          ),
        );
        expect(_clearIcon(), findsNothing);
        final Finder spinner = find.byType(DabblerSpinner);
        expect(spinner, findsOneWidget);
        expect(
          tester.widget<DabblerSpinner>(spinner).size,
          DabblerSpinnerSize.sm,
        );
        final Rect field = tester.getRect(find.byType(DabblerSearchField));
        final Rect s = tester.getRect(spinner);
        if (d == TextDirection.ltr) {
          expect(s.center.dx, greaterThan(field.center.dx));
        } else {
          expect(s.center.dx, lessThan(field.center.dx));
        }
        final Rect slot = tester.getRect(
          find.ancestor(of: spinner, matching: find.byType(SizedBox)).first,
        );
        expect(slot.width, DabblerSizing.touchTargetMin);
        expect(slot.height, DabblerSizing.touchTargetMin);
      });
    }

    testWidgets('clear comes back when loading ends; box height is stable', (
      WidgetTester tester,
    ) async {
      Widget build(bool loading) =>
          host(DabblerSearchField(initialValue: 'dab', loading: loading));
      await tester.pumpWidget(build(true));
      final double h = tester.getSize(find.byType(DabblerSurface).first).height;
      await tester.pumpWidget(build(false));
      expect(_clearIcon(), findsOneWidget);
      expect(find.byType(DabblerSpinner), findsNothing);
      expect(tester.getSize(find.byType(DabblerSurface).first).height, h);
    });

    testWidgets('announces a loading live region', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerSearchField(loading: true)));
      expect(find.bySemanticsLabel(DabblerSpinner.defaultLabel), findsWidgets);
      handle.dispose();
    });

    testWidgets('spinner keeps animating under reduced motion (no hang)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(const DabblerSearchField(loading: true)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DabblerSearchField — forwarded form props', () {
    testWidgets('validator / autovalidateMode / onSaved reach the Form', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: DabblerSearchField(
              validator: (String? v) =>
                  (v == null || v.isEmpty) ? 'Type something' : null,
              autovalidateMode: AutovalidateMode.disabled,
              onSaved: (String? v) => saved = v,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Type something'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'padel');
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'padel');
    });

    testWidgets('suffixText renders at the trailing edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSearchField(suffixText: '12 results')),
      );
      expect(find.text('12 results'), findsOneWidget);
    });
  });
}
