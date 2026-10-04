// Pinned values cite "Home Feed.dc.html" (alpha-plan design set) :489-519.
import 'package:dabbler_design_system/src/forms/composer_box.dart';
import 'package:dabbler_design_system/src/forms/select_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../feed/thread_host.dart';

void main() {
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('composer box and select pill draw in $dir', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        threadHost(
          Column(
            children: <Widget>[
              DabblerSelectPill(
                label: 'Public',
                icon: 'global',
                tone: threadColors.success,
                onTap: () => taps++,
              ),
              DabblerComposerBox(
                controller: TextEditingController(),
                placeholder: 'Say it',
                counter: '0/2000',
                tools: <DabblerComposerTool>[
                  DabblerComposerTool(
                    icon: 'gallery',
                    label: 'Media',
                    onTap: () => taps++,
                  ),
                ],
              ),
            ],
          ),
          direction: dir,
        ),
      );
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('0/2000'), findsOneWidget);
      await tester.tap(find.text('Public'));
      await tester.tap(find.bySemanticsLabel('Media'));
      expect(taps, 2);
    });
  }
}
