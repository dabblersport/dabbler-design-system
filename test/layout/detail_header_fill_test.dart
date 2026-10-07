import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

/// `DabblerDetailHeader.fillOf` is the colour `build()` paints: the band's
/// ColoredBox and the exposed fill are the same function.
void main() {
  for (final Brightness b in Brightness.values) {
    final String mode = b == Brightness.dark ? 'dark' : 'light';

    Future<void> check(
      WidgetTester t, {
      DabblerDetailHeaderTile? tile,
      DabblerTheme theme = DabblerTheme.sport,
      required Color expected,
    }) async {
      late BuildContext inner;
      await t.pumpWidget(
        host(
          Builder(
            builder: (BuildContext context) {
              inner = context;
              return DabblerDetailHeader(
                title: 'Title',
                tile: tile,
                theme: theme,
              );
            },
          ),
          brightness: b,
        ),
      );
      final ColoredBox band = t.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(DabblerDetailHeader),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      final Color exposed = DabblerDetailHeader.fillOf(
        inner,
        tile: tile,
        theme: theme,
      );
      expect(band.color, exposed, reason: 'painted == exposed ($mode)');
      expect(exposed, expected);
    }

    testWidgets('fillOf is the painted sport band — $mode', (
      WidgetTester t,
    ) async {
      await check(
        t,
        expected: DabblerColors.resolve(
          theme: DabblerTheme.sport,
          brightness: b,
        ).brandPrimary,
      );
    });

    testWidgets('fillOf follows the section theme — $mode', (
      WidgetTester t,
    ) async {
      await check(
        t,
        theme: DabblerTheme.social,
        expected: DabblerColors.resolve(
          theme: DabblerTheme.social,
          brightness: b,
        ).brandPrimary,
      );
    });

    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.sport,
      brightness: b,
    );
    for (final (DabblerDetailHeaderTile, DabblerToneColor) e
        in <(DabblerDetailHeaderTile, DabblerToneColor)>[
          (DabblerDetailHeaderTile.amber, c.tileAmberTone),
          (DabblerDetailHeaderTile.info, c.tileInfoTone),
          (DabblerDetailHeaderTile.accent, c.tileAccentTone),
        ]) {
      testWidgets('fillOf is the ${e.$1.name} tile surface — $mode', (
        WidgetTester t,
      ) async {
        await check(t, tile: e.$1, expected: e.$2.surface);
      });
    }
  }
}
