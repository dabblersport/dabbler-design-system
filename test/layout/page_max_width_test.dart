import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _page({double? maxWidth, TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[testColors()],
    ),
    home: Directionality(
      textDirection: direction,
      child: DabblerPage(
        maxContentWidth: maxWidth,
        topBar: const SizedBox(key: Key('top'), height: 20),
        body: const SizedBox.expand(key: Key('body')),
        bottomBar: const SizedBox(key: Key('bottom'), height: 20),
      ),
    ),
  );
}

void main() {
  group('DabblerPage.maxContentWidth', () {
    testWidgets('null keeps every band as wide as the page', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_page());
      expect(tester.getSize(find.byKey(const Key('body'))).width, 900);
      expect(tester.getSize(find.byKey(const Key('top'))).width, 900);
      expect(tester.getSize(find.byKey(const Key('bottom'))).width, 900);
    });

    testWidgets('holds the top bar, body and bottom bar to the limit, centred', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_page(maxWidth: DabblerPage.readableWidth));
      for (final String k in <String>['top', 'body', 'bottom']) {
        final Rect r = tester.getRect(find.byKey(Key(k)));
        expect(r.width, DabblerPage.readableWidth, reason: k);
        expect(r.left, (900 - DabblerPage.readableWidth) / 2, reason: k);
      }
      // The body still fills the height between the bars.
      expect(tester.getSize(find.byKey(const Key('body'))).height, 560);
    });

    testWidgets('a page narrower than the limit is not widened', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_page(maxWidth: DabblerPage.readableWidth));
      expect(tester.getSize(find.byKey(const Key('body'))).width, 393);
    });

    testWidgets('is symmetric in RTL', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _page(
          maxWidth: DabblerPage.readableWidth,
          direction: TextDirection.rtl,
        ),
      );
      final Rect r = tester.getRect(find.byKey(const Key('body')));
      expect(r.left, (900 - DabblerPage.readableWidth) / 2);
      expect(r.right, 900 - (900 - DabblerPage.readableWidth) / 2);
    });
  });
}
