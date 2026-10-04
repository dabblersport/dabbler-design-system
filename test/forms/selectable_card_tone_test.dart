import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

Finder _icon(String name) =>
    find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == name);

void main() {
  group('DabblerSelectableCard — tone', () {
    testWidgets('a tone supplies fill, idle edge and selected edge', (
      WidgetTester tester,
    ) async {
      final DabblerHueTone tone = DabblerHueTone.forSportKey('padel');
      await tester.pumpWidget(
        host(DabblerSelectableCard(title: 'Padel', tone: tone)),
      );
      DabblerSurface s = tester.widget<DabblerSurface>(
        find.byType(DabblerSurface),
      );
      expect(s.fill, tone.surface);
      expect(s.borderColor, tone.edge);
      expect(s.borderWidth, DabblerSizing.borderDefault);

      await tester.pumpWidget(
        host(DabblerSelectableCard(title: 'Padel', tone: tone, selected: true)),
      );
      s = tester.widget<DabblerSurface>(find.byType(DabblerSurface));
      expect(s.borderColor, tone.solid);
      expect(s.borderWidth, DabblerSizing.borderDefault * 2);
    });

    testWidgets('a ramp tone colours the idle radio from its idle step', (
      WidgetTester tester,
    ) async {
      final DabblerHueTone tone = DabblerHueTone.ramp(
        base: DabblerPalette.sportP600,
        deep: DabblerPalette.sportP700,
        card: testColors().surfaceCard,
      );
      await tester.pumpWidget(
        host(DabblerSelectableCard(title: 'Player', icon: 'game', tone: tone)),
      );
      expect(tester.widget<DabblerIcon>(_icon('record')).color, tone.idle);
      expect(tester.widget<DabblerIcon>(_icon('game')).color, tone.deep);
    });
  });

  group('DabblerSelectableCard — listRow', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('glyph, label and check, at least 63 tall ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(
              layout: DabblerSelectableCardLayout.listRow,
              icon: 'game',
              title: 'كرة القدم',
              selected: true,
            ),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(DabblerSurface)).height,
          greaterThanOrEqualTo(DabblerSelectableCard.listRowMinHeight),
        );
        final double glyph = tester.getCenter(_icon('game')).dx;
        final double check = tester.getCenter(_icon('tick-circle')).dx;
        expect(
          dir == TextDirection.ltr ? glyph < check : glyph > check,
          isTrue,
        );
      });
    }
  });

  group('DabblerSelectableCard — stacked', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('glyph over the label, check after it ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const DabblerSelectableCard(
              layout: DabblerSelectableCardLayout.stacked,
              icon: 'man',
              title: 'ذكر',
              selected: true,
            ),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(DabblerSurface)).height,
          greaterThanOrEqualTo(DabblerSelectableCard.stackedMinHeight),
        );
        expect(
          tester.getCenter(_icon('man')).dy,
          lessThan(tester.getCenter(_icon('tick-circle')).dy),
        );
        expect(
          tester.widget<DabblerSurface>(find.byType(DabblerSurface)).radius,
          DabblerRadius.lg,
        );
      });
    }

    testWidgets('the check is absent while idle', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerSelectableCard(
            layout: DabblerSelectableCardLayout.stacked,
            icon: 'man',
            title: 'Male',
          ),
        ),
      );
      expect(_icon('tick-circle'), findsNothing);
    });
  });
}
