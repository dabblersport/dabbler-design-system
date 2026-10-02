// Pins values from the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, file
// components/messaging/MessageReplyReference.jsx (mirror of 2026-10-02).
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

void main() {
  testWidgets('message variant: brand rule, sender caption-2 700, '
      'secondary quote clamped to 2 lines', (tester) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerMessageReplyReference(
          sender: 'Omar',
          content: 'Quoted text',
        ),
      ),
    );
    final c = partsColors();
    final Text sender = tester.widget(find.text('Omar'));
    expect(sender.style!.color, c.brandPrimary);
    expect(sender.style!.fontWeight, FontWeight.w700);
    expect(sender.maxLines, isNull, reason: 'the source does not clamp it');
    final Text body = tester.widget(find.text('Quoted text'));
    expect(body.maxLines, 2);
    expect(body.style!.color, c.textSecondary);
    final DecoratedBox box = tester.widget(find.byType(DecoratedBox).first);
    final BoxDecoration d = box.decoration as BoxDecoration;
    expect(d.color, isNull);
    final BorderDirectional b = d.border! as BorderDirectional;
    expect(b.start.width, 2);
    expect(b.start.color, c.brandPrimary);
  });

  testWidgets('onBrand variant rules and writes in on-brand', (tester) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerMessageReplyReference(
          sender: 'Lina',
          content: 'x',
          variant: DabblerReplyVariant.onBrand,
        ),
      ),
    );
    final c = partsColors();
    expect(tester.widget<Text>(find.text('Lina')).style!.color, c.onBrand);
    expect(tester.widget<Text>(find.text('x')).style!.color, c.onBrand);
  });

  testWidgets('composer variant: sunken fill clipped to the 9px radius', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerMessageReplyReference(
          sender: 'Omar',
          content: 'x',
          variant: DabblerReplyVariant.composer,
        ),
      ),
    );
    final ClipRRect clip = tester.widget(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(9));
    final BoxDecoration d =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(ClipRRect),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(d.color, partsColors().surfaceSunken);
  });

  testWidgets('cancel: 45px named button, 9px gap, end padding 9-6=3, '
      'calls back', (tester) async {
    int taps = 0;
    final h = tester.ensureSemantics();
    await tester.pumpWidget(
      partsHost(
        DabblerMessageReplyReference(
          sender: 'Omar',
          content: 'x',
          variant: DabblerReplyVariant.composer,
          onCancel: () => taps++,
        ),
      ),
    );
    final Finder cancel = find.bySemanticsLabel('Cancel reply');
    expect(tester.getSemantics(cancel).flagsCollection.isButton, isTrue);
    expect(tester.getSize(cancel), const Size(45, 45));
    final Rect outer = tester.getRect(find.byType(ClipRRect));
    expect(outer.right - tester.getRect(cancel).right, closeTo(3, 0.01));
    await tester.tap(cancel);
    expect(taps, 1);
    final DabblerIcon glyph = tester.widget(
      find.byWidgetPredicate(
        (w) => w is DabblerIcon && w.name == 'close-circle',
      ),
    );
    expect(glyph.size, 18);
    expect(glyph.color, partsColors().textTertiary);
    h.dispose();
  });

  testWidgets('attachment label leads with a 13px gallery glyph', (
    tester,
  ) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerMessageReplyReference(
          sender: 'Lina',
          attachmentLabel: 'Photo',
        ),
      ),
    );
    final DabblerIcon g = tester.widget(
      find.byWidgetPredicate((w) => w is DabblerIcon && w.name == 'gallery'),
    );
    expect(g.size, 13);
    expect(find.textContaining('Photo', findRichText: true), findsOneWidget);
  });

  testWidgets('RTL: the rule and text start on the right, cancel on the left; '
      'Arabic caption metrics', (tester) async {
    await tester.pumpWidget(
      partsHost(
        DabblerMessageReplyReference(
          sender: 'عمر',
          content: 'هل الملعب متاح؟',
          variant: DabblerReplyVariant.composer,
          onCancel: () {},
        ),
        direction: TextDirection.rtl,
      ),
    );
    final Rect outer = tester.getRect(find.byType(ClipRRect));
    final Rect sender = tester.getRect(find.text('عمر'));
    // 2px rule + 9px start padding.
    expect(outer.right - sender.right, closeTo(11, 0.01));
    final Rect cancel = tester.getRect(find.bySemanticsLabel('Cancel reply'));
    expect(cancel.left - outer.left, closeTo(3, 0.01));
    final double latin = DabblerType.caption1
        .resolveForDirection(TextDirection.ltr)
        .fontSize!;
    expect(
      tester.widget<Text>(find.text('هل الملعب متاح؟')).style!.fontSize,
      closeTo(latin - 0.9, 0.001),
    );
  });

  testWidgets('renders a PNG in both directions', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        tester,
        SizedBox(
          width: 320,
          child: DabblerMessageReplyReference(
            sender: d == TextDirection.rtl ? 'عمر' : 'Omar',
            content: d == TextDirection.rtl
                ? 'سأتأخر عشر دقائق'
                : 'Running late, 10 minutes',
            variant: DabblerReplyVariant.composer,
            onCancel: () {},
          ),
        ),
        name: 'message_reply_reference_${d.name}',
        size: const Size(360, 80),
        direction: d,
        alignment: Alignment.center,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
