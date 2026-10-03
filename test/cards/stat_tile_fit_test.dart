import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    ),
  );
}

double _fontSizeOf(WidgetTester t, String text) =>
    t.widget<Text>(find.text(text)).style!.fontSize!;

void main() {
  group('DabblerStatTileValue.scaleFor', () {
    const TextStyle style = TextStyle(fontSize: 26);
    test('1 when it fits, floor when far too wide', () {
      expect(
        DabblerStatTileValue.scaleFor(
          text: '1',
          style: style,
          maxWidth: 500,
          direction: TextDirection.ltr,
        ),
        1,
      );
      expect(
        DabblerStatTileValue.scaleFor(
          text: '123456789012345',
          style: style,
          maxWidth: 10,
          direction: TextDirection.ltr,
        ),
        DabblerStatTileValue.defaultMinScale,
      );
      expect(DabblerStatTileValue.defaultMinScale, 0.6);
    });
  });

  for (final TextDirection dir in TextDirection.values) {
    testWidgets('fitValue shrinks a long value, not below the floor '
        '(${dir.name})', (WidgetTester t) async {
      await t.pumpWidget(
        _host(
          const SizedBox(
            width: 110,
            height: 78,
            child: DabblerStatTile(
              value: '12,480',
              label: 'Minutes',
              fitValue: true,
            ),
          ),
          direction: dir,
        ),
      );
      expect(t.takeException(), isNull);
      final double size = _fontSizeOf(t, '12,480');
      expect(size, lessThan(DabblerStatTileSize.small.valueSize));
      expect(
        size,
        greaterThanOrEqualTo(
          DabblerStatTileSize.small.valueSize *
                  DabblerStatTileValue.defaultMinScale -
              0.001,
        ),
      );
    });
  }

  testWidgets('default is unchanged: clip, full size', (WidgetTester t) async {
    await t.pumpWidget(
      _host(
        const SizedBox(
          width: 110,
          height: 78,
          child: DabblerStatTile(value: '12,480', label: 'Minutes'),
        ),
      ),
    );
    final Text text = t.widget<Text>(find.text('12,480'));
    expect(text.overflow, TextOverflow.clip);
    expect(text.style!.fontSize, DabblerStatTileSize.small.valueSize);
    expect(find.byType(DabblerStatTileValue), findsNothing);
  });

  testWidgets('icon slot draws above the value, decorative, tile-ink', (
    WidgetTester t,
  ) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      _host(
        const SizedBox(
          width: 170,
          height: 100,
          child: DabblerStatTile(
            icon: DabblerIcon('calendar', key: Key('ico')),
            value: '214',
            label: 'Games run',
            tone: DabblerStatTileTone.brand,
          ),
        ),
      ),
    );
    expect(
      t.getRect(find.byKey(const Key('ico'))).bottom,
      lessThanOrEqualTo(t.getRect(find.text('214')).top),
    );
    expect(find.bySemanticsLabel('214, Games run'), findsOneWidget);
    final IconThemeData theme = IconTheme.of(
      t.element(find.byKey(const Key('ico'))),
    );
    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );
    expect(theme.color, c.onBrand);
    h.dispose();
  });

  group('StatGrid rowExtent', () {
    test('defaults', () {
      expect(DabblerStatGrid.rowHeight, 78);
      expect(DabblerStatGrid.detailsRowHeight, 100);
      expect(
        const DabblerStatGrid(children: <DabblerStatTile>[]).rowExtent,
        78,
      );
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('100px rows size the grid (${dir.name})', (
        WidgetTester t,
      ) async {
        await t.pumpWidget(
          _host(
            const DabblerStatGrid(
              rowExtent: DabblerStatGrid.detailsRowHeight,
              children: <DabblerStatTile>[
                DabblerStatTile(value: '1', label: 'a', span: 3),
                DabblerStatTile(value: '2', label: 'b', span: 3),
                DabblerStatTile(value: '3', label: 'c', span: 6),
              ],
            ),
            direction: dir,
          ),
        );
        // two rows of 100 plus one 9 gap
        expect(t.getSize(find.byType(DabblerStatGrid)).height, 209);
        final Rect a = t.getRect(find.byType(DabblerStatTile).first);
        expect(a.height, 100);
        if (dir == TextDirection.rtl) {
          expect(a.right, 360);
        } else {
          expect(a.left, 0);
        }
      });
    }
  });
}
