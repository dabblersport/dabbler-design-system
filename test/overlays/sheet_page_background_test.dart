import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feed/thread_host.dart';

void main() {
  testWidgets('pageBackground paints the panel in the page colour', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(
        const SizedBox(
          height: 400,
          child: DabblerSheet(
            presentation: DabblerSheetPresentation.inline,
            pageBackground: true,
            child: Text('body'),
          ),
        ),
      ),
    );
    final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    expect(
      boxes.any(
        (DecoratedBox b) =>
            b.decoration is BoxDecoration &&
            (b.decoration as BoxDecoration).color == threadColors.bgPrimary,
      ),
      isTrue,
    );
  });

  testWidgets('showCloseButton false draws no close button', (
    WidgetTester tester,
  ) async {
    Widget sheet(bool show) => threadHost(
      SizedBox(
        height: 400,
        child: DabblerSheet(
          presentation: DabblerSheetPresentation.inline,
          onClose: () {},
          title: 'T',
          showCloseButton: show,
          child: const Text('body'),
        ),
      ),
    );
    await tester.pumpWidget(sheet(true));
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    await tester.pumpWidget(sheet(false));
    expect(find.bySemanticsLabel('Close'), findsNothing);
  });
}
