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

  // KAN-461: the designed 162 minimum (Home Feed.dc.html:499 — min-height
  // 132 + 15 padding each side), opt-in; the default is unchanged.
  for (final TextDirection dir in TextDirection.values) {
    testWidgets('minFieldHeight yields the designed 162 field area ($dir)', (
      tester,
    ) async {
      Future<double> height({double? min}) async {
        await tester.pumpWidget(
          threadHost(
            DabblerComposerBox(
              controller: TextEditingController(),
              placeholder: 'Say it',
              tools: const <DabblerComposerTool>[],
              minFieldHeight: min,
            ),
            direction: dir,
          ),
        );
        return tester
            .getSize(
              find
                  .ancestor(
                    of: find.byType(TextField),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .height;
      }

      expect(DabblerComposerBox.designedHeight, 162);
      expect(await height(min: DabblerComposerBox.designedFieldMinHeight), 162);
      // Default unchanged: still sized by minLines (5), not by the minimum.
      expect(await height(), isNot(162));
    });
  }

  testWidgets('tapping the empty minimum area focuses the field', (
    tester,
  ) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      threadHost(
        DabblerComposerBox(
          controller: TextEditingController(),
          focusNode: node,
          placeholder: 'Say it',
          tools: const <DabblerComposerTool>[],
          minFieldHeight: DabblerComposerBox.designedFieldMinHeight,
        ),
      ),
    );
    expect(node.hasFocus, isFalse);
    await tester.tap(
      find.byKey(const ValueKey<String>('dabbler-composer-field-area')),
    );
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });
}
