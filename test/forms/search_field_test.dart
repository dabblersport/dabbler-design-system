import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import '_host.dart';

Finder _clearIcon() => find.byWidgetPredicate(
  (Widget w) => w is DabblerIcon && w.name == DabblerTextField.clearIconName,
);

Finder _clearButton() => find.bySemanticsLabel('Clear');

void main() {
  group('DabblerSearchField — the inline clear button', () {
    testWidgets('is absent while empty and appears once there is text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerSearchField()));
      expect(_clearIcon(), findsNothing);

      await tester.enterText(find.byType(EditableText), 'dab');
      await tester.pump();
      expect(_clearIcon(), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(_clearIcon(), findsNothing);
    });

    testWidgets('is a close-circle at --icon-sm in --muted on a 45px target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSearchField(initialValue: 'x')),
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(_clearIcon());
      expect(icon.name, 'close-circle');
      expect(icon.size, DabblerSizing.iconSm);
      expect(DabblerSizing.iconSm, 18);
      expect(icon.color, testColors().textTertiary);

      final Rect target = tester.getRect(
        find.ancestor(of: _clearIcon(), matching: find.byType(SizedBox)).first,
      );
      expect(target.width, DabblerSizing.touchTargetMin);
      expect(target.height, DabblerSizing.touchTargetMin);
    });

    testWidgets('the box stays 45 tall when the button appears', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerSearchField()));
      final Finder box = find.byType(DabblerSurface).first;
      final double empty = tester.getSize(box).height;
      await tester.enterText(find.byType(EditableText), 'dab');
      await tester.pump();
      expect(tester.getSize(box).height, empty);
      expect(empty, DabblerSizing.touchTargetMin);
    });

    testWidgets(
      'clearing empties the text, fires both callbacks, keeps focus',
      (WidgetTester tester) async {
        final List<String> changed = <String>[];
        int cleared = 0;
        await tester.pumpWidget(
          host(
            DabblerSearchField(
              onChanged: changed.add,
              onCleared: () => cleared++,
            ),
          ),
        );
        await tester.enterText(find.byType(EditableText), 'dab');
        await tester.pump();
        changed.clear();

        await tester.tap(_clearIcon());
        await tester.pump();

        expect(find.text('dab'), findsNothing);
        expect(changed, <String>['']);
        expect(cleared, 1);
        expect(_clearIcon(), findsNothing);
        final EditableTextState state = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(state.widget.focusNode.hasFocus, isTrue);
      },
    );

    testWidgets('works with an external controller, in both directions', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: 'abc',
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(DabblerSearchField(controller: controller)));
      expect(_clearIcon(), findsOneWidget, reason: 'seeded text shows it');

      controller.text = '';
      await tester.pump();
      expect(_clearIcon(), findsNothing, reason: 'external clear hides it');

      controller.text = 'later';
      await tester.pump();
      expect(_clearIcon(), findsOneWidget, reason: 'external set shows it');

      await tester.tap(_clearIcon());
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('a swapped controller is followed', (
      WidgetTester tester,
    ) async {
      final TextEditingController a = TextEditingController(text: 'a');
      final TextEditingController b = TextEditingController();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await tester.pumpWidget(host(DabblerSearchField(controller: a)));
      expect(_clearIcon(), findsOneWidget);
      await tester.pumpWidget(host(DabblerSearchField(controller: b)));
      expect(_clearIcon(), findsNothing);
      b.text = 'z';
      await tester.pump();
      expect(_clearIcon(), findsOneWidget);
    });

    testWidgets('clearable: false and disabled both hide it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSearchField(initialValue: 'x', clearable: false)),
      );
      expect(_clearIcon(), findsNothing);
      await tester.pumpWidget(
        host(const DabblerSearchField(initialValue: 'x', enabled: false)),
      );
      expect(_clearIcon(), findsNothing);
    });

    testWidgets('the plain search variant is unchanged (no clear by default)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.search,
            initialValue: 'x',
          ),
        ),
      );
      expect(_clearIcon(), findsNothing);
    });

    testWidgets('the semantics label is localisable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const DabblerSearchField(initialValue: 'x', clearLabel: 'مسح')),
      );
      expect(find.bySemanticsLabel('مسح'), findsOneWidget);
      expect(_clearButton(), findsNothing);
      handle.dispose();
    });

    testWidgets('the English default label is Clear', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const DabblerSearchField(initialValue: 'x')),
      );
      expect(_clearButton(), findsOneWidget);
      handle.dispose();
    });
  });

  group('DabblerSearchField — RTL', () {
    Future<void> pump(WidgetTester tester, TextDirection d) =>
        tester.pumpWidget(
          host(const DabblerSearchField(initialValue: 'x'), direction: d),
        );

    testWidgets('the clear button is on the right in LTR and the left in RTL', (
      WidgetTester tester,
    ) async {
      await pump(tester, TextDirection.ltr);
      final Rect boxLtr = tester.getRect(find.byType(DabblerSurface).first);
      final Rect clearLtr = tester.getRect(_clearIcon());
      expect(clearLtr.center.dx, greaterThan(boxLtr.center.dx));

      await pump(tester, TextDirection.rtl);
      final Rect boxRtl = tester.getRect(find.byType(DabblerSurface).first);
      final Rect clearRtl = tester.getRect(_clearIcon());
      expect(clearRtl.center.dx, lessThan(boxRtl.center.dx));
      // 6px inset + half the 45px target, measured from the box's edge.
      expect(
        clearRtl.center.dx - boxRtl.left,
        DabblerSpacing.space2 + DabblerSizing.touchTargetMin / 2,
      );
    });

    testWidgets('the search glyph stays at the opposite (start) end', (
      WidgetTester tester,
    ) async {
      await pump(tester, TextDirection.rtl);
      final Finder glyph = find.byWidgetPredicate(
        (Widget w) =>
            w is DabblerIcon && w.name == DabblerTextField.searchIconName,
      );
      expect(
        tester.getCenter(glyph).dx,
        greaterThan(tester.getCenter(_clearIcon()).dx),
      );
    });
  });

  group('DabblerSearchField — renders (AC5)', () {
    for (final TextDirection d in TextDirection.values) {
      final String tag = d == TextDirection.ltr ? 'ltr' : 'rtl';
      testWidgets('search field $tag', (WidgetTester tester) async {
        await renderPng(
          tester,
          const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DabblerSearchField(placeholder: 'Search people, games, posts'),
                SizedBox(height: 12),
                DabblerSearchField(
                  placeholder: 'Search people, games, posts',
                  initialValue: 'dabbler',
                ),
                SizedBox(height: 12),
                DabblerSearchField(
                  placeholder: 'Search',
                  initialValue: 'دابلر',
                  clearLabel: 'مسح',
                ),
              ],
            ),
          ),
          name: 'search_field_$tag',
          size: const Size(390, 220),
          direction: d,
          alignment: Alignment.topCenter,
        );
      });
    }
  });
}
