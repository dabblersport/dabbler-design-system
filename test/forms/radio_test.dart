import 'package:dabbler_design_system/src/forms/radio.dart';
import 'package:dabbler_design_system/src/interaction/focus_ring.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _circleFinder() => find
    .descendant(
      of: find.byType(DabblerRadio),
      matching: find.byType(Container),
    )
    .first;

BoxDecoration _circle(WidgetTester tester) =>
    tester.widget<Container>(_circleFinder()).decoration! as BoxDecoration;

void main() {
  group('Radio geometry is the design source', () {
    testWidgets('a 24px circle in a 45px row, with a 9px dot when selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerRadio(selected: true, label: 'intermediate')),
      );

      expect(tester.getSize(_circleFinder()), const Size(24, 24));
      expect(DabblerRadio.circleSize, DabblerSizing.iconMd);
      expect(_circle(tester).shape, BoxShape.circle);
      expect(
        tester.getSize(find.byType(DabblerRadio)).height,
        DabblerSizing.touchTargetMin,
      );

      final Size dot = tester.getSize(
        find
            .descendant(
              of: find.byType(DabblerRadio),
              matching: find.byType(Container),
            )
            .last,
      );
      expect(dot, const Size(9, 9), reason: 'Radio.jsx:14');
      expect(DabblerRadio.dotSize, DabblerSpacing.space3);
    });

    testWidgets('the ring thickens from 1 to 2 on selection', (
      WidgetTester tester,
    ) async {
      final DabblerColors colors = testColors();

      await tester.pumpWidget(host(const DabblerRadio(selected: false)));
      expect(_circle(tester).border!.top.width, DabblerSizing.borderDefault);
      expect(_circle(tester).border!.top.color, colors.borderDefault);

      await tester.pumpWidget(host(const DabblerRadio(selected: true)));
      expect(_circle(tester).border!.top.width, DabblerRadio.selectedRingWidth);
      expect(DabblerRadio.selectedRingWidth, 2);
      expect(_circle(tester).border!.top.color, colors.brandPrimary);
    });
  });

  group('Radio behaviour', () {
    testWidgets('it reports true and only true — there is no deselect', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(DabblerRadio(selected: true, onChanged: reported.add)),
      );

      await tester.tap(find.byType(DabblerRadio));
      await tester.pump();
      expect(
        reported,
        <bool>[true],
        reason: 'Radio.jsx:19 — onChange(true), even when already selected',
      );
    });

    testWidgets('a group is several radios reading one value', (
      WidgetTester tester,
    ) async {
      String chosen = 'beginner';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final String level in <String>[
                  'beginner',
                  'intermediate',
                  'advanced',
                ])
                  DabblerRadio(
                    label: level,
                    selected: chosen == level,
                    onChanged: (_) => setState(() => chosen = level),
                  ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('advanced'));
      await tester.pump();
      expect(chosen, 'advanced');

      final DabblerColors colors = testColors();
      final Iterable<Container> circles = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (Container c) =>
                (c.decoration as BoxDecoration?)?.shape == BoxShape.circle &&
                (c.decoration! as BoxDecoration).border != null,
          );
      expect(
        circles
            .where(
              (Container c) =>
                  (c.decoration! as BoxDecoration).border!.top.color ==
                  colors.brandPrimary,
            )
            .length,
        1,
        reason: 'exactly one selected — mutual exclusivity is the shared value',
      );
    });

    testWidgets('Space selects and the ring traces the circle', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(DabblerRadio(selected: false, onChanged: reported.add)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final DabblerFocusRing ring =
          tester.widget<DabblerFocusRing>(find.byType(DabblerFocusRing));
      expect(ring.visible, isTrue);
      expect(ring.borderRadius, DabblerRadius.pillAll);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, <bool>[true]);
    });

    testWidgets('disabled takes no click and no key', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(
        host(
          DabblerRadio(
            selected: false,
            disabled: true,
            onChanged: reported.add,
          ),
        ),
      );

      await tester.tap(find.byType(DabblerRadio));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(reported, isEmpty);
      expect(DabblerRadio.disabledOpacity, 0.5);
    });
  });

  group('Radio is RTL-correct', () {
    testWidgets('the circle moves to the right of the label under rtl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerRadio(selected: false, label: 'مبتدئ'),
          direction: TextDirection.rtl,
        ),
      );

      final Rect circle = tester.getRect(_circleFinder());
      final Rect label = tester.getRect(find.text('مبتدئ'));
      expect(circle.left - label.right, DabblerSpacing.stackDefault);
    });
  });

  group('Radio semantics', () {
    testWidgets('it is announced as a radio, not a checkbox', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerRadio(
            selected: true,
            label: 'intermediate',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(DabblerRadio)),
        matchesSemantics(
          label: 'intermediate',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
