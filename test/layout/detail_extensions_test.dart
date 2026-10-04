import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

void main() {
  test('StatTile detail size: 3x1, padding 15, 20/25, radius 12', () {
    expect(DabblerStatTileSize.detail.span, 3);
    expect(DabblerStatTileSize.detail.rows, 1);
    expect(DabblerStatTileSize.detail.padding, 15);
    expect(DabblerStatTileSize.detail.valueSize, 20);
    expect(DabblerStatTileSize.detail.valueLeading, 25);
    expect(DabblerStatTileSize.detail.radius, DabblerRadius.lgAll);
    expect(DabblerStatTileSize.small.radius, DabblerRadius.xlAll);
  });

  test('StatTile success tone uses the success status roles', () {
    final DabblerColors c = testColors();
    expect(
      DabblerStatTile.fillFor(c, DabblerStatTileTone.success),
      c.success.surface,
    );
    expect(
      DabblerStatTile.foregroundFor(c, DabblerStatTileTone.success),
      c.success.strong,
    );
  });

  for (final TextDirection d in TextDirection.values) {
    testWidgets('detail tile value is bold sans 20 — $d', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        host(
          const SizedBox(
            height: 100,
            child: DabblerStatTile(
              size: DabblerStatTileSize.detail,
              value: '7:30',
              label: 'مساء',
            ),
          ),
          direction: d,
        ),
      );
      final Text v = t.widget<Text>(find.text('7:30'));
      expect(v.style!.fontSize, 20);
      expect(v.style!.fontWeight, DabblerType.bold);
    });

    testWidgets('Section label: subtitle beside the title — $d', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        host(
          const DabblerSection(
            style: DabblerSectionStyle.label,
            title: 'Spaces',
            subtitle: 'three',
          ),
          direction: d,
        ),
      );
      expect(
        (t.getCenter(find.text('Spaces')).dy -
                t.getCenter(find.text('three')).dy)
            .abs(),
        lessThan(8),
      );
    });

    testWidgets('Chip compact: sunken fill, transparent border — $d', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        host(const DabblerChip(label: 'Parking', compact: true), direction: d),
      );
      final DabblerColors c = testColors();
      final DabblerSurface s = t.widget<DabblerSurface>(
        find.byType(DabblerSurface),
      );
      expect(s.fill, c.surfaceSunken);
      expect(s.borderColor, Colors.transparent);
    });
  }
}
