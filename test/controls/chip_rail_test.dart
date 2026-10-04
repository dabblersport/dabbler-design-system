import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

List<DabblerChipRailItem> _items(
  int n, {
  int selected = 0,
  void Function(int)? onTap,
  bool counts = false,
}) => <DabblerChipRailItem>[
  for (int i = 0; i < n; i++)
    DabblerChipRailItem(
      label: 'C$i',
      selected: i == selected,
      count: counts ? '$i' : null,
      onTap: () => onTap?.call(i),
    ),
];

Widget _rail(
  List<DabblerChipRailItem> items, {
  TextDirection d = TextDirection.ltr,
  Brightness b = Brightness.light,
  int rows = 1,
  bool fade = true,
  DabblerChipSize size = DabblerChipSize.regular,
  ScrollController? controller,
}) => host(
  DabblerChipRail(
    items: items,
    rows: rows,
    fade: fade,
    size: size,
    controller: controller,
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: DabblerSpacing.space6,
    ),
  ),
  direction: d,
  brightness: b,
);

Finder _chip(int i) => find.widgetWithText(DabblerChip, 'C$i');

void main() {
  for (final TextDirection d in TextDirection.values) {
    for (final Brightness b in Brightness.values) {
      group('DabblerChipRail $d $b', () {
        testWidgets('starts at the inline start with the 6 gap and gutter', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(_rail(_items(3), d: d, b: b));
          await tester.pump();
          final Rect host = tester.getRect(find.byType(DabblerChipRail));
          final Rect first = tester.getRect(_chip(0));
          final Rect second = tester.getRect(_chip(1));
          if (d == TextDirection.ltr) {
            expect(first.left - host.left, DabblerSpacing.space6);
            expect(second.left - first.right, DabblerChipRail.gap);
          } else {
            expect(host.right - first.right, DabblerSpacing.space6);
            expect(first.left - second.right, DabblerChipRail.gap);
          }
        });

        testWidgets('scrolls horizontally from the inline start', (
          WidgetTester tester,
        ) async {
          final ScrollController c = ScrollController();
          await tester.pumpWidget(_rail(_items(12), d: d, b: b, controller: c));
          await tester.pump();
          expect(c.offset, 0);
          expect(c.position.maxScrollExtent, greaterThan(0));
          final double before = tester.getCenter(_chip(0)).dx;
          // Drag toward the inline end of the content (the scroll's forward).
          await tester.drag(
            find.byKey(DabblerChipRail.scrollKey),
            Offset(d == TextDirection.ltr ? -200 : 200, 0),
          );
          await tester.pump();
          expect(c.offset, greaterThan(0));
          final double after = tester.getCenter(_chip(0)).dx;
          expect(
            d == TextDirection.ltr ? after < before : after > before,
            isTrue,
          );
        });

        testWidgets('tapping a chip reports its index', (
          WidgetTester tester,
        ) async {
          int? picked;
          await tester.pumpWidget(
            _rail(
              _items(3, onTap: (int i) => picked = i),
              d: d,
              b: b,
            ),
          );
          await tester.tap(_chip(1));
          expect(picked, 1);
        });
      });
    }
  }

  testWidgets('the chosen chip is scrolled into view on mount', (
    WidgetTester tester,
  ) async {
    final ScrollController c = ScrollController();
    await tester.pumpWidget(_rail(_items(14, selected: 12), controller: c));
    await tester.pump();
    await tester.pump();
    expect(c.offset, greaterThan(0));
    final Rect host = tester.getRect(find.byType(DabblerChipRail));
    expect(host.contains(tester.getCenter(_chip(12))), isTrue);
  });

  testWidgets('moving the selection reveals the new chip', (
    WidgetTester tester,
  ) async {
    final ScrollController c = ScrollController();
    await tester.pumpWidget(_rail(_items(14), controller: c));
    await tester.pump();
    await tester.pumpWidget(_rail(_items(14, selected: 13), controller: c));
    await tester.pump();
    await tester.pump();
    expect(c.offset, greaterThan(0));
  });

  testWidgets('two rows deal chips alternately, and scroll together', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_rail(_items(8), rows: 2));
    await tester.pump();
    final double y0 = tester.getCenter(_chip(0)).dy;
    final double y1 = tester.getCenter(_chip(1)).dy;
    final double y2 = tester.getCenter(_chip(2)).dy;
    expect(y1, greaterThan(y0));
    expect(y2, y0);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('counts and sizes pass through to the chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _rail(_items(3, counts: true), size: DabblerChipSize.small),
    );
    final DabblerChip chip = tester.widget<DabblerChip>(_chip(0));
    expect(chip.count, '0');
    expect(chip.size, DabblerChipSize.small);
    expect(chip.selected, isTrue);
    expect(tester.widget<DabblerChip>(_chip(1)).selected, isFalse);
  });

  testWidgets('edge fade: none at rest start, appears at the cut-off end', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_rail(_items(14)));
    await tester.pump();
    await tester.pump();
    final ShaderMask mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    expect(mask.blendMode, BlendMode.dstIn);
    expect(DabblerChipRail.fadeExtent, DabblerSpacing.space8);
    // Content overflows: the end edge fades, the start does not.
    final DabblerChipRailState s = tester.state(find.byType(DabblerChipRail));
    expect(s.fadingEnd, isTrue);
    expect(s.fadingStart, isFalse);
    await tester.drag(
      find.byKey(DabblerChipRail.scrollKey),
      const Offset(-60, 0),
    );
    await tester.pump();
    expect(s.fadingStart, isTrue);
    await tester.drag(
      find.byKey(DabblerChipRail.scrollKey),
      const Offset(-5000, 0),
    );
    await tester.pump();
    expect(s.fadingEnd, isFalse);
  });

  testWidgets('a short rail does not fade, and fade:false has no mask', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_rail(_items(2)));
    await tester.pump();
    final DabblerChipRailState s = tester.state(find.byType(DabblerChipRail));
    expect(s.fadingEnd, isFalse);
    await tester.pumpWidget(_rail(_items(14), fade: false));
    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets('empty renders nothing; Arabic labels do not throw', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_rail(const <DabblerChipRailItem>[]));
    expect(find.byType(DabblerChip), findsNothing);
    await tester.pumpWidget(
      host(
        DabblerChipRail(
          items: const <DabblerChipRailItem>[
            DabblerChipRailItem(label: 'الكل', selected: true, count: '٤'),
            DabblerChipRailItem(label: 'مدفوع'),
          ],
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('الكل'), findsOneWidget);
  });
}
