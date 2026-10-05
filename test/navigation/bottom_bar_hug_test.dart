import 'package:dabbler_design_system/src/layout/page.dart';
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pill hugs its content, at every destination count the app can show
/// (3: Feeds / Venues / Games; 4 and 5 with the Meetups and Community flags),
/// in LTR and in Arabic RTL pinned to the frame's physical layout, on the
/// frame's 393 column, a narrow 320 phone and a 1280 window (the page keeps
/// the phone column).
///
/// `Home Feed.dc.html` draws the pill `display: flex` with no `flex-grow`:
/// the active chip is `width: auto` (padding + glyph + gap + label), the
/// inactive items are 44 squares, and the row's `space-between` puts the free
/// space between the pill and the action. A chip that fills the pill (the live
/// Alpha build before `8d59c1b`) fails `active == natural` here.

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

// The app's own labels. The test font draws every glyph a full em wide, far
// wider than Glory, so more cases here take the narrow branch than on a
// device; both branches are asserted.
const List<DabblerNavigationItem> _all = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'feeds', icon: 'home-2', label: 'Feeds'),
  DabblerNavigationItem(id: 'community', icon: 'people', label: 'Community'),
  DabblerNavigationItem(id: 'venues', icon: 'location', label: 'Venues'),
  DabblerNavigationItem(id: 'games', icon: 'game', label: 'Games'),
  DabblerNavigationItem(id: 'meetups', icon: 'calendar', label: 'Meetups'),
];

const List<DabblerNavigationItem> _allAr = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'feeds', icon: 'home-2', label: 'الرئيسية'),
  DabblerNavigationItem(id: 'community', icon: 'people', label: 'المجتمع'),
  DabblerNavigationItem(id: 'venues', icon: 'location', label: 'ملاعب'),
  DabblerNavigationItem(id: 'games', icon: 'game', label: 'مباريات'),
  DabblerNavigationItem(id: 'meetups', icon: 'calendar', label: 'لقاءات'),
];

/// The app's order: Feeds, [Community], Venues, Games, [Meetups].
List<DabblerNavigationItem> _items(int n, {required bool arabic}) {
  final List<DabblerNavigationItem> l = arabic ? _allAr : _all;
  return switch (n) {
    3 => <DabblerNavigationItem>[l[0], l[2], l[3]],
    4 => <DabblerNavigationItem>[l[0], l[2], l[3], l[4]],
    _ => l,
  };
}

Future<void> _pump(
  WidgetTester t, {
  required double width,
  required int n,
  required bool arabic,
  String active = 'feeds',
}) async {
  t.view.physicalSize = Size(width, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 852), disableAnimations: true),
        child: Directionality(
          textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
          child: DabblerPage(
            maxContentWidth: DabblerPage.readableWidth,
            body: const SizedBox.expand(),
            bottomOverlay: DabblerNavigationBottomBar(
              items: _items(n, arabic: arabic),
              active: active,
              mirrorInRtl: false,
              rotateActionOnOpen: false,
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

Rect _rectOf(WidgetTester t, Element e) =>
    t.getRect(find.byElementPredicate((Element x) => x == e));

/// Each destination's hit box, then the action's, in physical order.
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
    .map((Element e) => _rectOf(t, e))
    .toList();

Rect _pill(WidgetTester t) => t
    .elementList(
      find.descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color == _colors.brandPrimary,
        ),
      ),
    )
    .map((Element e) => _rectOf(t, e))
    .firstWhere((Rect r) => r.width > DabblerSizing.navBarHeight);

/// What `width: auto` resolves the active chip to: `padding: 0 18px`, the
/// glyph, `gap: 8` and the label on one line.
double _natural(WidgetTester t, String label) {
  final RenderParagraph p = t.renderObject<RenderParagraph>(find.text(label));
  return DabblerSpacing.space6 * 2 +
      DabblerSizing.iconMd +
      DabblerNavigationBottomBar.activeGap +
      p.getMaxIntrinsicWidth(double.infinity);
}

void main() {
  for (final bool arabic in <bool>[false, true]) {
    final String dir = arabic ? 'AR' : 'EN';
    for (final double width in <double>[393, 320, 1280]) {
      for (final int n in <int>[3, 4, 5]) {
        testWidgets('$n items, $dir, ${width.toInt()} wide: the pill hugs', (
          WidgetTester t,
        ) async {
          await _pump(t, width: width, n: n, arabic: arabic);
          expect(t.takeException(), isNull, reason: 'no overflow');

          final Rect pill = _pill(t);
          final List<Rect> hits = _hitBoxes(t);
          expect(hits, hasLength(n + 1));
          final Rect activeChip = hits.first;
          final List<Rect> inactive = hits.sublist(1, n);
          final Rect action = hits.last;

          // Pill at the physical left (mirrorInRtl: false), action at the
          // physical right, both on the 56 row.
          expect(pill.height, DabblerSizing.navBarHeight);
          expect(action.size, const Size.square(DabblerSizing.navBarHeight));
          expect(activeChip.left, pill.left + DabblerSpacing.space3);
          expect(action.left, greaterThan(pill.right));

          // The pill ends `9` after its last item: no space inside it.
          expect(pill.right, closeTo(inactive.last.right + 9, 0.01));
          // The free space is between the pill and the action, at least the
          // row's `gap: 12`.
          expect(
            action.left - pill.right,
            greaterThanOrEqualTo(DabblerSpacing.space4 - 0.01),
          );
          for (int i = 1; i < hits.length - 1; i++) {
            expect(
              hits[i].left - hits[i - 1].right,
              closeTo(DabblerSpacing.space2, 0.01),
              reason: 'item gap 6',
            );
          }

          final String label = _items(n, arabic: arabic).first.label;
          final double natural = _natural(t, label);
          final double room =
              action.left -
              DabblerSpacing.space4 -
              pill.left -
              DabblerSpacing.space3 * 2 -
              DabblerSpacing.space2 * (n - 1) -
              DabblerNavigationBottomBar.itemSize * (n - 1);
          if (natural <= room + 0.01) {
            // It fits: the chip is exactly its content, never the leftover.
            expect(activeChip.width, closeTo(natural, 0.01));
            for (final Rect r in inactive) {
              expect(r.size, const Size.square(DabblerSizing.navItem));
            }
          } else {
            // Too narrow: the label ellipsizes first, then the squares give
            // way to their glyph; the chip still never exceeds its content.
            expect(activeChip.width, lessThan(natural));
            for (final Rect r in inactive) {
              expect(r.width, greaterThanOrEqualTo(DabblerSizing.iconMd));
              expect(r.width, lessThanOrEqualTo(DabblerSizing.navItem));
            }
          }
        });
      }
    }
  }

  testWidgets('switching the active item keeps the hug, no exception', (
    WidgetTester t,
  ) async {
    await _pump(t, width: 393, n: 3, arabic: false, active: 'venues');
    expect(t.takeException(), isNull);
    final List<Rect> hits = _hitBoxes(t);
    expect(hits[1].width, closeTo(_natural(t, 'Venues'), 0.01));
    expect(hits[0].size, const Size.square(DabblerSizing.navItem));
    expect(_pill(t).right, closeTo(hits[2].right + 9, 0.01));
  });

  testWidgets('a route no destination owns: every item a 44 square', (
    WidgetTester t,
  ) async {
    await _pump(t, width: 393, n: 3, arabic: false, active: 'none');
    expect(t.takeException(), isNull);
    final List<Rect> hits = _hitBoxes(t);
    for (final Rect r in hits.sublist(0, 3)) {
      expect(r.size, const Size.square(DabblerSizing.navItem));
    }
  });
}
