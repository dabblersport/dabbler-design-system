import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: dir,
        child: Theme(
          data: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              DabblerColors.resolve(
                theme: DabblerTheme.main,
                brightness: Brightness.light,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

Color _glyphColor(WidgetTester t, String icon) =>
    t.widget<DabblerIcon>(find.byWidgetPredicate(
      (Widget w) => w is DabblerIcon && w.name == icon,
    )).color!;

void main() {
  for (final TextDirection d in TextDirection.values) {
    testWidgets('action tone colours the glyph (${d.name})', (t) async {
      await t.pumpWidget(_host(
        dir: d,
        Column(children: <Widget>[
          DabblerNavigationTopBar.titled(
            title: 'N',
            safeArea: false,
            actions: <DabblerNavigationAction>[
              DabblerNavigationAction(
                icon: 'tick-circle',
                label: 'a',
                tone: DabblerNavigationActionTone.brand,
                onPressed: () {},
              ),
              DabblerNavigationAction(
                icon: 'setting-2',
                label: 'b',
                tone: DabblerNavigationActionTone.subtle,
                onPressed: () {},
              ),
            ],
          ),
        ]),
      ));
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      expect(_glyphColor(t, 'tick-circle'), c.brandPrimary);
      expect(_glyphColor(t, 'setting-2'), c.textTertiary);
    });

    testWidgets('heroTint paints the hero tint until scrolled (${d.name})',
        (t) async {
      final ScrollController sc = ScrollController();
      addTearDown(sc.dispose);
      await t.pumpWidget(_host(
        dir: d,
        Column(children: <Widget>[
          DabblerNavigationTopBar.titled(
            title: 'Settings',
            safeArea: false,
            scrollController: sc,
            titleRevealOffset: 50,
            heroTint: true,
          ),
          Expanded(
            child: ListView(controller: sc, children: const <Widget>[
              SizedBox(height: 3000),
            ]),
          ),
        ]),
      ));
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      );
      Color bg() => (t
              .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
              .decoration as BoxDecoration)
          .color!;
      expect(bg(), DabblerSettingsHeader.tintFor(c));
      sc.jumpTo(200);
      await t.pump();
      await t.pump();
      expect(bg(), c.bgPrimary);
    });
  }

  for (final TextDirection d in TextDirection.values) {
    testWidgets('group header shows count between label and rule (${d.name})',
        (t) async {
      await t.pumpWidget(_host(
        dir: d,
        const DabblerActivityGroupHeader('Today', count: '3 items', dense: true),
      ));
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
    });

    testWidgets('chip trailingIcon draws after the label (${d.name})',
        (t) async {
      await t.pumpWidget(_host(
        dir: d,
        Center(
          child: DabblerChip(
            label: '11 PM',
            onTap: () {},
            trailingIcon: const DabblerIcon('arrow-circle-right'),
          ),
        ),
      ));
      final Offset label = t.getCenter(find.text('11 PM'));
      final Offset icon = t.getCenter(find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name == 'arrow-circle-right',
      ));
      expect(d == TextDirection.ltr ? icon.dx > label.dx : icon.dx < label.dx,
          isTrue);
    });
  }
}
