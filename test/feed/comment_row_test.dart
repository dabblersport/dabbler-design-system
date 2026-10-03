// Pinned values cite "Post.dc.html" (alpha-plan design set): reply :285-300,
// nested reply :306-317.
import 'package:dabbler_design_system/src/feed/comment_row.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

void main() {
  testWidgets('draws author, handle, time, body; callbacks fire', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<String> calls = <String>[];
    await tester.pumpWidget(
      threadHost(
        DabblerCommentRow(
          name: 'Karim',
          handle: '@karim',
          time: '1h',
          body: 'Count me in',
          likes: 4,
          onLike: () => calls.add('like'),
          onReply: () => calls.add('reply'),
          onMore: () => calls.add('more'),
          repliesLabel: '2 replies',
          onViewReplies: () => calls.add('kids'),
          onTap: () => calls.add('tap'),
        ),
      ),
    );
    expect(find.text('Karim'), findsOneWidget);
    expect(find.text('@karim'), findsOneWidget);
    expect(find.text('1h'), findsOneWidget);
    expect(find.text('Count me in'), findsOneWidget);
    await tester.tap(find.text('Reply'));
    await tester.tap(find.text('2 replies'));
    await tester.tap(find.bySemanticsLabel(RegExp('^Like')));
    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.tap(find.text('Count me in'));
    expect(calls, <String>['reply', 'kids', 'like', 'more', 'tap']);
    handle.dispose();
  });

  testWidgets('text actions reach the 45px touch minimum', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(DabblerCommentRow(name: 'A', time: '1h', onReply: () {})),
    );
    final Size s = tester.getSize(
      find
          .ancestor(
            of: find.text('Reply'),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(s.height, greaterThanOrEqualTo(45));
    expect(s.width, greaterThanOrEqualTo(45));
  });

  testWidgets('long press fires with and without a tap and is in semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int long = 0;
    await tester.pumpWidget(
      threadHost(
        DabblerCommentRow(
          name: 'A',
          time: '1h',
          body: 'hold me',
          onLongPress: () => long++,
        ),
      ),
    );
    await tester.longPress(find.text('hold me'));
    expect(long, 1);
    expect(
      tester.getSemantics(find.text('hold me')),
      isSemantics(hasLongPressAction: true),
    );

    await tester.pumpWidget(
      threadHost(
        DabblerCommentRow(
          name: 'A',
          time: '1h',
          body: 'hold me',
          onTap: () {},
          onLongPress: () => long++,
        ),
      ),
    );
    await tester.longPress(find.text('hold me'));
    expect(long, 2);
    handle.dispose();
  });

  testWidgets('depth: xs avatar, indent from the start edge, no divider', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(const DabblerCommentRow(name: 'A', time: '1h', depth: 1)),
    );
    final DabblerAvatar avatar = tester.widget(find.byType(DabblerAvatar));
    expect(avatar.size, DabblerAvatarSize.xs);
    final double ltr = tester.getTopLeft(find.byType(DabblerAvatar)).dx;
    expect(ltr, DabblerCommentRow.indentStep);

    await tester.pumpWidget(
      threadHost(
        const DabblerCommentRow(name: 'A', time: '1h', depth: 1),
        direction: TextDirection.rtl,
      ),
    );
    final double rtlRight = tester.getTopRight(find.byType(DabblerAvatar)).dx;
    expect(360 - rtlRight, DabblerCommentRow.indentStep);
  });

  testWidgets('top level uses the sm avatar and draws the divider', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(const DabblerCommentRow(name: 'A', time: '1h')),
    );
    final DabblerAvatar avatar = tester.widget(find.byType(DabblerAvatar));
    expect(avatar.size, DabblerAvatarSize.sm);
    final DecoratedBox box = tester.widget(
      find
          .descendant(
            of: find.byType(DabblerCommentRow),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final Border border = (box.decoration as BoxDecoration).border! as Border;
    expect(border.bottom.color, threadColors.bgTertiary);
  });

  testWidgets('attachment slot draws under the body; RTL more trails left', (
    WidgetTester tester,
  ) async {
    const Key k = ValueKey<String>('att');
    await tester.pumpWidget(
      threadHost(
        DabblerCommentRow(
          name: 'A',
          time: '1h',
          body: 'body',
          attachment: const SizedBox(key: k, width: 80, height: 60),
          onMore: () {},
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(k)).dy,
      greaterThan(tester.getBottomLeft(find.text('body')).dy),
    );
    final double more = tester
        .getCenter(find.bySemanticsLabel('More options'))
        .dx;
    final double name = tester.getCenter(find.text('A')).dx;
    expect(more, lessThan(name));
  });

  testWidgets('liked heart is the error colour; digits are Western', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(
        const DabblerCommentRow(name: 'A', time: '٣س', likes: 3, liked: true),
      ),
    );
    expect(find.text('3س'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
