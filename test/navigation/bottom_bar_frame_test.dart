import 'package:dabbler_design_system/src/layout/fade.dart';
import 'package:dabbler_design_system/src/layout/page.dart';
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433 — the bottom bar's geometry as `Home Feed.dc.html` draws it
/// (measured in `home-design-measure.md` section 8), in LTR, in RTL mirrored
/// (the component default) and in RTL pinned to the frame's physical layout
/// (`mirrorInRtl: false`), with the Arabic strings the Arabic frame carries
/// (`Home Feed.dc.html:3501`).

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

const List<DabblerNavigationItem> _en = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'feeds', icon: 'home-2', label: 'Feeds'),
  DabblerNavigationItem(id: 'venues', icon: 'location', label: 'Venues'),
  DabblerNavigationItem(id: 'games', icon: 'game', label: 'Games'),
  DabblerNavigationItem(id: 'meetups', icon: 'calendar', label: 'Meetups'),
];

// `Home Feed.dc.html:3501`.
const List<DabblerNavigationItem> _ar = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'feeds', icon: 'home-2', label: 'الرئيسية'),
  DabblerNavigationItem(id: 'venues', icon: 'location', label: 'ملاعب'),
  DabblerNavigationItem(id: 'games', icon: 'game', label: 'مباريات'),
  DabblerNavigationItem(id: 'meetups', icon: 'calendar', label: 'لقاءات'),
];

const List<DabblerNavigationCreateItem> _createAr =
    <DabblerNavigationCreateItem>[
      DabblerNavigationCreateItem(
        id: 'post',
        icon: 'edit',
        label: 'منشور جديد',
        iconTone: DabblerNavigationIconTone.info,
      ),
      DabblerNavigationCreateItem(
        id: 'game',
        icon: 'game',
        label: 'مباراة جديدة',
        iconTone: DabblerNavigationIconTone.success,
      ),
      DabblerNavigationCreateItem(
        id: 'meetup',
        icon: 'calendar',
        label: 'لقاء جديد',
        iconTone: DabblerNavigationIconTone.accent,
      ),
    ];

// Short captions: the test font is far wider than Glory, so the frame's own
// captions would wrap and the menu would measure taller than the drawing.
const List<DabblerNavigationCreateItem> _createShort =
    <DabblerNavigationCreateItem>[
      DabblerNavigationCreateItem(id: 'post', icon: 'edit', label: 'Post'),
      DabblerNavigationCreateItem(id: 'game', icon: 'game', label: 'Game'),
      DabblerNavigationCreateItem(
        id: 'meetup',
        icon: 'calendar',
        label: 'Meet',
      ),
    ];

Widget _page({
  required TextDirection direction,
  required bool mirror,
  bool menuOpen = false,
  bool arabic = false,
  bool shortCreate = false,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
  home: MediaQuery(
    data: const MediaQueryData(size: Size(393, 852), disableAnimations: true),
    child: Directionality(
      textDirection: direction,
      child: DabblerPage(
        body: const SizedBox.expand(),
        bottomOverlay: DabblerNavigationBottomBar(
          items: arabic ? _ar : _en,
          active: 'feeds',
          menuOpen: menuOpen,
          rotateActionOnOpen: false,
          mirrorInRtl: mirror,
          createItems: shortCreate
              ? _createShort
              : (arabic
                    ? _createAr
                    : DabblerNavigationBottomBar.defaultCreateItems),
        ),
      ),
    ),
  ),
);

void _screen(WidgetTester t) {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

List<Rect> _hitBoxes(WidgetTester t) => t
    .elementList(
      find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is GestureDetector && w.behavior == HitTestBehavior.opaque,
        ),
      ),
    )
    .map((Element e) => t.getRect(find.byElementPredicate((x) => x == e)))
    .toList();

Rect _pill(WidgetTester t) {
  final Iterable<Element> boxes = t.elementList(
    find.descendant(
      of: find.byType(DabblerNavigationBottomBar),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == _colors.brandPrimary,
      ),
    ),
  );
  return boxes
      .map((Element e) => t.getRect(find.byElementPredicate((x) => x == e)))
      .firstWhere((Rect r) => r.width > DabblerSizing.navBarHeight);
}

