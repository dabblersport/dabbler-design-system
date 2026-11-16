// KAN-965: DabblerActivityCard and its parts, the Home Feed Active card
// transcribed from ActivityCard.dc.html, with the activity tile tones, the
// 28/32 and 14/18 roles and the avatar ring width. LTR and RTL, light and
// dark.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

BoxDecoration _deco(WidgetTester tester, Finder f) =>
    tester.widget<DecoratedBox>(f).decoration as BoxDecoration;

Finder _firstDeco(Finder of) =>
    find.descendant(of: of, matching: find.byType(DecoratedBox)).first;

TextStyle _text(WidgetTester tester, String s) =>
    tester.widget<Text>(find.text(s)).style!;

Widget _card({required List<Widget> children}) => DabblerActivityCard(
  tone: DabblerActivityTones.main,
  mark: 'calendar-add',
  children: children,
);

void main() {
  group('DabblerActivityTones', () {
    test('the design ACT_TONE fallbacks, exactly', () {
      const Map<String, (int, Color)> pinned = <String, (int, Color)>{
        'main': (0xFFEADDF8, DabblerPalette.mainP700),
        'sport': (0xFFDDEEDE, DabblerPalette.sportP700),
        'social': (0xFFDCE7F9, DabblerPalette.socialP700),
        'active': (0xFFF9DDEB, DabblerPalette.activeP700),
        'bright': (0xFFFDEBD6, DabblerPalette.brightS600),
        'accent': (0xFFFBE0EC, DabblerPalette.activeP700),
        'ended': (0xFFF0EBE0, DabblerPalette.inkSoft),
      };
      final List<DabblerToneColor> tones = DabblerActivityTones.all;
      expect(tones, hasLength(pinned.length));
      int i = 0;
      for (final MapEntry<String, (int, Color)> e in pinned.entries) {
        expect(tones[i].surface, Color(e.value.$1), reason: e.key);
        expect(tones[i].ink, e.value.$2, reason: e.key);
        i++;
      }
      expect(DabblerPalette.mainP700, const Color(0xFF5A1FA1));
      expect(DabblerPalette.sportP700, const Color(0xFF29692C));
      expect(DabblerPalette.socialP700, const Color(0xFF295AA8));
      expect(DabblerPalette.activeP700, const Color(0xFFA12C6B));
      expect(DabblerPalette.brightS600, const Color(0xFF703900));
      expect(DabblerPalette.inkSoft, const Color(0xFF404040));
    });
  });

  group('type roles', () {
    test('displayDay 28/32 display, smallCompact 14/18 sans', () {
      expect(DabblerType.displayDay.fontSize, 28);
      expect(DabblerType.displayDay.latinLeading, 32);
      expect(DabblerType.displayDay.role, DabblerTypeRole.display);
      expect(DabblerType.smallCompact.fontSize, 14);
      expect(DabblerType.smallCompact.latinLeading, 18);
      expect(DabblerType.smallCompact.arabicLeading, 18);
      expect(DabblerType.smallCompact.role, DabblerTypeRole.sans);
    });
  });

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String d = rtl ? 'rtl' : 'ltr';

    testWidgets('card: 18 padding, 12 gap, xl radius, tone ground — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          _card(
            children: const <Widget>[
              SizedBox(key: ValueKey<String>('a'), height: 20),
              SizedBox(key: ValueKey<String>('b'), height: 20),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect card = tester.getRect(find.byType(DabblerActivityCard));
      final Rect a = tester.getRect(find.byKey(const ValueKey<String>('a')));
      final Rect b = tester.getRect(find.byKey(const ValueKey<String>('b')));
      expect(a.top - card.top, 18);
      expect(a.left - card.left, 18);
      expect(card.right - a.right, 18);
      expect(b.top - a.bottom, 12);
      expect(card.bottom - b.bottom, 18);
      expect(card.height, 18 + 20 + 12 + 20 + 18);
      final ClipRRect clip = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(DabblerActivityCard),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(clip.borderRadius, BorderRadius.circular(18));
      final ColoredBox ground = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(DabblerActivityCard),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(ground.color, const Color(0xFFEADDF8));
    });

    testWidgets('mark: 120 bold at 14% ink, -18 end, -12 top — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          _card(children: const <Widget>[SizedBox(height: 120)]),
          direction: dir,
        ),
      );
      final Finder mark = find.byKey(
        const ValueKey<String>('activity-card-mark'),
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(mark);
      expect(icon.name, 'calendar-add');
      expect(icon.size, 120);
      expect(icon.weight, DabblerIconWeight.bold);
      expect(icon.color, DabblerPalette.mainP700.withValues(alpha: 0.14));
      final Rect card = tester.getRect(find.byType(DabblerActivityCard));
      final Rect m = tester.getRect(mark);
      expect(m.top - card.top, -12);
      if (rtl) {
        expect(m.left - card.left, -18);
      } else {
        expect(card.right - m.right, -18);
      }
      expect(
        find.ancestor(of: mark, matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
    });

    testWidgets('kicker: 4/10/4/8 pill; glyph gap 5, live gap 6 — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DabblerActivityKicker(
                key: ValueKey<String>('k'),
                label: 'New game',
                icon: 'game',
                ink: DabblerPalette.mainP700,
              ),
              DabblerActivityKicker(
                key: ValueKey<String>('l'),
                label: 'Happening now',
                ink: DabblerPalette.sportP700,
                live: true,
              ),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect k = tester.getRect(find.byKey(const ValueKey<String>('k')));
      final Rect g = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('k')),
          matching: find.byType(DabblerIcon),
        ),
      );
      final Rect t = tester.getRect(find.text('New game'));
      expect(k.height, 4 + 13 + 4);
      expect(g.size, const Size(12, 12));
      if (rtl) {
        expect(k.right - g.right, 8);
        expect(g.left - t.right, 5);
        expect(t.left - k.left, 10);
      } else {
        expect(g.left - k.left, 8);
        expect(t.left - g.right, 5);
        expect(k.right - t.right, 10);
      }
      expect(_text(tester, 'New game').color, DabblerPalette.mainP700);
      // RTL resolves the Arabic size (latin - 0.9, DabblerType).
      final double ar = rtl ? 0.9 : 0;
      expect(_text(tester, 'New game').fontSize, 11 - ar);
      expect(_text(tester, 'New game').height! * (11 - ar), closeTo(13, 0.01));
      expect(
        _deco(
          tester,
          _firstDeco(find.byKey(const ValueKey<String>('k'))),
        ).color,
        testColors().surfaceCard,
      );

      final Rect dot = tester.getRect(
        find.byKey(const ValueKey<String>('activity-live-dot')),
      );
      final Rect lt = tester.getRect(find.text('Happening now'));
      expect(dot.size, const Size(7, 7));
      expect(rtl ? dot.left - lt.right : lt.left - dot.right, 6);
      expect(_text(tester, 'Happening now').color, testColors().success.strong);
    });

    testWidgets('date tile 56x62, month 11/13 ink, day 28/32 — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerActivityDateTile(
              month: 'OCT',
              day: '21',
              ink: DabblerPalette.mainP700,
            ),
          ),
          direction: dir,
        ),
      );
      expect(
        tester.getSize(find.byType(DabblerActivityDateTile)),
        const Size(56, 62),
      );
      expect(_text(tester, 'OCT').color, DabblerPalette.mainP700);
      final double ar = rtl ? 0.9 : 0;
      expect(_text(tester, '21').fontSize, 28 - ar);
      expect(_text(tester, '21').height! * (28 - ar), closeTo(32, 0.01));
      expect(_text(tester, '21').color, DabblerPalette.ink);
    });

    testWidgets('stat 9/12, 16 glyph, 13/18, tone bar rounded — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerActivityStat(
            icon: 'people',
            text: '6/14',
            tone: DabblerActivityTones.main,
            fraction: 6 / 14,
          ),
          direction: dir,
        ),
      );
      final Rect s = tester.getRect(find.byType(DabblerActivityStat));
      final Rect i = tester.getRect(
        find.descendant(
          of: find.byType(DabblerActivityStat),
          matching: find.byType(DabblerIcon),
        ),
      );
      final Rect bar = tester.getRect(
        find.byKey(const ValueKey<String>('activity-bar')),
      );
      expect(i.size, const Size(16, 16));
      expect(i.top - s.top, 9 + 1, reason: '16 glyph centred on the 18 line');
      expect(rtl ? s.right - i.right : i.left - s.left, 12);
      expect(bar.height, 6);
      expect(s.bottom - bar.bottom, 9);
      expect(bar.width, hostWidth - 24);
      final ColoredBox track = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('activity-bar')),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(track.color, const Color(0xFFEADDF8));
      final Rect fill = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('activity-bar')),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(fill.width, closeTo((hostWidth - 24) * 0.43, 0.01));
      expect(rtl ? fill.right : fill.left, rtl ? bar.right : bar.left);
      expect(_text(tester, '6/14').fontSize, rtl ? 12.1 : 13);
      expect(DabblerActivityBar.drawnFraction(6 / 14), 0.43);
      expect(DabblerActivityBar.drawnFraction(1.4), 1);
    });

    testWidgets('chip 4/10 at 70% card, action 40 tall 0/18 14/18 — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Row(
            children: <Widget>[
              DabblerActivityChip(label: 'Padel'),
              Spacer(),
              DabblerActivityAction(
                label: 'Join game',
                ink: DabblerPalette.mainP700,
              ),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect chip = tester.getRect(find.byType(DabblerActivityChip));
      final Rect ct = tester.getRect(find.text('Padel'));
      expect(chip.height, 4 + 13 + 4);
      expect(ct.left - chip.left, 10);
      expect(
        _deco(tester, _firstDeco(find.byType(DabblerActivityChip))).color,
        testColors().surfaceCard.withValues(alpha: 0.7),
      );
      expect(_text(tester, 'Padel').color, DabblerPalette.inkSoft);

      final Rect a = tester.getRect(find.byType(DabblerActivityAction));
      final Rect at = tester.getRect(find.text('Join game'));
      expect(a.height, 40);
      expect(at.left - a.left, 18);
      expect(a.right - at.right, 18);
      final TextStyle st = _text(tester, 'Join game');
      final double size = rtl ? 13.1 : 14;
      expect(st.fontSize, size);
      expect(st.height! * size, closeTo(18, 0.01));
      expect(st.color, testColors().surfaceCard);
      expect(
        _deco(
          tester,
          find.byKey(const ValueKey<String>('activity-action')),
        ).color,
        DabblerPalette.mainP700,
      );
    });
  }

  testWidgets('dark: the card content resolves in light inks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        _card(
          children: <Widget>[
            Builder(
              builder: (BuildContext context) => Text(
                'x',
                style: TextStyle(color: DabblerColors.of(context).textPrimary),
              ),
            ),
            const DabblerActivityChip(label: 'Padel'),
          ],
        ),
        brightness: Brightness.dark,
      ),
    );
    expect(_text(tester, 'x').color, DabblerPalette.ink);
    expect(_text(tester, 'Padel').color, DabblerPalette.inkSoft);
    final ColoredBox ground = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(DabblerActivityCard),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(ground.color, const Color(0xFFEADDF8));
  });

  testWidgets('live dot pulses 1.6s ease-out; still under reduced motion', (
    WidgetTester tester,
  ) async {
    BoxDecoration dot() =>
        _deco(tester, find.byKey(const ValueKey<String>('activity-live-dot')));
    await tester.pumpWidget(host(const DabblerLiveDot()));
    final Color base = testColors().success.base;
    expect(dot().color, base);
    expect(dot().boxShadow!.single.spreadRadius, 0);
    expect(dot().boxShadow!.single.color, base.withValues(alpha: 0.55));
    await tester.pump(const Duration(milliseconds: 800));
    final double t = Curves.easeOut.transform(0.5);
    expect(dot().boxShadow!.single.spreadRadius, closeTo(7 * t, 1e-6));
    await tester.pump(const Duration(milliseconds: 800));
    expect(dot().boxShadow!.single.spreadRadius, closeTo(0, 1e-6));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(const DabblerLiveDot()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(dot().boxShadow, isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('avatar ring width: 3 outside the 64 portrait', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: DabblerAvatar(
            seed: 'Yousef',
            size: DabblerAvatarSize.lg,
            ringColor: DabblerPalette.paper,
            ringWidth: 3,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DabblerAvatar)), const Size(64, 64));
    final Finder ring = find.descendant(
      of: find.byType(DabblerAvatar),
      matching: find.byType(Positioned),
    );
    final Positioned p = tester.widget<Positioned>(ring.first);
    expect(p.left, -3);
    expect(DabblerAvatar.defaultRingWidth, 2);
  });
}
