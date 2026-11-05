import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/navigation/tab_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _c([Brightness b = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_c(brightness)]),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 384, child: child),
      ),
    ),
  ),
);

void main() {
  group('DabblerNavigationTabBar — NavigationTabBar.jsx', () {
    test('the source defaults are home-2, search-normal, add-circle, sms', () {
      expect(
        DabblerNavigationTabBar.defaultTabs
            .map((DabblerNavigationTab t) => t.icon)
            .toList(),
        <String>['home-2', 'search-normal', 'add-circle', 'sms'],
      );
      expect(DabblerNavigationTabBar.radius, 16);
      expect(DabblerNavigationTabBar.slotPadding, 12);
      expect(DabblerNavigationTabBar.iconSize, 24);
    });

    testWidgets('four equal slots; drawn height is 49 (KAN-292)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerNavigationTabBar()));
      final Size bar = tester.getSize(find.byType(DabblerNavigationTabBar));
      expect(bar.width, 384);
      // 47 content-box + the shell's two 1px borders, as the specimen renders.
      expect(bar.height, 49);
      expect(DabblerNavigationTabBar.barHeight, 49);
      final List<Size> slots = tester
          .widgetList<DabblerIcon>(find.byType(DabblerIcon))
          .map((DabblerIcon i) => tester.getSize(find.byWidget(i)))
          .toList();
      expect(slots.length, 4);
      expect(slots.every((Size s) => s == const Size(24, 24)), isTrue);
    });

    testWidgets('is at most 384 wide on a wider host', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_c()]),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 800, child: DabblerNavigationTabBar()),
            ),
          ),
        ),
      );
      // The root fills the 800 host; the drawn shell is what is capped.
      final Size bar = tester.getSize(
        find
            .descendant(
              of: find.byType(DabblerNavigationTabBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(bar.width, lessThanOrEqualTo(384));
      expect(bar.height, 49);
      expect(DabblerNavigationTabBar.rowHeight, 50);
      expect(DabblerNavigationTabBar.glyphLineHeight, 20);
    });

    testWidgets('only the active slot is bold and brand-coloured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerNavigationTabBar(activeIndex: 2)),
      );
      final List<DabblerIcon> icons = tester
          .widgetList<DabblerIcon>(find.byType(DabblerIcon))
          .toList();
      expect(icons[2].weight, DabblerIconWeight.bold);
      expect(icons[2].color, _c().brandPrimary);
      for (final int i in <int>[0, 1, 3]) {
        expect(icons[i].weight, DabblerIconWeight.linear);
        expect(icons[i].color, _c().textTertiary);
      }
    });

    testWidgets('tapping reports the slot; slots are selected buttons', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      final List<int> picked = <int>[];
      await tester.pumpWidget(
        _host(DabblerNavigationTabBar(onSelect: picked.add)),
      );
      await tester.tap(find.bySemanticsLabel('Messages'));
      expect(picked, <int>[3]);
      final SemanticsNode home = tester.getSemantics(
        find.bySemanticsLabel('Home'),
      );
      expect(home.flagsCollection.isSelected.name, 'isTrue');
      expect(home.flagsCollection.isButton, isTrue);
      h.dispose();
    });

    testWidgets('keyboard activates a focused slot', (
      WidgetTester tester,
    ) async {
      final List<int> picked = <int>[];
      await tester.pumpWidget(
        _host(DabblerNavigationTabBar(onSelect: picked.add)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picked, <int>[0]);
    });

    testWidgets('RTL reverses the slot order; dark renders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerNavigationTabBar(),
          direction: TextDirection.rtl,
          brightness: Brightness.dark,
        ),
      );
      final double homeX = tester.getCenter(find.byType(DabblerIcon).first).dx;
      final double smsX = tester.getCenter(find.byType(DabblerIcon).last).dx;
      expect(homeX, greaterThan(smsX));
      expect(DabblerSizing.iconMd, 24);
    });
  });
}
