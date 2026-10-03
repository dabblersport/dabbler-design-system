import 'dart:async';

import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/layout/refresh.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-409 item 3 — DabblerRefresh.

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          DabblerColors.resolve(
            theme: DabblerTheme.main,
            brightness: Brightness.light,
          ),
        ],
      ),
      home: Directionality(textDirection: direction, child: child),
    );

Widget _list() => ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: <Widget>[
    for (int i = 0; i < 30; i++) SizedBox(height: 48, child: Text('row $i')),
  ],
);

Future<Completer<void>> _pull(
  WidgetTester tester, {
  TextDirection direction = TextDirection.ltr,
}) async {
  final Completer<void> done = Completer<void>();
  int calls = 0;
  await tester.pumpWidget(
    _host(
      DabblerRefresh(
        onRefresh: () {
          calls++;
          return done.future;
        },
        child: _list(),
      ),
      direction: direction,
    ),
  );
  expect(find.byKey(DabblerRefresh.indicatorKey), findsNothing);
  await tester.fling(find.text('row 0'), const Offset(0, 300), 1000);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  expect(calls, 1);
  return done;
}

void main() {
  testWidgets('pulling calls onRefresh and shows the DS spinner until done', (
    WidgetTester tester,
  ) async {
    final Completer<void> done = await _pull(tester);
    final Finder indicator = find.byKey(DabblerRefresh.indicatorKey);
    expect(indicator, findsOneWidget);
    final DabblerSpinner spinner = tester.widget<DabblerSpinner>(indicator);
    expect(spinner.tone, DabblerSpinnerTone.brand);
    expect(spinner.animate, isTrue);
    // No Material progress indicator anywhere.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(RefreshProgressIndicator), findsNothing);

    done.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(DabblerRefresh.indicatorKey), findsNothing);
  });

  testWidgets('RTL: the same pull refreshes and centres the indicator', (
    WidgetTester tester,
  ) async {
    final Completer<void> done = await _pull(
      tester,
      direction: TextDirection.rtl,
    );
    final Rect r = tester.getRect(find.byKey(DabblerRefresh.indicatorKey));
    expect(r.center.dx, closeTo(400, 0.5));
    expect(r.top, DabblerRefresh.inset);
    done.complete();
    await tester.pump(const Duration(seconds: 1));
  });
}
