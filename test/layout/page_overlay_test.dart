import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/layout/fade.dart';
import 'package:dabbler_design_system/src/layout/page.dart';
import 'package:dabbler_design_system/src/navigation/bottom_bar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

/// KAN-412 W1 gap 7 — DabblerPage.bottomOverlay / overlayFade.

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

const Key _overlayKey = ValueKey<String>('overlay');
const Key _listKey = ValueKey<String>('list');

Widget _host(Widget page, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 800),
          disableAnimations: true,
        ),
        child: Directionality(textDirection: direction, child: page),
      ),
    );

const Widget _overlay = SizedBox(key: _overlayKey, height: 56);

Widget _list() => ListView.builder(
  key: _listKey,
  itemCount: 30,
  itemBuilder: (BuildContext c, int i) =>
      SizedBox(height: 60, child: Text('row $i')),
);

void _screen(WidgetTester t) {
  t.view.physicalSize = const Size(390, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('default: no overlay and no fade', (WidgetTester t) async {
    _screen(t);
    await t.pumpWidget(_host(DabblerPage(body: _list())));
    await t.pumpAndSettle();
    expect(find.byType(DabblerFade), findsNothing);
    expect(find.byKey(_overlayKey), findsNothing);
  });

  testWidgets('overlay sits at the bottom with the fade behind it', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _host(DabblerPage(body: _list(), bottomOverlay: _overlay)),
    );
    await t.pumpAndSettle();
    expect(find.byType(DabblerFade), findsOneWidget);
    final Rect fade = t.getRect(find.byType(DabblerFade));
    expect(fade.bottom, 800);
    expect(fade.width, 390);
    final Rect bar = t.getRect(find.byKey(_overlayKey));
    // 24px under the bar (--space-8), --space-6 at each side.
    expect(bar.bottom, 800 - DabblerFadeTokens.bottomInset);
    expect(bar.left, DabblerSpacing.space6);
    expect(bar.right, 390 - DabblerSpacing.space6);
    expect(fade.height, 56 + DabblerFadeTokens.bottomInset);
  });

  testWidgets('overlayFade: false drops the fade and the default padding', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _host(
        DabblerPage(body: _list(), bottomOverlay: _overlay, overlayFade: false),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(DabblerFade), findsNothing);
    final Rect bar = t.getRect(find.byKey(_overlayKey));
    expect(bar.bottom, 800);
    expect(bar.width, 390);
  });

  testWidgets('compact padding is the Listings 12px sides', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _host(
        DabblerPage(
          body: _list(),
          bottomOverlay: _overlay,
          overlayPadding: DabblerPage.overlayPaddingCompact,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getRect(find.byKey(_overlayKey)).left, DabblerSpacing.space4);
  });

  testWidgets('the body is not shrunk; scrolling content stays reachable', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _host(DabblerPage(body: _list(), bottomOverlay: _overlay)),
    );
    await t.pumpAndSettle();
    // The list keeps the full height beneath the overlay.
    expect(t.getRect(find.byKey(_listKey)).bottom, 800);
    await t.drag(find.byKey(_listKey), const Offset(0, -10000));
    await t.pumpAndSettle();
    final Rect last = t.getRect(find.text('row 29'));
    final double overlayTop = t.getRect(find.byType(DabblerFade)).top;
    expect(
      last.bottom,
      lessThanOrEqualTo(overlayTop + 0.5),
      reason: 'last row scrolls clear of the overlay',
    );
  });

  testWidgets('a bottom bar in the overlay mirrors: action at the inline end', (
    WidgetTester t,
  ) async {
    _screen(t);
    Future<double> actionDx(TextDirection d) async {
      await t.pumpWidget(
        _host(
          DabblerPage(
            body: _list(),
            bottomOverlay: const DabblerNavigationBottomBar(
              createItems: <DabblerNavigationCreateItem>[],
              safeArea: false,
            ),
          ),
          direction: d,
        ),
      );
      await t.pumpAndSettle();
      return t
          .getCenter(
            find.byWidgetPredicate(
              (Widget w) => w is DabblerIcon && w.name == 'add',
            ),
          )
          .dx;
    }

    expect(await actionDx(TextDirection.ltr), greaterThan(195));
    expect(await actionDx(TextDirection.rtl), lessThan(195));
  });

  testWidgets('a top bar keeps its slot above the body', (
    WidgetTester t,
  ) async {
    _screen(t);
    await t.pumpWidget(
      _host(
        DabblerPage(
          topBar: const SizedBox(height: 40),
          body: _list(),
          bottomOverlay: _overlay,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getRect(find.byKey(_listKey)).top, 40);
  });

  for (final TextDirection d in TextDirection.values) {
    testWidgets('render ${d.name}', (WidgetTester t) async {
      await renderPng(
        t,
        SizedBox(
          width: 390,
          height: 640,
          child: DabblerPage(
            body: ListView.builder(
              itemCount: 12,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding: const EdgeInsets.all(DabblerSpacing.space6),
                child: Text(
                  'Row $i',
                  style: DabblerType.body
                      .resolveForDirection(d)
                      .copyWith(color: _colors.textPrimary),
                ),
              ),
            ),
            bottomOverlay: const DabblerNavigationBottomBar(
              createItems: <DabblerNavigationCreateItem>[],
              safeArea: false,
            ),
          ),
        ),
        name: 'page_overlay_${d.name}',
        size: const Size(390, 640),
        direction: d,
      );
    });
  }
}
