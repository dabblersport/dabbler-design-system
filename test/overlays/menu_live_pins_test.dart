import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/overlays/menu.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pinned against a hand-transcribed mirror of live `components/overlays/Menu.jsx` of the Claude Design
/// project 4286affa-bf50-4ff6-9576-917f76a93ca1 (Dabbler Design System), read
/// via DesignSync get_file on 2026-10-02 and hand-transcribed (no byte check) to a local mirror by
/// the coordinator.
Widget _host(Widget child, {TextDirection d = TextDirection.ltr}) {
  final DabblerColors c = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[c]),
    home: Directionality(
      textDirection: d,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );
}

void main() {
  test(
    'constants: 480 sheet breakpoint, 200/320 width, 45dvh, 0.45 detent',
    () {
      // Menu.jsx: `(max-width: 479px)` sheet, `minWidth 200`, `maxWidth 320`,
      // `maxHeight: '45dvh'`, `detents={[0.45]}`, gap `--space-2`.
      expect(DabblerMenu.sheetBreakpoint, 480);
      expect(DabblerMenu.minPopoverWidth, 200);
      expect(DabblerMenu.maxPopoverWidth, 320);
      expect(DabblerMenu.maxHeightFraction, 0.45);
      expect(DabblerMenu.sheetDetents, <double>[0.45]);
      expect(DabblerMenu.anchorGap, DabblerSpacing.space2);
      // MenuItem: tile 30 (`width: 30, height: 30`), 12% mix, disabled .45.
      expect(DabblerMenuItem.tileSide, 30);
      expect(DabblerMenuItem.tileTintOpacity, 0.12);
      expect(DabblerMenuItem.disabledOpacity, 0.45);
    },
  );

  testWidgets('iconTone is a 30px tinted square with a 12% tone fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerMenuItem(
          label: 'x',
          icon: 'star',
          iconTone: DabblerMenuIconTone.success,
        ),
      ),
    );
    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );
    final Finder tile = find.byKey(DabblerMenuItem.tileKey);
    expect(tester.getSize(tile), const Size(30, 30));
    final BoxDecoration d =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: tile,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(d.color, c.success.base.withValues(alpha: 0.12));
    expect(d.borderRadius, DabblerRadius.mdAll);
  });

  testWidgets('row metrics: min 45, inline padding 9 (6 with a tile), gap 9', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: <Widget>[
            DabblerMenuItem(label: 'plain', icon: 'star'),
            DabblerMenuItem(
              label: 'tile',
              icon: 'star',
              iconTone: DabblerMenuIconTone.brand,
            ),
          ],
        ),
      ),
    );
    final Rect plain = tester.getRect(find.byType(DabblerMenuItem).first);
    final Rect tiled = tester.getRect(find.byType(DabblerMenuItem).last);
    expect(plain.height, greaterThanOrEqualTo(45));
    expect(tiled.height, greaterThanOrEqualTo(45));
    // Menu.jsx: `paddingInline: tint ? space-2 : space-3`.
    final Rect glyph = tester.getRect(find.byType(Icon).first);
    expect(glyph.left - plain.left, 9);
    final Rect tile = tester.getRect(find.byKey(DabblerMenuItem.tileKey));
    expect(tile.left - tiled.left, 6);
    // The label sits `--space-3` (9) after the leading visual.
    final Rect label = tester.getRect(find.text('plain'));
    expect(label.left - glyph.right, 9);
  });

  testWidgets('the same metrics mirror under RTL', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        const DabblerMenuItem(
          label: 'tile',
          icon: 'star',
          iconTone: DabblerMenuIconTone.brand,
        ),
        d: TextDirection.rtl,
      ),
    );
    final Rect row = tester.getRect(find.byType(DabblerMenuItem));
    final Rect tile = tester.getRect(find.byKey(DabblerMenuItem.tileKey));
    expect(row.right - tile.right, 6);
  });

  testWidgets('destructive is the strong error ink; disabled is .45', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: <Widget>[
            DabblerMenuItem(
              label: 'bin',
              icon: 'trash',
              tone: DabblerMenuItemTone.destructive,
            ),
            DabblerMenuItem(label: 'off', icon: 'lock', disabled: true),
          ],
        ),
      ),
    );
    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );
    expect(tester.widget<Text>(find.text('bin')).style!.color, c.error.strong);
    final Opacity o = tester.widget<Opacity>(
      find.ancestor(of: find.text('off'), matching: find.byType(Opacity)).first,
    );
    expect(o.opacity, 0.45);
  });

  testWidgets('selected draws a bold 18px tick-circle in the brand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerMenuItem(label: 's', icon: 'star', selected: true)),
    );
    // Live `MenuItem`: `<Icon name="tick-circle" type="bold" size={18}
    // color="var(--color-brand-primary)" />` when `selected`.
    final DabblerIcon tick = tester.widget<DabblerIcon>(
      find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'tick-circle',
      ),
    );
    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );
    expect(tick.weight, DabblerIconWeight.bold);
    expect(tick.size, 18);
    expect(tick.color, c.brandPrimary);
    // The leading glyph is the other icon: linear, 18.
    final DabblerIcon lead = tester.widget<DabblerIcon>(
      find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'star',
      ),
    );
    expect(lead.weight, DabblerIconWeight.linear);
    expect(lead.size, 18);
  });
}
