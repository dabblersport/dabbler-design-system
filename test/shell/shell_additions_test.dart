// DS-3 (shell part): DabblerPage, the titled top bar and avatar photo, and the
// new PostRow / NewsCard / ActivityRow slots. Each with an RTL case.
import 'package:dabbler_design_system/src/controls/chip.dart';
import 'package:dabbler_design_system/src/feed/activity_row.dart';
import 'package:dabbler_design_system/src/feed/news_card.dart';
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/layout/page.dart';
import 'package:dabbler_design_system/src/navigation/top_bar.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  EdgeInsets padding = EdgeInsets.zero,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
  home: MediaQuery(
    data: MediaQueryData(size: const Size(390, 800), padding: padding),
    child: Directionality(textDirection: direction, child: child),
  ),
);

Widget _inBox(Widget child) => Align(
  alignment: Alignment.topLeft,
  child: SizedBox(width: 360, child: SingleChildScrollView(child: child)),
);

void _screen(WidgetTester t) {
  t.view.physicalSize = const Size(390, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  setUp(() => DabblerAvatar.portrait = const DabblerPlaceholderPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  group('DabblerPage', () {
    testWidgets('paints the page ground and no Material scaffold', (t) async {
      await t.pumpWidget(_host(const DabblerPage(body: Text('body'))));
      expect(find.text('body'), findsOneWidget);
      expect(find.byType(Scaffold), findsNothing);
      final ColoredBox ground = t.widget<ColoredBox>(
        find.descendant(
          of: find.byType(DabblerPage),
          matching: find.byType(ColoredBox),
        ).first,
      );
      expect(ground.color, _colors().bgPrimary);
    });

    testWidgets('top bar above the body, bottom bar below', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerPage(
            topBar: SizedBox(height: 50, child: Text('top')),
            bottomBar: SizedBox(height: 60, child: Text('bottom')),
            body: Center(child: Text('body')),
          ),
        ),
      );
      final double top = t.getCenter(find.text('top')).dy;
      final double body = t.getCenter(find.text('body')).dy;
      final double bottom = t.getCenter(find.text('bottom')).dy;
      expect(top, lessThan(body));
      expect(body, lessThan(bottom));
    });

    testWidgets('safe area only on an edge without a bar', (t) async {
      _screen(t);
      const EdgeInsets insets = EdgeInsets.only(top: 40, bottom: 30);
      await t.pumpWidget(
        _host(
          const DabblerPage(body: SizedBox.expand(key: Key('b'))),
          padding: insets,
        ),
      );
      Rect r = t.getRect(find.byKey(const Key('b')));
      expect(r.top, 40);
      expect(r.bottom, 800 - 30);

      await t.pumpWidget(
        _host(
          const DabblerPage(
            topBar: SizedBox(height: 50),
            bottomBar: SizedBox(height: 60),
            body: SizedBox.expand(key: Key('b')),
          ),
          padding: insets,
        ),
      );
      r = t.getRect(find.byKey(const Key('b')));
      expect(r.top, 50, reason: 'the bar owns the top inset');
      expect(r.bottom, 800 - 60, reason: 'the bar owns the bottom inset');
    });

    testWidgets('lifts content above the keyboard', (t) async {
      _screen(t);
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors()]),
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(390, 800),
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: DabblerPage(body: SizedBox.expand(key: Key('b'))),
          ),
        ),
      );
      expect(t.getRect(find.byKey(const Key('b'))).bottom, 500);
    });

    testWidgets('RTL renders', (t) async {
      await t.pumpWidget(
        _host(
          const DabblerPage(
            topBar: DabblerNavigationTopBar.titled(title: 'الإعدادات'),
            body: Text('محتوى'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(t.takeException(), isNull);
    });
  });

  group('DabblerNavigationTopBar.titled', () {
    testWidgets('back, title and actions; no wordmark, no avatar', (t) async {
      var backs = 0;
      await t.pumpWidget(
        _host(
          _inBox(
            DabblerNavigationTopBar.titled(
              title: 'Notifications',
              onBack: () => backs++,
              actions: const <DabblerNavigationAction>[
                DabblerNavigationAction(icon: 'share', label: 'Share'),
              ],
              safeArea: false,
            ),
          ),
        ),
      );
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(DabblerWordmark), findsNothing);
      expect(find.byType(DabblerAvatar), findsNothing);
      await t.tap(find.bySemanticsLabel('Back'));
      expect(backs, 1);
      final DabblerIcon glyph = t.widget<DabblerIcon>(
        find.byWidgetPredicate(
          (Widget w) => w is DabblerIcon && w.name.startsWith('arrow-circle'),
        ),
      );
      expect(glyph.name, 'arrow-circle-left');
    });

    testWidgets('RTL: the back glyph points to the reading start, at the '
        'right edge', (t) async {
      await t.pumpWidget(
        _host(
          _inBox(
            DabblerNavigationTopBar.titled(
              title: 'الإشعارات',
              onBack: () {},
              safeArea: false,
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      final Finder back = find.byWidgetPredicate(
        (Widget w) => w is DabblerIcon && w.name.startsWith('arrow-circle'),
      );
      // The glyph is drawn through DabblerIcon.mirrorInRtl: the widget keeps
      // the LTR name and the icon swaps to its measured mirror in RTL.
      final DabblerIcon icon = t.widget<DabblerIcon>(back);
      expect(icon.name, DabblerNavigationTopBar.backIcon);
      expect(icon.mirrorInRtl, isTrue);
      expect(
        t.getCenter(back).dx,
        greaterThan(t.getCenter(find.text('الإشعارات')).dx),
      );
    });

    testWidgets('plain bar passes avatarImageUrl to the avatar', (t) async {
      await t.pumpWidget(
        _host(
          _inBox(
            const DabblerNavigationTopBar(
              avatarSeed: 'Moataz',
              avatarImageUrl: 'https://example.invalid/me.png',
              safeArea: false,
            ),
          ),
        ),
      );
      expect(
        t.widget<DabblerAvatar>(find.byType(DabblerAvatar)).imageUrl,
        'https://example.invalid/me.png',
      );
    });
  });

  group('DabblerPostRow slots', () {
    DabblerPostRow row({
      VoidCallback? onAuthorTap,
      VoidCallback? onRepost,
      int? views,
      bool reposted = false,
    }) => DabblerPostRow(
      name: 'Suraj Mehta',
      time: '2h',
      place: 'Al Quoz',
      body: 'Anyone playing?',
      imageUrl: 'https://example.invalid/a.png',
      onAuthorTap: onAuthorTap,
      onRepost: onRepost,
      reposts: 3,
      reposted: reposted,
      views: views,
      media: const SizedBox(key: Key('media'), height: 120),
      reactions: const DabblerChip(label: 'Hyped 4'),
      kindBadge: const DabblerBadge(label: 'Dab'),
    );

    testWidgets('draws photo, media, repost, reactions, badge and views', (
      t,
    ) async {
      await t.pumpWidget(
        _host(_inBox(row(onRepost: () {}, views: 412, onAuthorTap: () {}))),
      );
      expect(
        t.widget<DabblerAvatar>(find.byType(DabblerAvatar)).imageUrl,
        'https://example.invalid/a.png',
      );
      expect(find.byKey(const Key('media')), findsOneWidget);
      expect(find.text('Hyped 4'), findsOneWidget);
      expect(find.text('Dab'), findsOneWidget);
      expect(find.text('3'), findsOneWidget, reason: 'repost count');
      expect(find.text('412'), findsOneWidget, reason: 'view count');
      // Media sits under the body, the reactions under the actions.
      expect(
        t.getTopLeft(find.byKey(const Key('media'))).dy,
        greaterThan(t.getTopLeft(find.text('Anyone playing?')).dy),
      );
      expect(
        t.getTopLeft(find.text('Hyped 4')).dy,
        greaterThan(t.getTopLeft(find.text('3')).dy),
      );
    });

    testWidgets('repost and views hidden unless the caller asks', (t) async {
      await t.pumpWidget(_host(_inBox(row())));
      expect(find.text('3'), findsNothing);
      expect(find.text('412'), findsNothing);
    });

    testWidgets('author tap from the avatar and from the name', (t) async {
      var author = 0;
      var repost = 0;
      await t.pumpWidget(
        _host(
          _inBox(row(onAuthorTap: () => author++, onRepost: () => repost++)),
        ),
      );
      await t.tap(find.byType(DabblerAvatar));
      await t.tap(find.text('Suraj Mehta'));
      expect(author, 2);
      await t.tap(find.text('3'));
      expect(repost, 1);
    });

    testWidgets('reposted draws the bold brand glyph', (t) async {
      await t.pumpWidget(
        _host(_inBox(row(onRepost: () {}, reposted: true))),
      );
      final DabblerIcon glyph = t.widget<DabblerIcon>(
        find.byWidgetPredicate((Widget w) => w is DabblerIcon && w.name == 'refresh'),
      );
      expect(glyph.weight, DabblerIconWeight.bold);
      expect(glyph.color, _colors().brandPrimary);
    });

    testWidgets('RTL: avatar at the right edge, no exception', (t) async {
      await t.pumpWidget(
        _host(
          _inBox(row(onRepost: () {}, views: 1, onAuthorTap: () {})),
          direction: TextDirection.rtl,
        ),
      );
      expect(t.takeException(), isNull);
      expect(
        t.getCenter(find.byType(DabblerAvatar)).dx,
        greaterThan(t.getCenter(find.text('Suraj Mehta')).dx),
      );
    });
  });

  group('DabblerNewsCard reaction picker', () {
    testWidgets('long press opens the picker, tap still likes', (t) async {
      var likes = 0;
      var picks = 0;
      await t.pumpWidget(
        _host(
          _inBox(
            DabblerNewsCard(
              title: 'Story',
              time: '5h',
              likes: 2,
              onLike: () => likes++,
              onLikeLongPress: () => picks++,
            ),
          ),
        ),
      );
      await t.longPress(find.text('2'));
      await t.tap(find.text('2'));
      expect(picks, 1);
      expect(likes, 1);
    });

    testWidgets('RTL renders', (t) async {
      await t.pumpWidget(
        _host(
          _inBox(
            DabblerNewsCard(
              title: 'خبر',
              time: '5h',
              onLike: () {},
              onLikeLongPress: () {},
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(t.takeException(), isNull);
    });
  });

  group('DabblerActivityRow thumbnail', () {
    Widget activity() => DabblerActivityRow(
      leading: const DabblerAvatar(seed: 'K', size: DabblerAvatarSize.sm),
      actor: 'khalid',
      verb: 'commented on',
      thumbnail: const SizedBox.expand(key: Key('thumb')),
    );

    testWidgets('a 40px thumbnail at the end of the row', (t) async {
      await t.pumpWidget(_host(_inBox(activity())));
      final Rect thumb = t.getRect(find.byKey(const Key('thumb')));
      expect(thumb.size, const Size(40, 40));
      expect(
        thumb.center.dx,
        greaterThan(t.getCenter(find.byType(DabblerAvatar)).dx),
      );
    });

    testWidgets('RTL: the thumbnail moves to the left end', (t) async {
      await t.pumpWidget(
        _host(_inBox(activity()), direction: TextDirection.rtl),
      );
      expect(
        t.getRect(find.byKey(const Key('thumb'))).center.dx,
        lessThan(t.getCenter(find.byType(DabblerAvatar)).dx),
      );
    });
  });
}
