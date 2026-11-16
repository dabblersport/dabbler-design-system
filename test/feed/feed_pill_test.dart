// KAN-963: DabblerFeedPill is the post row's sport pill made public, with an
// emoji slot, a data tint (DabblerHueTone.parseHex / fromColor), a selected
// state and a 45px hit area. The post row's sport tag is drawn with it.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

BoxDecoration _deco(WidgetTester tester, Finder pill) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(of: pill, matching: find.byType(DecoratedBox))
                  .first,
            )
            .decoration
        as BoxDecoration;

Color _labelInk(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  group('DabblerHueTone.parseHex', () {
    test('#RRGGBB, RRGGBB and #AARRGGBB parse; alpha is dropped', () {
      expect(DabblerHueTone.parseHex('#3B82F6'), const Color(0xFF3B82F6));
      expect(DabblerHueTone.parseHex('3b82f6'), const Color(0xFF3B82F6));
      expect(DabblerHueTone.parseHex('#803B82F6'), const Color(0xFF3B82F6));
    });

    test('null, malformed and grey give no tone (neutral fallback)', () {
      expect(DabblerHueTone.parseHex(null), isNull);
      expect(DabblerHueTone.parseHex('blue'), isNull);
      expect(DabblerHueTone.parseHex('#12345'), isNull);
      expect(DabblerHueTone.fromHex(null), isNull);
      expect(DabblerHueTone.fromHex('#808080'), isNull, reason: 'achromatic');
      expect(DabblerHueTone.fromHex('#3B82F6'), isNotNull);
    });

    test('the tone keeps the colour hue', () {
      final DabblerHueTone a = DabblerHueTone.fromHex('#3B82F6')!;
      final DabblerHueTone b = DabblerHueTone.fromHex('#2563EB')!;
      final DabblerHueTone c = DabblerHueTone.fromHex('#EF4444')!;
      expect(a.solid.b > a.solid.r, isTrue, reason: 'blue stays blue');
      expect(c.solid.r > c.solid.b, isTrue, reason: 'red stays red');
      expect(a, isNot(c));
      expect((a.solid.b - b.solid.b).abs() < 0.1, isTrue);
    });
  });

  for (final TextDirection dir in TextDirection.values) {
    final String d = dir.name;
    group('DabblerFeedPill ($d)', () {
      testWidgets('drawn metrics match the post row sport pill', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const DabblerPostRow(
                  name: 'Suraj',
                  time: '2h',
                  place: 'Dubai',
                  body: 'Nets tonight',
                  sportLabel: 'Cricket',
                  sportEmoji: '🏏',
                  showActions: false,
                  metrics: DabblerFeedMetrics.drawn,
                ),
                const DabblerFeedPill(
                  key: ValueKey<String>('vibe'),
                  label: 'Cricket',
                  emoji: '🏏',
                  metrics: DabblerFeedMetrics.drawn,
                ),
              ],
            ),
            direction: dir,
          ),
        );
        final Finder sport = find
            .descendant(
              of: find.byType(DabblerPostRow),
              matching: find.byType(DabblerFeedPill),
            )
            .first;
        final Size a = tester.getSize(sport);
        final Size b = tester.getSize(
          find.byKey(const ValueKey<String>('vibe')),
        );
        expect(a, b, reason: 'one pill, one size');
        // 32 in Latin; in Arabic the emoji's 15/23 line makes it 35, as the
        // frame's Arabic pill (5 + 23 + 5 + the 2 border px).
        expect(
          b.height,
          dir == TextDirection.ltr
              ? DabblerHomeFrame.sportPillHeight
              : DabblerHomeFrame.sportPillPaddingBlock * 2 +
                    DabblerSizing.borderDefault * 2 +
                    DabblerType.subheadline.resolveForDirection(dir).height! *
                        DabblerType.subheadline
                            .resolveForDirection(dir)
                            .fontSize!,
        );
        expect(find.text('🏏'), findsNWidgets(2), reason: 'emoji slot');
        final TextStyle emoji = tester
            .widget<Text>(find.text('🏏').last)
            .style!;
        expect(
          emoji.fontSize,
          DabblerType.subheadline.resolveForDirection(dir).fontSize,
        );
        final TextStyle label = tester
            .widget<Text>(find.text('Cricket').last)
            .style!;
        expect(
          label.fontSize,
          DabblerType.caption1.resolveForDirection(dir).fontSize,
        );
        final BoxDecoration deco = _deco(tester, sport);
        expect(deco.color, isNull, reason: 'neutral pill: no fill');
        expect((deco.border! as Border).top.color, threadColors.borderDefault);
      });

      testWidgets('a tint colours the outlined pill; selected fills it', (
        WidgetTester tester,
      ) async {
        final Color tint = DabblerHueTone.parseHex('#3B82F6')!;
        final DabblerHueTone tone = DabblerHueTone.fromColor(tint)!;
        await tester.pumpWidget(
          threadHost(
            Column(
              children: <Widget>[
                DabblerFeedPill(
                  key: const ValueKey<String>('idle'),
                  label: 'Calm 2',
                  tint: tint,
                ),
                DabblerFeedPill(
                  key: const ValueKey<String>('mine'),
                  label: 'Calm 3',
                  tint: tint,
                  selected: true,
                  onTap: () {},
                ),
              ],
            ),
            direction: dir,
          ),
        );
        final BoxDecoration idle = _deco(
          tester,
          find.byKey(const ValueKey<String>('idle')),
        );
        expect(idle.color, tone.surface);
        expect((idle.border! as Border).top.color, tone.edge);
        expect(_labelInk(tester, 'Calm 2'), tone.deep);
        final BoxDecoration mine = _deco(
          tester,
          find.byKey(const ValueKey<String>('mine')),
        );
        expect(mine.color, tone.solid);
        expect(_labelInk(tester, 'Calm 3'), tone.surface, reason: 'readable');
        expect(
          tester.getSize(find.byKey(const ValueKey<String>('idle'))).height,
          tester.getSize(find.byKey(const ValueKey<String>('mine'))).height,
          reason: 'selecting does not resize',
        );
      });

      testWidgets('no tint: neutral; selected neutral is the brand fill', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            const DabblerFeedPill(label: 'Calm 1', selected: true),
            direction: dir,
          ),
        );
        final BoxDecoration deco = _deco(tester, find.byType(DabblerFeedPill));
        expect(deco.color, threadColors.brandPrimary);
        expect(_labelInk(tester, 'Calm 1'), threadColors.onBrand);
      });

      testWidgets('onTap: a button hit from the 45 box around it', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await tester.pumpWidget(
          threadHost(
            Padding(
              padding: const EdgeInsets.all(DabblerSpacing.space8),
              child: DabblerFeedPill(label: 'Calm 1', onTap: () => taps++),
            ),
            direction: dir,
          ),
        );
        final Rect r = tester.getRect(find.byType(DecoratedBox).last);
        await tester.tapAt(r.bottomCenter + const Offset(0, 4));
        expect(taps, 1, reason: 'below the pill, inside the 45 box');
        await tester.tapAt(r.center);
        expect(taps, 2);
      });
    });
  }
}
