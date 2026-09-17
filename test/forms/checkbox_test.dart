import 'package:dabbler_design_system/src/forms/checkbox.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _boxFinder() => find
    .descendant(
      of: find.byType(DabblerCheckbox),
      matching: find.byType(Container),
    )
    .first;

BoxDecoration _box(WidgetTester tester) =>
    tester.widget<Container>(_boxFinder()).decoration! as BoxDecoration;

void main() {
  group('Checkbox geometry is the design source', () {
    testWidgets('a 24px box at --radius-sm, in a 45px row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerCheckbox(checked: false, label: 'Notify me')),
      );

      expect(tester.getSize(_boxFinder()), const Size(24, 24));
      expect(DabblerCheckbox.boxSize, DabblerSizing.iconMd);
      expect(
        _box(tester).borderRadius,
        DabblerRadius.smAll,
        reason: 'Checkbox.jsx:11 — borderRadius: var(--radius-sm)',
      );
      expect(
        tester.getSize(find.byType(DabblerCheckbox)).height,
        DabblerSizing.touchTargetMin,
      );
      expect(DabblerSizing.touchTargetMin, greaterThanOrEqualTo(44));
    });

    testWidgets('the gap between box and label is --stack-default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerCheckbox(checked: false, label: 'Notify me')),
      );

      final Rect box = tester.getRect(_boxFinder());
      final Rect label = tester.getRect(find.text('Notify me'));
      expect(label.left - box.right, DabblerSpacing.stackDefault);
      expect(DabblerSpacing.stackDefault, 12);
    });
  });

  group('Checkbox colour comes from the tokens', () {
    testWidgets('checked fills brandPrimary; unchecked is a bare hairline', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = testColors();

      await tester.pumpWidget(host(const DabblerCheckbox(checked: true)));
      expect(_box(tester).color, colors.brandPrimary);
      expect(_box(tester).border!.top.color, colors.brandPrimary);
      expect(
        find.byType(CustomPaint).evaluate().isNotEmpty,
        isTrue,
        reason: 'the check mark is drawn when checked',
      );

      await tester.pumpWidget(host(const DabblerCheckbox(checked: false)));
      expect(_box(tester).color, isNull, reason: 'background: transparent');
      expect(_box(tester).border!.top.color, colors.borderDefault);
      expect(_box(tester).border!.top.width, DabblerSizing.borderDefault);
    });

    testWidgets('the mark is the source path, at --color-on-brand', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerCheckbox(checked: true)));

      final CustomPaint paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(DabblerCheckbox),
              matching: find.byType(CustomPaint),
            )
            .last,
      );
      final DabblerCheckMarkPainter painter =
          paint.painter! as DabblerCheckMarkPainter;
      expect(painter.color, testColors().onBrand);
      expect(
        DabblerCheckMarkPainter.points,
        const <Offset>[Offset(20, 6), Offset(9, 17), Offset(4, 12)],
        reason: 'Checkbox.jsx:15 — d="M20 6 9 17l-5-5"',
      );
      expect(paint.size, const Size.square(DabblerCheckbox.markSize));
      expect(DabblerCheckbox.markSize, DabblerSizing.iconSm);
    });
  });

  group('Checkbox behaviour', () {
    testWidgets('a tap reports the opposite value', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(
          DabblerCheckbox(
            checked: false,
            label: 'Notify me',
            onChanged: reported.add,
          ),
        ),
      );

      await tester.tap(find.byType(DabblerCheckbox));
      await tester.pump();
      expect(reported, <bool>[true]);
    });

    testWidgets('Space flips it and the ring traces the box', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(DabblerCheckbox(checked: true, onChanged: reported.add)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final DabblerFocusRing ring =
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing));
      expect(ring.visible, isTrue);
      expect(ring.borderRadius, DabblerRadius.smAll);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, <bool>[false]);
    });

    testWidgets('disabled is 50% opaque and takes no click', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(
          DabblerCheckbox(
            checked: false,
            disabled: true,
            onChanged: reported.add,
          ),
        ),
      );

      expect(
        tester
            .widget<Opacity>(
              find
                  .descendant(
                    of: find.byType(DabblerCheckbox),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        DabblerCheckbox.disabledOpacity,
      );
      await tester.tap(find.byType(DabblerCheckbox));
      await tester.pump();
      expect(reported, isEmpty);
    });
  });

  group('Checkbox is RTL-correct', () {
    testWidgets('the box moves to the right of the label under rtl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerCheckbox(checked: false, label: 'أعلمني'),
          direction: TextDirection.rtl,
        ),
      );

      final Rect box = tester.getRect(_boxFinder());
      final Rect label = tester.getRect(find.text('أعلمني'));
      expect(box.left, greaterThan(label.right - 1));
      expect(box.left - label.right, DabblerSpacing.stackDefault);
    });
  });

  group('Checkbox semantics', () {
    testWidgets('it is announced as a checkbox with its state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerCheckbox(
            checked: true,
            label: 'Notify me',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(DabblerCheckbox)),
        matchesSemantics(
          label: 'Notify me',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
