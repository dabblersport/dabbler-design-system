// Pins live `components/messaging/messaging.jsx` (live Claude Design project
// 4286affa-bf50-4ff6-9576-917f76a93ca1, read via DesignSync get_file on
// 2026-10-02, local mirror): SPACING, KIND_GLYPH, GAME_STATUS, DELIVERY,
// REACTIONS.
import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SPACING rhythm matches messaging.jsx', () {
    expect(DabblerMessagingSpacing.timelineInline, 12);
    expect(DabblerMessagingSpacing.timelineBlock, 12);
    expect(DabblerMessagingSpacing.groupGap, 12);
    expect(DabblerMessagingSpacing.messageGap, 3);
    expect(DabblerMessagingSpacing.avatarGap, 6);
    expect(DabblerMessagingSpacing.avatarGutter, 28);
    expect(DabblerMessagingSpacing.senderGap, 3);
    expect(DabblerMessagingSpacing.replyGap, 6);
    expect(DabblerMessagingSpacing.metaGap, 3);
    expect(DabblerMessagingSpacing.reactionGap, 0);
    expect(DabblerMessagingSpacing.systemBlock, 3);
    expect(DabblerMessagingSpacing.bubbleInline, 12);
    expect(DabblerMessagingSpacing.bubbleBlock, 9);
  });

  test('avatar gutter equals the xs avatar size', () {
    expect(DabblerAvatarSize.xs.diameter, DabblerMessagingSpacing.avatarGutter);
  });

  test('KIND_GLYPH', () {
    expect(DabblerConversationKind.squad.glyph, 'people');
    expect(DabblerConversationKind.huddle.glyph, 'global');
    expect(DabblerConversationKind.player.glyph, isNull);
    expect(DabblerConversationKind.game.glyph, isNull);
  });

  test('GAME_STATUS: only three statuses earn colour', () {
    final Map<DabblerActivityStatus, (String, DabblerStatusTone?)>
    want = <DabblerActivityStatus, (String, DabblerStatusTone?)>{
      DabblerActivityStatus.open: ('Open', null),
      DabblerActivityStatus.full: ('Full', null),
      DabblerActivityStatus.confirmed: ('Confirmed', DabblerStatusTone.success),
      DabblerActivityStatus.soon: ('Starting soon', DabblerStatusTone.warning),
      DabblerActivityStatus.live: ('In progress', DabblerStatusTone.success),
      DabblerActivityStatus.completed: ('Completed', null),
      DabblerActivityStatus.cancelled: ('Cancelled', DabblerStatusTone.error),
    };
    for (final DabblerActivityStatus s in DabblerActivityStatus.values) {
      expect((s.label, s.tone), want[s], reason: s.name);
    }
  });

  test('DELIVERY glyphs and weights', () {
    expect(DabblerDeliveryState.sending.icon, 'clock');
    expect(DabblerDeliveryState.sending.weight, DabblerIconWeight.linear);
    expect(DabblerDeliveryState.sent.icon, 'tick-circle');
    expect(DabblerDeliveryState.sent.weight, DabblerIconWeight.linear);
    expect(DabblerDeliveryState.delivered.weight, DabblerIconWeight.bold);
    expect(DabblerDeliveryState.read.weight, DabblerIconWeight.bold);
    expect(DabblerDeliveryState.failed.icon, 'danger');
  });

  for (final Brightness b in Brightness.values) {
    test('DELIVERY tones resolve through roles (${b.name})', () {
      final DabblerColors c = DabblerColors.resolve(
        theme: DabblerTheme.main,
        brightness: b,
      );
      // --muted glyph -> tertiary; --ink-soft -> secondary.
      expect(DabblerDeliveryState.sending.colorFor(c), c.textTertiary);
      expect(DabblerDeliveryState.sent.colorFor(c), c.textTertiary);
      expect(DabblerDeliveryState.delivered.colorFor(c), c.textSecondary);
      expect(DabblerDeliveryState.read.colorFor(c), c.brandPrimary);
      expect(DabblerDeliveryState.failed.colorFor(c), c.error.strong);
    });
  }

  test('light delivered tone is exactly --ink-soft #404040, muted #8C8C8C', () {
    final DabblerColors c = DabblerColors.resolve(
      theme: DabblerTheme.main,
      brightness: Brightness.light,
    );
    expect(DabblerDeliveryState.delivered.colorFor(c), const Color(0xFF404040));
    expect(DabblerDeliveryState.sent.colorFor(c), const Color(0xFF8C8C8C));
  });

  test('REACTIONS order, glyphs and labels', () {
    expect(
      DabblerReactions.all
          .map((DabblerReactionDef r) => '${r.key}|${r.icon}|${r.label}')
          .toList(),
      <String>[
        "in|tick-circle|I'm in",
        'late|clock|Running late',
        "out|close-circle|Can't make it",
        'like|like-1|Nice',
        'heart|heart|Love it',
        'star|star|Standout',
      ],
    );
    expect(DabblerReactions.byKey('heart').label, 'Love it');
    expect(DabblerReactions.byKey('nope').key, 'in');
  });

  testWidgets('DabblerMessagingTap: tap, keyboard, inert when null', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            DabblerColors.resolve(
              theme: DabblerTheme.main,
              brightness: Brightness.light,
            ),
          ],
        ),
        home: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DabblerMessagingTap(
                onTap: () => taps++,
                label: 'go',
                child: const SizedBox(width: 40, height: 40),
              ),
              const DabblerMessagingTap(
                onTap: null,
                label: 'inert',
                child: SizedBox(width: 40, height: 40),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('go'));
    expect(taps, 1);
    final SemanticsHandle h = tester.ensureSemantics();
    final SemanticsNode inert = tester.getSemantics(
      find.bySemanticsLabel('inert'),
    );
    expect(inert.flagsCollection.isButton, isFalse);
    expect(
      tester.getSemantics(find.bySemanticsLabel('go')).flagsCollection.isButton,
      isTrue,
    );
    h.dispose();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 2);
  });
}
