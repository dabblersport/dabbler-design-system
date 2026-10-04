import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

class _Tile extends StatelessWidget {
  const _Tile(this.label, {this.height = 40});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: height, child: Text(label));
}

void main() {
  group('DabblerTileGrid', () {
    testWidgets('lays tiles in equal columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          DabblerTileGrid(
            children: <Widget>[for (int i = 0; i < 8; i++) _Tile('t$i')],
          ),
        ),
      );
      final double w0 = tester.getSize(find.text('t0')).width;
      expect(
        tester.getTopLeft(find.text('t1')).dx -
            tester.getTopLeft(find.text('t0')).dx,
        greaterThan(0),
      );
      expect(
        tester.getTopLeft(find.text('t4')).dy,
        greaterThan(tester.getTopLeft(find.text('t0')).dy),
      );
      expect(w0, greaterThan(0));
    });

    testWidgets('a taller tile makes only its row taller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerTileGrid(
            columns: 2,
            children: const <Widget>[
              _Tile('a'),
              _Tile('b', height: 80),
              _Tile('c'),
              _Tile('d'),
            ],
          ),
        ),
      );
      final double row1 =
          tester.getTopLeft(find.text('c')).dy -
          tester.getTopLeft(find.text('a')).dy;
      expect(row1, 80 + DabblerSpacing.space3);
    });

    testWidgets('a short last row keeps the column width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          DabblerTileGrid(
            columns: 3,
            children: const <Widget>[
              _Tile('a'),
              _Tile('b'),
              _Tile('c'),
              _Tile('d'),
            ],
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('d')).dx,
        tester.getTopLeft(find.text('a')).dx,
      );
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('first tile at the inline start ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            DabblerTileGrid(
              columns: 2,
              children: const <Widget>[_Tile('أ'), _Tile('ب')],
            ),
            direction: dir,
          ),
        );
        final double first = tester.getCenter(find.text('أ')).dx;
        final double second = tester.getCenter(find.text('ب')).dx;
        expect(
          dir == TextDirection.ltr ? first < second : first > second,
          isTrue,
        );
      });
    }
  });
}
