// Pinned values cite "Post.dc.html" (alpha-plan design set): resting bar
// :329-341, composing frame :525-580.
import 'package:dabbler_design_system/src/feed/reply_composer.dart';
import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/layout/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

Finder _send() => find.bySemanticsLabel('Send');

void main() {
  testWidgets('send is disabled while empty and sends the text when ready', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<String> sent = <String>[];
    await tester.pumpWidget(threadHost(DabblerReplyComposer(onSend: sent.add)));
    expect(
      tester.getSemantics(_send()),
      isSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    await tester.tap(_send());
    expect(sent, isEmpty);

    await tester.enterText(find.byType(TextField), 'I am in');
    await tester.pump();
    expect(
      tester.getSemantics(_send()),
      isSemantics(isButton: true, isEnabled: true),
    );
    await tester.tap(_send());
    expect(sent, <String>['I am in']);

    await tester.testTextInput.receiveAction(TextInputAction.send);
    expect(sent.length, 2);
    handle.dispose();
  });

  testWidgets('sending shows a spinner and disables send', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final TextEditingController c = TextEditingController(text: 'x');
    final List<String> sent = <String>[];
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(onSend: sent.add, controller: c, sending: true),
      ),
    );
    expect(find.byType(DabblerSpinner), findsOneWidget);
    await tester.tap(_send());
    expect(sent, isEmpty);
    expect(tester.getSemantics(_send()), isSemantics(isEnabled: false));
    handle.dispose();
    c.dispose();
  });

  testWidgets('replying-to line and cancel; attachments slot; attach actions', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<String> calls = <String>[];
    const Key k = ValueKey<String>('prev');
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(
          onSend: (_) {},
          replyingTo: '@moataz',
          onCancelReply: () => calls.add('cancel'),
          attachments: const SizedBox(key: k, height: 40, width: 40),
          attachActions: <DabblerReplyComposerAction>[
            DabblerReplyComposerAction(
              icon: 'gallery',
              label: 'Add photo',
              onTap: () => calls.add('photo'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Replying to'), findsOneWidget);
    expect(find.text('@moataz'), findsOneWidget);
    expect(find.byKey(k), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Cancel reply'));
    await tester.tap(find.bySemanticsLabel('Add photo'));
    expect(calls, <String>['cancel', 'photo']);
    expect(tester.getSize(_send()).height, greaterThanOrEqualTo(45));
    handle.dispose();
  });

  testWidgets('multiline grows and Enter adds a line', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(DabblerReplyComposer(onSend: (_) {}, multiline: true)),
    );
    final TextField f = tester.widget(find.byType(TextField));
    expect(f.maxLines, 5);
    expect(f.textInputAction, TextInputAction.newline);
    final double one = tester.getSize(find.byType(DabblerReplyComposer)).height;
    await tester.enterText(find.byType(TextField), 'a\nb\nc');
    await tester.pump();
    expect(
      tester.getSize(find.byType(DabblerReplyComposer)).height,
      greaterThan(one),
    );
  });

  testWidgets('pads the home inset with the keyboard closed, not open', (
    WidgetTester tester,
  ) async {
    const MediaQueryData closed = MediaQueryData(
      size: Size(400, 800),
      viewPadding: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.only(bottom: 30),
    );
    await tester.pumpWidget(
      threadHost(DabblerReplyComposer(onSend: (_) {}), media: closed),
    );
    final double withInset = tester
        .getSize(find.byType(DabblerReplyComposer))
        .height;
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(onSend: (_) {}),
        media: closed.copyWith(viewInsets: const EdgeInsets.only(bottom: 300)),
      ),
    );
    final double open = tester
        .getSize(find.byType(DabblerReplyComposer))
        .height;
    expect(withInset - open, 30);
  });

  testWidgets('works as DabblerPage.bottomBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: <ThemeExtension<dynamic>>[threadColors]),
        home: DabblerPage(
          body: const SizedBox.expand(),
          bottomBar: DabblerReplyComposer(onSend: (_) {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.byType(DabblerReplyComposer)).dy,
      tester.getSize(find.byType(DabblerPage)).height,
    );
  });

  testWidgets('RTL: attach leads at the right, send trails at the left', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(
          onSend: (_) {},
          attachActions: <DabblerReplyComposerAction>[
            DabblerReplyComposerAction(
              icon: 'gallery',
              label: 'Add photo',
              onTap: () {},
            ),
          ],
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.getCenter(find.bySemanticsLabel('Add photo')).dx,
      greaterThan(tester.getCenter(_send()).dx),
    );
    handle.dispose();
  });

  testWidgets('reduced motion: no animated duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      threadHost(
        DabblerReplyComposer(onSend: (_) {}),
        media: const MediaQueryData(disableAnimations: true),
      ),
    );
    for (final AnimatedContainer a in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    )) {
      expect(a.duration, Duration.zero);
    }
  });
}
