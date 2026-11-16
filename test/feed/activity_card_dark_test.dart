// KAN-972: the Active card follows the theme. Every DabblerActivityTone has
// a dark pair from the package's dark palette (same hue family), readable to
// WCAG AA; the card has no light island; DabblerFeedPill takes dark colours
// from data or derives them from the hue. Light and dark, LTR and RTL.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

TextStyle _text(WidgetTester tester, String s) =>
    tester.widget<Text>(find.text(s)).style!;

BoxDecoration _deco(WidgetTester tester, Finder f) =>
    tester.widget<DecoratedBox>(f).decoration as BoxDecoration;

void main() {
  final DabblerColors dark = testColors(brightness: Brightness.dark);
  final DabblerColors light = testColors();

  group('DabblerActivityTone', () {
    test('light is the design pair; dark is the dark palette pair', () {
      expect(DabblerActivityTone.main.light, DabblerActivityTones.main);
      expect(DabblerActivityTone.gold.light, DabblerActivityTones.gold);
      expect(DabblerActivityTone.info.light, DabblerActivityTones.info);
      final Map<DabblerActivityTone, (Color, Color)> pinned =
          <DabblerActivityTone, (Color, Color)>{
            DabblerActivityTone.main: (
              Color.lerp(
                DabblerProvisionalDark.surfaceCard,
                DabblerPalette.mainP400,
                0.14,
              )!,
              DabblerPalette.mainP300,
            ),
            DabblerActivityTone.sport: (
              const Color(0xFF0E3A2E),
              DabblerPalette.sportP300,
            ),
            DabblerActivityTone.social: (
              const Color(0xFF16243F),
              DabblerPalette.socialP300,
            ),
            DabblerActivityTone.info: (
              const Color(0xFF16243F),
              DabblerPalette.socialP300,
            ),
            DabblerActivityTone.active: (
              const Color(0xFF3A1730),
              DabblerPalette.activeP300,
            ),
            DabblerActivityTone.accent: (
              const Color(0xFF3A1A2A),
              DabblerPalette.activeP300,
            ),
            DabblerActivityTone.bright: (
              const Color(0xFF3A1A06),
              DabblerPalette.brightP300,
            ),
            DabblerActivityTone.ended: (
              const Color(0xFF262626),
              const Color(0xFFB8B0A0),
            ),
            DabblerActivityTone.gold: (
              const Color(0xFF3A2E06),
              DabblerPalette.brightP300,
            ),
          };
      expect(pinned.keys.toSet(), DabblerActivityTone.values.toSet());
      for (final MapEntry<DabblerActivityTone, (Color, Color)> e
          in pinned.entries) {
        expect(e.key.dark.surface, e.value.$1, reason: e.key.name);
        expect(e.key.dark.ink, e.value.$2, reason: e.key.name);
        expect(e.key.resolve(Brightness.dark), e.key.dark);
        expect(e.key.of(dark), e.key.dark);
        expect(e.key.of(light), e.key.light);
      }
    });

    test('dark pairs read to WCAG AA', () {
      for (final DabblerActivityTone t in DabblerActivityTone.values) {
        final DabblerToneColor d = t.dark;
        final Color chip = Color.alphaBlend(
          dark.surfaceCard.withValues(alpha: DabblerActivityChip.fillAlpha),
          d.surface,
        );
        final Map<String, double> ratios = <String, double>{
          'body text on the ground': _contrast(dark.textPrimary, d.surface),
          'secondary text on the ground': _contrast(
            dark.textSecondary,
            d.surface,
          ),
          'ink on the card surface (kicker, stat glyph)': _contrast(
            d.ink,
            dark.surfaceCard,
          ),
          'action label on the ink': _contrast(dark.surfaceCard, d.ink),
          'ink on its ground (pair metric)': _contrast(d.ink, d.surface),
          'chip text on the chip': _contrast(dark.textSecondary, chip),
        };
        for (final MapEntry<String, double> r in ratios.entries) {
          expect(
            r.value,
            greaterThanOrEqualTo(4.5),
            reason: '${t.name}: ${r.key}',
          );
        }
      }
    });
  });

  for (final TextDirection dir in TextDirection.values) {
    final String d = dir == TextDirection.rtl ? 'rtl' : 'ltr';
    for (final Brightness b in Brightness.values) {
      final String m = b == Brightness.dark ? 'dark' : 'light';
      testWidgets('card follows the theme — $m $d', (
        WidgetTester tester,
      ) async {
        final DabblerColors c = testColors(brightness: b);
        final DabblerToneColor tone = DabblerActivityTone.main.resolve(b);
        await tester.pumpWidget(
          host(
            DabblerActivityCard(
              tone: tone,
              mark: 'calendar-add',
              children: <Widget>[
                DabblerActivityKicker(
                  label: 'New game',
                  ink: tone.ink,
                  icon: 'game',
                ),
                Builder(
                  builder: (BuildContext context) => Text(
                    'body',
                    style: TextStyle(
                      color: DabblerColors.of(context).textPrimary,
                    ),
                  ),
                ),
                DabblerActivityDateTile(month: 'OCT', day: '21', ink: tone.ink),
                DabblerActivityStat(
                  icon: 'people',
                  text: '6/14',
                  tone: tone,
                  fraction: 0.5,
                ),
                Row(
                  children: <Widget>[
                    const DabblerActivityChip(label: 'Padel', emoji: '🎾'),
                    const Spacer(),
                    DabblerActivityAction(label: 'Join', ink: tone.ink),
                  ],
                ),
              ],
            ),
            direction: dir,
            brightness: b,
          ),
        );
        final ColoredBox ground = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(DabblerActivityCard),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(ground.color, tone.surface);
        expect(
          tester
              .widget<DabblerIcon>(
                find.byKey(const ValueKey<String>('activity-card-mark')),
              )
              .color,
          tone.ink.withValues(alpha: DabblerActivityCard.markOpacity),
        );
        // No island: the content reads the ambient theme.
        expect(_text(tester, 'body').color, c.textPrimary);
        expect(_text(tester, 'New game').color, tone.ink);
        expect(
          _deco(
            tester,
            find
                .descendant(
                  of: find.byType(DabblerActivityKicker),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          ).color,
          c.surfaceCard,
        );
        expect(_text(tester, '21').color, c.textPrimary);
        expect(_text(tester, '6/14').color, c.textPrimary);
        expect(
          tester
              .widget<ColoredBox>(
                find.descendant(
                  of: find.byKey(const ValueKey<String>('activity-bar')),
                  matching: find.byType(ColoredBox),
                ),
              )
              .color,
          tone.surface,
        );
        expect(_text(tester, 'Padel').color, c.textSecondary);
        expect(_text(tester, 'Join').color, c.surfaceCard);
        expect(
          _deco(
            tester,
            find.byKey(const ValueKey<String>('activity-action')),
          ).color,
          tone.ink,
        );
      });

      testWidgets('strip, box and award follow the theme — $m $d', (
        WidgetTester tester,
      ) async {
        final DabblerColors c = testColors(brightness: b);
        final DabblerToneColor tone = DabblerActivityTone.gold.resolve(b);
        await tester.pumpWidget(
          host(
            Column(
              children: <Widget>[
                DabblerActivitySlim(
                  tone: tone,
                  icon: 'trend-up',
                  kicker: 'K',
                  value: 'Padel',
                  metric: '+3',
                ),
                DabblerActivityTrendBox(
                  tone: tone,
                  icon: 'hashtag',
                  kicker: 'H',
                  value: '#x',
                  metric: '9',
                ),
                DabblerActivityBadge(label: 'W', ink: tone.ink),
              ],
            ),
            direction: dir,
            brightness: b,
          ),
        );
        expect(_text(tester, 'Padel').color, c.textPrimary);
        expect(_text(tester, '#x').color, c.textPrimary);
        expect(_text(tester, 'K').color, tone.ink);
        expect(_text(tester, 'W').color, c.surfaceCard);
        expect(
          _deco(
            tester,
            find.byKey(const ValueKey<String>('activity-slim-metric')),
          ).color,
          c.surfaceCard,
        );
      });

      testWidgets('feed pill: data dark colours, rest and selected — $m $d', (
        WidgetTester tester,
      ) async {
        final DabblerColors c = testColors(brightness: b);
        const Color tint = Color(0xFF3B82F6);
        const Color darkBg = Color(0xFF15233A);
        const Color darkEdge = Color(0xFF2E4A78);
        await tester.pumpWidget(
          host(
            const Column(
              children: <Widget>[
                DabblerFeedPill(
                  key: ValueKey<String>('rest'),
                  label: 'Calm 2',
                  tint: tint,
                  darkTint: darkBg,
                  darkEdge: darkEdge,
                ),
                DabblerFeedPill(
                  key: ValueKey<String>('mine'),
                  label: 'Calm 3',
                  tint: tint,
                  darkTint: darkBg,
                  darkEdge: darkEdge,
                  selected: true,
                ),
                DabblerFeedPill(
                  key: ValueKey<String>('derived'),
                  label: 'Hype 1',
                  tint: tint,
                ),
                DabblerFeedPill(
                  key: ValueKey<String>('neutral'),
                  label: 'Padel',
                ),
              ],
            ),
            direction: dir,
            brightness: b,
          ),
        );
        BoxDecoration deco(String k) => _deco(
          tester,
          find
              .descendant(
                of: find.byKey(ValueKey<String>(k)),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        Color border(String k) => (deco(k).border! as Border).top.color;
        final DabblerHueTone lightTone = DabblerHueTone.fromColor(tint)!;
        if (b == Brightness.dark) {
          expect(deco('rest').color, darkBg);
          expect(border('rest'), darkEdge);
          expect(_text(tester, 'Calm 2').color, c.textPrimary);
          expect(
            deco('mine').color,
            Color.lerp(darkBg, darkEdge, DabblerFeedPill.darkSelectedShare),
          );
          expect(border('mine'), darkEdge);
          expect(_text(tester, 'Calm 3').color, c.textPrimary);
          final DabblerHueTone derived = DabblerHueTone.darkFromColor(tint)!;
          expect(deco('derived').color, derived.surface);
          expect(border('derived'), derived.edge);
          expect(
            _contrast(c.textPrimary, derived.surface),
            greaterThanOrEqualTo(4.5),
          );
        } else {
          // Light is unchanged: the hue's pastel, its deep ink.
          expect(deco('rest').color, lightTone.surface);
          expect(border('rest'), lightTone.edge);
          expect(_text(tester, 'Calm 2').color, lightTone.deep);
          expect(deco('mine').color, lightTone.edge);
        }
        // The neutral pill (the sport tag) follows the theme.
        expect(deco('neutral').color, isNull);
        expect(border('neutral'), c.borderDefault);
        expect(_text(tester, 'Padel').color, c.textSecondary);
      });
    }
  }

  test('a grey tint has no dark tone (neutral fallback)', () {
    expect(DabblerHueTone.darkFromColor(const Color(0xFF808080)), isNull);
    final DabblerHueTone t = DabblerHueTone.darkHue(250);
    expect(t.surface.computeLuminance(), lessThan(0.05));
  });
}
