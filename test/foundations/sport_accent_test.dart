import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _wrap(
  Widget child, {
  TextDirection d = TextDirection.ltr,
  Brightness b = Brightness.light,
}) => host(
  Row(children: <Widget>[child]),
  direction: d,
  brightness: b,
);

DabblerSurface _pill(WidgetTester t) => t.widget<DabblerSurface>(
  find.descendant(
    of: find.byType(DabblerChip),
    matching: find.byType(DabblerSurface),
  ),
);

Text _label(WidgetTester t, String s) => t.widget<Text>(find.text(s));

void main() {
  group('DabblerSportAccent.of — Profiles.dc.html:474-480', () {
    test('the four listed sports take their own ramps', () {
      expect(DabblerSportAccent.of('padel').base, DabblerPalette.mainP600);
      expect(DabblerSportAccent.of('padel').tint, DabblerPalette.mainP300);
      expect(DabblerSportAccent.of('padel').deep, DabblerPalette.mainP700);
      expect(DabblerSportAccent.of('football').base, DabblerPalette.sportP600);
      expect(
        DabblerSportAccent.of('basketball').base,
        DabblerPalette.activeP600,
      );
      expect(
        DabblerSportAccent.of('basketball').deep,
        DabblerColors.tileAccent.ink,
      );
      expect(DabblerSportAccent.of('tennis').base, DabblerPalette.socialP600);
      expect(DabblerSportAccent.of('tennis').deep, DabblerColors.tileInfo.ink);
    });

    test('anything else is the All entry, as ACCENT[sel] ?? ACCENT.All', () {
      for (final String? k in <String?>[
        null,
        '',
        'running',
        'table-tennis',
        'nope',
      ]) {
        expect(DabblerSportAccent.of(k), DabblerSportAccent.all);
      }
      expect(DabblerSportAccent.all.base, DabblerPalette.sportP600);
      expect(
        DabblerSportAccent.forSport(DabblerSport.tennis),
        DabblerSportAccent.tennis,
      );
      expect(DabblerSportAccent.forSport(null), DabblerSportAccent.all);
    });

    test('introduces no colour of its own', () {
      const List<String> keys = <String>[
        'padel',
        'football',
        'basketball',
        'tennis',
      ];
      final Set<Color> palette = <Color>{
        DabblerPalette.mainP300,
        DabblerPalette.mainP600,
        DabblerPalette.mainP700,
        DabblerPalette.sportP300,
        DabblerPalette.sportP600,
        DabblerPalette.sportP700,
        DabblerPalette.activeP300,
        DabblerPalette.activeP600,
        DabblerPalette.activeP700,
        DabblerPalette.socialP300,
        DabblerPalette.socialP600,
        DabblerPalette.socialP700,
      };
      for (final String k in keys) {
        final DabblerSportAccent a = DabblerSportAccent.of(k);
        expect(palette, containsAll(<Color>[a.base, a.tint, a.deep]));
      }
    });

    test('onColorOf follows the theme, not the accent', () {
      for (final Brightness b in Brightness.values) {
        final DabblerColors c = testColors(brightness: b);
        expect(DabblerSportAccent.onColorOf(c), c.onBrand);
      }
    });
  });

  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      group('DabblerChip accent $b $d', () {
        testWidgets('selected: base fill, transparent border, on-brand ink, '
            'dot at 70%', (WidgetTester tester) async {
          await tester.pumpWidget(
            _wrap(
              DabblerChip(
                label: 'Padel',
                selected: true,
                accent: DabblerSportAccent.padel,
                dot: true,
                size: DabblerChipSize.large,
                leadingIcon: const DabblerIcon('game'),
                onTap: () {},
              ),
              d: d,
              b: b,
            ),
          );
          final DabblerColors c = testColors(brightness: b);
          expect(_pill(tester).fill, DabblerPalette.mainP600);
          expect(_pill(tester).borderColor, Colors.transparent);
          expect(_label(tester, 'Padel').style!.color, c.onBrand);
          // 45 tall, the painted pill is the target.
          expect(
            tester.getSize(find.byType(DabblerSurface)).height,
            DabblerChip.largeHeight,
          );
          final DecoratedBox dot = tester
              .widgetList<DecoratedBox>(find.byType(DecoratedBox))
              .firstWhere(
                (DecoratedBox w) =>
                    (w.decoration as BoxDecoration).shape == BoxShape.circle,
              );
          expect(
            (dot.decoration as BoxDecoration).color,
            c.onBrand.withValues(alpha: 0.7),
          );
        });

        testWidgets('idle: card fill, secondary ink, accent dot', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            _wrap(
              DabblerChip(
                label: 'Tennis',
                accent: DabblerSportAccent.tennis,
                dot: true,
                size: DabblerChipSize.large,
                onTap: () {},
              ),
              d: d,
              b: b,
            ),
          );
          final DabblerColors c = testColors(brightness: b);
          expect(_pill(tester).fill, isNull);
          expect(_label(tester, 'Tennis').style!.color, c.textSecondary);
          final DecoratedBox dot = tester
              .widgetList<DecoratedBox>(find.byType(DecoratedBox))
              .firstWhere(
                (DecoratedBox w) =>
                    (w.decoration as BoxDecoration).shape == BoxShape.circle,
              );
          expect(
            (dot.decoration as BoxDecoration).color,
            DabblerPalette.socialP600,
          );
        });

        testWidgets('Arabic label renders; large chip is 14 semibold', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            _wrap(
              DabblerChip(
                label: 'بادل',
                selected: true,
                accent: DabblerSportAccent.padel,
                size: DabblerChipSize.large,
                onTap: () {},
              ),
              d: d,
              b: b,
            ),
          );
          expect(tester.takeException(), isNull);
          final TextStyle s = _label(tester, 'بادل').style!;
          expect(s.fontWeight, DabblerType.semibold);
          expect(
            s.fontSize,
            DabblerType.subheadline.resolveForDirection(d).fontSize! - 1,
          );
        });
      });
    }
  }

  testWidgets('a vibe wins over an accent', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        DabblerChip(
          label: 'Calm',
          vibe: DabblerVibe.calm,
          accent: DabblerSportAccent.padel,
          selected: true,
          onTap: () {},
        ),
      ),
    );
    expect(_pill(tester).fill, isNot(DabblerPalette.mainP600));
  });

  testWidgets('small chip: 34 tall, 13/18 medium', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        DabblerChip(
          label: 'All',
          count: '4',
          size: DabblerChipSize.small,
          onTap: () {},
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(DabblerSurface)).height,
      DabblerChip.smallHeight,
    );
    final TextStyle s = _label(tester, 'All').style!;
    expect(s.fontSize, DabblerType.footnote.fontSize);
    expect(s.fontWeight, DabblerType.medium);
  });

  testWidgets('regular chip is unchanged: 38 tall, 15/20 medium', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(DabblerChip(label: 'x', onTap: () {})));
    expect(
      tester.getSize(find.byType(DabblerSurface)).height,
      DabblerChip.visualHeight,
    );
  });

  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('DabblerBadge accent $b $d', (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrap(
            const DabblerBadge(
              label: 'Basketball',
              accent: DabblerSportAccent.basketball,
            ),
            d: d,
            b: b,
          ),
        );
        final BoxDecoration deco =
            tester
                    .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                    .decoration
                as BoxDecoration;
        expect(deco.color, DabblerPalette.activeP600);
        expect(
          tester.widget<Text>(find.text('Basketball')).style!.color,
          testColors(brightness: b).onBrand,
        );
      });
    }
  }

  testWidgets('badge: status wins over accent', (WidgetTester tester) async {
    final DabblerColors c = testColors();
    await tester.pumpWidget(
      _wrap(
        DabblerBadge(
          label: 'x',
          accent: DabblerSportAccent.padel,
          status: c.success,
        ),
      ),
    );
    final BoxDecoration deco =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;
    expect(deco.color, c.success.surface);
  });

  for (final Brightness b in Brightness.values) {
    for (final TextDirection d in TextDirection.values) {
      testWidgets('cards take accent: $b $d', (WidgetTester tester) async {
        final DabblerColors c = testColors(brightness: b);
        final Color plain = DabblerCard.fillOf(c, DabblerCardVariant.standard);
        final Color tinted = DabblerSportAccent.padel.surfaceOver(plain);
        expect(tinted, isNot(plain));
        await tester.pumpWidget(
          host(
            Column(
              children: <Widget>[
                DabblerCardGame(
                  title: 'مباراة',
                  accent: DabblerSportAccent.padel,
                ),
                DabblerCardVenue(
                  name: 'ملعب',
                  accent: DabblerSportAccent.padel,
                ),
                const DabblerCardVenue(name: 'plain'),
              ],
            ),
            direction: d,
            brightness: b,
            width: 360,
          ),
        );
        expect(tester.takeException(), isNull);
        final List<DabblerCard> cards = tester
            .widgetList<DabblerCard>(find.byType(DabblerCard))
            .toList();
        expect(cards[0].fill, tinted);
        expect(cards[1].fill, tinted);
        expect(cards[2].fill, isNull);
      });
    }
  }
}
