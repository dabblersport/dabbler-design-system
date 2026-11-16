// KAN-967: the new Active card types from ActivityCard.dc.html: the trending
// strip and pair, the award spotlight, the stat strip, the featured photo,
// the reasons, the review and the venue row; the info and gold tones; the
// 24/30 and 18/24 roles; the compact kicker. LTR and RTL.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

TextStyle _text(WidgetTester tester, String s) =>
    tester.widget<Text>(find.text(s)).style!;

BoxDecoration _deco(WidgetTester tester, Finder f) =>
    tester.widget<DecoratedBox>(f).decoration as BoxDecoration;

void main() {
  test('tones: info is tile-info, gold is 30% amber over white', () {
    expect(DabblerActivityTones.info.surface, const Color(0xFFDCEAFB));
    expect(DabblerActivityTones.info.ink, DabblerPalette.socialP700);
    expect(
      DabblerActivityTones.gold.surface,
      Color.lerp(const Color(0xFFFFFFFF), const Color(0xFFFFD60A), 0.3),
    );
    expect(DabblerActivityTones.gold.ink, const Color(0xFF703900));
  });

  test('roles: displayFeature 24/30, displayQuote 18/24', () {
    expect(DabblerType.displayFeature.fontSize, 24);
    expect(DabblerType.displayFeature.latinLeading, 30);
    expect(DabblerType.displayQuote.fontSize, 18);
    expect(DabblerType.displayQuote.latinLeading, 24);
    expect(DabblerType.displayQuote.role, DabblerTypeRole.display);
  });

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;
    final String d = rtl ? 'rtl' : 'ltr';
    double start(Rect outer, Rect inner) =>
        rtl ? outer.right - inner.right : inner.left - outer.left;

    testWidgets('slim: 12/15 padding, 64 min, 40 tile, 20 glyph — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerActivitySlim(
            tone: DabblerActivityTones.info,
            icon: 'trend-up',
            kicker: 'Trending',
            value: 'Padel',
            metric: '+38%',
          ),
          direction: dir,
        ),
      );
      final Rect s = tester.getRect(find.byType(DabblerActivitySlim));
      expect(s.height, 64);
      final Finder tile = find
          .descendant(
            of: find.byType(DabblerActivitySlim),
            matching: find.byType(DecoratedBox),
          )
          .first;
      final Rect t = tester.getRect(tile);
      expect(t.size, const Size(40, 40));
      expect(start(s, t), 15);
      expect(t.top - s.top, 12);
      expect(_deco(tester, tile).borderRadius, DabblerRadius.lgAll);
      final List<DabblerIcon> icons = tester
          .widgetList<DabblerIcon>(
            find.descendant(
              of: find.byType(DabblerActivitySlim),
              matching: find.byType(DabblerIcon),
            ),
          )
          .toList();
      expect(icons.first.size, 20);
      expect(icons.first.weight, DabblerIconWeight.bold);
      expect(icons.last.name, 'trend-up');
      expect(icons.last.size, 14);
      expect(icons.last.weight, DabblerIconWeight.linear);
      final Rect m = tester.getRect(
        find.byKey(const ValueKey<String>('activity-slim-metric')),
      );
      expect(m.height, 5 + 16 + 5);
      expect(rtl ? m.left - s.left : s.right - m.right, 15);
      expect(_text(tester, 'Trending').color, DabblerPalette.socialP700);
      expect(_text(tester, 'Padel').fontSize, rtl ? 19.1 : 20);
      expect(_text(tester, '+38%').color, DabblerPalette.socialP700);
    });

    testWidgets('pair: two equal boxes, gap 9, 132 min, 78 mark — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerActivityPair(
            start: DabblerActivityTrendBox(
              key: ValueKey<String>('a'),
              tone: DabblerActivityTones.main,
              icon: 'hashtag',
              kicker: 'Tag',
              value: '#x',
              metric: '214',
            ),
            end: DabblerActivityTrendBox(
              key: ValueKey<String>('b'),
              tone: DabblerActivityTones.info,
              icon: 'trend-up',
              kicker: 'Sport',
              value: 'Cricket',
              metric: '+22%',
            ),
          ),
          direction: dir,
        ),
      );
      final Rect a = tester.getRect(find.byKey(const ValueKey<String>('a')));
      final Rect b = tester.getRect(find.byKey(const ValueKey<String>('b')));
      expect(a.width, (hostWidth - 9) / 2);
      expect(b.width, a.width);
      expect(a.height, 132);
      expect(b.height, 132);
      expect(rtl ? a.left - b.right : b.left - a.right, 9);
      final Finder mark = find.descendant(
        of: find.byKey(const ValueKey<String>('a')),
        matching: find.byKey(const ValueKey<String>('activity-trend-mark')),
      );
      final Rect mr = tester.getRect(mark);
      expect(mr.size, const Size(78, 78));
      expect(mr.bottom - a.bottom, 14);
      expect(rtl ? a.left - mr.left : mr.right - a.right, 12);
      final Rect k = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('a')),
          matching: find.byType(DabblerActivityKicker),
        ),
      );
      expect(start(a, k), 15);
      expect(k.top - a.top, 15);
      final Rect metric = tester.getRect(find.text('214'));
      expect(a.bottom - metric.bottom, 15, reason: 'margin-top:auto');
      final Rect value = tester.getRect(find.text('#x'));
      expect(value.top - k.bottom, 9);
      expect(_text(tester, '#x').fontSize, rtl ? 21.1 : 22);
    });

    testWidgets('compact kicker pads 4/9/4/7 — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: AlignmentDirectional.topStart,
            child: DabblerActivityKicker(
              label: 'K',
              ink: DabblerPalette.mainP700,
              icon: 'hashtag',
              compact: true,
            ),
          ),
          direction: dir,
        ),
      );
      final Rect k = tester.getRect(find.byType(DabblerActivityKicker));
      final Rect g = tester.getRect(find.byType(DabblerIcon));
      final Rect t = tester.getRect(find.text('K'));
      expect(start(k, g), 7);
      expect(rtl ? t.left - k.left : k.right - t.right, 9);
      expect(k.height, 21);
    });

    testWidgets('badge 4/10 ink fill; award 80 ring 4, medal 30 — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.topStart,
                child: DabblerActivityBadge(
                  label: 'W',
                  ink: DabblerPalette.activeP700,
                ),
              ),
              DabblerActivityAward(
                seed: 'Khalid',
                mark: 'medal-star',
                ink: DabblerPalette.activeP700,
                headline: 'Khalid',
                sub: 'Football',
              ),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect badge = tester.getRect(find.byType(DabblerActivityBadge));
      expect(badge.height, 4 + 13 + 4);
      expect(_text(tester, 'W').color, testColors().surfaceCard);
      final Rect av = tester.getRect(find.byType(DabblerAvatar));
      expect(av.size, const Size(80, 80));
      expect(
        tester.widget<DabblerAvatar>(find.byType(DabblerAvatar)).ringWidth,
        4,
      );
      final Rect medal = tester.getRect(
        find.byKey(const ValueKey<String>('activity-award-medal')),
      );
      expect(medal.size, const Size(36, 36), reason: '30 plus the 3 ring');
      expect(medal.bottom - av.bottom, 4 + 3);
      expect(rtl ? av.left - medal.left : medal.right - av.right, 6 + 3);
      final Rect award = tester.getRect(find.byType(DabblerActivityAward));
      expect(av.top - award.top, 3);
      final Rect h = tester.getRect(find.text('Khalid').last);
      expect(h.top - av.bottom, 9);
      expect(_text(tester, 'Khalid').fontSize, rtl ? 25.1 : 26);
    });

    testWidgets('stats: 3 equal cells, gap 6, 9/6 padding — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerActivityStats(
            items: <(String, String)>[('6', 'G'), ('4', 'M'), ('4.9', 'R')],
          ),
          direction: dir,
        ),
      );
      final Rect strip = tester.getRect(find.byType(DabblerActivityStats));
      final Rect v = tester.getRect(find.text('6'));
      final Rect l = tester.getRect(find.text('G'));
      expect(strip.height, 9 + 25 + 1 + 13 + 9);
      expect(v.top - strip.top, 9);
      expect(l.top - v.bottom, 1);
      expect(_text(tester, 'G').color, testColors().textTertiary);
      expect(_text(tester, '6').fontSize, rtl ? 19.1 : 20);
      final double cell = (hostWidth - 12) / 3;
      final Rect c = tester.getRect(
        find
            .descendant(
              of: find.byType(DabblerActivityStats),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(c.width, closeTo(cell, 1e-9));
    });

    testWidgets('photo 150, rating pill 9 in; reason; review; row — $d', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DabblerActivityPhoto(ratingText: '4.7'),
              DabblerActivityReason(
                icon: 'clock',
                text: 'Free',
                ink: DabblerPalette.brightS600,
              ),
              DabblerActivityReview(
                seed: 'Aisha',
                name: 'Aisha',
                line: 'Tue',
                rating: 5,
                ratingLabel: 'Rated 5 out of 5',
                quote: 'Good',
              ),
              DabblerActivityVenueRow(
                title: 'Al Quoz',
                detail: '4.8',
                ink: DabblerPalette.socialP700,
              ),
            ],
          ),
          direction: dir,
        ),
      );
      final Rect p = tester.getRect(find.byType(DabblerActivityPhoto));
      expect(p.size, const Size(hostWidth, 150));
      final Rect pill = tester.getRect(
        find.byKey(const ValueKey<String>('activity-photo-rating')),
      );
      expect(p.bottom - pill.bottom, 9);
      expect(start(p, pill), 9);
      expect(pill.height, 4 + 16 + 4);
      final DabblerIcon star = tester.widget<DabblerIcon>(
        find.descendant(
          of: find.byType(DabblerActivityPhoto),
          matching: find.byType(DabblerIcon),
        ),
      );
      expect(star.color, const Color(0xFFFFD60A));
      expect(star.size, 13);

      final Rect r = tester.getRect(find.byType(DabblerActivityReason));
      expect(r.height, 5 + 16 + 5);

      expect(find.text('“Good”'), findsOneWidget);
      expect(_text(tester, '“Good”').fontSize, rtl ? 17.1 : 18);
      final Rect rv = tester.getRect(find.byType(DabblerActivityReview));
      final Rect ra = tester.getRect(
        find.descendant(
          of: find.byType(DabblerActivityReview),
          matching: find.byType(DabblerAvatar),
        ),
      );
      expect(start(rv, ra), 12);
      // `align-items:center`: the 36 avatar centres on the name column, 36
      // in Latin, 39 in Arabic (subheadline's Arabic leading 23).
      expect(ra.top - rv.top, rtl ? 12 + 1.5 : 12);
      expect(
        tester.widget<DabblerRating>(find.byType(DabblerRating)).size,
        DabblerRatingSize.sm,
      );
      expect(_text(tester, 'Tue').color, testColors().textTertiary);

      final Rect vr = tester.getRect(find.byType(DabblerActivityVenueRow));
      expect(vr.height, 40);
      expect(_text(tester, 'Al Quoz').fontSize, rtl ? 14.1 : 15);
      expect(_text(tester, '4.8').color, testColors().textSecondary);
    });
  }
}
