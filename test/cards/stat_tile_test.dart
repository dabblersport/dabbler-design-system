import 'package:dabbler_design_system/src/cards/stat_tile.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
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
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

void main() {
  group('footprints — StatTile.jsx SIZES', () {
    test('span, rows, padding and value type per size', () {
      expect(DabblerStatTileSize.small.span, 2);
      expect(DabblerStatTileSize.small.rows, 1);
      expect(DabblerStatTileSize.small.padding, 12);
      expect(DabblerStatTileSize.small.valueSize, 26);
      expect(DabblerStatTileSize.small.valueLeading, 30);
      expect(DabblerStatTileSize.hero.span, 4);
      expect(DabblerStatTileSize.hero.rows, 2);
      expect(DabblerStatTileSize.hero.valueSize, 46);
      expect(DabblerStatTileSize.hero.valueLeading, 48);
      expect(DabblerStatTileSize.wide.span, 6);
      expect(DabblerStatTileSize.wide.rows, 2);
      expect(DabblerStatTileSize.wide.valueSize, 22);
    });

    test('span and rows override the size', () {
      const DabblerStatTile t = DabblerStatTile(
        value: '1',
        label: 'a',
        span: 3,
        rows: 2,
      );
      expect(t.effectiveSpan, 3);
      expect(t.effectiveRows, 2);
    });

    test('art boxes per size', () {
      final a = DabblerStatTile.artBoxFor(DabblerStatTileSize.hero);
      expect((a.width, a.height, a.right, a.top), (0.52, 0.72, -0.04, 0.14));
      final w = DabblerStatTile.artBoxFor(DabblerStatTileSize.wide);
      expect((w.width, w.height, w.right, w.top), (0.30, 1.0, 0.02, 0.0));
    });
  });

  group('value type — the recorded overrides', () {
    test('small is title-1 face at 26/30, hero large-title at 46/48', () {
      final TextStyle s = DabblerStatTile.valueStyleFor(
        DabblerStatTileSize.small,
        TextDirection.ltr,
      );
      expect(s.fontSize, 26);
      expect(s.height! * s.fontSize!, closeTo(30, 0.001));
      expect(s.fontFamily, contains('Gloock'));
      final TextStyle h = DabblerStatTile.valueStyleFor(
        DabblerStatTileSize.hero,
        TextDirection.ltr,
      );
      expect(h.fontSize, 46);
      expect(h.height! * h.fontSize!, closeTo(48, 0.001));
    });

    test(
      'wide keeps title-2 at its own 22 with leading 28 (26 not applied)',
      () {
        final TextStyle s = DabblerStatTile.valueStyleFor(
          DabblerStatTileSize.wide,
          TextDirection.ltr,
        );
        expect(s.fontSize, 22);
        expect(s.height! * s.fontSize!, closeTo(28, 0.001));
      },
    );

    test('tracking is -0.01em', () {
      final TextStyle s = DabblerStatTile.valueStyleFor(
        DabblerStatTileSize.small,
        TextDirection.ltr,
      );
      expect(s.letterSpacing, closeTo(-0.26, 0.0001));
    });

    testWidgets('the label is footnote 13/18 at weight 600', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const DabblerStatTile(value: '9', label: 'Games', sub: 'sub')),
      );
      final Text label = tester.widget<Text>(find.text('Games'));
      expect(label.style!.fontSize, 13);
      expect(label.style!.fontWeight, FontWeight.w600);
      final Text sub = tester.widget<Text>(find.text('sub'));
      expect(sub.style!.fontSize, 12);
    });
  });

  group('tones', () {
    test('every tone resolves a fill, border, ink and sub colour', () {
      final DabblerColors c = _colors();
      for (final DabblerStatTileTone t in DabblerStatTileTone.values) {
        DabblerStatTile.fillFor(c, t);
        DabblerStatTile.borderFor(c, t);
        DabblerStatTile.foregroundFor(c, t);
        DabblerStatTile.subFor(c, t);
      }
      expect(
        DabblerStatTile.fillFor(c, DabblerStatTileTone.card),
        c.surfaceCard,
      );
      expect(
        DabblerStatTile.borderFor(c, DabblerStatTileTone.card),
        c.borderDefault,
      );
      expect(
        DabblerStatTile.fillFor(c, DabblerStatTileTone.brand),
        c.brandPrimary,
      );
      expect(
        DabblerStatTile.foregroundFor(c, DabblerStatTileTone.brand),
        c.onBrand,
      );
      expect(
        DabblerStatTile.fillFor(c, DabblerStatTileTone.amber),
        DabblerColors.tileAmber.surface,
      );
      expect(
        DabblerStatTile.foregroundFor(c, DabblerStatTileTone.danger),
        c.error.strong,
      );
    });

    test('only brand and ink knock the art out to white', () {
      for (final DabblerStatTileTone t in DabblerStatTileTone.values) {
        expect(
          DabblerStatTile.knockoutFor(t),
          t == DabblerStatTileTone.brand || t == DabblerStatTileTone.ink,
        );
      }
    });

    test('sub opacities: brand 80%, ink 70%, amber 62%', () {
      final DabblerColors c = _colors();
      expect(
        DabblerStatTile.subFor(c, DabblerStatTileTone.brand).a,
        closeTo(0.8, 0.01),
      );
      expect(
        DabblerStatTile.subFor(c, DabblerStatTileTone.ink).a,
        closeTo(0.7, 0.01),
      );
      expect(
        DabblerStatTile.subFor(c, DabblerStatTileTone.amber).a,
        closeTo(0.62, 0.01),
      );
      expect(
        DabblerStatTile.subFor(c, DabblerStatTileTone.card),
        c.textSecondary,
      );
    });
  });

  group('interaction', () {
    testWidgets('an inert tile is not a button and not focusable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DabblerStatTile(value: '9', label: 'Games')),
      );
      final SemanticsNode n = tester.getSemantics(find.byType(DabblerStatTile));
      expect(n.label, '9, Games');
      expect(n.flagsCollection.isButton, isFalse);
      h.dispose();
    });

    testWidgets('onTap makes it a button that fires once and is 45 tall', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerStatTile(value: '9', label: 'Games', onTap: () => taps++)),
      );
      final SemanticsNode n = tester.getSemantics(find.byType(DabblerStatTile));
      expect(n.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(DabblerStatTile));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(DabblerStatTile)).height,
        greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
      );
      h.dispose();
    });

    testWidgets('link announces as a link', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          DabblerStatTile(value: '9', label: 'Games', link: true, onTap: () {}),
        ),
      );
      final SemanticsNode n = tester.getSemantics(find.byType(DabblerStatTile));
      expect(n.flagsCollection.isLink, isTrue);
      expect(n.flagsCollection.isButton, isFalse);
      h.dispose();
    });

    testWidgets('Enter activates a focused tile', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerStatTile(value: '9', label: 'Games', onTap: () => taps++)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('trailing sits at the inline end and mirrors in RTL', (
      WidgetTester tester,
    ) async {
      const Key k = Key('trail');
      Future<Offset> at(TextDirection d) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              height: 78,
              child: DabblerStatTile(
                value: '9',
                label: 'Games',
                trailing: SizedBox(key: k, width: 18, height: 18),
              ),
            ),
            direction: d,
          ),
        );
        return tester.getTopLeft(find.byKey(k));
      }

      final Offset ltr = await at(TextDirection.ltr);
      final Offset rtl = await at(TextDirection.rtl);
      expect(ltr.dx, greaterThan(180), reason: 'inline end is the right');
      expect(rtl.dx, lessThan(180), reason: 'inline end is the left in RTL');
    });
  });

  group('DabblerStatGrid placement — CSS grid auto-flow', () {
    test('two smalls and a hero: hero wraps to the next row', () {
      final p = DabblerStatGrid.place(<(int, int)>[(2, 1), (2, 1), (4, 2)]);
      expect(p.origins, <(int, int)>[(0, 0), (2, 0), (0, 1)]);
      expect(p.rows, 3);
    });

    test('three smalls fill one row; the fourth starts a new row', () {
      final p = DabblerStatGrid.place(<(int, int)>[
        (2, 1),
        (2, 1),
        (2, 1),
        (2, 1),
      ]);
      expect(p.origins, <(int, int)>[(0, 0), (2, 0), (4, 0), (0, 1)]);
    });

    test('a tall hero lets later smalls fill beside it (auto-flow row)', () {
      final p = DabblerStatGrid.place(<(int, int)>[(4, 2), (2, 1), (2, 1)]);
      expect(p.origins, <(int, int)>[(0, 0), (4, 0), (4, 1)]);
      expect(p.rows, 2);
    });

    test('constants are the source', () {
      expect(DabblerStatGrid.columns, 6);
      expect(DabblerStatGrid.rowHeight, 78);
      expect(DabblerStatGrid.gap, 9);
    });

    testWidgets('a grid sizes tiles by columns, rows and gap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerStatGrid(
            children: <DabblerStatTile>[
              DabblerStatTile(value: '1', label: 'a'),
              DabblerStatTile(
                value: '2',
                label: 'b',
                size: DabblerStatTileSize.hero,
              ),
            ],
          ),
        ),
      );
      const double cell = (360 - 5 * 9) / 6;
      final Size small = tester.getSize(find.byType(DabblerStatTile).first);
      expect(small.width, closeTo(2 * cell + 9, 0.01));
      expect(small.height, 78);
      final Size hero = tester.getSize(find.byType(DabblerStatTile).last);
      expect(hero.width, closeTo(4 * cell + 3 * 9, 0.01));
      expect(hero.height, 2 * 78 + 9);
    });
  });

  testWidgets('every tone and size renders in RTL and dark without error', (
    WidgetTester tester,
  ) async {
    for (final Brightness b in Brightness.values) {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: b,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[c]),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: DabblerStatGrid(
                  children: <DabblerStatTile>[
                    for (final DabblerStatTileTone t
                        in DabblerStatTileTone.values)
                      DabblerStatTile(value: '٤', label: 'x', tone: t),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
