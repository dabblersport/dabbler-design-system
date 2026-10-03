// Pinned values cite "Post.dc.html" (alpha-plan design set) :241-252.
import 'package:dabbler_design_system/src/feed/post_detail.dart';
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

DabblerPostRow _row({DabblerPostDetail? detail}) => DabblerPostRow(
  name: 'Moataz',
  time: '2h',
  place: 'Al Quoz',
  body: 'Football Sunday',
  detail: detail,
);

void main() {
  testWidgets('without detail the row is unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(threadHost(_row()));
    expect(find.byType(DabblerPostDetailLine), findsNothing);
  });

  testWidgets('detail draws timestamp, edited and visibility above actions', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      threadHost(
        _row(
          detail: const DabblerPostDetail(
            timestamp: '8:00 PM · Aug 16, 2026',
            editedLabel: 'Edited',
            visibilityLabel: 'Public',
            visibilitySemanticLabel: 'Visible to everyone',
          ),
        ),
      ),
    );
    expect(find.text('8:00 PM · Aug 16, 2026'), findsOneWidget);
    expect(find.text('Edited'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.bySemanticsLabel('Visible to everyone'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.byType(DabblerPostDetailLine)).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.bySemanticsLabel(RegExp('^Like'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byType(DabblerPostDetailLine)).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.text('Football Sunday')).dy,
      ),
    );
    handle.dispose();
  });

  testWidgets('no edited marker or visibility when null; Western digits', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(_row(detail: const DabblerPostDetail(timestamp: '٨:٠٠'))),
    );
    expect(find.text('8:00'), findsOneWidget);
    expect(find.text('Edited'), findsNothing);
  });

  testWidgets('RTL: visibility trails at the left', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(
        _row(
          detail: const DabblerPostDetail(
            timestamp: 'today',
            visibilityLabel: 'Public',
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.getCenter(find.text('Public')).dx,
      lessThan(tester.getCenter(find.text('today')).dx),
    );
  });
}
