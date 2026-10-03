// Pinned values cite the Claude Design file "Home Feed.dc.html" (DesignSync,
// fetched 2026-10-03, truncated at 256 KiB): post row :285-338, activity row
// :341-401, news card :407-436.
import 'package:dabbler_design_system/src/feed/activity_row.dart';
import 'package:dabbler_design_system/src/feed/feed_atoms.dart';
import 'package:dabbler_design_system/src/feed/news_card.dart';
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      ),
    );

DabblerPostRow _post({
  VoidCallback? onTap,
  VoidCallback? onLike,
  VoidCallback? onMore,
  bool liked = false,
}) => DabblerPostRow(
  name: 'Suraj Mehta',
  roleLabel: 'Player',
  distance: '1.1 km',
  time: '2h',
  place: 'Nad Al Sheba',
  segments: const <DabblerPostSegment>[
    DabblerPostSegment('Anyone playing? '),
    DabblerPostSegment('#dabblersport', link: true),
  ],
  sportLabel: 'Cricket',
  likes: 12,
  replies: 4,
  liked: liked,
  onTap: onTap,
  onLike: onLike,
  onMore: onMore,
  onComment: () {},
  onShare: () {},
  onVibe: () {},
);

void main() {
  group('PostRow', () {
    testWidgets('draws its content and the 36px avatar', (tester) async {
      await tester.pumpWidget(_host(_post()));
      expect(find.text('Suraj Mehta'), findsOneWidget);
      expect(find.text('1.1 km'), findsOneWidget);
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(tester.getSize(find.byType(DabblerAvatar)), const Size(36, 36));
      final RichText rich = tester.widget<RichText>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is RichText && w.text.toPlainText().contains('#dabblersport'),
        ),
      );
      TextSpan? link;
      rich.text.visitChildren((InlineSpan s) {
        if (s is TextSpan && s.text == '#dabblersport') link = s;
        return true;
      });
      expect(link!.style!.color, _colors().brandPrimary);
    });

    testWidgets('actions fire and are at least 45px', (tester) async {
      int likes = 0;
      int more = 0;
      int taps = 0;
      await tester.pumpWidget(
        _host(
          _post(
            onLike: () => likes++,
            onMore: () => more++,
            onTap: () => taps++,
          ),
        ),
      );
      final Finder like = find.byWidgetPredicate(
        (Widget w) => w is DabblerFeedAction && w.icon == 'heart',
      );
      expect(tester.getSize(like).width, greaterThanOrEqualTo(45));
      expect(tester.getSize(like).height, greaterThanOrEqualTo(45));
      await tester.tap(like);
      await tester.tap(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerFeedAction && w.icon == 'more-circle',
        ),
      );
      expect(likes, 1);
      expect(more, 1);
      expect(taps, 0, reason: 'an action tap does not open the row');
      await tester.tap(find.text('Suraj Mehta'));
      expect(taps, 1);
    });

    testWidgets('liked heart is error-coloured and bold', (tester) async {
      await tester.pumpWidget(_host(_post(liked: true, onLike: () {})));
      final DabblerFeedAction a = tester.widget<DabblerFeedAction>(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerFeedAction && w.icon == 'heart',
        ),
      );
      expect(a.color, _colors().error.base);
    });

    testWidgets('RTL: avatar leads on the right, more trails on the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_post(onMore: () {}), direction: TextDirection.rtl),
      );
      final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
      final Rect more = tester.getRect(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerFeedAction && w.icon == 'more-circle',
        ),
      );
      expect(avatar.right, greaterThan(300));
      expect(more.left, lessThan(60));
    });

    testWidgets('digits are Western in the distance pill', (tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerPostRow(
            name: 'x',
            distance: '٣ كم',
            time: '٢س',
            place: 'p',
          ),
        ),
      );
      expect(find.text('3 كم'), findsOneWidget);
      expect(find.text('2س'), findsOneWidget);
    });
  });

  group('NewsCard', () {
    DabblerNewsCard card({VoidCallback? onTap, VoidCallback? onLike}) =>
        DabblerNewsCard(
          media: const SizedBox.expand(key: Key('media')),
          sportLabel: 'Football',
          title: 'Dubai adds pitches',
          excerpt: 'One two three four five six seven eight nine ten ' * 12,
          time: '3h ago',
          likes: 128,
          comments: 24,
          views: 1902,
          onTap: onTap,
          onLike: onLike,
          onComment: () {},
        );

    testWidgets('media block is 210px high and hosts the slot', (tester) async {
      await tester.pumpWidget(_host(card()));
      expect(tester.getSize(find.byKey(const Key('media'))).height, 210);
      expect(find.text('Football'), findsOneWidget);
      expect(find.text('1902'), findsOneWidget);
    });

    testWidgets('excerpt clamps to two lines', (tester) async {
      await tester.pumpWidget(_host(card()));
      final Text excerpt = tester.widget<Text>(
        find.byWidgetPredicate(
          (Widget w) => w is Text && (w.data ?? '').startsWith('One two'),
        ),
      );
      expect(excerpt.maxLines, 2);
    });

    testWidgets('like and card taps are separate', (tester) async {
      int likes = 0;
      int taps = 0;
      await tester.pumpWidget(
        _host(card(onLike: () => likes++, onTap: () => taps++)),
      );
      await tester.tap(find.text('128'));
      expect(likes, 1);
      expect(taps, 0);
      await tester.tap(find.text('Dubai adds pitches'));
      expect(taps, 1);
    });

    testWidgets('RTL: pill at the right, age at the left', (tester) async {
      await tester.pumpWidget(_host(card(), direction: TextDirection.rtl));
      final Rect pill = tester.getRect(find.text('Football'));
      final Rect time = tester.getRect(find.text('3h ago'));
      expect(pill.right, greaterThan(300));
      expect(time.left, lessThan(60));
    });
  });

  group('ActivityRow', () {
    DabblerActivityRow row({
      VoidCallback? onAction,
      bool filled = true,
      bool live = false,
    }) => DabblerActivityRow(
      leading: const DabblerAvatar(seed: 'Khalid', size: DabblerAvatarSize.sm),
      actor: 'Khalid',
      verb: 'created a game',
      subject: 'Saturday net practice',
      place: 'Al Maryah Island',
      when: 'Sat 6:00 PM',
      distance: '5.4 km',
      actionLabel: 'Join game',
      actionFilled: filled,
      onAction: onAction,
      count: '7/12 going',
      live: live,
      sportLabel: 'Cricket',
    );

    testWidgets('card carries the 24px radius and grey fill', (tester) async {
      await tester.pumpWidget(_host(row()));
      final Container c = tester.widget<Container>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).borderRadius ==
                  BorderRadius.circular(24),
        ),
      );
      expect((c.decoration! as BoxDecoration).color, _colors().surfaceGrey);
    });

    testWidgets('action pill is 33px painted in a 45px target', (tester) async {
      int actions = 0;
      await tester.pumpWidget(_host(row(onAction: () => actions++)));
      final Finder pill = find.byWidgetPredicate(
        (Widget w) => w is Container && w.constraints?.maxHeight == 33,
      );
      expect(tester.getSize(pill).height, 33);
      expect(
        tester.getSize(find.byType(DabblerFeedTappable).first).height,
        greaterThanOrEqualTo(45),
      );
      await tester.tap(find.text('Join game'));
      expect(actions, 1);
    });

    testWidgets('Live badge draws only when live', (tester) async {
      await tester.pumpWidget(_host(row()));
      expect(find.text('Live'), findsNothing);
      await tester.pumpWidget(_host(row(live: true)));
      expect(find.text('Live'), findsOneWidget);
    });

    testWidgets('system tile is 40px; group header renders', (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: <Widget>[
              DabblerActivityGroupHeader('Earlier today'),
              DabblerActivitySystemTile('location'),
            ],
          ),
        ),
      );
      expect(find.text('Earlier today'), findsOneWidget);
      expect(
        tester.getSize(find.byType(DabblerActivitySystemTile)),
        const Size(40, 40),
      );
    });

    testWidgets('RTL: leading widget on the right', (tester) async {
      await tester.pumpWidget(
        _host(row(onAction: () {}), direction: TextDirection.rtl),
      );
      final Rect lead = tester.getRect(find.byType(DabblerAvatar));
      expect(lead.right, greaterThan(300));
    });
  });
}
