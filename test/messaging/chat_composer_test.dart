import 'dart:ui' show Tristate;

import 'package:dabbler_design_system/src/controls/button.dart';
import 'package:dabbler_design_system/src/feedback/spinner.dart';
import 'package:dabbler_design_system/src/messaging/chat_composer.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 360,
}) {
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: Brightness.light,
  );
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

DabblerColors _colors() => DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Finder _byLabel(String label) => find.bySemanticsLabel(label);

void main() {
  group('ready / off rules — ChatComposer.jsx', () {
    test('ready needs a non-blank value and a live state', () {
      expect(const DabblerChatComposer(value: 'hi').ready, isTrue);
      expect(const DabblerChatComposer(value: '   ').ready, isFalse);
      expect(const DabblerChatComposer().ready, isFalse);
      expect(
        const DabblerChatComposer(
          value: 'hi',
          state: DabblerChatComposerState.sending,
        ).ready,
        isFalse,
      );
      expect(
        const DabblerChatComposer(
          value: 'hi',
          state: DabblerChatComposerState.disabled,
        ).ready,
        isFalse,
      );
      expect(
        const DabblerChatComposer(value: 'hi', disabled: true).ready,
        isFalse,
      );
    });
  });

  group('behaviour', () {
    testWidgets('typing reports the text; send fires onSend once', (
      tester,
    ) async {
      String draft = '';
      int sent = 0;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (BuildContext c, StateSetter set) => DabblerChatComposer(
              value: draft,
              onChange: (String v) => set(() => draft = v),
              onSend: () => sent++,
            ),
          ),
        ),
      );
      await tester.tap(_byLabel('Send'));
      expect(sent, 0, reason: 'empty send is inert');
      await tester.enterText(find.byType(TextField), 'See you at 7');
      await tester.pump();
      expect(draft, 'See you at 7');
      await tester.tap(_byLabel('Send'));
      expect(sent, 1);
    });

    testWidgets('Enter sends only when ready', (tester) async {
      int sent = 0;
      await tester.pumpWidget(
        _host(DabblerChatComposer(value: 'go', onSend: () => sent++)),
      );
      await tester.tap(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(sent, 1);

      await tester.pumpWidget(
        _host(DabblerChatComposer(value: '  ', onSend: () => sent++)),
      );
      await tester.tap(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(sent, 1);
    });

    testWidgets('attach and emoji appear only when handlers are given', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerChatComposer()));
      expect(_byLabel('Add attachment'), findsNothing);
      expect(_byLabel('Emoji'), findsNothing);
      expect(_byLabel('Send'), findsOneWidget);

      int attach = 0, emoji = 0;
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(onAttach: () => attach++, onEmoji: () => emoji++),
        ),
      );
      await tester.tap(_byLabel('Add attachment'));
      await tester.tap(_byLabel('Emoji'));
      expect((attach, emoji), (1, 1));
    });

    testWidgets('custom labels name the targets', (tester) async {
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            onAttach: () {},
            onEmoji: () {},
            attachLabel: 'ارفاق',
            emojiLabel: 'ايموجي',
            sendLabel: 'ارسال',
          ),
        ),
      );
      expect(_byLabel('ارفاق'), findsOneWidget);
      expect(_byLabel('ايموجي'), findsOneWidget);
      expect(_byLabel('ارسال'), findsOneWidget);
    });

    testWidgets('quick replies call onQuickReply with the text', (
      tester,
    ) async {
      final List<String> picked = <String>[];
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            quickReplies: const <String>["I'm in", 'Running late'],
            onQuickReply: picked.add,
          ),
        ),
      );
      await tester.tap(find.text('Running late'));
      expect(picked, <String>['Running late']);
    });

    testWidgets('quick replies are at least 45px tall', (tester) async {
      await tester.pumpWidget(
        _host(const DabblerChatComposer(quickReplies: <String>['A'])),
      );
      final Size s = tester.getSize(
        find
            .ancestor(of: find.text('A'), matching: find.byType(Container))
            .first,
      );
      expect(s.height, greaterThanOrEqualTo(45));
    });
  });

  group('precedence — notice > replyTo > quickReplies', () {
    testWidgets('notice replaces the whole input row', (tester) async {
      int acted = 0;
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            notice: DabblerComposerNotice(
              text: 'Only admins can post.',
              actionLabel: 'Learn more',
              onAction: () => acted++,
            ),
            replyTo: const DabblerComposerReply(sender: 'A', content: 'x'),
            quickReplies: const <String>['Q'],
            onAttach: () {},
          ),
        ),
      );
      expect(find.byType(TextField), findsNothing);
      expect(_byLabel('Send'), findsNothing);
      expect(_byLabel('Add attachment'), findsNothing);
      expect(find.byType(DabblerMessageReplyReference), findsNothing);
      expect(find.text('Q'), findsNothing);
      expect(find.text('Only admins can post.'), findsOneWidget);
      await tester.tap(find.text('Learn more'));
      expect(acted, 1);
      expect(find.byType(DabblerButton), findsOneWidget);
    });

    testWidgets('replyTo hides quick replies and shows the reference', (
      tester,
    ) async {
      int cancelled = 0;
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            replyTo: DabblerComposerReply(
              sender: 'Layla',
              content: 'Court 2',
              onCancel: () => cancelled++,
            ),
            quickReplies: const <String>['Q'],
          ),
        ),
      );
      expect(find.byType(DabblerMessageReplyReference), findsOneWidget);
      expect(find.text('Q'), findsNothing);
      await tester.tap(_byLabel('Cancel reply'));
      expect(cancelled, 1);
    });
  });

  group('states', () {
    testWidgets('sending shows a spinner and disables everything', (
      tester,
    ) async {
      int sent = 0;
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            value: 'hi',
            state: DabblerChatComposerState.sending,
            onSend: () => sent++,
            onAttach: () {},
          ),
        ),
      );
      expect(find.byType(DabblerSpinner), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      await tester.tap(_byLabel('Send'), warnIfMissed: false);
      expect(sent, 0);
    });

    testWidgets('disabled: sunken field, inert targets', (tester) async {
      int attach = 0;
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            state: DabblerChatComposerState.disabled,
            onAttach: () => attach++,
          ),
        ),
      );
      await tester.tap(_byLabel('Add attachment'), warnIfMissed: false);
      expect(attach, 0);
      final BoxDecoration d = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((AnimatedContainer c) => c.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((BoxDecoration b) => b.borderRadius != null);
      expect(d.color, _colors().surfaceSunken);
    });

    testWidgets('ready send fills with brand; empty send is sunken', (
      tester,
    ) async {
      Color sendFill() {
        final BoxDecoration d = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .map((AnimatedContainer c) => c.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((BoxDecoration b) => b.shape == BoxShape.circle);
        return d.color!;
      }

      await tester.pumpWidget(_host(const DabblerChatComposer()));
      expect(sendFill(), _colors().surfaceSunken);
      await tester.pumpWidget(_host(const DabblerChatComposer(value: 'x')));
      expect(sendFill(), _colors().brandPrimary);
    });

    testWidgets('value passed in is shown and updates', (tester) async {
      await tester.pumpWidget(_host(const DabblerChatComposer(value: 'a')));
      expect(find.text('a'), findsOneWidget);
      await tester.pumpWidget(_host(const DabblerChatComposer(value: 'ab')));
      expect(find.text('ab'), findsOneWidget);
    });
  });

  group('geometry', () {
    testWidgets('icon targets are 45x45', (tester) async {
      await tester.pumpWidget(
        _host(DabblerChatComposer(onAttach: () {}, onEmoji: () {})),
      );
      for (final String l in <String>['Add attachment', 'Emoji', 'Send']) {
        final Size s = tester.getSize(_byLabel(l));
        expect((s.width, s.height), (45.0, 45.0), reason: l);
      }
    });

    testWidgets('field is at least 45 tall with 24 corners', (tester) async {
      await tester.pumpWidget(_host(const DabblerChatComposer()));
      final Finder field = find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      expect(tester.getSize(field).height, greaterThanOrEqualTo(45));
      final BoxDecoration d =
          tester.widget<AnimatedContainer>(field).decoration! as BoxDecoration;
      expect(d.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('root has a faint top hairline on the page fill', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const DabblerChatComposer()));
      final DecoratedBox box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(DabblerChatComposer),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final BoxDecoration d = box.decoration as BoxDecoration;
      expect(d.color, _colors().bgPrimary);
      expect((d.border! as Border).top.color, _colors().bgTertiary);
      expect((d.border! as Border).top.width, 1);
    });
  });

  group('RTL / Arabic', () {
    testWidgets('attach leads at the right, send trails at the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(onAttach: () {}, onEmoji: () {}),
          direction: TextDirection.rtl,
        ),
      );
      final double attach = tester.getCenter(_byLabel('Add attachment')).dx;
      final double send = tester.getCenter(_byLabel('Send')).dx;
      final double field = tester.getCenter(find.byType(TextField)).dx;
      expect(attach, greaterThan(field));
      expect(send, lessThan(field));
    });

    testWidgets('emoji sits at the inline end (left) of the field in RTL, '
        'keeping a 6px gap plus the 1px border to the edge', (tester) async {
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(onEmoji: () {}),
          direction: TextDirection.rtl,
        ),
      );
      final Finder field = find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final Rect f = tester.getRect(field);
      final Rect e = tester.getRect(_byLabel('Emoji'));
      expect(e.left - f.left, 7, reason: '1px border + 6px end padding');
    });

    testWidgets('the same gap holds in LTR on the right edge', (tester) async {
      await tester.pumpWidget(_host(DabblerChatComposer(onEmoji: () {})));
      final Finder field = find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final Rect f = tester.getRect(field);
      final Rect e = tester.getRect(_byLabel('Emoji'));
      expect(f.right - e.right, 7);
    });

    testWidgets('quick replies start at the inline start (right) in RTL', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerChatComposer(quickReplies: <String>['اول', 'ثاني']),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getCenter(find.text('اول')).dx,
        greaterThan(tester.getCenter(find.text('ثاني')).dx),
      );
    });

    testWidgets('Arabic input uses 14.1 / 23 subheadline metrics', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerChatComposer(value: 'مرحبا'),
          direction: TextDirection.rtl,
        ),
      );
      final TextStyle s = tester
          .widget<TextField>(find.byType(TextField))
          .style!;
      expect(s.fontSize, closeTo(14.1, 0.001));
      expect(s.height! * s.fontSize!, closeTo(23, 0.01));
    });

    testWidgets('narrow width in RTL does not overflow', (tester) async {
      await tester.pumpWidget(
        _host(
          DabblerChatComposer(
            value: 'رسالة طويلة جدا جدا جدا جدا جدا جدا جدا',
            onAttach: () {},
            onEmoji: () {},
          ),
          direction: TextDirection.rtl,
          width: 240,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('semantics', () {
    testWidgets('targets are named buttons; send enabled only when ready', (
      tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(DabblerChatComposer(onAttach: () {}, onEmoji: () {})),
      );
      SemanticsNode node(String l) => tester.getSemantics(_byLabel(l));
      expect(node('Add attachment').flagsCollection.isButton, isTrue);
      expect(node('Emoji').flagsCollection.isButton, isTrue);
      expect(node('Send').flagsCollection.isButton, isTrue);
      expect(node('Send').flagsCollection.isEnabled, Tristate.isFalse);

      await tester.pumpWidget(
        _host(DabblerChatComposer(value: 'x', onSend: () {})),
      );
      expect(node('Send').flagsCollection.isEnabled, Tristate.isTrue);
      h.dispose();
    });

    testWidgets('the field is a text field with the placeholder as hint', (
      tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const DabblerChatComposer(placeholder: 'Message')),
      );
      expect(find.bySemanticsLabel('Message'), findsWidgets);
      expect(
        tester
            .getSemantics(find.byType(EditableText))
            .flagsCollection
            .isTextField,
        isTrue,
      );
      h.dispose();
    });

    testWidgets('disabled quick replies are named, disabled buttons', (
      tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const DabblerChatComposer(
            disabled: true,
            quickReplies: <String>["I'm in"],
          ),
        ),
      );
      final SemanticsNode n = tester.getSemantics(_byLabel("I'm in"));
      expect(n.flagsCollection.isButton, isTrue);
      expect(n.flagsCollection.isEnabled, Tristate.isFalse);
      h.dispose();
    });
  });
}
