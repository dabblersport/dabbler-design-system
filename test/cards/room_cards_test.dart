import 'package:dabbler_design_system/src/cards/card_active_room.dart';
import 'package:dabbler_design_system/src/cards/card_poll.dart';
import 'package:dabbler_design_system/src/cards/card_room.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

DabblerColors _c([Brightness b = Brightness.light]) =>
    DabblerColors.resolve(theme: DabblerTheme.main, brightness: b);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  double width = 360,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[_c(brightness)]),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

void main() {
  group('DabblerCardPoll — CardPoll.jsx', () {
    const List<DabblerPollOption> opts = <DabblerPollOption>[
      DabblerPollOption(fraction: 0.65, percentLabel: '65%'),
      DabblerPollOption(fraction: 0.35, percentLabel: '35%'),
    ];

    test('constants and default option colours', () {
      expect(DabblerCardPoll.barHeight, 8);
      expect(DabblerCardPoll.headerTintAlpha, 0.133);
      expect(DabblerCardPoll.barGap, 12);
      expect(DabblerCardPoll.optionColorFor(_c(), 0), _c().brandPrimary);
      expect(DabblerCardPoll.optionColorFor(_c(), 1), DabblerPalette.activeP600);
    });

    testWidgets('question is subheadline 15/700; percent is caption-1 12/700',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardPoll(
            question: 'Which color scheme?',
            options: opts,
            votesLabel: '42 votes',
          ),
        ),
      );
      final Text q = tester.widget<Text>(find.text('Which color scheme?'));
      expect(q.style!.fontSize, 15);
      expect(q.style!.fontWeight, FontWeight.w700);
      final Text p = tester.widget<Text>(find.text('65%'));
      expect(p.style!.fontSize, 12);
      expect(p.style!.fontWeight, FontWeight.w700);
      expect(p.style!.color, _c().brandPrimary);
      expect(tester.widget<Text>(find.text('35%')).style!.color,
          DabblerPalette.activeP600);
    });

    testWidgets('bars fill to their fraction of the track', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardPoll(
            question: 'Q',
            options: opts,
            votesLabel: '42 votes',
          ),
        ),
      );
      final List<FractionallySizedBox> fills = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .toList();
      expect(fills.map((FractionallySizedBox f) => f.widthFactor),
          <double?>[0.65, 0.35]);
    });

    testWidgets('options are announced by their label; end poll is a button '
        'only when it has a handler', (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int ended = 0;
      await tester.pumpWidget(
        _host(
          DabblerCardPoll(
            question: 'Q',
            options: opts,
            votesLabel: '42 votes',
            onEndPoll: () => ended++,
          ),
        ),
      );
      expect(find.bySemanticsLabel('65%'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('end poll'));
      expect(ended, 1);
      await tester.pumpWidget(
        _host(
          const DabblerCardPoll(
            question: 'Q',
            options: opts,
            votesLabel: '42 votes',
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('end poll'))
            .flagsCollection
            .isButton,
        isFalse,
        reason: 'no handler: plain text, not a button',
      );
      h.dispose();
    });

    testWidgets('fractions are clamped and RTL/dark render', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        await tester.pumpWidget(
          _host(
            const DabblerCardPoll(
              question: 'س',
              options: <DabblerPollOption>[
                DabblerPollOption(fraction: 1.7, percentLabel: '100%'),
                DabblerPollOption(fraction: -1, percentLabel: '0%'),
              ],
              votesLabel: '٤٢',
            ),
            direction: TextDirection.rtl,
            brightness: b,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('DabblerCardRoom — CardRoom.jsx', () {
    test('avatar geometry is the source', () {
      expect(DabblerCardRoom.avatarSide, 36);
      expect(DabblerCardRoom.avatarStep, 28);
      expect(DabblerCardRoom.chipRing, 2);
      expect(DabblerCardRoom.padding, 16);
    });

    testWidgets('chip text is caption-2 11 at 700, name 11/500, topic 15/700',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardRoom(
            name: 'Design Studio',
            topic: 'Critique',
            avatarSeeds: <String>['a', 'b'],
            overflowLabel: '+42',
          ),
        ),
      );
      final Text chip = tester.widget<Text>(find.text('+42'));
      expect(chip.style!.fontSize, 11);
      expect(chip.style!.fontWeight, FontWeight.w700);
      final Text name = tester.widget<Text>(find.text('Design Studio'));
      expect(name.style!.fontSize, 11);
      expect(name.style!.fontWeight, FontWeight.w500);
      final Text topic = tester.widget<Text>(find.text('Critique'));
      expect(topic.style!.fontSize, 15);
      expect(topic.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('the stack steps 28 apart and the chip follows the last avatar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardRoom(
            name: 'n',
            topic: 't',
            avatarSeeds: <String>['a', 'b', 'c'],
            overflowLabel: '+9',
          ),
        ),
      );
      final List<double> xs = tester
          .widgetList<DabblerAvatar>(find.byType(DabblerAvatar))
          .map((DabblerAvatar a) => tester.getTopLeft(find.byWidget(a)).dx)
          .toList();
      expect(xs[1] - xs[0], 28);
      expect(xs[2] - xs[1], 28);
      expect(tester.getTopLeft(find.text('+9')).dx,
          greaterThan(xs[2] + 28 - 36));
    });

    testWidgets('no seeds and no label draws no stack; tap makes a button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(
        _host(DabblerCardRoom(name: 'n', topic: 't', onTap: () => taps++)),
      );
      expect(find.byType(DabblerAvatar), findsNothing);
      await tester.tap(find.bySemanticsLabel('n, t'));
      expect(taps, 1);
      h.dispose();
    });

    testWidgets('the stack mirrors to the start side in RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardRoom(
            name: 'n',
            topic: 't',
            avatarSeeds: <String>['a'],
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.getTopLeft(find.byType(DabblerAvatar)).dx, lessThan(180));
    });
  });

  group('DabblerCardActiveRoom — CardActiveRoom.jsx', () {
    testWidgets('footnote 13 at 600 and 700, pills caption-1 12', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardActiveRoom(
            name: 'Design Sync',
            topic: 'Weekly critique',
            speakerSeed: 'Mina',
          ),
        ),
      );
      expect(tester.widget<Text>(find.text('Design Sync')).style!.fontWeight,
          FontWeight.w600);
      expect(tester.widget<Text>(find.text('Weekly critique')).style!.fontWeight,
          FontWeight.w700);
      expect(tester.widget<Text>(find.text('Design Sync')).style!.fontSize, 13);
      expect(tester.widget<Text>(find.text('unmute')).style!.fontSize, 12);
      expect(tester.widget<Text>(find.text('join')).style!.fontWeight,
          FontWeight.w600);
    });

    testWidgets('pills fire only when a handler is given', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle h = tester.ensureSemantics();
      int mute = 0, join = 0;
      await tester.pumpWidget(
        _host(
          DabblerCardActiveRoom(
            name: 'n',
            topic: 't',
            speakerSeed: 's',
            onMute: () => mute++,
            onJoin: () => join++,
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('unmute'));
      await tester.tap(find.bySemanticsLabel('join'));
      expect((mute, join), (1, 1));
      await tester.pumpWidget(
        _host(
          const DabblerCardActiveRoom(name: 'n', topic: 't', speakerSeed: 's'),
        ),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('join'))
            .flagsCollection
            .isButton,
        isFalse,
      );
      h.dispose();
    });

    testWidgets('speaking caption is shown; custom labels are used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const DabblerCardActiveRoom(
            name: 'n',
            topic: 't',
            speakerSeed: 's',
            speakingLabel: 'يتحدث الآن',
            joinLabel: 'انضم',
            muteLabel: 'إلغاء الكتم',
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(find.text('يتحدث الآن'), findsOneWidget);
      expect(find.text('انضم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
