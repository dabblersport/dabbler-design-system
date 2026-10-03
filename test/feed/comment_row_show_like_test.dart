import 'package:dabbler_design_system/src/feed/comment_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('showLike false hides the like action ($dir)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        threadHost(
          const DabblerCommentRow(
            name: 'Karim',
            time: '1h',
            body: 'Count me in',
            showLike: false,
          ),
          direction: dir,
        ),
      );
      expect(find.bySemanticsLabel(RegExp('^Like')), findsNothing);
    });

    testWidgets('showLike defaults to true ($dir)', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        threadHost(
          const DabblerCommentRow(name: 'Karim', time: '1h', body: 'Count me in'),
          direction: dir,
        ),
      );
      expect(find.bySemanticsLabel(RegExp('^Like')), findsOneWidget);
      handle.dispose();
    });
  }
}
