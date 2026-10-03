import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/surfaces/badge.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

/// KAN-412 W1 gap 6 — the per-item unread dot and count badge.

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _bar(
  List<DabblerNavigationItem> items, {
  TextDirection direction = TextDirection.ltr,
}) => MediaQuery(
  data: const MediaQueryData(disableAnimations: true),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 390,
          child: DabblerNavigationBottomBar(
            items: items,
            active: 'home',
            createItems: const <DabblerNavigationCreateItem>[],
            safeArea: false,
          ),
        ),
      ),
    ),
  ),
);

const List<DabblerNavigationItem> _plain = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
  DabblerNavigationItem(id: 'inbox', icon: 'sms', label: 'Inbox'),
];

const List<DabblerNavigationItem> _withCount = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
  DabblerNavigationItem(
    id: 'inbox',
    icon: 'sms',
    label: 'Inbox',
    count: 3,
    badgeLabel: '3 unread',
  ),
];

const List<DabblerNavigationItem> _withDot = <DabblerNavigationItem>[
  DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
  DabblerNavigationItem(
    id: 'inbox',
    icon: 'sms',
    label: 'Inbox',
    unread: true,
    badgeLabel: 'unread',
  ),
];

Rect _glyphRect(WidgetTester t) => t.getRect(
  find
      .descendant(
        of: find.byType(DabblerNavigationBottomBar),
        matching: find.byType(Icon),
      )
      .at(1),
);

