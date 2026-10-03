import 'package:dabbler_design_system/src/layout/tab_pager.dart';
import 'package:dabbler_design_system/src/layout/tabs.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-409 item 3 — DabblerTabPager.

const List<DabblerTabItem> _items = <DabblerTabItem>[
  DabblerTabItem(id: 'a', label: 'Alpha'),
  DabblerTabItem(id: 'b', label: 'Beta'),
];

Widget _list(String p) => ListView(
  children: <Widget>[
    for (int i = 0; i < 40; i++) SizedBox(height: 50, child: Text('$p$i')),
  ],
);

Widget _host({
  TextDirection direction = TextDirection.ltr,
  ValueChanged<int>? onChanged,
  PageController? controller,
}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: Brightness.light,
      ),
    ],
  ),
  home: Directionality(
    textDirection: direction,
    child: DabblerTabPager(
      items: _items,
      pages: <Widget>[_list('a'), _list('b')],
      onChanged: onChanged,
      controller: controller,
    ),
  ),
);

String? _selected(WidgetTester tester) =>
    tester.widget<DabblerTabs>(find.byType(DabblerTabs)).value;

void main() {
  testWidgets('tapping a tab moves the body', (WidgetTester tester) async {
    final List<int> changes = <int>[];
    await tester.pumpWidget(_host(onChanged: changes.add));
    expect(find.text('a0'), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(find.text('b0'), findsOneWidget);
    expect(_selected(tester), 'b');
    expect(changes, <int>[1]);
  });

  testWidgets('swiping the body moves the tab (LTR swipes left)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(_selected(tester), 'b');
    expect(find.text('b0'), findsOneWidget);
  });

  testWidgets('RTL: page order mirrors — swiping right advances', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(direction: TextDirection.rtl));
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(_selected(tester), 'a', reason: 'leftward swipe goes nowhere');
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1500);
    await tester.pumpAndSettle();
    expect(_selected(tester), 'b');
  });

  testWidgets('an external controller drives the header', (
    WidgetTester tester,
  ) async {
    final PageController c = PageController();
    addTearDown(c.dispose);
    await tester.pumpWidget(_host(controller: c));
    c.jumpToPage(1);
    await tester.pumpAndSettle();
    expect(_selected(tester), 'b');
  });

  testWidgets('each tab keeps its scroll position', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.drag(find.text('a0'), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('a0'), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('a0'), findsNothing, reason: 'offset was kept');
    expect(find.text('a12'), findsOneWidget);
  });
}
