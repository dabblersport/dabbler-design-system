// Pins values from the live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, file
// components/messaging/ConversationNotice.jsx (mirror of 2026-10-02).
import 'package:dabbler_design_system/src/feedback/banner.dart';
import 'package:dabbler_design_system/src/messaging/messaging_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'messaging_parts_host.dart';

void main() {
  test('tone mapping: critical aliases error', () {
    expect(
      DabblerConversationNotice.bannerToneFor(DabblerNoticeTone.critical),
      DabblerBannerTone.error,
    );
    expect(
      DabblerConversationNotice.bannerToneFor(DabblerNoticeTone.error),
      DabblerBannerTone.error,
    );
    expect(
      DabblerConversationNotice.bannerToneFor(DabblerNoticeTone.info),
      DabblerBannerTone.info,
    );
    expect(
      DabblerConversationNotice.bannerToneFor(DabblerNoticeTone.success),
      DabblerBannerTone.success,
    );
    expect(
      DabblerConversationNotice.bannerToneFor(DabblerNoticeTone.warning),
      DabblerBannerTone.warning,
    );
  });

  testWidgets('critical renders the error banner', (tester) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerConversationNotice(
          tone: DabblerNoticeTone.critical,
          title: 'Game cancelled',
        ),
      ),
    );
    expect(
      tester.widget<DabblerBanner>(find.byType(DabblerBanner)).tone,
      DabblerBannerTone.error,
    );
  });

  testWidgets('banner spans the thread less 6px gutters; timestamp centred '
      '3px below in secondary ink', (tester) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerConversationNotice(
          title: 'Kickoff moved',
          timestamp: '18:02',
        ),
      ),
    );
    final Rect banner = tester.getRect(find.byType(DabblerBanner));
    expect(banner.left, 6);
    expect(banner.width, 360 - 12);
    final Rect ts = tester.getRect(find.text('18:02'));
    expect(ts.center.dx, closeTo(180, 0.01));
    expect(ts.top - banner.bottom, closeTo(3, 0.01));
    expect(
      tester.widget<Text>(find.text('18:02')).style!.color,
      partsColors().textSecondary,
    );
  });

  testWidgets('action and dismiss reach the callbacks', (tester) async {
    int a = 0, d = 0;
    await tester.pumpWidget(
      partsHost(
        DabblerConversationNotice(
          tone: DabblerNoticeTone.warning,
          title: 'Payment required',
          actionLabel: 'Pay now',
          onAction: () => a++,
          onDismiss: () => d++,
        ),
      ),
    );
    final DabblerBanner b = tester.widget(find.byType(DabblerBanner));
    expect(b.action!.label, 'Pay now');
    await tester.tap(find.text('Pay now'));
    expect(a, 1);
    b.onDismiss!();
    expect(d, 1);
  });

  testWidgets('no action without a label', (tester) async {
    await tester.pumpWidget(
      partsHost(DabblerConversationNotice(title: 'x', onAction: () {})),
    );
    expect(
      tester.widget<DabblerBanner>(find.byType(DabblerBanner)).action,
      isNull,
    );
  });

  testWidgets('RTL: gutters stay 6px on both sides', (tester) async {
    await tester.pumpWidget(
      partsHost(
        const DabblerConversationNotice(title: 'تغيّر الملعب'),
        direction: TextDirection.rtl,
      ),
    );
    final Rect banner = tester.getRect(find.byType(DabblerBanner));
    expect(banner.width, 348);
  });

  testWidgets('renders a PNG in both directions', (tester) async {
    for (final TextDirection d in TextDirection.values) {
      final bool ar = d == TextDirection.rtl;
      final f = await renderPng(
        tester,
        SizedBox(
          width: 360,
          child: DabblerConversationNotice(
            tone: DabblerNoticeTone.critical,
            title: ar ? 'أُلغيت المباراة' : 'Game cancelled',
            description: ar ? 'الملعب مغلق.' : 'The court is closed.',
            actionLabel: ar ? 'التفاصيل' : 'Details',
            onAction: () {},
            onDismiss: () {},
            timestamp: '18:02',
          ),
        ),
        name: 'conversation_notice_${d.name}',
        size: const Size(380, 200),
        direction: d,
        alignment: Alignment.center,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });

  testWidgets('action target clears the 45 floor (D-039)', (tester) async {
    // Dabbler/dabbler-docs/DECISIONS.md:13014 (D-032) and :13611 (D-039).
    await tester.pumpWidget(
      partsHost(
        DabblerConversationNotice(
          tone: DabblerNoticeTone.warning,
          title: 'Payment required',
          actionLabel: 'Pay now',
          onAction: () {},
          onDismiss: () {},
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(DabblerBanner.actionTargetKey)).height,
      greaterThanOrEqualTo(45),
    );
    final Size dismiss =
        tester.getSize(find.byKey(DabblerBanner.dismissTargetKey));
    expect(dismiss.width, greaterThanOrEqualTo(45));
    expect(dismiss.height, greaterThanOrEqualTo(45));
  });
}
