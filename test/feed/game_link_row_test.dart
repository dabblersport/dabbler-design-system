// Pinned values cite "Home Feed.dc.html" (alpha-plan design set) :889-912.
import 'package:dabbler_design_system/src/feed/attachment_add_tile.dart';
import 'package:dabbler_design_system/src/feed/game_link_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('game link row draws and taps in $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        threadHost(
          DabblerGameLinkRow(
            month: 'Aug',
            day: '18',
            title: 'Friday 5-a-side',
            place: 'Zayed',
            time: '8:00 PM',
            status: 'Live',
            live: true,
            selected: true,
            onTap: () => taps++,
          ),
          direction: dir,
        ),
      );
      expect(find.text('Friday 5-a-side'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      await tester.tap(find.text('Friday 5-a-side'));
      expect(taps, 1);
    });
  }

  testWidgets('solid add tile is the 64 x 128 rail tile', (tester) async {
    await tester.pumpWidget(
      threadHost(
        Align(
          alignment: Alignment.topLeft,
          child: DabblerAttachmentAddTile(
            semanticLabel: 'Add more media',
            icon: 'add',
            dashed: false,
            tileWidth: 64,
            tileHeight: 128,
            onTap: () {},
          ),
        ),
      ),
    );
    final Size size = tester.getSize(find.byType(DabblerAttachmentAddTile));
    expect(size.width, 64);
    expect(size.height, 128);
  });
}