void main() {
  testWidgets('default: no indicator, plain semantics', (WidgetTester t) async {
    await t.pumpWidget(_bar(_plain));
    expect(find.byKey(DabblerNavigationItemBadge.dotKey), findsNothing);
    expect(find.byKey(DabblerNavigationItemBadge.countKey), findsNothing);
    expect(find.bySemanticsLabel('Inbox'), findsOneWidget);
  });

  testWidgets('dot is the 7px DabblerBadge.dot, no text', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_bar(_withDot));
    expect(find.byKey(DabblerNavigationItemBadge.dotKey), findsOneWidget);
    final DabblerBadge badge = t.widget<DabblerBadge>(
      find.byType(DabblerBadge),
    );
    expect(badge.isDot, isTrue);
    expect(
      t.getSize(find.byType(DabblerBadge)),
      const Size.square(DabblerBadge.dotDiameter),
    );
  });

  testWidgets('count pill shows the number and caps at 99+', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_bar(_withCount));
    expect(find.byKey(DabblerNavigationItemBadge.countKey), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(DabblerNavigationItemBadge.countText(99), '99');
    expect(DabblerNavigationItemBadge.countText(100), '99+');
    await t.pumpWidget(
      _bar(const <DabblerNavigationItem>[
        DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
        DabblerNavigationItem(id: 'a', icon: 'sms', label: 'A', count: 250),
        DabblerNavigationItem(id: 'b', icon: 'sms', label: 'B', count: 0),
      ]),
    );
    expect(find.text('99+'), findsOneWidget);
    expect(find.byKey(DabblerNavigationItemBadge.countKey), findsOneWidget);
  });

  testWidgets('count wins over dot', (WidgetTester t) async {
    await t.pumpWidget(
      _bar(const <DabblerNavigationItem>[
        DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
        DabblerNavigationItem(
          id: 'a',
          icon: 'sms',
          label: 'A',
          count: 2,
          unread: true,
        ),
      ]),
    );
    expect(find.byKey(DabblerNavigationItemBadge.countKey), findsOneWidget);
    expect(find.byKey(DabblerNavigationItemBadge.dotKey), findsNothing);
  });

  testWidgets('semantics label is appended: "Inbox, 3 unread"', (
    WidgetTester t,
  ) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(_bar(_withCount));
    expect(find.bySemanticsLabel('Inbox, 3 unread'), findsOneWidget);
    await t.pumpWidget(_bar(_withDot));
    expect(find.bySemanticsLabel('Inbox, unread'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('count without badgeLabel appends the bare number', (
    WidgetTester t,
  ) async {
    expect(
      DabblerNavigationItemBadge.semanticLabel(
        const DabblerNavigationItem(
          id: 'a',
          icon: 'sms',
          label: 'Inbox',
          count: 4,
        ),
      ),
      'Inbox, 4',
    );
    expect(
      DabblerNavigationItemBadge.semanticLabel(
        const DabblerNavigationItem(
          id: 'a',
          icon: 'sms',
          label: 'Inbox',
          unread: true,
        ),
      ),
      'Inbox',
    );
  });

  testWidgets(
    'dot sits at the glyph top-inline-end: right in LTR, left in RTL',
    (WidgetTester t) async {
      await t.pumpWidget(_bar(_withDot));
      Rect glyph = _glyphRect(t);
      Rect dot = t.getRect(find.byKey(DabblerNavigationItemBadge.dotKey));
      expect(dot.center.dx, greaterThan(glyph.center.dx));
      expect(dot.center.dy, lessThan(glyph.center.dy));
      expect(
        dot.right,
        closeTo(glyph.right - DabblerNavigationItemBadge.dotInset, 0.5),
      );

      await t.pumpWidget(_bar(_withDot, direction: TextDirection.rtl));
      glyph = _glyphRect(t);
      dot = t.getRect(find.byKey(DabblerNavigationItemBadge.dotKey));
      expect(dot.center.dx, lessThan(glyph.center.dx));
      expect(dot.center.dy, lessThan(glyph.center.dy));
      expect(
        dot.left,
        closeTo(glyph.left + DabblerNavigationItemBadge.dotInset, 0.5),
      );
    },
  );

  testWidgets('count pill mirrors in RTL', (WidgetTester t) async {
    await t.pumpWidget(_bar(_withCount));
    final Rect ltrGlyph = _glyphRect(t);
    final Rect ltr = t.getRect(find.byKey(DabblerNavigationItemBadge.countKey));
    expect(ltr.center.dx, greaterThan(ltrGlyph.center.dx));
    await t.pumpWidget(_bar(_withCount, direction: TextDirection.rtl));
    final Rect rtlGlyph = _glyphRect(t);
    final Rect rtl = t.getRect(find.byKey(DabblerNavigationItemBadge.countKey));
    expect(rtl.center.dx, lessThan(rtlGlyph.center.dx));
  });

  test('item equality includes the indicator fields', () {
    const DabblerNavigationItem a = DabblerNavigationItem(
      id: 'a',
      icon: 'sms',
      label: 'A',
    );
    expect(a, const DabblerNavigationItem(id: 'a', icon: 'sms', label: 'A'));
    expect(
      a ==
          const DabblerNavigationItem(
            id: 'a',
            icon: 'sms',
            label: 'A',
            count: 1,
          ),
      isFalse,
    );
    expect(
      a ==
          const DabblerNavigationItem(
            id: 'a',
            icon: 'sms',
            label: 'A',
            unread: true,
          ),
      isFalse,
    );
  });

  for (final TextDirection d in TextDirection.values) {
    testWidgets('render ${d.name}', (WidgetTester t) async {
      await renderPng(
        t,
        SizedBox(
          width: 390,
          child: DabblerNavigationBottomBar(
            items: const <DabblerNavigationItem>[
              DabblerNavigationItem(id: 'home', icon: 'home-2', label: 'Home'),
              DabblerNavigationItem(
                id: 'inbox',
                icon: 'sms',
                label: 'Inbox',
                count: 3,
                badgeLabel: '3 unread',
              ),
              DabblerNavigationItem(
                id: 'games',
                icon: 'game',
                label: 'Games',
                unread: true,
              ),
              DabblerNavigationItem(id: 'you', icon: 'user', label: 'You'),
            ],
            active: 'home',
            createItems: const <DabblerNavigationCreateItem>[],
            safeArea: false,
          ),
        ),
        name: 'bottom_bar_badges_${d.name}',
        size: const Size(390, 100),
        direction: d,
      );
    });
  }
}
