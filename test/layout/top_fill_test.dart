import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {double top = 44}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(padding: EdgeInsets.only(top: top)),
    child: child,
  ),
);

void main() {
  testWidgets('paints the inset in the colour, ignoring pointers', (t) async {
    const Color c = Color(0xFF123456);
    await t.pumpWidget(
      _app(const DabblerTopFill(color: c, child: SizedBox.expand())),
    );
    final Finder strip = find.descendant(
      of: find.byType(DabblerTopFill),
      matching: find.byType(ColoredBox),
    );
    expect(t.widget<ColoredBox>(strip).color, c);
    expect(t.getSize(strip).height, 44);
    expect(
      find.ancestor(of: strip, matching: find.byType(IgnorePointer)),
      findsWidgets,
    );
  });

  testWidgets('null colour or no inset paints nothing', (t) async {
    await t.pumpWidget(_app(const DabblerTopFill(child: SizedBox.expand())));
    expect(
      find.descendant(
        of: find.byType(DabblerTopFill),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
    await t.pumpWidget(
      _app(
        const DabblerTopFill(
          color: Color(0xFF123456),
          child: SizedBox.expand(),
        ),
        top: 0,
      ),
    );
    expect(
      find.descendant(
        of: find.byType(DabblerTopFill),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });
}
