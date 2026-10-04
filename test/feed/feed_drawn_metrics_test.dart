// KAN-433: the feed rows with DabblerFeedMetrics.drawn, against the Home Feed
// frame's measured figures (home-design-measure.md sections 4, 7a, 7b, 7c, 9a).
// The Arabic strings are the Arabic frame's own dictionary in
// `Home Feed.dc.html`; none is written here.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

const String _arName = 'سوراج ميهتا';
const String _arPlace = 'ند الشبا';
const String _arCricket = 'كريكيت';
const String _arGame = 'خماسي الثلاثاء';
const String _arVenue = 'مدينة دبي الرياضية';
const String _arUpcoming = 'القادمة';

DabblerPostRow _post({
  required DabblerFeedMetrics metrics,
  required bool rtl,
  VoidCallback? onLike,
}) => DabblerPostRow(
  metrics: metrics,
  name: rtl ? _arName : 'Suraj Mehta',
  roleLabel: 'Player',
  distance: 'Dab',
  time: '2h',
  place: rtl ? _arPlace : 'Nad Al Sheba',
  body: 'Anyone playing cricket in Dubai this weekend?',
  sportLabel: rtl ? _arCricket : 'Cricket',
  likes: 12,
  replies: 4,
  onLike: onLike ?? () {},
  onTap: () {},
  onComment: () {},
  onShare: () {},
  onVibe: () {},
  onMore: () {},
);

