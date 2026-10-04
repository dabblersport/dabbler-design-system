import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forms/_host.dart';

TextStyle _style(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

DabblerIcon _icon(WidgetTester tester) =>
    tester.widget<DabblerIcon>(find.byType(DabblerIcon));

void main() {
  group('DabblerInlineMessage', () {
    testWidgets('draws the glyph and the words in the error strong colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerInlineMessage('Not right.')));
      final DabblerColors c = testColors();
      expect(_icon(tester).name, 'danger');
      expect(_icon(tester).weight, DabblerIconWeight.bold);
      expect(_icon(tester).color, c.error.strong);
      expect(_icon(tester).size, DabblerSizing.iconInline);
      expect(_style(tester, 'Not right.').color, c.error.strong);
      expect(_style(tester, 'Not right.').fontWeight, DabblerType.medium);
    });

    testWidgets('each tone takes its own colour and default glyph', (
      WidgetTester tester,
    ) async {
      final DabblerColors c = testColors();
      final Map<DabblerInlineMessageTone, (String, Color)> expected =
          <DabblerInlineMessageTone, (String, Color)>{
            DabblerInlineMessageTone.error: ('danger', c.error.strong),
            DabblerInlineMessageTone.success: ('tick-circle', c.success.strong),
            DabblerInlineMessageTone.warning: ('warning-2', c.warning.strong),
            DabblerInlineMessageTone.info: ('info-circle', c.info.strong),
          };
      for (final MapEntry<DabblerInlineMessageTone, (String, Color)> e
          in expected.entries) {
        await tester.pumpWidget(host(DabblerInlineMessage('x', tone: e.key)));
        expect(_icon(tester).name, e.value.$1, reason: e.key.name);
        expect(_icon(tester).color, e.value.$2, reason: e.key.name);
      }
    });

    testWidgets('a custom icon replaces the glyph and stays bold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerInlineMessage('Expired.', icon: 'clock')),
      );
      expect(_icon(tester).name, 'clock');
      expect(_icon(tester).weight, DabblerIconWeight.bold);
    });

    testWidgets('the glyph is 6 before the message and a long message wraps', (
      WidgetTester tester,
    ) async {
      const String long =
          'Your password does not match. Try again, or email yourself a code '
          'to get back in.';
      await tester.pumpWidget(host(const DabblerInlineMessage(long)));
      final Rect icon = tester.getRect(find.byType(DabblerIcon));
      final Rect text = tester.getRect(find.text(long));
      expect(text.left - icon.right, DabblerSpacing.iconGap);
      expect(
        text.right,
        lessThanOrEqualTo(
          tester.getRect(find.byType(DabblerInlineMessage)).right,
        ),
      );
      expect(text.height, greaterThan(DabblerType.footnote.latinLeading));
    });

    testWidgets('RTL puts the glyph at the right and the Arabic text first', (
      WidgetTester tester,
    ) async {
      const String ar = 'الرمز غير صحيح. تحقق من بريدك وحاول مرة أخرى.';
      await tester.pumpWidget(
        host(const DabblerInlineMessage(ar), direction: TextDirection.rtl),
      );
      final Rect icon = tester.getRect(find.byType(DabblerIcon));
      final Rect text = tester.getRect(find.text(ar));
      expect(icon.left, greaterThan(text.left));
      expect(
        tester.getTopRight(find.byType(DabblerInlineMessage)).dx,
        closeTo(icon.right, 0.5),
      );
      // The Arabic step resolves its own size, smaller than the Latin one.
      expect(_style(tester, ar).fontSize, DabblerType.footnote.arabicFontSize);
    });

    testWidgets('an error is a live region; success is not', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerInlineMessage('Bad.')));
      expect(
        tester.getSemantics(find.byType(DabblerInlineMessage)),
        isSemantics(label: 'Bad.', isLiveRegion: true),
      );
      await tester.pumpWidget(
        host(
          const DabblerInlineMessage(
            'Good.',
            tone: DabblerInlineMessageTone.success,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DabblerInlineMessage)),
        isSemantics(label: 'Good.', isLiveRegion: false),
      );
      handle.dispose();
    });

    test('interrupts only for error and warning', () {
      expect(const DabblerInlineMessage('a').interrupts, isTrue);
      expect(
        const DabblerInlineMessage(
          'a',
          tone: DabblerInlineMessageTone.warning,
        ).interrupts,
        isTrue,
      );
      expect(
        const DabblerInlineMessage(
          'a',
          tone: DabblerInlineMessageTone.info,
        ).interrupts,
        isFalse,
      );
    });
  });
}
