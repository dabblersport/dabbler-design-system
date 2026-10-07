import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

const List<DabblerTabItem> _tabs = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'All'),
  DabblerTabItem(id: 'b', label: 'Two'),
];

Widget _page({
  required bool filters,
  DabblerListingHead head = DabblerListingHead.tint,
  ValueChanged<Color?>? onBand,
}) => DabblerListingPage(
  head: head,
  onBandColor: onBand,
  header: const DabblerPageHeader(
    title: 'Games',
    safeArea: false,
    contentPadding: DabblerPageHeader.listingPadding,
  ),
  tabs: _tabs,
  filters: filters
      ? <DabblerFilterRailItem>[
          DabblerFilterRailItem(label: 'Today', onRemove: () {}),
        ]
      : const <DabblerFilterRailItem>[],
  clearAllLabel: 'Clear all',
  onClearAll: () {},
  pages: <Widget>[
    for (int i = 0; i < 2; i++)
      ListView(children: const <Widget>[SizedBox(height: 2000)]),
  ],
);

double _opacity(WidgetTester t, Finder f) => t
    .widget<AnimatedOpacity>(
      find.ancestor(of: f, matching: find.byType(AnimatedOpacity)).first,
    )
    .opacity;

Future<void> _scrollTo(WidgetTester t, double dy) async {
  await t.drag(find.byType(ListView).first, Offset(0, -dy));
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('band tint is brand 14% over the card colour', (t) async {
    Color? band;
    await t.pumpWidget(
      host(_page(filters: false, onBand: (c) => band = c), width: 393),
    );
    await t.pump();
    final DabblerColors c = testColors();
    expect(
      band,
      Color.lerp(c.surfaceCard, c.brandPrimary, DabblerListingPage.tintShare),
    );
  });

  testWidgets('accent head is the accent tile surface; none reports null', (
    t,
  ) async {
    Color? band;
    await t.pumpWidget(
      host(
        _page(
          filters: false,
          head: DabblerListingHead.accent,
          onBand: (c) => band = c,
        ),
        width: 393,
      ),
    );
    await t.pump();
    expect(band, DabblerColors.tileAccent.surface);
    await t.pumpWidget(
      host(
        _page(
          filters: false,
          head: DabblerListingHead.none,
          onBand: (c) => band = c,
        ),
        width: 393,
      ),
    );
    await t.pump();
    expect(band, isNull);
  });

  testWidgets('with filters: scrolling folds tabs and title, filters stay', (
    t,
  ) async {
    await t.pumpWidget(host(_page(filters: true), width: 393));
    expect(_opacity(t, find.text('All')), 1);
    expect(_opacity(t, find.text('Games')), 1);
    await _scrollTo(t, 200);
    expect(_opacity(t, find.text('All')), 0);
    expect(_opacity(t, find.text('Games')), 0);
    expect(find.text('Clear all'), findsOneWidget);
    // Back to the top: expands (hysteresis under 8).
    await _scrollTo(t, -400);
    expect(_opacity(t, find.text('All')), 1);
    expect(_opacity(t, find.text('Games')), 1);
  });

  testWidgets('without filters: tabs fold, the title row stays', (t) async {
    await t.pumpWidget(host(_page(filters: false), width: 393));
    await _scrollTo(t, 200);
    expect(_opacity(t, find.text('All')), 0);
    expect(_opacity(t, find.text('Games')), 1);
  });

  testWidgets('hysteresis: a scroll of 30 does not collapse', (t) async {
    await t.pumpWidget(host(_page(filters: true), width: 393));
    await _scrollTo(t, 30);
    expect(_opacity(t, find.text('All')), 1);
  });

  testWidgets('tapping a tab moves to its page', (t) async {
    await t.pumpWidget(host(_page(filters: false), width: 393));
    await t.tap(find.text('Two'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
