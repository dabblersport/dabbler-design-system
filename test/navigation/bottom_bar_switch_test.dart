// KAN-413 regression: tapping another bottom-bar item used to throw
// "Cannot interpolate between finite constraints and unbounded constraints"
// from the item's AnimatedContainer (width null <-> 44).
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: Directionality(
        textDirection: direction,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: 360, child: child),
        ),
      ),
    );

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('switching the active item animates without an exception '
        '(${dir.name})', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      String active = 'home';
      late StateSetter set;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              set = setState;
              return DabblerNavigationBottomBar(
                active: active,
                onSelect: (String id) => set(() => active = id),
              );
            },
          ),
          direction: dir,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Games'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(active, 'games');
      // The active item shows its label; the first one is the icon alone.
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      handle.dispose();
    });
  }

  testWidgets('the active label is not squeezed: only the active item flexes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerNavigationBottomBar(
          items: <DabblerNavigationItem>[
            DabblerNavigationItem(id: 'a', icon: 'home-2', label: 'Feeds'),
            DabblerNavigationItem(id: 'b', icon: 'location', label: 'Venues'),
            DabblerNavigationItem(id: 'c', icon: 'game', label: 'Games'),
          ],
          active: 'b',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // `Venues` at 15px is far wider than the 20px a third-share cap left it.
    expect(tester.getSize(find.text('Venues')).width, greaterThan(40));
  });
}
