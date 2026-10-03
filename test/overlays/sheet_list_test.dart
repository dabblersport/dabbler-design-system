import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

Widget _row(BuildContext _, int i) =>
    SizedBox(height: 50, child: Text('Row $i'));

void main() {
  group('DabblerSheetList', () {
    testWidgets('a long list is bounded and scrolls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerSheetList(
            itemCount: 100,
            itemBuilder: _row,
            maxHeight: 200,
          ),
        ),
      );
      expect(tester.getSize(find.byType(ListView)).height, 200);
      expect(find.text('Row 99'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -6000));
      await tester.pumpAndSettle();
      expect(find.text('Row 99'), findsOneWidget);
    });

    testWidgets('a short list shrinks to fit', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const DabblerSheetList(itemCount: 2, itemBuilder: _row)),
      );
      expect(tester.getSize(find.byType(ListView)).height, 100);
    });

    testWidgets('default bound is half the viewport', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerSheetList(itemCount: 100, itemBuilder: _row)),
      );
      final double screen =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(
        tester.getSize(find.byType(ListView)).height,
        screen * DabblerSheetList.defaultMaxHeightFraction,
      );
    });

    testWidgets('header is pinned above the rows', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerSheetList(
            header: Text('search'),
            itemCount: 3,
            itemBuilder: _row,
          ),
        ),
      );
      expect(
        tester.getRect(find.text('search')).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(ListView)).top),
      );
    });

    testWidgets('loading shows the spinner and keeps the header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerSheetList(
            header: Text('search'),
            loading: true,
            loadingLabel: 'Loading',
            itemCount: 3,
            itemBuilder: _row,
          ),
        ),
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(find.text('search'), findsOneWidget);
    });

    testWidgets('empty text in muted footnote; custom empty wins', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerSheetList(
            itemCount: 0,
            itemBuilder: _row,
            emptyText: 'Nothing',
          ),
        ),
      );
      final Text t = tester.widget(find.text('Nothing'));
      expect(t.style!.color, testColors().textTertiary);
      await tester.pumpWidget(
        host(
          const DabblerSheetList(
            itemCount: 0,
            itemBuilder: _row,
            emptyText: 'Nothing',
            empty: Text('Custom'),
          ),
        ),
      );
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Nothing'), findsNothing);
    });

    for (final TextDirection dir in TextDirection.values) {
      testWidgets('works inside a content-sized sheet ($dir)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (BuildContext context) => GestureDetector(
                onTap: () => showDabblerSheet<void>(
                  context: context,
                  title: 'Places',
                  detent: DabblerSheetDetent.content,
                  builder: (_) =>
                      const DabblerSheetList(itemCount: 60, itemBuilder: _row),
                ),
                child: const Text('open'),
              ),
            ),
            direction: dir,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Row 0'), findsOneWidget);
        expect(find.text('Row 59'), findsNothing);
      });
    }
  });
}
