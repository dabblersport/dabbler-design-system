// Pinned values cite "Post.dc.html" (alpha-plan design set) :58-126, :525-580.
import 'package:dabbler_design_system/src/feed/attachment_add_tile.dart';
import 'package:dabbler_design_system/src/feed/open_post.dart';
import 'package:dabbler_design_system/src/feed/post_row.dart';
import 'package:dabbler_design_system/src/feed/reply_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

DabblerOpenPost _post({VoidCallback? onFollow, VoidCallback? onLike}) =>
    DabblerOpenPost(
      name: 'Moataz',
      roleLabel: 'Player',
      badgeLabel: 'Dab',
      handle: '@moataz',
      followLabel: 'Follow',
      onFollow: onFollow,
      segments: const <DabblerPostSegment>[DabblerPostSegment('Football')],
      sportLabel: 'Football',
      placeLabel: 'Al Quoz',
      timeLabel: '8:00 PM',
      dateLabel: 'Aug 16',
      viewsLabel: '1,204 views',
      audienceLabel: 'EN',
      likes: 128,
      onLike: onLike,
      onShare: () {},
    );

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('open post draws every line in $dir', (tester) async {
      await tester.pumpWidget(
        Directionality(textDirection: dir, child: threadHost(_post())),
      );
      for (final String t in <String>[
        'Moataz',
        'Player',
        'Dab',
        '@moataz',
        'Follow',
        'Football',
        'Al Quoz',
        '8:00 PM',
        '1,204 views',
        'EN',
        '128',
      ]) {
        expect(find.textContaining(t), findsWidgets, reason: t);
      }
    });
  }

  testWidgets('follow and like fire their callbacks', (tester) async {
    int follows = 0;
    int likes = 0;
    await tester.pumpWidget(
      threadHost(_post(onFollow: () => follows++, onLike: () => likes++)),
    );
    await tester.tap(find.text('Follow'));
    await tester.tap(find.text('128'));
    expect(follows, 1);
    expect(likes, 1);
  });

  testWidgets('composing mode shows counter, Reply pill and add tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(
          onSend: (_) {},
          composing: true,
          multiline: true,
          canSendEmpty: true,
          counter: '82/280',
          attachments: DabblerAttachmentAddTile(
            semanticLabel: 'Add',
            label: 'Add',
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('82/280'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
