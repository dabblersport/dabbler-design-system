// Pinned values cite "Post.dc.html" (alpha-plan design set): thumbnail
// :541-546, place pill :547.
import 'package:dabbler_design_system/src/feed/attachment_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

void main() {
  testWidgets('thumbnail: 96 square, remove is a named 45px button', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int removed = 0;
    await tester.pumpWidget(
      threadHost(
        Align(
          alignment: AlignmentDirectional.topStart,
          child: DabblerAttachmentChip(
            thumbnail: const ColoredBox(color: Color(0x00000000)),
            semanticLabel: 'Pitch photo',
            onRemove: () => removed++,
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(DabblerAttachmentChip)),
      const Size(96, 96),
    );
    final Finder remove = find.bySemanticsLabel('Remove attachment');
    expect(tester.getSize(remove), const Size(45, 45));
    expect(tester.getSemantics(remove), isSemantics(isButton: true));
    expect(find.bySemanticsLabel('Pitch photo'), findsOneWidget);
    await tester.tap(remove);
    expect(removed, 1);
    handle.dispose();
  });

  testWidgets('remove sits at the end corner and mirrors in RTL', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    Widget chip() => Align(
      alignment: AlignmentDirectional.topStart,
      child: DabblerAttachmentChip(
        thumbnail: const SizedBox.expand(),
        semanticLabel: 'p',
        onRemove: () {},
      ),
    );
    await tester.pumpWidget(threadHost(chip()));
    final Rect frame = tester.getRect(find.byType(DabblerAttachmentChip));
    final Rect ltr = tester.getRect(find.bySemanticsLabel('Remove attachment'));
    expect(ltr.right, frame.right);
    expect(ltr.top, frame.top);

    await tester.pumpWidget(threadHost(chip(), direction: TextDirection.rtl));
    final Rect frameR = tester.getRect(find.byType(DabblerAttachmentChip));
    final Rect rtl = tester.getRect(find.bySemanticsLabel('Remove attachment'));
    expect(rtl.left, frameR.left);
    handle.dispose();
  });

  testWidgets('pill: icon, label, remove; no remove without callback', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int taps = 0;
    await tester.pumpWidget(
      threadHost(
        DabblerAttachmentChip(
          icon: 'location',
          label: 'Al Quoz',
          onRemove: () {},
          onTap: () => taps++,
        ),
      ),
    );
    expect(find.text('Al Quoz'), findsOneWidget);
    expect(find.bySemanticsLabel('Remove attachment'), findsOneWidget);
    expect(
      tester.getSize(find.byType(DabblerAttachmentChip)).height,
      greaterThanOrEqualTo(45),
    );
    await tester.tap(find.text('Al Quoz'));
    expect(taps, 1);

    await tester.pumpWidget(
      threadHost(
        const DabblerAttachmentChip(icon: 'location', label: 'Al Quoz'),
        direction: TextDirection.rtl,
      ),
    );
    expect(find.bySemanticsLabel('Remove attachment'), findsNothing);
    handle.dispose();
  });
}