void main() {
  setUp(() => DabblerAvatar.portrait = const DabblerPlaceholderPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;

    group('PostRow drawn — $dir', () {
      testWidgets(
        'the type pill is 17 high (2/8, 11/13, regular, no hairline)',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            threadHost(
              _post(metrics: DabblerFeedMetrics.drawn, rtl: rtl),
              direction: dir,
            ),
          );
          expect(tester.getSize(find.byType(DabblerBadge)).height, 17);
          final Text label = tester.widget<Text>(find.text('Dab'));
          expect(label.style!.fontWeight, DabblerType.regular);
        },
      );

      testWidgets('actions lay out at 20 and sit 18 apart', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            _post(metrics: DabblerFeedMetrics.drawn, rtl: rtl),
            direction: dir,
          ),
        );
        final Finder actions = find.byType(DabblerFeedAction);
        expect(tester.getSize(actions.at(1)), const Size(20, 20)); // vibe
        expect(tester.getSize(actions.at(4)), const Size(20, 20)); // more
        final Rect like = tester.getRect(actions.at(0));
        final Rect vibe = tester.getRect(actions.at(1));
        final double gap = rtl
            ? like.left - vibe.right
            : vibe.left - like.right;
        expect(gap, DabblerSpacing.space6);
      });

      testWidgets('the 45px target survives as a hit-test-only area', (
        WidgetTester tester,
      ) async {
        int likes = 0;
        await tester.pumpWidget(
          threadHost(
            _post(
              metrics: DabblerFeedMetrics.drawn,
              rtl: rtl,
              onLike: () => likes++,
            ),
            direction: dir,
          ),
        );
        final Rect like = tester.getRect(find.byType(DabblerFeedAction).first);
        // 11px below the 20px glyph box: inside a 45 box, outside the layout.
        await tester.tapAt(like.bottomCenter + const Offset(0, 8));
        expect(likes, 1);
      });

      testWidgets('the sport pill is 32 high and the default row is taller', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            _post(metrics: DabblerFeedMetrics.drawn, rtl: rtl),
            direction: dir,
          ),
        );
        final Size drawn = tester.getSize(find.byType(DabblerPostRow));
        final Rect pill = tester.getRect(
          find
              .ancestor(
                of: find.text(rtl ? _arCricket : 'Cricket'),
                matching: find.byType(ConstrainedBox),
              )
              .first,
        );
        expect(pill.height, DabblerHomeFrame.sportPillHeight);

        await tester.pumpWidget(
          threadHost(
            _post(metrics: DabblerFeedMetrics.touch, rtl: rtl),
            direction: dir,
          ),
        );
        // Touch: 45px action boxes. Drawn: 20 high actions under 12 of air.
        expect(
          tester.getSize(find.byType(DabblerFeedAction).first).height,
          DabblerSizing.touchTargetMin,
        );
        expect(
          drawn.height,
          isNot(tester.getSize(find.byType(DabblerPostRow)).height),
        );
      });
    });

    group('NewsCard drawn — $dir', () {
      Widget card(DabblerFeedMetrics m) => DabblerNewsCard(
        metrics: m,
        sportLabel: 'Football',
        title: 'Dubai adds twelve floodlit community pitches',
        excerpt: 'The municipality confirmed the first six sites open.',
        time: '3h ago',
        likes: 128,
        comments: 24,
        views: 1902,
        onLike: () {},
        onComment: () {},
      );

      testWidgets('hero 210, actions 18 high 15 apart, pill 21 high', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(card(DabblerFeedMetrics.drawn), direction: dir),
        );
        expect(tester.getSize(find.byType(ClipRRect).first).height, 210);
        expect(tester.getSize(find.byType(DabblerBadge)).height, 21);
        final Finder actions = find.byType(DabblerFeedAction);
        expect(tester.getSize(actions.first).height, 18);
        final Rect heart = tester.getRect(actions.at(0));
        final Rect comment = tester.getRect(actions.at(1));
        final double gap = rtl
            ? heart.left - comment.right
            : comment.left - heart.right;
        expect(gap, DabblerSpacing.space5);
      });

      testWidgets('the sport pill stays on the physical left, as the frame', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(card(DabblerFeedMetrics.drawn), direction: dir),
        );
        final Rect hero = tester.getRect(find.byType(ClipRRect).first);
        final Rect pill = tester.getRect(find.byType(DabblerBadge));
        expect(pill.left - hero.left, DabblerSpacing.space4);
        expect(pill.top - hero.top, DabblerSpacing.space4);
      });
    });

    group('ActivityRow drawn — $dir', () {
      Widget row(DabblerFeedMetrics m) => DabblerActivityRow(
        metrics: m,
        leading: DabblerActivitySystemTile('ticket-2', metrics: m),
        actor: rtl ? _arGame : 'Meydan Padel',
        verb: 'opened a court',
        place: rtl ? _arVenue : 'Meydan',
        when: 'in 2h',
        actionLabel: 'Book',
        sportLabel: rtl ? _arCricket : 'Padel',
        onAction: () {},
      );

      testWidgets('tile 42, action pill 35, badge 21, card margin 4', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(row(DabblerFeedMetrics.drawn), direction: dir),
        );
        expect(
          tester.getSize(find.byType(DabblerActivitySystemTile)),
          const Size(42, 42),
        );
        expect(tester.getSize(find.byType(DabblerBadge)).height, 21);
        final Finder pill = find.byType(DabblerExpandedHitArea).last;
        expect(tester.getSize(pill).height, 35);
        final Size card = tester.getSize(find.byType(DabblerActivityRow));
        await tester.pumpWidget(
          threadHost(row(DabblerFeedMetrics.touch), direction: dir),
        );
        expect(
          tester.getSize(find.byType(DabblerActivitySystemTile)),
          const Size(40, 40),
        );
        expect(
          card.height,
          isNot(tester.getSize(find.byType(DabblerActivityRow)).height),
        );
      });
    });

    group('UpcomingReminder drawn — $dir', () {
      final List<DabblerUpcomingItem> items = <DabblerUpcomingItem>[
        for (final String day in <String>['4', '6', '8'])
          DabblerUpcomingItem(
            month: 'OCT',
            day: day,
            title: rtl ? _arGame : 'Tuesday 5-a-side',
            detail: '${rtl ? _arVenue : 'Dubai Sports City'} · 7:30 PM',
            ringFraction: 0.9,
            ringBig: '2',
            ringSmall: 'hours',
            short: 'in 2h',
          ),
      ];
      Widget reminder({bool collapsed = false}) => DabblerUpcomingReminder(
        metrics: DabblerFeedMetrics.drawn,
        items: items,
        title: rtl ? '$_arUpcoming · 3' : 'Upcoming · 3',
        collapsed: collapsed,
        expanded: false,
        onDismiss: () {},
        onExpandStrip: () {},
        onToggleExpanded: () {},
        stripLabel: '3 upcoming',
        moreLabel: '2 more this week',
        showLessLabel: 'Show less',
        dismissLabel: 'Hide',
      );

      testWidgets('the stack is 165 high: 25 + 9 + 96 + 3 + 32', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(threadHost(reminder(), direction: dir));
        expect(
          tester.getSize(find.byType(DabblerUpcomingReminder)).height,
          165,
        );
        final Rect front = tester.getRect(find.byType(DabblerSurface).at(2));
        expect(front.height, 82); // 56 + 12 + 12 + the hairline on both sides
        expect(
          front.top -
              tester.getTopLeft(find.byType(DabblerUpcomingReminder)).dy,
          34,
        );
      });

      testWidgets('the hide button is a 34 box bleeding 8 past the end in LTR, '
          'flush in RTL (the frame margin is physical)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(threadHost(reminder(), direction: dir));
        final Rect block = tester.getRect(find.byType(DabblerUpcomingReminder));
        final Rect hide = tester.getRect(
          find.byType(DabblerExpandedHitArea).at(1),
        );
        expect(hide.size, const Size(34, 34));
        if (rtl) {
          expect(hide.left, block.left);
        } else {
          expect(hide.right - block.right, DabblerHomeFrame.reminderHideBleed);
        }
      });

      testWidgets('the opened list is 124 high: two 61 rows, a 34 x 39 tile, '
          'a 10 gap, and Show less 6 below', (WidgetTester tester) async {
        await tester.pumpWidget(
          threadHost(
            DabblerUpcomingReminder(
              metrics: DabblerFeedMetrics.drawn,
              items: items,
              title: 'Upcoming · 3',
              collapsed: false,
              expanded: true,
              onDismiss: () {},
              onExpandStrip: () {},
              onToggleExpanded: () {},
              stripLabel: '3 upcoming',
              moreLabel: '2 more this week',
              showLessLabel: 'Show less',
              dismissLabel: 'Hide',
            ),
            direction: dir,
          ),
        );
        final Finder tiles = find.ancestor(
          of: find.text('OCT').at(1),
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is SizedBox && w.width == DabblerHomeFrame.upcomingTileWidth,
          ),
        );
        final Rect list = tester.getRect(
          find
              .ancestor(of: tiles.first, matching: find.byType(DabblerSurface))
              .first,
        );
        expect(list.height, 124);
        // Arabic leading is 23 on the day figure, so the frame's tile is 42.
        expect(tester.getSize(tiles.first), Size(34, rtl ? 42 : 39));
        final Rect tile = tester.getRect(tiles.first);
        // 1 hairline + 12 padding inside the card, on the reading-start side.
        if (rtl) {
          expect(list.right - tile.right, 13);
        } else {
          expect(tile.left - list.left, 13);
        }
        final Rect title = tester.getRect(find.text(items.first.title).last);
        if (rtl) {
          expect(tile.left - title.right, greaterThanOrEqualTo(10));
        } else {
          expect(title.left - tile.right, 10);
        }
        final Rect less = tester.getRect(find.text('Show less'));
        expect(less.center.dy - list.bottom, closeTo(6 + 16, 3));
      });

      testWidgets('the folded strip is 30 high with physical 9 / 6 padding', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(reminder(collapsed: true), direction: dir),
        );
        final Rect strip = tester.getRect(find.byType(DabblerSurface));
        expect(strip.height, 30);
        final Rect chevron = tester.getRect(find.byType(DabblerIcon));
        // The frame's `padding:0 6px 0 9px` is physical.
        if (rtl) {
          expect(chevron.left - strip.left, DabblerSpacing.space3);
        } else {
          expect(strip.right - chevron.right, DabblerSpacing.space2);
        }
      });
    });
  }

  group('Badge', () {
    testWidgets('drawn keeps the neutral hairline, drops the status one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        threadHost(
          Column(
            children: <Widget>[
              DabblerBadge(
                label: 'Dab',
                status: threadColors.info,
                metrics: DabblerFeedMetrics.drawn,
              ),
              DabblerBadge(
                label: 'Padel',
                status: DabblerBadge.neutralStatusOf(threadColors),
                metrics: DabblerFeedMetrics.drawn,
              ),
            ],
          ),
        ),
      );
      BoxDecoration deco(int i) =>
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(DabblerBadge).at(i),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(deco(0).border, isNull);
      expect(deco(1).border, isNotNull);
    });
  });

  group('ActionRow drawn', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('a row with a note is 65 high and borderless, $dir', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          threadHost(
            const DabblerActionRow(
              metrics: DabblerFeedMetrics.drawn,
              icon: 'eye-slash',
              label: 'Hide post',
              note: 'Fewer like this',
            ),
            direction: dir,
          ),
        );
        // 65 in Latin, 68 in the Arabic frame (leading 23 on the label).
        expect(
          tester.getSize(find.byType(DabblerActionRow)).height,
          dir == TextDirection.rtl ? 68 : 65,
        );
        expect(
          tester
                  .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                  .decoration
              as BoxDecoration,
          isA<BoxDecoration>().having(
            (BoxDecoration d) => d.border,
            'border',
            isNull,
          ),
        );
      });
    }
  });

  group('Chip drawn', () {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('a sub-chip is 34 high with a 14 glyph and keeps its 45 '
          'target, $dir', (WidgetTester tester) async {
        int taps = 0;
        await tester.pumpWidget(
          threadHost(
            SizedBox(
              height: 58,
              child: Row(
                children: <Widget>[
                  Center(
                    child: DabblerChip(
                      metrics: DabblerFeedMetrics.drawn,
                      label: dir == TextDirection.rtl ? 'دبي' : 'Dubai',
                      selected: true,
                      leadingIcon: const DabblerIcon('location'),
                      onTap: () => taps++,
                    ),
                  ),
                ],
              ),
            ),
            direction: dir,
          ),
        );
        final Rect chip = tester.getRect(find.byType(DabblerSurface));
        expect(chip.height, 34);
        expect(tester.getSize(find.byType(DabblerIcon)), const Size(14, 14));
        await tester.tapAt(chip.bottomCenter + const Offset(0, 5));
        expect(taps, 1);
      });
    }
  });
}
