import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, Brightness b, TextDirection dir) => MediaQuery(
  data: const MediaQueryData(disableAnimations: true),
  child: Directionality(
    textDirection: dir,
    child: Theme(
      data: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(theme: DabblerTheme.main, brightness: b),
        ],
      ),
      child: child,
    ),
  ),
);

void main() {
  group('surfaceHeaderMessages token', () {
    test('is #DCEAFB in light and #16243F in dark, in every theme', () {
      for (final DabblerTheme t in DabblerTheme.values) {
        expect(
          DabblerColors.resolve(
            theme: t,
            brightness: Brightness.light,
          ).surfaceHeaderMessages,
          const Color(0xFFDCEAFB),
        );
        expect(
          DabblerColors.resolve(
            theme: t,
            brightness: Brightness.dark,
          ).surfaceHeaderMessages,
          const Color(0xFF16243F),
        );
      }
    });
  });

  group('DabblerNavigationTopBar heroTone', () {
    Future<Color> topColor(
      WidgetTester t,
      Brightness b,
      TextDirection d, {
      DabblerNavigationHeroTone? tone,
    }) async {
      final ScrollController sc = ScrollController();
      addTearDown(sc.dispose);
      await t.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              DabblerNavigationTopBar.titled(
                title: 'Messages',
                safeArea: false,
                scrollController: sc,
                heroTint: true,
                heroTone: tone ?? DabblerNavigationHeroTone.brand,
              ),
              Expanded(
                child: ListView(
                  controller: sc,
                  children: const <Widget>[SizedBox(height: 3000)],
                ),
              ),
            ],
          ),
          b,
          d,
        ),
      );
      return (t
                  .widget<AnimatedContainer>(
                    find.byType(AnimatedContainer).first,
                  )
                  .decoration
              as BoxDecoration)
          .color!;
    }

    for (final Brightness b in Brightness.values) {
      for (final TextDirection d in TextDirection.values) {
        testWidgets(
          'messages tone paints the token at the top (${b.name}, ${d.name})',
          (t) async {
            final DabblerColors c = DabblerColors.resolve(
              theme: DabblerTheme.main,
              brightness: b,
            );
            expect(
              await topColor(t, b, d, tone: DabblerNavigationHeroTone.messages),
              c.surfaceHeaderMessages,
            );
          },
        );

        testWidgets(
          'default tone is unchanged: the brand tint (${b.name}, ${d.name})',
          (t) async {
            final DabblerColors c = DabblerColors.resolve(
              theme: DabblerTheme.main,
              brightness: b,
            );
            expect(await topColor(t, b, d), DabblerSettingsHeader.tintFor(c));
          },
        );
      }
    }
  });
}
