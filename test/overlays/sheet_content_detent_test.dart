import 'package:dabbler_design_system/src/overlays/sheet.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

/// KAN-412 W1 gap 8 — DabblerSheetDetent.content.

const Size _viewport = Size(800, 600);

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) => MediaQuery(
  data: MediaQueryData(
    size: _viewport,
    viewInsets: viewInsets,
    disableAnimations: true,
  ),
  child: Directionality(
    textDirection: direction,
    child: Theme(
      data: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      child: Navigator(
        // A fresh navigator per call, so a second pump rebuilds the page.
        key: UniqueKey(),
        onGenerateRoute: (RouteSettings s) => PageRouteBuilder<void>(
          settings: s,
          pageBuilder: (_, _, _) => child,
        ),
      ),
    ),
  ),
);

Widget _body(double height) => SizedBox(height: height, child: const Text('x'));

DabblerSheet _sheet(
  double bodyHeight, {
  DabblerSheetDetent detent = DabblerSheetDetent.content,
  double? cap,
  VoidCallback? onClose,
  Widget? footer,
}) => DabblerSheet(
  onClose: onClose ?? () {},
  title: 'Title',
  detent: detent,
  contentMaxFraction: cap ?? DabblerSheet.defaultContentMaxFraction,
  footer: footer,
  child: _body(bodyHeight),
);

double _panelHeight(WidgetTester t) =>
    t.getRect(find.byType(ClipRRect).first).height;

void main() {
  testWidgets('default detent is fractions and unchanged (half height)', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(DabblerSheet(onClose: () {}, child: _body(40))));
    await t.pumpAndSettle();
    expect(_panelHeight(t), closeTo(_viewport.height * 0.5, 0.5));
    const DabblerSheet s = DabblerSheet();
    expect(s.detent, DabblerSheetDetent.fractions);
  });

  testWidgets('a short body gives a short sheet', (WidgetTester t) async {
    await t.pumpWidget(_host(_sheet(40)));
    await t.pumpAndSettle();
    expect(_panelHeight(t), lessThan(_viewport.height * 0.5));
    expect(_panelHeight(t), greaterThan(40));
    final double short = _panelHeight(t);

    await t.pumpWidget(_host(_sheet(200)));
    await t.pumpAndSettle();
    expect(_panelHeight(t), closeTo(short + 160, 0.5));
  });

  testWidgets('a tall body stops at the cap and scrolls', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(_sheet(2000)));
    await t.pumpAndSettle();
    expect(
      _panelHeight(t),
      closeTo(_viewport.height * DabblerSheet.defaultContentMaxFraction, 0.5),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await t.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await t.pumpAndSettle();
    final ScrollableState scroll = t.state(find.byType(Scrollable));
    expect(scroll.position.pixels, greaterThan(0));
  });

  testWidgets('contentMaxFraction caps it, never above the 0.96 ceiling', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(_sheet(2000, cap: 0.78)));
    await t.pumpAndSettle();
    expect(_panelHeight(t), closeTo(_viewport.height * 0.78, 0.5));
    await t.pumpWidget(_host(_sheet(2000, cap: 1.5)));
    await t.pumpAndSettle();
    expect(
      _panelHeight(t),
      closeTo(_viewport.height * DabblerSheet.maxHeightFraction, 0.5),
    );
  });

  testWidgets('the footer stays pinned and counts toward the height', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(_sheet(2000, footer: const Text('Apply'))));
    await t.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    expect(
      t.getRect(find.text('Apply')).bottom,
      lessThanOrEqualTo(_viewport.height),
    );
    expect(
      _panelHeight(t),
      closeTo(_viewport.height * DabblerSheet.defaultContentMaxFraction, 0.5),
    );
  });

  testWidgets('the panel sits on the bottom edge', (WidgetTester t) async {
    await t.pumpWidget(_host(_sheet(40)));
    await t.pumpAndSettle();
    expect(t.getRect(find.byType(ClipRRect).first).bottom, _viewport.height);
  });

  testWidgets('a long drag dismisses; a short one springs back', (
    WidgetTester t,
  ) async {
    int closed = 0;
    await t.pumpWidget(_host(_sheet(80, onClose: () => closed++)));
    await t.pumpAndSettle();
    final Finder handle = find.byWidgetPredicate(
      (Widget w) =>
          w is Container && w.constraints?.maxWidth == DabblerSheet.handleWidth,
    );
    final double before = _panelHeight(t);
    await t.drag(handle, const Offset(0, 10));
    await t.pumpAndSettle();
    expect(closed, 0);
    expect(_panelHeight(t), before);
    await t.drag(handle, const Offset(0, 300));
    await t.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('RTL: same height, title at the inline start (right)', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(_host(_sheet(80)));
    await t.pumpAndSettle();
    final double ltr = _panelHeight(t);
    final double ltrTitle = t.getRect(find.text('Title')).left;
    await t.pumpWidget(_host(_sheet(80), direction: TextDirection.rtl));
    await t.pumpAndSettle();
    expect(_panelHeight(t), ltr);
    expect(t.getRect(find.text('Title')).left, greaterThan(ltrTitle));
  });

  testWidgets('showDabblerSheet takes detent and cap', (WidgetTester t) async {
    await t.pumpWidget(
      _host(
        Builder(
          builder: (BuildContext context) => GestureDetector(
            onTap: () => showDabblerSheet<void>(
              context: context,
              detent: DabblerSheetDetent.content,
              contentMaxFraction: 0.78,
              builder: (_) => _body(2000),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(_panelHeight(t), closeTo(_viewport.height * 0.78, 0.5));
  });

  testWidgets('showDabblerSheet keeps the fractions default', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      _host(
        Builder(
          builder: (BuildContext context) => GestureDetector(
            onTap: () => showDabblerSheet<void>(
              context: context,
              builder: (_) => _body(10),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(_panelHeight(t), closeTo(_viewport.height * 0.5, 0.5));
  });

  for (final TextDirection d in TextDirection.values) {
    for (final bool tall in <bool>[false, true]) {
      testWidgets('render ${tall ? 'tall' : 'short'} ${d.name}', (
        WidgetTester t,
      ) async {
        await renderPng(
          t,
          SizedBox(
            width: 390,
            height: 640,
            child: DabblerSheet(
              onClose: () {},
              title: d == TextDirection.rtl ? 'الفلاتر' : 'Filters',
              detent: DabblerSheetDetent.content,
              footer: Text(
                'Apply',
                style: DabblerType.body
                    .resolveForDirection(d)
                    .copyWith(color: _colors.textPrimary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int i = 0; i < (tall ? 24 : 3); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Option $i',
                        style: DabblerType.body
                            .resolveForDirection(d)
                            .copyWith(color: _colors.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          name: 'sheet_content_${tall ? 'tall' : 'short'}_${d.name}',
          size: const Size(390, 640),
          direction: d,
        );
      });
    }
  }
}