void main() {
  test('the nav sizing tokens are off the grid and pinned', () {
    expect(DabblerSizing.navItem, 44);
    expect(DabblerSizing.navBarHeight, 56);
    expect(DabblerSizing.navGlyphLarge, 26);
    expect(DabblerSizing.navCreateTile, 62);
    expect(DabblerSizing.navFadeHeight, 80);
    for (final double v in <double>[
      DabblerSizing.navItem,
      DabblerSizing.navBarHeight,
      DabblerSizing.navGlyphLarge,
      DabblerSizing.navCreateTile,
      DabblerSizing.navFadeHeight,
    ]) {
      expect(v % 3, isNot(0));
    }
    expect(DabblerNavigationBottomBar.itemSize, DabblerSizing.navItem);
    expect(DabblerNavigationBottomBar.glyph26, DabblerSizing.navGlyphLarge);
    expect(
      DabblerNavigationBottomBar.createTileHeight,
      DabblerSizing.navCreateTile,
    );
  });

  for (final ({String name, TextDirection dir, bool mirror, bool arabic}) c
      in <({String name, TextDirection dir, bool mirror, bool arabic})>[
        (name: 'LTR', dir: TextDirection.ltr, mirror: true, arabic: false),
        (
          name: 'RTL pinned',
          dir: TextDirection.rtl,
          mirror: false,
          arabic: true,
        ),
        (
          name: 'LTR ignores the flag',
          dir: TextDirection.ltr,
          mirror: false,
          arabic: false,
        ),
      ]) {
    testWidgets('closed bar: the frame\'s geometry — ${c.name}', (
      WidgetTester t,
    ) async {
      _screen(t);
      await t.pumpWidget(
        _page(direction: c.dir, mirror: c.mirror, arabic: c.arabic),
      );
      await t.pumpAndSettle();

      final Rect pill = _pill(t);
      expect(pill.left, 18, reason: 'pill at the physical left, margin 18');
      expect(pill.top, 772);
      expect(pill.height, 56);

      final List<Rect> hits = _hitBoxes(t);
      expect(hits, hasLength(5), reason: '4 items + the action');
      final Rect action = hits.last;
      expect(action, const Rect.fromLTWH(319, 772, 56, 56));
      // Inactive items are 44 circles; the active one is 44 high.
      for (final Rect item in hits.sublist(1, 4)) {
        expect(item.size, const Size(44, 44));
        expect(item.top, 778);
      }
      expect(hits.first.height, 44);
      expect(hits.first.left, 27, reason: 'pill padding 9');
      // Same left-to-right order as LTR: each item right of the last.
      for (int i = 1; i < 4; i++) {
        expect(hits[i].left, greaterThan(hits[i - 1].right));
      }
      expect(hits[1].left - hits[0].right, 6, reason: 'item gap 6');
      // The pill hugs its content: 9 of padding after the last item, so the
      // free space is between the pill and the action, not inside the pill.
      expect(pill.right, hits[3].right + 9);
      expect(pill.width, lessThan(action.left - 12 + 0.01));

      final Rect fade = t.getRect(find.byType(DabblerFade));
      expect(fade, const Rect.fromLTWH(0, 772, 393, 80));
    });
  }

  testWidgets('RTL mirrored (the default) puts the pill on the right', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _page(direction: TextDirection.rtl, mirror: true, arabic: true),
    );
    await t.pumpAndSettle();
    final Rect pill = _pill(t);
    expect(pill.right, 393 - 18);
    expect(_hitBoxes(t).last.left, 18, reason: 'action at the left');
  });

  testWidgets('RTL pinned: Arabic label keeps the ambient text direction', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _page(direction: TextDirection.rtl, mirror: false, arabic: true),
    );
    await t.pumpAndSettle();
    final Text label = t.widget<Text>(find.text('الرئيسية'));
    expect(label.textDirection, TextDirection.rtl);
    // The glyph is left of the label, as the Arabic frame draws it.
    final Rect row = t.getRect(find.text('الرئيسية'));
    expect(row.left, greaterThan(45 + 24), reason: 'label right of the glyph');
  });

  for (final ({String name, TextDirection dir, bool mirror, bool arabic}) c
      in <({String name, TextDirection dir, bool mirror, bool arabic})>[
        (name: 'LTR', dir: TextDirection.ltr, mirror: true, arabic: false),
        (
          name: 'RTL pinned',
          dir: TextDirection.rtl,
          mirror: false,
          arabic: true,
        ),
      ]) {
    testWidgets('open create menu: 289 x 108.63, tiles 83 x 62 — ${c.name}', (
      WidgetTester t,
    ) async {
      _screen(t);
      await t.pumpWidget(
        _page(
          direction: c.dir,
          mirror: c.mirror,
          menuOpen: true,
          arabic: c.arabic,
          shortCreate: true,
        ),
      );
      await t.pumpAndSettle();

      final Finder card = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == _colors.surfaceCard &&
            (w.decoration! as BoxDecoration).borderRadius ==
                DabblerRadius.xxlAll,
      );
      final Rect menu = t.getRect(card);
      expect(menu.left, 18);
      expect(menu.width, 289);
      // The frame's caption line is 15.625 (12.5 x 1.25); Flutter rounds a
      // text line to a whole logical pixel, so the menu is 109 here.
      expect(menu.height, closeTo(108.625, 0.5));
      expect(menu.bottom, 828, reason: 'grows upward from the action');

      final List<Rect> tiles = _hitBoxes(t);
      // three tiles + the action
      expect(tiles, hasLength(4));
      for (final Rect tile in tiles.sublist(0, 3)) {
        expect(tile.width, 83);
        expect(tile.height, closeTo(84.625, 0.5));
      }
      expect(tiles[0].left, 30);
      expect(tiles[1].left, 121);
      expect(tiles[2].left, 212);
      expect(tiles.last, const Rect.fromLTWH(319, 772, 56, 56));
    });
  }

  testWidgets('RTL pinned: the Arabic captions keep the ambient direction', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _page(
        direction: TextDirection.rtl,
        mirror: false,
        menuOpen: true,
        arabic: true,
      ),
    );
    await t.pumpAndSettle();
    for (final String caption in <String>[
      'منشور جديد',
      'مباراة جديدة',
      'لقاء جديد',
    ]) {
      expect(
        t.widget<Text>(find.text(caption)).textDirection,
        TextDirection.rtl,
      );
    }
    expect(_hitBoxes(t).last, const Rect.fromLTWH(319, 772, 56, 56));
  });

  testWidgets('the default RTL behaviour is unchanged for other callers', (
    WidgetTester t,
  ) async {
    expect(const DabblerNavigationBottomBar().mirrorInRtl, isTrue);
  });
}
