import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433 — the Home header drawn as the frame measures it
/// (`home-design-measure.md` section 3): 18 gutter, 6 above and 12 below a 45
/// row (63), 24 glyphs in 45 boxes 6 apart, the 36 avatar flush at the end
/// edge, and the unread dot pinned `top:9; right:9` of the bell's box.
final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  DabblerFeedMetrics metrics, {
  TextDirection direction = TextDirection.ltr,
  VoidCallback? onAvatar,
}) => MediaQuery(
  data: const MediaQueryData(disableAnimations: true),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 393,
          child: DabblerNavigationTopBar(
            metrics: metrics,
            safeArea: false,
            leading: const SizedBox(width: 110, height: 39),
            actions: const <DabblerNavigationAction>[
              DabblerNavigationAction(
                icon: 'search-normal',
                label: 'Search',
                onPressed: _noop,
              ),
              DabblerNavigationAction(
                icon: 'notification-bing',
                label: 'Notifications',
                unread: true,
                onPressed: _noop,
              ),
            ],
            onAvatarPressed: onAvatar,
          ),
        ),
      ),
    ),
  ),
);

void _noop() {}

void main() {
  setUp(() => DabblerAvatar.portrait = const DabblerPlaceholderPortrait());
  tearDown(() => DabblerAvatar.portrait = const DabblerRandomAvatarPortrait());

  for (final TextDirection dir in TextDirection.values) {
    final bool rtl = dir == TextDirection.rtl;

    group('drawn — $dir', () {
      testWidgets('63 high; glyphs 24 in 45 boxes 6 apart; avatar 36', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(DabblerFeedMetrics.drawn, direction: dir));
        expect(tester.getSize(find.byType(DabblerNavigationTopBar)).height, 63);
        final Finder glyphs = find.byType(DabblerIcon);
        expect(tester.getSize(glyphs.at(0)), const Size(24, 24));
        final Finder boxes = find.byType(DabblerFocusRing);
        final Rect search = tester.getRect(boxes.at(0));
        final Rect bell = tester.getRect(boxes.at(1));
        expect(search.size, const Size(45, 45));
        expect(bell.size, const Size(45, 45));
        final double gap = rtl ? search.left - bell.right : bell.left - search.right;
        expect(gap, DabblerSpacing.space2);
        expect(tester.getSize(find.byType(DabblerAvatar)), const Size(36, 36));
      });

      testWidgets('the gutter is 18 at both edges', (WidgetTester tester) async {
        await tester.pumpWidget(_host(DabblerFeedMetrics.drawn, direction: dir));
        final Rect leading = tester.getRect(find.byType(SizedBox).at(2));
        final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
        if (rtl) {
          expect(393 - leading.right, DabblerSpacing.space6);
          expect(avatar.left, DabblerSpacing.space6);
        } else {
          expect(leading.left, DabblerSpacing.space6);
          expect(393 - avatar.right, DabblerSpacing.space6);
        }
      });

      testWidgets('the unread dot is 13 and sits 9 in from the physical right '
          'and top of the bell box, in both directions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(DabblerFeedMetrics.drawn, direction: dir));
        final Rect dot = tester.getRect(
          find.byKey(DabblerNavigationUnreadDot.dotKey),
        );
        final Rect bell = tester.getRect(find.byType(DabblerFocusRing).at(1));
        expect(dot.size, const Size(13, 13));
        expect(dot.top - bell.top, DabblerSpacing.space3);
        expect(bell.right - dot.right, DabblerSpacing.space3);
      });

      testWidgets('the avatar keeps a 45 target around its 36', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await tester.pumpWidget(
          _host(DabblerFeedMetrics.drawn, direction: dir, onAvatar: () => taps++),
        );
        final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
        // 4px past the 36 disc, inside the 45 target and the 63 bar.
        await tester.tapAt(avatar.topCenter - const Offset(0, 4));
        expect(taps, 1);
      });
    });

    testWidgets('touch (default) is unchanged — 62 high, 22 glyphs, $dir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(DabblerFeedMetrics.touch, direction: dir));
      expect(tester.getSize(find.byType(DabblerNavigationTopBar)).height, 62);
      expect(tester.getSize(find.byType(DabblerIcon).first), const Size(22, 22));
    });
  }

  test('the titled bar ignores metrics and is never drawn', () {
    const DabblerNavigationTopBar bar = DabblerNavigationTopBar.titled(
      title: 'Settings',
    );
    expect(bar.metrics, DabblerFeedMetrics.touch);
  });
}
