// Pins live `components/messaging/Message.jsx` + `Message.prompt.md` (live
// Claude Design project 4286affa-bf50-4ff6-9576-917f76a93ca1, read via
// DesignSync get_file on 2026-10-02, local mirror). Values asserted: bubble
// padding 9/12, maxWidth 76% / 288 bare, radius xl with sm own-side tail and
// grouped corner, 28px avatar gutter + 6 gap, 3px column gaps, image 232x156,
// sending opacity .7, 2px selected outline outside layout, reduced group
// delivery set, Retry 45px target.
import 'dart:io';

import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';

final DabblerColors _colors = DabblerColors.resolve(
  theme: DabblerTheme.main,
  brightness: Brightness.light,
);

Widget _host(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_colors]),
      home: Directionality(
        textDirection: dir,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 400, child: child),
        ),
      ),
    );

/// The bubble's decoration box (the one painting fill or border with a radius).
BoxDecoration _bubbleDecoration(WidgetTester tester) {
  return tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(DabblerMessage),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((DecoratedBox d) => d.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((BoxDecoration b) => b.borderRadius != null);
}

void main() {
  group('radiusFor — own-side logical corners', () {
    const Radius xl = Radius.circular(18);
    const Radius sm = Radius.circular(6);
    test('incoming: tail at bottomStart, grouped corner topStart', () {
      for (final DabblerGroupPosition p in DabblerGroupPosition.values) {
        final BorderRadiusDirectional r = DabblerMessage.radiusFor(
          outgoing: false,
          position: p,
        );
        expect(r.bottomStart, sm);
        expect(r.topEnd, xl);
        expect(r.bottomEnd, xl);
        expect(r.topStart, DabblerMessage.leads(p) ? xl : sm, reason: p.name);
      }
    });
    test('outgoing: tail at bottomEnd, grouped corner topEnd', () {
      for (final DabblerGroupPosition p in DabblerGroupPosition.values) {
        final BorderRadiusDirectional r = DabblerMessage.radiusFor(
          outgoing: true,
          position: p,
        );
        expect(r.bottomEnd, sm);
        expect(r.topStart, xl);
        expect(r.bottomStart, xl);
        expect(r.topEnd, DabblerMessage.leads(p) ? xl : sm, reason: p.name);
      }
    });
    test('RTL resolves the incoming tail to the physical bottom-right', () {
      final BorderRadius rtl = DabblerMessage.radiusFor(
        outgoing: false,
        position: DabblerGroupPosition.middle,
      ).resolve(TextDirection.rtl);
      expect(rtl.bottomRight, sm);
      expect(rtl.topRight, sm);
      expect(rtl.bottomLeft, xl);
      expect(rtl.topLeft, xl);
    });
    test('leads / trails', () {
      expect(DabblerMessage.leads(DabblerGroupPosition.single), isTrue);
      expect(DabblerMessage.leads(DabblerGroupPosition.first), isTrue);
      expect(DabblerMessage.leads(DabblerGroupPosition.middle), isFalse);
      expect(DabblerMessage.trails(DabblerGroupPosition.last), isTrue);
      expect(DabblerMessage.trails(DabblerGroupPosition.first), isFalse);
    });
  });

  testWidgets('incoming bubble: card fill, 1px outline, padding 9/12', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerMessage(content: 'Hi')));
    final BoxDecoration d = _bubbleDecoration(tester);
    expect(d.color, _colors.surfaceCard);
    expect((d.border! as Border).top.width, 1);
    expect((d.border! as Border).top.color, _colors.borderDefault);
    final Rect text = tester.getRect(find.text('Hi'));
    final Rect bubble = tester.getRect(
      find
          .ancestor(of: find.text('Hi'), matching: find.byType(DecoratedBox))
          .first,
    );
    expect(text.left - bubble.left, 12);
    expect(text.top - bubble.top, 9);
  });

  testWidgets('outgoing bubble: brand fill, no border, aligned to end', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'Yo',
        ),
      ),
    );
    final BoxDecoration d = _bubbleDecoration(tester);
    expect(d.color, _colors.brandPrimary);
    expect(d.border, isNull);
    expect(tester.getRect(find.text('Yo')).right, 400 - 12);
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'Yo',
        ),
        dir: TextDirection.rtl,
      ),
    );
    expect(tester.getRect(find.text('Yo')).left, 12);
  });

  testWidgets('max width is 76% of the full row, gutter included', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DabblerMessage(
          context: DabblerMessageContext.group,
          sender: 'L',
          content: 'word ' * 80,
        ),
      ),
    );
    final Rect bubble = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('word'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(bubble.width, closeTo(400 * 0.76, 0.01));
    expect(bubble.left, 28 + 6);
  });

  testWidgets('bare image: 288 cap, 232x156, transparent, 3px padding', (
    WidgetTester tester,
  ) async {
    const Key img = Key('img');
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          attachment: DabblerMessageAttachment.image(
            child: SizedBox.expand(key: img),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(img)), const Size(232, 156));
    final BoxDecoration d = _bubbleDecoration(tester);
    expect(d.color, isNull);
    expect(d.border, isNull);
    expect(tester.getTopLeft(find.byKey(img)), const Offset(3, 3));
  });

  testWidgets('group: avatar + sender lead, 3px sender gap, RTL mirror', (
    WidgetTester tester,
  ) async {
    for (final TextDirection dir in TextDirection.values) {
      await tester.pumpWidget(
        _host(
          const DabblerMessage(
            context: DabblerMessageContext.group,
            sender: 'Layla',
            content: 'Hi',
          ),
          dir: dir,
        ),
      );
      expect(find.byType(DabblerAvatar), findsOneWidget);
      final Rect avatar = tester.getRect(find.byType(DabblerAvatar));
      expect(avatar.width, 28);
      if (dir == TextDirection.ltr) {
        expect(avatar.left, 0);
      } else {
        expect(avatar.right, 400);
      }
      final Rect name = tester.getRect(find.text('Layla'));
      final Rect bubble = tester.getRect(
        find
            .ancestor(of: find.text('Hi'), matching: find.byType(DecoratedBox))
            .first,
      );
      expect(bubble.top - name.bottom, 3);
    }
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          context: DabblerMessageContext.group,
          groupPosition: DabblerGroupPosition.middle,
          sender: 'Layla',
          content: 'Hi',
          timestamp: '17:00',
        ),
      ),
    );
    expect(find.byType(DabblerAvatar), findsNothing);
    expect(find.text('Layla'), findsNothing);
    expect(find.text('17:00'), findsNothing);
    // The gutter is kept so the run stays aligned.
    expect(tester.getRect(find.text('Hi')).left, 28 + 6 + 12);
  });

  testWidgets('Arabic content resolves the Arabic subheadline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const DabblerMessage(content: 'مرحبا'), dir: TextDirection.rtl),
    );
    final Text t = tester.widget<Text>(find.text('مرحبا'));
    expect(
      t.style!.fontSize,
      DabblerType.subheadline.resolveForDirection(TextDirection.rtl).fontSize,
    );
  });

  group('delivery set', () {
    Future<void> pump(
      WidgetTester tester,
      DabblerDeliveryState s,
      DabblerMessageContext ctx, {
      DabblerMessageDirection dir = DabblerMessageDirection.outgoing,
    }) => tester.pumpWidget(
      _host(
        DabblerMessage(
          direction: dir,
          context: ctx,
          content: 'x',
          timestamp: '1',
          deliveryState: s,
        ),
      ),
    );

    testWidgets('direct shows every state', (WidgetTester tester) async {
      for (final DabblerDeliveryState s in DabblerDeliveryState.values) {
        await pump(tester, s, DabblerMessageContext.direct);
        expect(find.bySemanticsLabel(s.name), findsOneWidget, reason: s.name);
      }
    });
    testWidgets('group shows only sending and failed', (
      WidgetTester tester,
    ) async {
      for (final DabblerDeliveryState s in DabblerDeliveryState.values) {
        await pump(tester, s, DabblerMessageContext.group);
        final bool shown =
            s == DabblerDeliveryState.sending ||
            s == DabblerDeliveryState.failed;
        expect(
          find.bySemanticsLabel(s.name),
          shown ? findsOneWidget : findsNothing,
          reason: s.name,
        );
      }
    });
    testWidgets('incoming never shows delivery', (WidgetTester tester) async {
      await pump(
        tester,
        DabblerDeliveryState.read,
        DabblerMessageContext.direct,
        dir: DabblerMessageDirection.incoming,
      );
      expect(find.bySemanticsLabel('read'), findsNothing);
    });
    testWidgets('delivery glyph is 14px in its tone', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        DabblerDeliveryState.read,
        DabblerMessageContext.direct,
      );
      final DabblerIcon icon = tester.widget<DabblerIcon>(
        find.byType(DabblerIcon),
      );
      expect(icon.size, 14);
      expect(icon.color, _colors.brandPrimary);
    });
  });

  testWidgets('sending fades to 0.7; others opaque', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'x',
          deliveryState: DabblerDeliveryState.sending,
        ),
      ),
    );
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0.7,
    );
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'x',
          deliveryState: DabblerDeliveryState.sent,
        ),
      ),
    );
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
  });

  testWidgets('failed: error metadata, edited label, Retry 45px target', (
    WidgetTester tester,
  ) async {
    int retries = 0;
    await tester.pumpWidget(
      _host(
        DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'x',
          timestamp: '17:00',
          edited: true,
          editedLabel: 'معدلة',
          deliveryState: DabblerDeliveryState.failed,
          onRetry: () => retries++,
          retryLabel: 'Again',
        ),
      ),
    );
    expect(
      tester.widget<Text>(find.text('17:00')).style!.color,
      _colors.error.strong,
    );
    expect(find.text('· معدلة'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(DabblerMessage.retryKey)).height,
      greaterThanOrEqualTo(45),
    );
    final Text retry = tester.widget<Text>(find.text('Again'));
    expect(retry.style!.fontWeight, FontWeight.w700);
    // Inline position: 3px after the glyph, no extra padding.
    expect(
      tester.getRect(find.text('Again')).left -
          tester.getRect(find.byType(DabblerIcon)).right,
      3,
    );
    await tester.tap(find.text('Again'));
    expect(retries, 1);
  });

  testWidgets('Retry under RTL: 45 target, 3px after the glyph, mirrored', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DabblerMessage(
          direction: DabblerMessageDirection.outgoing,
          content: 'x',
          timestamp: '17:00',
          deliveryState: DabblerDeliveryState.failed,
          onRetry: () {},
          retryLabel: 'Again',
        ),
        dir: TextDirection.rtl,
      ),
    );
    expect(
      tester.getSize(find.byKey(DabblerMessage.retryKey)).height,
      greaterThanOrEqualTo(45),
    );
    // In RTL Retry sits to the LEFT of the glyph, 3px away.
    expect(
      tester.getRect(find.byType(DabblerIcon)).left -
          tester.getRect(find.text('Again')).right,
      3,
    );
  });

  testWidgets('selected outline is 2px brand, outside, no layout change', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const DabblerMessage(content: 'Sel')));
    final Rect before = tester.getRect(find.text('Sel'));
    await tester.pumpWidget(
      _host(
        const DabblerMessage(
          content: 'Sel',
          state: DabblerMessageState.selected,
        ),
      ),
    );
    expect(tester.getRect(find.text('Sel')), before);
    final DecoratedBox ring = tester.widget<DecoratedBox>(
      find.byKey(DabblerMessage.selectedOutlineKey),
    );
    final BoxDecoration d = ring.decoration as BoxDecoration;
    expect((d.border! as Border).top.width, 2);
    expect((d.border! as Border).top.color, _colors.brandPrimary);
    final Rect bubble = tester.getRect(
      find
          .ancestor(of: find.text('Sel'), matching: find.byType(DecoratedBox))
          .first,
    );
    final Rect outline = tester.getRect(
      find.byKey(DabblerMessage.selectedOutlineKey),
    );
    expect(bubble.left - outline.left, 4);
  });

  testWidgets('onPress makes a button; readOnly removes it', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle h = tester.ensureSemantics();
    int presses = 0;
    await tester.pumpWidget(
      _host(DabblerMessage(content: 'Tap me', onPress: () => presses++)),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Tap me'))
          .flagsCollection
          .isButton,
      isTrue,
    );
    await tester.tap(find.text('Tap me'));
    expect(presses, 1);
    await tester.pumpWidget(
      _host(
        DabblerMessage(
          content: 'Tap me',
          onPress: () => presses++,
          state: DabblerMessageState.readOnly,
        ),
      ),
    );
    expect(find.byType(DabblerMessagingTap), findsNothing);
    await tester.tap(find.text('Tap me'));
    expect(presses, 1);
    h.dispose();
  });

  testWidgets('press scales while held', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(DabblerMessage(content: 'Hold', onPress: () {})),
    );
    final TestGesture g = await tester.startGesture(
      tester.getCenter(find.text('Hold')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final DabblerPressScale ps = tester.widget<DabblerPressScale>(
      find.byType(DabblerPressScale),
    );
    expect(ps.pressed, isTrue);
    await g.up();
  });

  testWidgets('reactions sit 3px under the bubble and report keys', (
    WidgetTester tester,
  ) async {
    String? got;
    await tester.pumpWidget(
      _host(
        DabblerMessage(
          content: 'R',
          reactions: const <DabblerMessageReaction>[
            DabblerMessageReaction(key: 'in', count: 2),
          ],
          onReact: (String k) => got = k,
        ),
      ),
    );
    final Rect bubble = tester.getRect(
      find
          .ancestor(of: find.text('R'), matching: find.byType(DecoratedBox))
          .first,
    );
    final Rect row = tester.getRect(find.byType(DabblerReactionGroup));
    expect(row.top - bubble.bottom, 3);
    await tester.tap(find.byType(DabblerMessagingTap).first);
    expect(got, 'in');
  });

  testWidgets('PNG: bubbles per position and delivery, LTR and RTL', (
    WidgetTester tester,
  ) async {
    for (final TextDirection dir in TextDirection.values) {
      final bool ar = dir == TextDirection.rtl;
      final File f = await renderPng(
        tester,
        SizedBox(
          width: 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DabblerGroupPosition p in DabblerGroupPosition.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: DabblerMessage(
                    context: DabblerMessageContext.group,
                    groupPosition: p,
                    sender: ar ? 'ليلى' : 'Layla',
                    content: ar
                        ? 'ملعب 3 الليلة${p.name}'
                        : 'Pitch 3 ${p.name}',
                    timestamp: '17:10',
                  ),
                ),
              for (final DabblerDeliveryState s in DabblerDeliveryState.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: DabblerMessage(
                    direction: DabblerMessageDirection.outgoing,
                    content: ar ? 'في الطريق' : 'On my way',
                    timestamp: s.name,
                    deliveryState: s,
                    state: s == DabblerDeliveryState.read
                        ? DabblerMessageState.selected
                        : DabblerMessageState.normal,
                    onRetry: s == DabblerDeliveryState.failed ? () {} : null,
                  ),
                ),
            ],
          ),
        ),
        name: 'message_${dir.name}',
        size: const Size(390, 760),
        direction: dir,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
