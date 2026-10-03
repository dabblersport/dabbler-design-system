import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _icon(String name) =>
    find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == name);

void main() {
  group('DabblerSelectableCard — row', () {
    testWidgets('idle shows the record glyph, selected the tick', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSelectableCard(title: 'Player', icon: 'game')),
      );
      expect(_icon('record'), findsOneWidget);
      expect(_icon('tick-circle'), findsNothing);

      await tester.pumpWidget(
        host(
          const DabblerSelectableCard(
            title: 'Player',
            icon: 'game',
            selected: true,
          ),
        ),
      );
      expect(_icon('tick-circle'), findsOneWidget);
      final DabblerIcon tick = tester.widget<DabblerIcon>(_icon('tick-circle'));
      expect(tick.weight, DabblerIconWeight.bold);
      expect(tick.color, testColors().brandPrimary);
      final DabblerIcon glyph = tester.widget<DabblerIcon>(_icon('game'));
      expect(glyph.weight, DabblerIconWeight.bold);
    });

    testWidgets('selected border is the tint at twice borderDefault', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSelectableCard(title: 'x', selected: true)),
      );
      final DabblerSurface s = tester.widget<DabblerSurface>(
        find.byType(DabblerSurface),
      );
      expect(s.borderColor, testColors().brandPrimary);
      expect(s.borderWidth, DabblerSizing.borderDefault * 2);
      expect(s.radius, DabblerRadius.lg);
      expect(
        s.fill,
        DabblerSurface.tintedFillOf(testColors(), testColors().brandPrimary),
      );
    });

    testWidgets('tap calls onChanged with the toggled value', (
      WidgetTester tester,
    ) async {
      final List<bool> got = <bool>[];
      await tester.pumpWidget(
        host(DabblerSelectableCard(title: 'Player', onChanged: got.add)),
      );
      await tester.tap(find.byType(DabblerSelectableCard));
      await tester.pumpAndSettle();
      expect(got, <bool>[true]);
    });

    testWidgets('keyboard activation toggles', (WidgetTester tester) async {
      final List<bool> got = <bool>[];
      await tester.pumpWidget(
        host(
          DabblerSelectableCard(
            title: 'Player',
            selected: true,
            onChanged: got.add,
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(got, <bool>[false]);
    });

    testWidgets('semantics: button, selected state, joined label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          DabblerSelectableCard(
            caption: 'Player',
            title: 'Find games',
            subtitle: 'Near you',
            selected: true,
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DabblerSelectableCard)),
        isSemantics(
          label: 'Player, Find games, Near you',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('disabled without onChanged', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerSelectableCard(title: 'x')));
      expect(
        tester.getSemantics(find.byType(DabblerSelectableCard)),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
      handle.dispose();
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('glyph at inline start, check at inline end ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(title: 'x', icon: 'game'),
            direction: dir,
          ),
        );
        final double glyph = tester.getCenter(_icon('game')).dx;
        final double check = tester.getCenter(_icon('record')).dx;
        expect(dir == TextDirection.ltr ? glyph < check : glyph > check, true);
      });
    }
  });

  group('DabblerSelectableCard — tile', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('check sits in the top inline-end corner ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const Center(
              child: SizedBox(
                width: 80,
                child: DabblerSelectableCard(
                  layout: DabblerSelectableCardLayout.tile,
                  title: 'Padel',
                  icon: 'cup',
                  selected: true,
                ),
              ),
            ),
            direction: dir,
          ),
        );
        final Rect card = tester.getRect(find.byType(DabblerSurface));
        final Rect tick = tester.getRect(_icon('tick-circle'));
        expect(tick.top - card.top, lessThan(DabblerSpacing.space4));
        if (dir == TextDirection.ltr) {
          expect(card.right - tick.right, lessThan(DabblerSpacing.space4));
        } else {
          expect(tick.left - card.left, lessThan(DabblerSpacing.space4));
        }
        final DabblerSurface s = tester.widget<DabblerSurface>(
          find.byType(DabblerSurface),
        );
        expect(s.radius, DabblerRadius.md);
      });
    }

    testWidgets('idle tile has no check', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerSelectableCard(
            layout: DabblerSelectableCardLayout.tile,
            title: 'Padel',
          ),
        ),
      );
      expect(_icon('tick-circle'), findsNothing);
      expect(_icon('record'), findsNothing);
    });
  });
}
