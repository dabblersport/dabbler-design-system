import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabbler_design_system/components/dabbler_card.dart';
import 'package:dabbler_design_system/components/dabbler_surface.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 320,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dabblerThemeData(DabblerTheme.main, Brightness.light),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(child: SizedBox(width: width, child: child)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('interactive card fires onTap; a non-tappable card does not',
      (tester) async {
    var taps = 0;
    await _pump(
      tester,
      DabblerCard(
        variant: DabblerCardVariant.interactive,
        onTap: () => taps++,
        child: const Text('Tap me'),
      ),
    );
    await tester.tap(find.byType(DabblerCard));
    await tester.pump();
    expect(taps, 1);

    // Standard card with no onTap is not interactive — no InkWell in the tree.
    await _pump(
      tester,
      const DabblerCard(child: Text('Static')),
    );
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('glass card: casts the two-part glass shadow and blurs once',
      (tester) async {
    await _pump(tester, const DabblerCard(child: Text('Glass')));

    // The two-part glass shadow (brand cast + white lip) is present.
    final shadowed = tester
        .widgetList<Container>(find.descendant(
          of: find.byType(DabblerCard),
          matching: find.byType(Container),
        ))
        .where((c) =>
            c.decoration is BoxDecoration &&
            ((c.decoration! as BoxDecoration).boxShadow?.isNotEmpty ?? false));
    expect(shadowed, isNotEmpty);
    expect(
      (shadowed.first.decoration! as BoxDecoration).boxShadow!.length,
      2, // coloured cast + white lip
    );

    // Exactly one BackdropFilter per top-level surface.
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('nested glass never nests BackdropFilters', (tester) async {
    await _pump(
      tester,
      const DabblerCard(
        child: DabblerCard(
          variant: DabblerCardVariant.filled,
          child: Text('Nested'),
        ),
      ),
    );
    // Outer card blurs; the nested card must skip its own filter.
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('reduce-transparency: high contrast disables every blur',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dabblerThemeData(DabblerTheme.main, Brightness.light),
        home: const MediaQuery(
          data: MediaQueryData(highContrast: true),
          child: Scaffold(
            body: Center(child: DabblerCard(child: Text('Solid'))),
          ),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Solid'), findsOneWidget);
  });

  testWidgets('list tile min height is >= 45 (>= 36 when dense)',
      (tester) async {
    await _pump(tester, const DabblerListTile(title: 'Standard'));
    expect(
      tester.getSize(find.byType(DabblerListTile)).height,
      greaterThanOrEqualTo(45),
    );

    await _pump(tester, const DabblerListTile(title: 'Dense', dense: true));
    expect(
      tester.getSize(find.byType(DabblerListTile)).height,
      greaterThanOrEqualTo(36),
    );
  });

  testWidgets('list tile: tap fires; disabled does not', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      DabblerListTile(title: 'Tap', onTap: () => taps++),
    );
    await tester.tap(find.byType(DabblerListTile));
    await tester.pump();
    expect(taps, 1);

    await _pump(
      tester,
      DabblerListTile(title: 'Off', enabled: false, onTap: () => taps++),
    );
    await tester.tap(find.byType(DabblerListTile), warnIfMissed: false);
    await tester.pump();
    expect(taps, 1); // unchanged
  });

  testWidgets('RTL: trailing chevron mirrors glyph + side; divider insets right',
      (tester) async {
    await _pump(
      tester,
      DabblerListTile(
        leading: const Icon(Icons.event),
        title: 'RTL',
        trailing: const DabblerChevron(),
        showDivider: true,
        onTap: () {},
      ),
      direction: TextDirection.rtl,
    );

    // Chevron glyph mirrors (› → ‹) and sits on the left (end side in RTL).
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    final tileRect = tester.getRect(find.byType(DabblerListTile));
    final chevron = tester.getCenter(find.byIcon(Icons.chevron_left));
    expect(chevron.dx, lessThan(tileRect.center.dx));

    // Divider (the ~0.5px-high box) is inset on the start = right side in RTL:
    // its left edge reaches the tile's left, its right edge is inset.
    Rect? dividerRect;
    for (final e in find.byType(Container).evaluate()) {
      final box = e.renderObject as RenderBox;
      if (box.size.height <= 1.0 && box.size.width > 1.0) {
        dividerRect = box.localToGlobal(Offset.zero) & box.size;
        break;
      }
    }
    expect(dividerRect, isNotNull);
    expect(dividerRect!.left, closeTo(tileRect.left, 1.0));
    expect(dividerRect.right, lessThan(tileRect.right - 1.0));
  });
}
